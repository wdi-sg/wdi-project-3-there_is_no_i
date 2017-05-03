class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel"
    stream_from "room_channel_#{restaurant.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
