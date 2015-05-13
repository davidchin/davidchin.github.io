class HamburgerMenu
  constructor: (button, options) ->
    # Initialize
    defaultOptions =
      activeClass: 'active'

    @options = $.extend({}, defaultOptions, options)
    @button = $(button)

    # Observe
    @button.click => @toggle()

  toggle: ->
    if @expanded then @collapse() else @expand()

  expand: ->
    @expanded = true

    @button
      .attr('aria-expanded', true)
      .attr('aria-label', 'Close menu')
      .parent()?.addClass(@options.activeClass)

  collapse: ->
    @expanded = false

    @button
      .attr('aria-expanded', false)
      .attr('aria-label', 'Open menu')
      .parent()?.removeClass(@options.activeClass)

# Export
window.HamburgerMenu = HamburgerMenu
