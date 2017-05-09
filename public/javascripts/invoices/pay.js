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

var stripeButton = document.querySelector('.stripe-button-el')
stripeButton.addEventListener('click', (event) => {
  handler.open({
    amount: parseFloat(document.getElementById('total_price').value) * 100
  })
})
