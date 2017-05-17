$(document).on('ready', function () {
  var hide = true
  var orders = []
  // update the Stripe Checkout fields and submit
  var handler = StripeCheckout.configure({
    key: 'pk_test_9yHOz6zrh9nnjNOGLjV2Pvcq',
    locale: 'auto',
    currency: 'SGD',
    name: gon.restaurant,
    description: gon.description,
    token: function (token) {
      $('input#stripeToken').val(token.id)
      $('form').submit()
    }
  })

// show and hide takeaway
  document.getElementById('takeaway-show-hide').addEventListener('click', () => {
    if (hide) {
      document.getElementById('takeaway-show-hide').textContent = 'Cancel'
      document.querySelectorAll('.add-to-order').forEach((button) => {
        button.style.display = 'block'
      })
      hide = false
    } else {
      if (orders.length > 0) {
        if (window.confirm('You have pending orders. Are you sure you want to Cancel?')) {
          document.getElementById('takeaway-show-hide').textContent = 'Order'
          orders = []
          var list = document.querySelector('.ordered-items-list')
          while (list.firstChild) {
            list.removeChild(list.firstChild)
          }
          document.querySelectorAll('.add-to-order').forEach((button) => {
            button.style.display = 'none'
          })
          document.querySelector('.ordered-items').style.display = 'none'
          hide = true
        }
      } else {
        document.getElementById('takeaway-show-hide').textContent = 'Order'
        document.querySelectorAll('.add-to-order').forEach((button) => {
          button.style.display = 'none'
        })
        document.querySelector('.ordered-items').style.display = 'none'
        hide = true
      }
    }
  })

// add items from menu
  document.querySelector('.all-menu-items').addEventListener('click', (event) => {
    var target = event.target
    if (target.className === 'add-to-order') {
      addToOrders(target)
      redrawList()
    }
  })

// add and remove items from ordered list
  document.querySelector('.ordered-items-list').addEventListener('click', (event) => {
    var target = event.target
    if (target.className === 'remove-one') {
      var removed = false
      var removeIndex = 0
      for (var i = 0; i < orders.length; i++) {
        if (!removed) {
          if (orders[i]['id'] === parseInt(target.value)) {
            removeIndex = i
            removed = true
            break
          }
        }
      }
      orders.splice(removeIndex, 1)
      redrawList()
    }
    if (target.className === 'add-one') {
      var chosen = false
      var addIndex = 0
      orders.forEach((obj, ind) => {
        if (!chosen) {
          if (obj['id'] === parseInt(target.value)) {
            addIndex = ind
            chosen = true
          }
        }
      })
      var addOrder = orders[addIndex]
      orders.push(addOrder)
      redrawList()
    }
  })

// redraw ordered-items-list
  function redrawList () {
    var list = document.querySelector('.ordered-items-list')
    while (list.firstChild) {
      list.removeChild(list.firstChild)
    }
    count(orders).sort((a, b) => { return a['id'] - b['id'] }).forEach((item) => {
      addToList('<td><button class="remove-one" value=' + item['id'] + ' type="button">-</button></td><td>' + item['count'] + '</td><td><button class="add-one" value=' + item['id'] + ' type="button">+</button></td><td>' + item['name'] + '</td><td>$' + (item['count'] * item['price']).toFixed(2).toString() + '</td>')
    })
    if (orders.length > 0) {
      document.querySelector('.ordered-items').style.display = 'block'
      addToList('<td colspan="4">Total</td><td>$' + totalPrice().toFixed(2) + '</td>')
      var stripeButton = document.querySelector('.stripe-button-el')
      var createOrdersButton = document.getElementById('create-orders-button')
      if (stripeButton) {
        stripeButton.addEventListener('click', (event) => {
          updateOrders()
        })
      } else {
        createOrdersButton.addEventListener('click', (event) => {
          updateOrders()
        })
      }
    } else {
      document.querySelector('.ordered-items').style.display = 'none'
    }
  }

// adds a <li> to the orders
  function addToList (html) {
    var newOrder = document.createElement('tr')
    newOrder.innerHTML = html
    document.querySelector('.ordered-items-list').appendChild(newOrder)
  }

// split the item.id/item.name/item.price and add to orders
  function addToOrders (target) {
    var newObj = {}
    var targetSplit = target.value.split('/')
    newObj['id'] = parseInt(targetSplit[0])
    newObj['name'] = targetSplit[1]
    newObj['price'] = parseFloat(targetSplit[2])
    orders.push(newObj)
  }

// take the orders and return a compiled array of items ordered {item, count, price}
  function count (orders) {
    var newArr = []
    var nameArr = []
    orders.forEach((obj) => {
      if (!nameArr.includes(obj['name'])) {
        nameArr.push(obj['name'])
      }
    })
    nameArr.forEach((name) => {
      newArr.push({id: 0, name: name, price: 0.0, count: 0})
    })
    orders.forEach((obj) => {
      newArr.forEach((item) => {
        if (item['name'] === obj['name']) {
          item['id'] = obj['id']
          item['count'] += 1
          item['price'] = obj['price']
        }
      })
    })
    return newArr
  }

// returns the total price of the orders
  function totalPrice () {
    return orders.reduce((a, b) => { return a + b['price'] }, 0.0)
  }

// convert the orders array into a string of menu-item ids and submits that string
  function updateOrders () {
    var realTP = totalPrice()
    console.log(orders)
    var allOrders = orders.slice()
    var first = allOrders.shift().id.toString()
    var ordersStr = allOrders.reduce((one, two) => { return one + '/' + two.id.toString() }, first)
    document.getElementById('orders').value = ordersStr
    document.getElementById('total_price').value = realTP.toString()
    handler.open({
      amount: parseFloat(document.getElementById('total_price').value) * 100
    })
  }
})
