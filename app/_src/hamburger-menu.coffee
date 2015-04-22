class HamburgerMenu
  constructor: (button, options) ->
    # Initialize
    defaultOptions =
      activeClass: 'active'

    @options = $.extend({}, defaultOptions, options)
    @button = $(button)

    # Observe
    @button.click =>
      @button.parent().toggleClass(@options.activeClass)

# Export
window.HamburgerMenu = HamburgerMenu
