LinkHelper =
  convert: (element) ->
    $element = $(element)
    $newElement = $('<a>')
    attributes = $element.prop('attributes')
    
    # Copy attributes
    for attribute in attributes
      matches = /^data\-anchor-(\w+)/.exec(attribute.name)
    
      if matches && matches[1]
        $newElement.attr(matches[1], attribute.value)
      else
        $newElement.attr(attribute.name, attribute.value)
    
    # Set value
    $newElement
      .html("#{ $element.html() } #{ $newElement.attr('title') }")
      .data($element.data())

    # Replace element
    $element.replaceWith($newElement)

# Export
window.LinkHelper = LinkHelper
