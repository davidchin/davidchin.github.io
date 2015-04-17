---
layout: post
title: How to round a number to certain decimal places
date: 2014-03-04 00:00:00
categories: javascript
summary: Here is a technique that I use to round a number to certain decimal places for display. Let’s say, if you want to round the result of 23/7 to 2 decimal places instead of rounding it to a whole number.
---

Here is a technique that I use to round a number to certain decimal places for display. Let’s say, if you want to round the result of 23/7 to 2 decimal places instead of rounding it to a whole number.

{% highlight javascript %}
var Decimal = {
  convert: function(number, decimal_places) {
    if (typeof number === 'number' && typeof decimal_places === 'number') {
      var denominator    = Math.pow(10, decimal_places),
          rounded_number = Math.round(number * denominator) / denominator;

      return rounded_number;
    } else {
      return number;
    }
  }
};
{% endhighlight %}

You can see a [live demo](http://jsfiddle.net/dyfchin/q64eB/) here.
