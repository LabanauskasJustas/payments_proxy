json.status 'ok'
json.code 200
json.errors @errors
json.messages @messages
json.result do
  json.orders @orders do |order|
    json.order_id order.order_id
    json.payment_id order.payment_id
    json.payment_url order.TransactionHash.dig(:payment_url) unless order.status == 'canceled'
    json.created_at order.created_at
    json.deleted_at order.deleted_at
    json.status order.status
  end
end
