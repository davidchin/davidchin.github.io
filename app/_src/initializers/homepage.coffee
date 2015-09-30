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
