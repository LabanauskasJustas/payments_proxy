class Services::OrderApi
  attr_reader :request_body, :current_user

  def initialize(request_body: nil, order_user: current_user)
    @coingate_config ||= coingate_config
    @request_body = request_body
    @current_user = order_user
    @errors = []
  end

  def save_order
    @order = @current_user.orders.new(
      order_id: @request_body.fetch("order_id") || "Order-#{SecureRandom.hex(10)}",
      amount: @request_body.fetch("price_amount"),
      status: "new",
      TransactionHash: {
        order_id: @request_body.fetch("order_id"),
        price_amount: @request_body.fetch("price_amount"),
        price_currency:   @request_body.fetch("price_currency"),
        receive_currency: @request_body.fetch("receive_currency") || 'EUR',
        callback_url: "https://payment-test.requestcatcher.com/payments/callback?token=#{@request_body.fetch("token")}}",
        cancel_url: 'https://payment-test.requestcatcher.com/cart',
        success_url: 'https://payment-test.requestcatcher.com/account/orders',
        description: @request_body.fetch("description") || "Blank",
      }
    )
    order_payment ||= CoinGate::Merchant::Order.create!(@order.TransactionHash)
    unless order_payment
      @order.update_attribute(status: "failed")
    else
      @order.update!( amount: order_payment.price_amount, status: order_payment.status, payment_id: order_payment.id)
    end
    @order
  end

  def cancel_order
    order_status = CoinGate::Merchant::Order.find!(@order.payment_id).status
    @order = @current_user.orders.find_by_payment_id(payment_id)
    if order_status == "cancelled"
      @order.destroy
    end
  end

  def find_order(payment_id)
    @order = @current_user.orders.find_by_payment_id(payment_id)
    binding.break
    return @order if CoinGate::Merchant::Order.find(payment_id)
  end

  private

  def coingate_config
    CoinGate.config do |config|
      config.auth_token  = ENV['COINGATE_SECRET'] || Rails.application.credentials.coingate.fetch(:api_key) 
      config.environment = Rails.env.production? ? 'live' : 'sandbox'
    end.freeze
  end

  def endpoint
    Rails.env.production? ? 'https://api.coingate.com/v2' : 'https://api-sandbox.coingate.com/v2'
  end
end