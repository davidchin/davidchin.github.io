---
layout: post
title: Disable AngularJS ngAnimate for selected elements
date: 2014-10-03 00:00:00
tags: angularjs
description: There are two ways to disable ngAnimate for selected elements. You can tell Angular to only watch for CSS transitional changes to directive elements if they have a specific class name. Alternatively, if you're writing your own directive, you can call the `$animate.enabled` method directly to disable animation.
---

There are two ways to disable ngAnimate for selected elements. You can tell Angular to only watch for CSS transitional changes to directive elements if they have a specific class name. Alternatively, if you're writing your own directive, you can call the `$animate.enabled` method directly to disable animation.

## CSS method

You can configure `ngAnimate` to only enable animation for elements with a particular set of class names.

{% highlight javascript %}
angular.module('Application', ['ngAnimate'])
  .config(function($animateProvider) {
    $animateProvider.classNameFilter(/ng-animate-enabled/);
  });
{% endhighlight %}

`#classNameFilter` accepts a regular expression as its argument. Therefore, if you want, instead of selectively enabling ngAnimate, you can do the reverse and selectively disable ngAnimate for certain elements. For example:

{% highlight javascript %}
angular.module('Application', ['ngAnimate'])
  .config(function($animateProvider) {
    $animateProvider.classNameFilter(/^(?:(?!ng-animate-disabled).)*$/);
  });
{% endhighlight %}

{% highlight css %}
.btn {
  color: #ccc;
  transition: color .3s ease-out;
}

.btn:hover {
  color: #000;
}
{% endhighlight %}

{% highlight html %}
<a href="/logout" class="btn ng-animate-disabled" ng-show="isMember">Logout</a>
<a href="/login" class="btn ng-animate-disabled" ng-hide="isMember">Login</a>
{% endhighlight %}

With this configuration, the login/logout buttons do not watch for transitional changes. This is useful because sometimes you apply CSS transition to an element for styling purposes; but inadvertently, you apply a directive such as `ng-hide` on it as well. Instead of hiding the element immediately when `ng-hide` becomes truthy, you will see a delay. The delay is due to the fact that `ng-hide` internally uses `$animate.addClass`. Therefore, it needs to wait for the CSS transition to complete before applying `ng-hide` class.

## JS method

The Javascript method is very straightforward, however, you need to get a reference to the element you wish to disable ngAnimate.

{% highlight javascript %}
$animate.enabled(false, element);
{% endhighlight %}

Therefore, it is only useful in cases where you're writing your own directive, as it is not recommended to select DOM elements in controllers for the sake of Separation of Concerns.

I find the first method much more flexible and fits with ngAnimate's paradigm of using CSS to specify transitional behaviours.
