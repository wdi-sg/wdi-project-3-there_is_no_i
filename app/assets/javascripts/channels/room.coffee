App.room = App.cable.subscriptions.create "RoomChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    unless data.message.blank?
      $('#messages-table').append data.message if data.thing is @restaurant.id
      # scroll_bottom()

  $(document).on 'turbolinks:load', ->
    submit_message()
    # scroll_bottom()

  submit_message = () ->
    $('#message_content').on 'keydown', (event) ->
      if event.keyCode is 13
        App.messages.send({message: $('#message_content').val, thing: @restaurant.id})
        event.target.value = ""
        event.preventDefault()

    $('input').on 'click', (event) ->
      App.messages.send({message: $('#message_content').val, thing: @restaurant.id})
      $('#message_content').val('')
      event.preventDefault()

  # scroll_bottom = () ->
  # $('#messages').scrollTop($('#messages')[0].scrollHeight)
