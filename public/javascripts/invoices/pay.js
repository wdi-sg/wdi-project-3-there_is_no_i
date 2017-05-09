$(document).on('turbolinks:load', function() {
  var handler = StripeCheckout.configure({
  key: 'pk_test_9yHOz6zrh9nnjNOGLjV2Pvcq',
  locale: 'auto',
  currency: 'SGD',
  name: gon.restaurant.name,
  description: 'Order',
  token: function (token) {
    $('input#stripeToken').val(token.id)
    $('form').submit()
  }
})

var stripeButtons = document.querySelectorAll('.stripe-button-el')
stripeButtons.forEach((button) => {
  button.addEventListener('click', (event) => {
    handler.open({
      amount: parseFloat(event.target.parentNode.parentNode.childNodes[4].value) * 100
    })
  })
})
})
