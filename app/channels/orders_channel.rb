class OrdersChannel < ApplicationCable::Channel
  def subscribed
    stream_from "orders"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(payload)
    Order.create(invoice: payload["invoice_id"], content: payload["order"])
  end
end
