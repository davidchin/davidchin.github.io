$(document).ready ->
  html = $('body, html')
  homepage = $("#homepage")

  if homepage.get(0)
    fullpageOptions = 
      sectionSelector: '.page-section'
      slideSelector: '.page-section--slide'
      navigation: true
      autoScrolling: false
      anchors: [
        'about'
        'project-12wbt'
        'project-12wbt-daily'
        'project-vibe-hotels'
        'project-beautyheaven'
        'personal-projects'
        'contact'
      ]

    homepage.fullpage(fullpageOptions)
