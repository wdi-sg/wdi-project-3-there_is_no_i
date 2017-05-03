class MessagesController < ApplicationController
  before_action :get_messages, only: [:index, :create]

  def index
  end

  def create
    message = Message.new(message_params)
    if message.save
      ActionCable.server.broadcast 'room_channel',
                                   content:  message.content
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
      params.require(:message).permit(:content)
    end

end
