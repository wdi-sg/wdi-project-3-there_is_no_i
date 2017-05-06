App.orders = App.cable.subscriptions.create('OrdersChannel', {
  received: function (data) {
    return $("[data-invoice='" + data.invoice_id + "']").append(data.order)
  }
})

$(document).on('turbolinks:load', function() {
  submitNewMessage()
})

function submitNewMessage(){  
  $('textarea#message_content').keydown(function(event) {
    if (event.keyCode === 13) {
        var msg = event.target.value
        var invoiceId = $("[data-invoice]").data().invoice
        App.messages.send({message: msg, invoice_id: invoiceId})
        $('[data-textarea="message"]').val(" ")
        return false;
     }
  })
}
