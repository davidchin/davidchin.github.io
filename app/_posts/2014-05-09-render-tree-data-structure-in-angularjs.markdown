---
layout: post
title: Render tree data structure in AngularJS
date: 2015-05-09 00:00:00
tags: angularjs
description: I came across a problem where I needed to lazily render a navigation menu in a tree structure using AngularJS. The API returns the child pages of a parent page by id. For example, GET `/documents/1` gives you all the subpages of page 1. If you click on one of the subpages, it queries the API again to render its subpages, and so forth.
---

I came across a problem where I needed to lazily render a navigation menu in a tree structure using AngularJS. The API returns the child pages of a parent page by id. For example, GET `/documents/1` gives you all the subpages of page 1. If you click on one of the subpages, it queries the API again to render its subpages, and so forth.

The depth of the tree is unknown. The JSON response looks like this:

{% highlight javascript %}
[
  {
    id: 1,
    name: 'Folder',
    hasChildren: true
  },

  {
    id: 2,
    name: 'Folder',
    hasChildren: true
  },

  {
    id: 3,
    name: 'Page',
    hasChildren: false
  }
]
{% endhighlight %}

In order to render the tree nodes, I need to parse the data recursively. I decided to apply the composite pattern and create a set of directives to handle the view logic. The directive looks like this:

{% highlight html %}
<document-tree documents="documents"></document-tree>
{% endhighlight %}

The implementation looks like this:

{% highlight javascript %}
angular.module('application')
  .directive('documentTree', function() {
    return {
      scope: {
        documents: '='
      },
      restrict: 'E',
      template: [
        '<ol class="list-group">',
          '<li ng-repeat="child in documents.children" class="list-group-item">',
            '<document-tree-node child="child">',
              '<a ng-click="documents.open(child)" href="javascript:void(0);">',
                '{{ child.name }}',
              '</a>',
            '</document-tree-node>',
          '</li>',
        '</ol>'
      ].join("")
    };
  })

  .directive('documentTreeNode', function($interpolate, $compile) {
    return {
      scope: {
        child: '='
      },
      restrict: 'E',

      link: function(scope, element) {
        var treeNode = {
          init: function() {
            // Init any vars
            scope.$watch('child.isExpanded', this.toggle.bind(this));
          },

          expand: function() {
            this.domId = 'document-children-' + scope.child.id;

            // Insert child documents
            var template = '<document-tree id="{{ childrenId }}" documents="child.documents"></document-tree>',
                html = $interpolate(template)({ childrenId: this.domId }),
                childrenElement = $compile(html)(scope);

            // Insert compiled template
            element.append(childrenElement);
          },

          collapse: function() {
            // Remove child elements, if needed
            $('#' + this.domId).remove();
          },

          toggle: function(shouldExpand) {
            if (shouldExpand) {
              this.expand();
            } else {
              this.collapse();
            }
          }
        };

        // Init
        treeNode.init();
      }
    };
  });
{% endhighlight %}

As you can see, `documentTreeNode` compiles itself if it has leaf elements. It needs to be compiled manually, otherwise, you will get a recursive compilation error if the recursion is implemented in the template.

The root `documents` object is the root of the tree structure, constructed using the data returned by API. The task of communicating with API is delegated to the `Documents` model. You can see the [full code and demo](http://codepen.io/davidchin/pen/BNjpNr) here.
