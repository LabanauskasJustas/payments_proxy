require 'uri'
require 'net/http'
require 'openssl'

class CoingateApi
  class Client

    def initialize
      @client ||= api
    end

    # def api
    #   url = URI("https://api.coingate.com/api/v2/orders")

    #   http = Net::HTTP.new(url.host, url.port)
    #   http.use_ssl = true

    #   request = Net::HTTP::Post.new(url)
    #   request["accept"] = 'application/json'
    #   request["content-type"] = 'application/x-www-form-urlencoded'
    #   request.body = order_body(@order)
    #   request["Authorization"] = "Bearer #{credentials.fetch(:api_key)}}"
    #   response = http.request(request)
    #   puts response.read_body

    #   response = RestClient.post()
    # end

    def create_order(order_params = {})
      begin
      response = RestClient.post("#{credentials.fetch(:Endpoint)}/orders", order_params,
        credentials.fetch(:Authorization).merge('Content-Type' => 'application/x-www-form-urlencoded'))
      order = Order.new(TransactionHash: {
        order_id: order_params.fetch(:order_id),
        price_amount: order_params.fetch(:price_amount),
        price_currency: order_params.fetch(:price_currency),
        receive_currency: order_params.fetch(:receive_currency),
        title: order_params.fetch(:title),
        description:  order_params.fetch(:description),
        callback_url: order_params.fetch(:callback_url),
        success_url:  order_params.fetch(:success_url),
        cancel_url: order_params.fetch(:cancel_url),
        success_auto_return:  order_params.fetch(:success_auto_return)
      })
      rescue => e
        response(e.http_code, e.response)
      end
    end

    def response(http_code, response_body)
      response_body = JSON.parse(response_body, symbolize_names: true) rescue response_body
  
      OpenStruct.new(success?: http_code == 200, http_code: http_code, reason: response_body.try(:fetch, :reason, nil), response: response_body)
    end

    def cancel_order

    end

    def order_body(order)
      "order_id=#{order_params.fetch(:order_id)}&
      price_amount=#{price_amount}&
      price_currency=#{price_currency}&
      receive_currency=#{receive_currency}&
      title=#{title}&description=#{description}&
      callback_url=#{callback_url}&cancel_url=#{cancel_url}&
      success_url=#{success_url}&token=#{token}&
      purchaser_email=#{purchaser_email}"
    end

    private

    def transaction_params
      @order.TransactionHash || {}
    end

    def credentials
      {
        Authorization:  "Bearer #{Rails.application.credentials.coingate.fetch(:api_key)}",
        Endpoint: Rails.env.production? ? "https://api.coingate.com/api/v2" : "https://api-sandbox.coingate.com/v2"
      }
    end
  end
end