App.room = App.cable.subscriptions.create "RoomChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    appendOrders(data)

  appendOrders = (data) ->
    tableToAttachTo = $('#' + 'orders-for-' + data.restaurant.toString())
    tr = $('<tr>')
    tr.html('<tr><td>' + data.invoice + '</td><td>' + data.received + '</td><td> </td><td>' + data.item + '</td><td>-</td><td>' + data.is_take_away + '</td><td>-</td></tr>')
    tableToAttachTo.append(tr)
