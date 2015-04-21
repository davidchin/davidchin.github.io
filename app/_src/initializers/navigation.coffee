$ ->
  button = $('[data-hamburger-menu]')
  
  button.click ->
    button.parent().toggleClass('global-navigation--active')
