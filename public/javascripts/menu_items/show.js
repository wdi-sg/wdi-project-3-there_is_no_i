var hide = true
var orders = []

// show and hide takeaway
document.getElementById('takeaway-show-hide').addEventListener('click', () => {
  if (hide) {
    document.getElementById('takeaway-show-hide').textContent = 'Cancel Takeaway'
    document.querySelectorAll('.add-to-order').forEach((button) => {
      button.style.display = 'block'
    })
    hide = false
  } else {
    if (orders.length > 0) {
      if (window.confirm('You have pending orders. Are you sure you want to cancel takeaway?')) {
        document.getElementById('takeaway-show-hide').textContent = 'Order Takeaway'
        orders = []
        $('.ordered-items-list').empty()
        document.querySelectorAll('.add-to-order').forEach((button) => {
          button.style.display = 'none'
        })
        hide = true
      }
    } else {
      document.getElementById('takeaway-show-hide').textContent = 'Order Takeaway'
      document.querySelectorAll('.add-to-order').forEach((button) => {
        button.style.display = 'none'
      })
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
    orders.forEach((obj, ind) => {
      if (!removed) {
        if (obj['id'] === parseInt(target.value)) {
          removeIndex = ind
          removed = true
        }
      }
    })
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
  $('.ordered-items-list').empty()
  count(orders).sort((a, b) => { return a['id'] - b['id'] }).forEach((item) => {
    addToList('<button class="remove-one" value=' + item['id'] + '>-</button> ' + item['count'] + ' <button class="add-one" value=' + item['id'] + '>+</button>' + ' x ' + item['name'] + ' => ' + (item['count'] * item['price']).toFixed(2).toString())
  })
  addToList('Total: ' + totalPrice().toFixed(2))
}

// adds a <li> to the orders
function addToList (html) {
  var newOrder = document.createElement('li')
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
