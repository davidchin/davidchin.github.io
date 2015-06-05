$ ->
  $('[data-anchor-href]').each ->
    LinkHelper.convert(this)
