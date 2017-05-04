class MessagesController < ApplicationController
  before_action :get_messages, only: [:index, :create]

  def index
  end

  def create
    message = Message.new(message_params)
    if message.save
      # ActionCable.server.broadcast 'room_channel',
      #   message: render_message(message)
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
      params.require(:message).permit(:content, :thing)
    end

    def render_message(message)
      render(partial: 'message', locals: { message: message, thing: @restaurant.id })
    end

    def set_restaurant_id
      @restaurant = Restaurant.find(params: [:restaurant_id])
    end

end
