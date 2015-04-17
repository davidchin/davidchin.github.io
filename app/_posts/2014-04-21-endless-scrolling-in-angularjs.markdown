---
layout: post
title: Endless scrolling in AngularJS
date: 2014-04-21 00:00:00
tags: angularjs
description: Endless scrolling (or infinite scrolling) can be neatly implement in AngularJS by isolating DOM logic in a directive. It is a useful UI feature allowing users to load the next set of data without having to click on a pagination link or navigate to a different page. However, as more items get loaded and more DOM elements get rendered, front-end performance becomes an issue as more memory gets consumed.
---

Endless scrolling (or infinite scrolling) can be neatly implement in AngularJS by isolating DOM logic in a directive. It is a useful UI feature allowing users to load the next set of data without having to click on a pagination link or navigate to a different page. However, as more items get loaded and more DOM elements get rendered, front-end performance becomes an issue as more memory gets consumed.

One way to get around that issue is by changing the user interaction so that only a fixed number of items can be fetched by scrolling. For example, after the first five pages, you have to manually click on ‘next’ or pagination links to navigate to a new page, clearing previously rendered elements.

## Solution

Otherwise, if you don’t want the user interaction to change, you have to work out a way to remove off-screen elements from the DOM so that they don’t sit around and chew up memory. I created a directive in AngularJS which does exactly that. It monitors changes in scrolling position and determines if it should request more data. It cleans up off-screen elements and re-inserts them if they reappear again. Internally, it does a shallow copy of the subject array, truncates it, and uses `ng-repeat` directive to render the truncated collection.

## Demo

You can check out the [demo](/demos/angular/endless-scroll) here. The example calls the Tumblr API and fetches some blog posts. Appending a page parameter in the URL, ie: `?page=2` would deep-link and fetch Page 2 initially.

## Usage

You can download it via Bower `bower install angular-endless-scroll` or via [GitHub](https://github.com/davidchin/angular-endless-scroll). The GitHub page has an instruction on how to use it in your project.

In short, to use it, you set it as an attribute to the element you wish to repeat with an expression, much like `ng-repeat`. For example:

{% highlight html %}
<div class="container">
  <div endless-scroll="item in items">
    {{ item.name }}
  </div>
</div>
{% endhighlight %}

The directive handles the DOM manipulation logic, to keep track of scrolling position and clean up off-screen elements. It notifies its parent scope when you scroll to the bottom of the page. In your controller, you can listen to that event and determine if there is a need to make a new API request to fetch the next page of items.

The directive does not try to make assumptions about your API response format. This way, it is flexible enough for you to implement application-specific logic in your controller to handle pagination and deep-linking. 

Please visit the [GitHub](https://github.com/davidchin/angular-endless-scroll) page for more information. 
