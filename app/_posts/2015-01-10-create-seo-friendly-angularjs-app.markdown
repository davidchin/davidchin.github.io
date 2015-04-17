---
layout: post
title: Create SEO friendly AngularJS app
date: 2015-01-10 00:00:00
tags: angularjs
---

The biggest problem with AngularJS is that pages you built with it cannot be directly crawled by search engines, because their content is dynamically rendered and therefore not visible in the source code. To get around this problem, you have to pre-render your pages on the server using a JavaScript-enabled headless browser, such as PhantomJS, and then cache the result so that the server doesn’t get hit when crawlers visit the same page again.

## Using a third-party service

The simplest way to achieve this is to use a third-party service, such as [prerender.io](https://prerender.io/) It is a paid service (free if you only have less than 250 pages). It is very good and I recommend using it for client projects because you don’t have to waste client’s money to tackle a problem that is already solved by someone else (and the cost is cheap).

## Roll your own

However, if you just want to play around with the concept, you can read on. I managed to make Rails-backed AngularJS app indexable by doing the following things.

### Install PhantomJS

Firstly, install PhantomJS as a Node module `npm install --save phantomjs`. This will update your `package.json` and install PhantomJS in your `node_modules` folder.

### Rails middleware

Secondly, create a middleware that intercepts all incoming requests.

In `config/initializer/snapshot.rb`

{% highlight ruby %}
require 'snapshot/renderer'

YourApplication::Application.config.middleware.use(Snapshot::Renderer)
{% endhighlight %}

In `lib/snapshot/renderer.rb`

{% highlight ruby %}
module Snapshot
  class Renderer
    # A list of bots that don't support _escaped_fragment_
    BOTS = [
      'baiduspider',
      'facebookexternalhit',
      'twitterbot',
      'rogerbot',
      'linkedinbot',
      'embedly',
      'bufferbot',
      'quora link preview',
      'showyoubot',
      'outbrain',
      'pinterest',
      'developers.google.com/+/web/snippet',
      'slackbot'
    ]

    def initialize(app)
      @app = app
    end

    def call(env)
      fragment = parse_fragment(env)

      if fragment
        render_fragment(env, fragment)
      elsif bot_request?(env) && page_request?(env)
        fragment = { path: env['REQUEST_PATH'], query: env['QUERY_STRING'] }
        render_fragment(env, fragment)
      else
        @app.call(env)
      end
    end

    private

    def parse_fragment(env)
      regexp = /(?:_escaped_fragment_=)([^&]*)/
      query = env['QUERY_STRING']
      match = regexp.match(query)

      # Interpret _escaped_fragment_ and figure out which page needs to be rendered
      { path: URI.unescape(match[1]), query: query.sub(regexp, '') } if match
    end

    def render_fragment(env, fragment)
      url = "#{ env['rack.url_scheme'] }://#{ env['HTTP_HOST'] }#{ fragment[:path] }"
      url += "?#{ fragment[:query] }" if fragment[:query].present?

      # Run PhantomJS
      body = `node_modules/.bin/phantomjs lib/snapshot/browser.js #{ url } --load-images=false`

      # Output pre-rendered response
      status, headers = @app.call(env)
      response = Rack::Response.new(body, status, headers)
      response.finish
    end

    def bot_request?(env)
      user_agent = env['HTTP_USER_AGENT']
      buffer_agent = env['X-BUFFERBOT']

      buffer_agent || (user_agent && BOTS.any? { |bot| bot.include?(user_agent.downcase) })
    end

    def page_request?(env)
      method = env['REQUEST_METHOD'] || 'GET'
      accept = env['HTTP_ACCEPT']
      path = env['REQUEST_PATH']

      # Only return true if it is a GET request, accepting text/html response
      # not hitting API endpoint, and not requesting static asset
      method.upcase == 'GET' &&
      accept =~ /text\/html/ &&
      !(path =~ /^\/(?:assets|api)/) &&
      !(path =~ /\.[a-z0-9]{2,4}$/i)
    end
  end
end
{% endhighlight %}

Essentially what the middleware does is, if the incoming request is a GET request accepting text/html (and not looking for a static asset in the public directory, or hitting an API endpoint), it will ask PhantomJS to render the web page. The headless browser will return HTML containing the the page content (replacing AngularJS template code with actual content). Once the output is returned, the middleware passes it down to the next middleware on the stack, which eventually gets returned to the search engine.

If you look at the code, you’ll see that it looks for `_escaped_fragment_` first. That’s because of the [Ajax-crawling specification](https://developers.google.com/webmasters/ajax-crawling/docs/specification) implemented by Google and Bing. It just means that if your application uses hash fragments (#!) or HTML5 history API to fetch pages using AJAX, the search engine automatically requests theses pages using a special URL instead. For example `http://domain.com/recipes/123` maps to `http://domain.com?_escaped_fragment_=/recipes/123` The purpose of this is to give the server an opportunity to return static crawlable content instead of JavaScript templates. Please note that if you use pushState to generate pretty URLs, you need to explicitly tell the crawler by putting `<meta name="fragment" content="!">` in `head`

### Configure PhantomJS

Thirdly, in `lib/snapshot/browser.js`

{% highlight javascript %}
// Dependencies
var system = require('system'),
    webpage = require('webpage');

// Arguments check
var url = system.args[1];

if (url) {
  // Load page
  var page = webpage.create();

  // Set viewport
  page.viewportSize = {
    width: 1024,
    height: 800
  };

  page.open(url, function(status) {
    var attempts = 0;

    function checkPageReady() {
      var html;

      // Evaluate page
      html = page.evaluate(function() {
        var body = document.getElementsByTagName('body')[0];

        // Return HTML when page is fully loaded
        if (body.getAttribute('data-ready') === 'true') {
          return document.getElementsByTagName('html')[0].outerHTML;
        }
      });

      // Output HTML if defined and exit
      if (html) {
        console.log(html);
        phantom.exit();
      }

      // Break if too many attempts were made
      else if (attempts < 100) {
        attempts++;

        // Try again
        setTimeout(checkPageReady, 100);
      } else {
        console.error('Failed to wait for the requested page to load');
        phantom.exit();
      }
    }

    if (status === 'success') {
      // Check if page is fully loaded
      checkPageReady();
    } else {
      // Otherwise, if page cannot be found, exit
      phantom.exit();
    }
  });
}
{% endhighlight %}

The above is the script used by PhantomJS to open the AngularJS page before returning the HTML output to the middleware. Basically, the headless browser synchronously waits for the page to finish loading and then takes a snapshot of it. Internally, in your AngularJS app, you need to watch for the completion of all API requests and set a flag once all the content is loaded and rendered, for example, setting `data-ready` attribute in the `body` tag to true. I just used something I built previously for that - [angular-ra-pageload](https://github.com/red-ant/angular-ra-pageload)

If you restart your unicorn server and CURL it using the _escaped_fragment_ url, you should see a rendered output instead of AngularJS templates. Please note that if you run your app on Heroku, you need to use [multi-buildpack](https://github.com/heroku/heroku-buildpack-multi) so both Node and Ruby can run.

Anyway, from this experiment, it becomes clear that the pre-rendering is an expensive operation, that's why I recommend delegating the task to a third-party service which handles the caching for you. Otherwise, you'll need to do it yourself.

