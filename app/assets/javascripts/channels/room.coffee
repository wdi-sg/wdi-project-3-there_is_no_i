App.room = App.cable.subscriptions.create "RoomChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # console.log (JSON.stringify(data.user))
    do_it(data)
    # unless data.message.blank?
    #   $('#messages-table').append data.message if data.thing is @restaurant.id
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
  do_it = (data) ->
    x = 'orders-for-' + data.restaurant.toString()
    y = $('#' + x)
    z = $('<tr>')
    aa = $('<td>')
    # aa.text = data.order.id
    # z.append(aa)
    z.html('<tr><td>' + data.invoice + '</td><td>' + data.received + '</td><td> </td><td>' + data.item + '</td><td> </td><td>' + data.is_take_away + '</td><td></td></tr>')
    y.append(z)
