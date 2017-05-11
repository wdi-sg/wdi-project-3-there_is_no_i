class TwilioController < ApplicationController
  include SendTwilio
  include Format
  skip_before_action :verify_authenticity_token

  def receive
    # we can keep message counts in session to check if it's the first message to maintain a conversation
    # session[:counter] ||= 0
    # sms_count = session[:counter]
    # if sms_count == 0
    #   # do something
    # else
    #   # do something else
    # end
    # session[:counter] += 1

    from = params["From"] # gets the sender's number '+6587427184'
    body = params["Body"].downcase # gets the sender's message
    begin
      @user = User.where(phone: from[3..10]) # TAKE OUT +65
    rescue ActiveRecord::RecordNotFound => e
      @user = []
    end
    if @user.count > 0
      if Reservation.where(status: ['queuing', 'awaiting']).where(user_id: @user[0].id).count > 0
        x = Reservation.where(status: ['queuing', 'awaiting']).where(user_id: @user[0].id)[0]
        @message = "Hey #{@user.name}! Your estimated wait time is #{estimatedReservationWaitTime(x, 5)} minutes."
      else
        @message = "Hmm... You don't seem to be in a queue! Find a restaurant at https://locavorusrex.herokuapp.com"
      end
    else
        @message = "Hmm... Thanks for the message, but you're a complete stranger to us! Find out more at https://locavorusrex.herokuapp.com"
    end
    send_message(from, @message)
  end
end
