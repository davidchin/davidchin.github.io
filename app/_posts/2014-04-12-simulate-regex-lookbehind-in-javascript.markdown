---
layout: post
title: Simulate RegEx lookbehind in JavaScript
date: 2014-04-12 00:00:00
tags: javascript regexp
description: RegEx lookbehind is a very useful tool as it allows you to check whether a string appears before a pattern you try to match. Unfortunately, it is not available in JavaScript - therefore, in order to achieve a similar effect, we have to find another way to fake it.
---

RegEx lookbehind is a very useful tool as it allows you to check whether a string appears before a pattern you try to match. Unfortunately, it is not available in JavaScript - therefore, in order to achieve a similar effect, we have to find another way to fake it. One of the ways to do it is to break the intended regex into two parts and match them one after another.

Consider the following [example](http://jsfiddle.net/dyfchin/k86VC/), which aims to append a string to a file path if it meets certain conditions.

{% highlight javascript %}
// To simulate /(?<=^\/images\/cars\/)([\w\-\.]*)(?=.(?:jpg|png|gif))/

var lookahead   = /([\w\-\.]*)(?=.(?:jpg|png|gif))/,
    lookbehind  = /^\/images\/cars\/$/,
    appendText  = '-car',
    replaceFn   = function(matched, $1) {
        var str    = arguments[arguments.length - 1],
            offset = arguments[arguments.length - 2];
        
        if (lookbehind.test(str.substr(0, offset))) {
            return $1 + appendText;
        } else {
            return matched;
        }
    };

// Expect filename is appended with '-car'
console.log('/images/cars/toyota.jpg'.replace(lookahead, replaceFn));
console.log('/images/cars/honda-civic.jpg'.replace(lookahead, replaceFn));
console.log('/images/cars/honda.png'.replace(lookahead, replaceFn));

// Expect nothing is replaced or appended
console.log('/views/cars/honda.html'.replace(lookahead, replaceFn));
console.log('/images/cars/honda.pdf'.replace(lookahead, replaceFn));
console.log('/images/cars/parts/wheel.jpg'.replace(lookahead, replaceFn));
console.log('/images/motorbikes/honda.jpg'.replace(lookahead, replaceFn));
console.log('/assets/images/cars/honda.jpg'.replace(lookahead, replaceFn));
{% endhighlight %}

This is the regex we plan to use to match and capture the desired file names and replaced with something different.

{% highlight javascript %}
/(?<=^\/images\/cars\/)([\w-\.]*)(?=.(?:jpg|png|gif))/
{% endhighlight %}

To break the regex apart, firstly, we have to ignore the positive lookbehind for now and use the latter part of the regex to test against the subject. If it matches, we then use the first part of regex (without the lookbehind grouping brackets) to check against the subject again, from the beginning up to the first match. The second check ensures that the file name captured from the first check belongs to the intended folder. At last, we append the new text to the backreference of the captured match and return it inside the replace function. You can check out the [demo](http://jsfiddle.net/dyfchin/k86VC/) here.
