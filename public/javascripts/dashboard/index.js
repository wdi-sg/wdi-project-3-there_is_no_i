var reservationsButton = document.getElementById('dashboard-reservations-button')
var queueButton = document.getElementById('dashboard-queue-button')
var notifiedButton = document.getElementById('dashboard-notified-button')
var diningButton = document.getElementById('dashboard-dining-button')

var allButtons = [reservationsButton, queueButton, notifiedButton, diningButton]

var reservationsSection = document.getElementById('dashboard-reservations-section')
var queueSection = document.getElementById('dashboard-queue-section')
var notifiedSection = document.getElementById('dashboard-notified-section')
var diningSection = document.getElementById('dashboard-dining-section')

var allSections = [reservationsSection, queueSection, notifiedSection, diningSection]

allButtons.forEach(function (button, index) {
  button.addEventListener('click', function () {
    allSections.forEach(function (section) {
      section.style.display = 'none'
    })
    allButtons.forEach(function (button) {
      button.className = 'waves-effect waves-light btn light-blue lighten-3'
    })
    allSections[index].style.display = 'block'
    button.className = 'waves-effect waves-light btn pink accent-1'
  })
})

allSections.forEach((section) => {
  section.style.display = 'none'
})
diningSection.style.display = 'block'
diningButton.className = 'waves-effect waves-light btn pink accent-1'

var x = 'notice-' +  gon.restaurant_id.toString()
console.log(x);
var notice = document.getElementById(x)
console.log(notice);
notice.addEventListener('click', function () {
  this.style.display = 'none'
  window.location.reload()
})
