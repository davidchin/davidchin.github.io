$(document).ready ->
  html = $('body, html')
  homepage = $("#homepage")

  if homepage.get(0)
    fullpageOptions = 
      sectionSelector: '.page-section'
      slideSelector: '.page-section--slide'
      navigation: true
      autoScrolling: false
      fitToSection: false
      recordHistory: false

    homepage.fullpage(fullpageOptions)
