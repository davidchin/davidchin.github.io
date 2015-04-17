---
layout: post
title: AngularJS directives for modifying ngModel values
date: 2014-04-27 00:00:00
tags: angularjs
description: Recently I created a set of AngularJS directives allowing you to prepend or append a string to the model value of a ngModel without affecting its view value. For example, you might want to prepend `http://` to a web address input field instead of asking the user to enter it. And you want this to happen before sending its form to the server.
---

Recently I created a set of AngularJS directives allowing you to prepend or append a string to the model value of a ngModel without affecting its view value. For example, you might want to prepend `http://` to a web address input field instead of asking the user to enter it. And you want this to happen before sending its form to the server.

One way to do it is to put the logic inside your controller and process the form data before sending it. Another way to do it so to put the logic inside a reusable directive and declare the add-on behaviour in the view. Personally, I prefer the latter. And you can achieve it by adding a parser and a formatter to the ngModel directive you wish to modify.

## Background

As you might already know, ngModel has parsers and formatters allowing you to modify its model and view value. Its model value (`$modelValue`) refers to the value of the scope property that is bound to the directive. Its view value (`$viewValue`), on the other hand, refers to the value displayed in the input field of the directive.

## Download

You can clone the project at [GitHub](https://github.com/davidchin/angular-input-add-on) or download it using Bower:

~~~
bower install angular-input-add-on
~~~

The source code demonstrates the usage of a parser and formatter to change the model value of a ngModel and affect its display in the input field.

## Example usage

You can use the `input-prepend` directive like this.

{% highlight html %}
<div class="input-group">
  <span class="input-group-addon">http://</span>
  <input ng-model="name" input-prepend="http://" type="text" class="form-control">
</div>
{% endhighlight %}

The example uses a span label to indicate to the user that ‘http://’ is pre-filled. And `input-prepend="http://"` declares that its attribute value would get prepended to the user input. `input-append` works the same way except it appends the string to the end instead. Also, you can use both directives at once if you wish to prepend as well as append strings to a field.

The directives are delegated with the responsibility of handling the logic of modifying a user's input, without having to worry about other parts of the application logic. Because of their declarative nature, they can be easily reused and help to reduce the size of your controller. Also, they can be chained with other parsers and formatters to control the modification of a bound scope property as a whole.
