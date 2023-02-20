json.status 'ok'
json.code 200
json.errors @errors
json.messages @messages
json.result do
  json.order_id @order.order_id
  json.canceled_at @order.canceled_at
  json.status @order.status
end
