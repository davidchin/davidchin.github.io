---
layout: post
title: Using ngAnimate to animate directives in AngularJS
date: 2014-05-17 00:00:00
tags: angularjs
description: AngularJS makes it easy to animate elements using CSS. When ngAnimate module is specified as a dependency, many default Angular directives inherit the ability to automatically add and/or remove classes when certain events occur.
---

AngularJS makes it easy to animate elements using CSS. When ngAnimate module is specified as a dependency, many default Angular directives inherit the ability to automatically add and/or remove classes when certain events occur. Therefore, if these classes contain CSS transitions or animations, the applied elements would be animated accordingly. The good thing about this approach, compared to using jQuery, is that transitions that are purely presentational and neatly separated from your application logic. Therefore, even if your user’s browser doesn’t support CSS transitions, he can still use your application.

## Example using default directive

Take ngRepeat as an example, When the directive inserts a new element on a page, it adds `ng-enter` class to the inserted element. In `ng-repeat`, you can define which properties you wish to animate. And then, it adds `ng-enter-active` when your pre-defined animation is ready to fire, and removes it when the animation finishes. Behind the scene, $animate service manages the chain of events so you don’t have to worry about setting up observers and handlers yourself.

This is how you might set up your stylesheet in SCSS:

{% highlight scss %}
.list-group-item {
  // Apply transitions when an item gets added, removed or repositioned in a list
  &.ng-enter,
  &.ng-leave,
  &.ng-move {
    transition: 0.5s linear all;
  }

  // Apply a transition delay (stagger effect) to items (with the same parent element) that are manipulated at the same time
  // For example, if multiple items get added at once, ng-enter transition would be applied to each with a delay in between
  &.ng-enter-stagger,
  &.ng-leave-stagger,
  &.ng-move-stagger {
    transition-delay: 0.05s;
  }

  // Define the start opacity value for ng-enter and ng-move
  // And define the end value for ng-leave
  &.ng-enter,
  &.ng-move,
  &.ng-leave.ng-leave-active {
    opacity: 0;
  }

  // Define the start opacity value for ng-leave
  // And define the end value for ng-enter and ng-move
  &.ng-enter.ng-enter-active,
  &.ng-move.ng-move-active,
  &.ng-leave {
    opacity: 1;
  }
}
{% endhighlight %}

And your view is simply:

{% highlight html %}
<ul>
  <li ng-repeat="country in countries" class="list-group-item">
    {{ country.name }}
  </li>
</ul>
{% endhighlight %}

## Example using custom directive

If you’re writing your own directive, you can use $animate service to perform ‘enter’, ‘leave’ and ‘move’ animations manually. It is what gets used internally by default directives in Angular. You can still use $animate API even if ngAnimate module is not injected. The main module has a barebone version which gets decorated when ngAnimate becomes available.

This is how you might want to use `$animate` service to perform DOM manipulations with animation hooks.

{% highlight javascript %}
angular.module('Demo', ['ngAnimate'])

  // Directive to display the meta data of an item
  // For example:
  // <li item-meta="item">{{ item.name }}</li>
  .directive('itemMeta', function($animate) {
    return {
      restrict: 'A',
      scope: {
        item: '=itemMeta'
      },
      link: function(scope, element) {
        var label;

        // Watch for changes to the bound object
        scope.$watch('item.category', function(value) {
          // Create a label element (it not created already)
          if (!label) {
            label = angular.element('<span>').addClass('label label-info');
          }

          // Display data bound by its parent controller
          label.text(value);
        });

        // Listen for mouse events
        element.on('mouseenter', function() {
          scope.$apply(function() {
            var contents = element.contents();

            // Append the label as a child element and trigger 'ng-enter' transition
            $animate.enter(label, element, contents.eq(contents.length - 1));
          });
        });

        element.on('mouseleave', function() {
          scope.$apply(function() {
            // Remove the label from the element and trigger 'ng-leave' transition
            $animate.leave(label);
          });
        });
      }
    };
  });
{% endhighlight %}

Alternatively, you can use any of the default directives inside your directive template to borrow some of their animation abilities.

## Demo

You can have a look at this [demo](http://jsfiddle.net/dyfchin/dY34f/), which demonstrates how AngularJS automatically adds pre-defined classes to a list of elements when they get added, removed or moved by various filters. It also demonstrates how to perform class-based animations when writing your own directive using `$animate` service.

## JavaScript-based animation

If you want to show animations in older browsers that don’t support CSS transitions or animations. AngularJS does have a way for you to define JavaScript-based animations. I’m not going to go into it in detail, but basically, you have to define a CSS class and specify what animations you want to run when certain events (i.e.: enter, leave, move) get fired by `$animate` service.

{% highlight javascript %}
angular.module('Demo', ['ngAnimate'])

    // Any element that has .demo-animation class would execute the following
    .animation('.demo-animation', function() {
      return {
        // Same terminology as CSS-based animations
        enter: function(element, done) {
          $(element).animate({ left: 100 }, done);
        }
      }
    });
{% endhighlight %}
