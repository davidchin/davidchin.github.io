$ ->
  html = $('body, html')
  homepage = $("#homepage")

  return unless homepage.get(0)

  fullpageOptions = 
    sectionSelector: '.page-section'
    slideSelector: '.page-section--slide'
    navigation: true
    fitToSection: false
    recordHistory: false
    autoScrolling: false

  homepage.fullpage(fullpageOptions)

  # Disable autoscrolling for some screen sizes
  enquire.register 'screen and (min-height: 480px)',
    deferSetup : true

    match: ->
      $.fn.fullpage.setAutoScrolling(true);

    unmatch: ->
      $.fn.fullpage.setAutoScrolling(false);

    setup: ->
      $.fn.fullpage.setAutoScrolling(true);
