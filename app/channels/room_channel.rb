class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    ActionCable.server.broadcast('room_channel', {invoice: data.invoice, received: data.received, item: data.item, is_take_away: data.is_take_away, restaurant: data.restaurant_invoices_path})
  end
end
