---
layout: post
title: Using HttpInterceptor to listen for page load event in AngularJS
date: 2014-10-03 00:00:00
tags: angularjs
---

Often you need to make several GET API requests and fetch a few HTML partials to render an AngularJS page. To know when a page finishes loading, obviously you cannot just listen for `DOMContentLoaded` event, because AJAX calls happen afterwards. Instead, you can use a HttpInterceptor to monitor the completion of all GET requests when $location changes.

## How it works

HttpInterceptor acts as middleware allowing you to do extra stuff before and after making a request and receiving a response. To achieve an outcome similar to page 'ready' event, you need to keep track of the number of requests made, and cross them off the list when they are fulfilled (successful or not).

## Example

You can see an [example](http://jsfiddle.net/dyfchin/sf7hqa52/) demonstrating the concept. Below is a snippet of the example.

{% highlight javascript %}
angular.module('loading', [])

  .factory('loadingInterceptor', function($q, loadingProgress) {
    var pendingRequests = [];

    function onRequest(request) {
      loadingProgress.queue(request);

      console.log('Pending request: ' + request.url);
      
      return request;
    }

    function onResponse(response) {
      loadingProgress.dequeue(response.config);

      console.log('Completed request: ' + response.config.url);
      
      return response;
    }

    function onError(response) {
      loadingProgress.dequeue(response.config);

      console.log('Failed request: ' + response.config.url);

      return $q.reject(response);
    }

    return {
      request: onRequest,
      response: onResponse,
      requestError: onError,
      responseError: onError
    };
  })

  .factory('loadingProgress', function($rootScope, $timeout) {
    return {
      init: function() {
        this.pendingRequests = [];
      },

      reset: function() {
        this.pendingRequests.length = 0;
        this.loaded = false;
      },

      queue: function(request) {
        // Add to queue if it is a GET request
        if (request.method === 'GET') {
          this.pendingRequests.push(request.url);
          this.loaded = false;
        }
      },

      dequeue: function(request) {
        var index = this.pendingRequests.indexOf(request.url);

        // Remove from queue
        if (index !== -1) {
          this.pendingRequests.splice(index, 1);
        }

        // Wait for the next digest cycle
        $timeout(function() {
          // If there are no pending requests, notify child scopes
          if (this.pendingRequests.length === 0 && !this.loaded) {
            this.notify('pageReady');
            this.loaded = true;
          }
        }.bind(this));
      },

      notify: function() {
        $rootScope.$broadcast.apply($rootScope, arguments);
      }
    };
  });
{% endhighlight %}

And this is an example view/controller which makes some http calls, which get tracked by `loadingProgress` service through `loadingInterceptor`. 

{% highlight html %}
<div ng-controller="AppController">
    <strong ng-show="loadingProgress.loaded">Loaded!</strong>
    <strong ng-hide="loadingProgress.loaded">Loading...</strong>
    
    <!-- Load a HTML partial -->
    <ng-include src="'http://fiddle.jshell.net/echo/html/'"></ng-include>
</div>
{% endhighlight %}

{% highlight javascript %}
angular.module('app', ['ngRoute', 'loading'])

  .config(function($httpProvider) {
    // Register a http interceptor
    $httpProvider.interceptors.push('loadingInterceptor');
  })

  .run(function($rootScope, loadingProgress) {
    // Init loadingProgress service
    loadingProgress.init();

    // Reset loading queue on route change
    $rootScope.$on('$routeChangeSuccess', loadingProgress.reset);
    $rootScope.$on('$routeUpdate', loadingProgress.reset);
  })

  .controller('AppController', function($scope, $http, loadingProgress) {
    // Make a http GET request
    $http.get('http://fiddle.jshell.net/echo/json/')
      .then(function() {
        // Make another http GET request after the first one
        return $http.get('http://fiddle.jshell.net/echo/xml/');
      });

    // Listen for "pageReady" event
    $scope.$on('pageReady', function() {
      console.log('Completed all http requests');
    });

    // Assign to scope for demo purpose
    $scope.loadingProgress = loadingProgress;
  });
{% endhighlight %}

As you can see, you can broadcast a ‘ready’ event from the $rootScope to inform child scopes that all GET requests are fulfilled. Such event is useful in many cases. For example, you might want to scroll to a specific element on the page; but you can only do it once the page finishes loading, otherwise its offset position would get miscalculated. You might also want to implement a site-wide loading indicator, toggling its visibility when the `ready` event gets fired.

## Download
I needed a similar functionality for my day job - to notify NewRelic when a page finishes loading, otherwise the timing report seems unrealistic. I moved it into a [Bower component](https://github.com/red-ant/angular-ra-pageload) so it can be shared across different Angular projects. You can check out a [demo here](http://jsfiddle.net/dyfchin/3a1updw0/). To use it in your project, try

~~~
bower install angular-ra-pageload
~~~
