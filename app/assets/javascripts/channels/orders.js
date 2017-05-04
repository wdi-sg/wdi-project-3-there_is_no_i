App.orders = App.cable.subscriptions.create('OrdersChannel', {
  received: function (data) {
    return $("[data-transaction='" + data.transaction_id + "']").append(data.order)
  }
})

$(document).on('turbolinks:load', function() {
  submitNewMessage()
})

function submitNewMessage(){  
  $('textarea#message_content').keydown(function(event) {
    if (event.keyCode === 13) {
        var msg = event.target.value
        var transactionId = $("[data-transaction]").data().transaction
        App.messages.send({message: msg, transaction_id: transactionId})
        $('[data-textarea="message"]').val(" ")
        return false;
     }
  })
}
