# frozen_string_literal: true

module Services
  class OrderApi
    attr_reader :request_body, :current_user

    def initialize(request_body: nil, order_user: current_user, order: nil)
      @coingate_config = coingate_config
      @request_body = request_body
      @current_user = order_user
      @order = order
      @errors = []
    end

    def save_order
      @order = @current_user.orders.new(
        order_id: @request_body.fetch('order_id') || "Order-#{SecureRandom.hex(10)}",
        amount: @request_body.fetch('price_amount'),
        status: 'new',
        TransactionHash: {
          order_id: @request_body.fetch('order_id'),
          price_amount: @request_body.fetch('price_amount'),
          price_currency: @request_body.fetch('price_currency'),
          receive_currency: @request_body.fetch('receive_currency') || 'EUR',
          callback_url: "#{endpoint}orders/#{@request_body.fetch('order_id')}",
          cancel_url: "#{endpoint}orders/#{@request_body.fetch('order_id')}",
          success_url: "#{endpoint}orders/#{@request_body.fetch('order_id')}",
          description: @request_body.fetch('description') || 'Blank'
        }
      )
      order_payment ||= CoinGate::Merchant::Order.create!(@order.TransactionHash)
      if order_payment
        @order.TransactionHash.update(payment_url: order_payment.payment_url)
        @order.update!(
          amount: order_payment.price_amount,
          status: order_payment.status,
          payment_id: order_payment.id,
        )
      else
        @order.errors.add(:payment, 'Failed')
      end
      @order
    end

    def cancel_order
      @invoice_order = coingate_order(@order.payment_id)
      @order.cancel unless @invoice_order.status == 'cancelled'
    end

    def find_order(payment_id)
      @order = @current_user.orders.find_by_payment_id(payment_id)
      @invoice_order = coingate_order(@order.payment_id)
      unless @invoice_order.status == @order.status
        @order.update(status: @invoice_order.status)
      end
      @order
    end

    private

    def coingate_config
      CoinGate.config do |config|
        config.auth_token  = ENV['COINGATE_SECRET'] || Rails.application.credentials.coingate.fetch(:api_key)
        config.environment = Rails.env.production? ? 'live' : 'sandbox'
      end.freeze
    end

    def coingate_order(payment_id)
      CoinGate::Merchant::Order.find!(payment_id)
    end

    def endpoint
      'https://payment-proxy.herokuapp.com/'
    end
  end
end
