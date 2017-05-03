class MessagesController < ApplicationController
  before_action :get_messages, only: [:index, :create]

  def index
    @message = Message.all
    @new_message = Message.new
  end

  def create
    message = Message.new(message_params)
    if message.save
      ActionCable.server.broadcast 'room_channel',
        message: render_message(message)
      ActionCable.server.broadcast "room_channel_#{set_restaurant_id}",
        message: "#{set_restaurant_id}"
    else
      render 'index'
    end
  end

  private

    def get_messages
      @messages = Message.all
      @message  = Message.new
    end

    def message_params
      params.require(:message).permit(:content, :id)
    end

    def render_message(message)
      render(partial: 'message', locals: { message: message })
    end

    def set_restaurant_id
      Restaurant.first.id
    end

end
