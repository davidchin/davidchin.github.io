---
layout: post
title: How to break AngularJS promise chain
date: 2014-03-27 00:00:00
tags: angularjs
description: Using a promise chain is a very powerful way to handle asynchronous calls. Especially, when you need to make API calls sequently, where the second call depends on the response of the first call.
---

Using a promise chain is a very powerful way to handle asynchronous calls. Especially, when you need to make API calls sequently, where the second call depends on the response of the first call. Knowing how to break the promise chain saves you from making unnecessary calls, also giving you the flexibility of executing fallback methods.

For example, you want to make an API request and set up a chain of promises following the initial call. After receiving the initial response, you want to inspect it and decide what to do next. You want to break the promise chain if certain conditions are met in order to skip subsequent success callbacks. To do something like that, have a look at the following <a href="http://jsfiddle.net/dyfchin/MGPfm/">example</a>:

{% highlight javascript %}
// NOTE: 3rd-party REST APIs might change so the example below might not work as intended
angular.module('app', ['ngResource'])
  .controller('main', function($scope, $q, $resource) {
    var Repo   = $resource('https://api.github.com/rate_limit'),
      Greeting = $resource('http://angularjs.org/greet.php',
                 { callback: 'JSON_CALLBACK' },
                 { get: { method: 'JSONP' } });
    
    Repo.get().$promise
      // When API call is successful
      .then(function(response) {
        if (response.rate && response.rate.limit > 10000) {
          return response;
        } else {
          return $q.reject({ message: 'Rejecting this promise' });
        }
      })
    
      // Next promise in the chain
      .then(function(response) {
        $scope.message = angular.toJson(response);
        
        // Make another API call or forward response
        return Greeting.get().$promise;
      }, function(response) {
        $scope.message = response.message;
        
        // Forward rejection
        return $q.reject(response);
      })
    
      // Another promise in the chain
      .then(function() {
        $scope.message2 = 'The promise chain was not interrupted';
      }, function(response) {
        $scope.message2 = 'The promise chain was interrupted';
      });
  });
{% endhighlight %}

Calling `$q.reject` returns a rejected promise. Returning the rejected promise effectively rejects the current promise (the first `then` success callback). By forwarding the rejection inside each of the error callbacks until the last, you can prevent subsequent promises from getting resolved. Conversely, not forwarding the rejection would mean that the following promise will still get fulfilled and execute its success callback.

You can see a [live demo](http://jsfiddle.net/dyfchin/5hdPb/3/) here.
