json.status 'ok'
json.code 200
json.errors @errors
json.messages @messages
json.result do
  json.order_id @order.order_id
  json.payment_id @order.payment_id
  json.payment_url @order.TransactionHash.dig(:payment_url)
  json.created_at @order.created_at.strftime('%Y-%m-%d %H:%M')
  json.status @order.status
end
