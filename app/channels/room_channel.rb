class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(payload)
    message = Message.create(thing: payload["thing"], content: payload["message"])
    ActionCable.server.broadcast('messages', {message: message.content, thing: message.thing})
  end
end
