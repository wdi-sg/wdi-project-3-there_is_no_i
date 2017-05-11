class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    if data.walkin != nil
      ActionCable.server.broadcast('room_channel', {walkin: data.id, queue_number: data.queue_number, name: data.name, phone: data.phone, party_size: data.party_size, start_time: data.start_time, table_name: data.table_name, restaurant: data.restaurant_id})
    elsif data.reservation != nil
      ActionCable.server.broadcast('room_channel', {reservation: data.id, name: data.name, phone: data.phone, party_size: data.party_size, start_time: data.start_time, table_name: data.table_name, restaurant: data.restaurant_id})
    else
      ActionCable.server.broadcast('room_channel', {invoice: data.invoice, received: data.received, item: data.item, is_take_away: data.is_take_away, restaurant: data.restaurant_invoices_path, request: data.request, table: @invoice.table_id})
    end
  end
end
