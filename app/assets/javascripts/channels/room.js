App.room = App.cable.subscriptions.create('RoomChannel', {
  connected: function () {
    // Called when the subscription is ready for use on the server
  },
  disconnected: function () {
    // Called when the subscription has been terminated by the server
  },
  received: function (data) {
    if (data.walkin) {
      appendQueue(data)
    }
    else if (data.reservation) {
      appendReservation(data)
    }
    else {
      appendOrders(data)
    }
  }
})

function appendOrders (data) {
  var tableToAttachTo = $('#' + 'orders-for-' + data.restaurant.toString())
  var tr = $('<tr>')
  tr.html('<tr><td>' + data.invoice + '</td><td>' + data.received + '</td><td> </td><td>' + data.item + '</td><td>-</td><td>' + data.is_take_away + '</td><td>-</td></tr>')
  tableToAttachTo.append(tr)
}

function appendQueue (data) {
  var queueTable = $('#queue_' + data.restaurant)

  var newQueue = document.createElement('tr')
  newQueue.innerHTML = '<tr><td><i class="material-icons left">edit</i>Edit</td>' + '<td>#' + data.queue_number + '</td>'  + '<td>' + data.name + '<br>' + data.phone + '</td>' + '<td><i class="material-icons left">people</i>' + data.party_size + 'pax</td>' + '<td><i class="material-icons left">access_time</i>' + data.start_time + '</td>' + '<td>No Order</td>'+ '<td>' + data.table_name + '</td><td></td></tr>'

  queueTable.append(newQueue)
}

function appendReservation (data) {
  var reservationTable = $('#reservation_' + data.restaurant)

  var newReservation = document.createElement('tr')
  newReservation.innerHTML = '<tr><td><i class="material-icons left">edit</i>Edit</td>' + '<td>#' + data.reservation + '</td>'  + '<td>' + data.name + '<br>' + data.phone + '</td>' + '<td><i class="material-icons left">people</i>' + data.party_size + 'pax</td>' + '<td><i class="material-icons left">access_time</i>' + data.start_time + '</td>' + '<td>No Order</td>'+ '<td>' + data.table_name + '</td><td></td></tr>'

  reservationTable.append(newReservation)
}
