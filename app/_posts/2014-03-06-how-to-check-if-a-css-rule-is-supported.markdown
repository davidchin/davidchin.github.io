---
layout: post
title: How to check if a CSS rule is supported
date: 2014-03-06 00:00:00
tags: javascript
description: Sometimes, you want to check if a CSS rule is supported by your user’s current browser using Javascript. For example, you might want to check if the browser supports CSS transition, if not, use jQuery animation as a fallback.
---

Sometimes, you want to check if a CSS rule is supported by your user’s current browser using Javascript. For example, you might want to check if the browser supports CSS transition, if not, use jQuery animation as a fallback. Here is a way to do it:

{% highlight javascript %}
var CSS = (function() {
  // Create a dummy element for testing
  // Only create it once within a closure
  var div      = document.createElement('div'),
      prefixes = ['Moz', 'Webkit', 'O', 'ms'];
  
  return {
    camelize: function(prop) {
      // Javascript refer to CSS properties in their camelized form
      return prop.replace(/[-_\s]+(.)?/g, function(match, captured) {
        if (captured) {
          return captured.toUpperCase();
        }
      });
    },

    check: function(prop) {
      if (prop in div.style) {
        // Check if property is supported without a vendor prefix
        return prop;
      } else {
        // Check if property is supported with a vendor prefix
        for (var i = 0, length = prefixes.length; i < length; i++) {
          var vendorProp = this.camelize(prefixes[i] + '-' + prop);
          
          if (vendorProp in div.style) {
            return vendorProp;
          }
        }
      }
    }
  };
})();
{% endhighlight %}

You can see a [live demo](http://jsfiddle.net/dyfchin/5hdPb/3/) here.
