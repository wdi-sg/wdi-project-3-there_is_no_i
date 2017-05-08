class MainController < ApplicationController
  include SendTwilio
  def index
    @is_main = true
    send_message('+6587427184', 'TEST TROUBLESHOOT')
  end
end
