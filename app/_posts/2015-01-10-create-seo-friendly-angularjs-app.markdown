---
layout: post
title:  "Create SEO friendly AngularJS app"
date:   2015-01-10 10:13:01
categories: angularjs
---
The biggest problem with AngularJS is that pages you built with it cannot be directly crawled by search engines, because their content is dynamically rendered and therefore not visible in the source code.

To get around this problem, you have to pre-render your pages on the server using a JavaScript-enabled headless browser, such as PhantomJS, and then cache the result so that the server doesn’t get hit when crawlers visit the same page again.
