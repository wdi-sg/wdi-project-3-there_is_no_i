class OrdersChannel < ApplicationCable::Channel
  def subscribed
    stream_from "orders"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(payload)
    Order.create(transaction: payload["transaction_id"], content: payload["order"])
  end
end
