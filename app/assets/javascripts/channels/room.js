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
  var tr = document.createElement('tr')
  tr.innerHTML = '<td><a href="/restaurants/' + data.restaurant + '/invoices/' + data.invoice + '">' + data.invoice + '</a></td><td>' + data.received + '</td><td>' + data.item + '</td><td>' + data.table + '</td><td>' + data.request + '</td><td>' + data.is_take_away + '</td><td><input type="button" value="Reload" onClick="window.location.reload()"></td>'

  var notice = $('#notice-' + data.restaurant)

  tableToAttachTo.append(tr)
  if (data.is_take_away.length > 0) {
    notice.text('New Takeaway Order Received')
    notice.css('display', 'block')
  }
}

function appendQueue (data) {
  var queueTable = $('#queue_' + data.restaurant)

  var newQueue = document.createElement('tr')
  newQueue.innerHTML = '<tr><td><i class="material-icons left">edit</i><br><a href="/restaurants/'+ data.restaurant +'/diners/'+ data.walkin + '/edit">Edit</a></td>' + '<td>' + data.queue_number + '</td>'  + '<td>' + data.name + '<br>' + data.phone + '</td>' + '<td><i class="material-icons left">people</i>' + data.party_size + 'pax</td>' + '<td><i class="material-icons left">access_time</i>' + data.start_time + '</td>' + '<td>No Order</td>'+ '<td>' + data.table_name + '</td><td><a data-confirm="This will remove the customer from the queue. This action is permanent. OK to procced?" rel="nofollow" data-method="put" href="/restaurants/'+ data.restaurant +'/cancelled/'+ data.walkin + '">Cancel</a></td></tr>'

  var notice = $('#notice-' + data.restaurant)
  queueTable.append(newQueue)
  notice.text( data.name + ' has joined the Queue')
  notice.css('display', 'block')
}

function appendReservation (data) {
  var reservationTable = $('#reservation_' + data.restaurant)

  var newReservation = document.createElement('tr')
  newReservation.innerHTML = '<tr><td><i class="material-icons left">edit</i><br><a href="/restaurants/'+ data.restaurant +'/diners/'+ data.reservation + '/edit">Edit</a></td>' + '<td>' + data.reservation + '</td>'  + '<td>' + data.name + '<br>' + data.phone + '</td>' + '<td><i class="material-icons left">people</i>' + data.party_size + 'pax</td>' + '<td><i class="material-icons left">access_time</i>' + data.start_time + '</td>' + '<td>No Order</td>'+ '<td>' + data.table_name + '</td><td><a rel="nofollow" data-method="put" href="/restaurants/'+ data.restaurant +'/seated/'+ data.reservation + '">Seated</a></td></tr>'

  var notice = $('#notice-' + data.restaurant)

  reservationTable.append(newReservation)
  notice.text(data.name + ' has made a reservation')
  notice.css('display', 'block')
}
