---
layout: post
title: Simple range slider component built with React
date: 2015-09-30 00:00:00
tags: react
---

Recently, I needed a component for accepting a range of numeric values inside a form. I couldn't just use a native input range slider as it only accepts a single value. So I thought I might just write one myself. I decided to release it as a standalone package. You can check it out on [Github](https://github.com/davidchin/react-input-range) or try it in your project - `npm install react-input-range`.

## Background

`react-input-range` allows users to input a range of numeric values or a single value within a predefined range. By default, basic styles are applied, but can be overridden easily.

## Example

You can see a simple example below. For more detail, please refer to the [README](https://github.com/davidchin/react-input-range).

{% highlight js %}
import React from 'react';
import InputRange from 'react-input-range';

const values = {
  min: 2,
  max: 10
};

function onChange(component, values) {
  console.log(values);
}

React.render(
  <InputRange maxValue={20} minValue={0} values={values} onChange={onChange} />,
  document.getElementById('input-range')
);
{% endhighlight %}

## Demo

<p data-height="360" data-theme-id="0" data-slug-hash="GpNvqw" data-default-tab="result" data-user="davidchin" class='codepen'>See the Pen <a href='http://codepen.io/davidchin/pen/GpNvqw/'>React component for inputting numeric values within a range</a> by David Chin (<a href='http://codepen.io/davidchin'>@davidchin</a>) on <a href='http://codepen.io'>CodePen</a>.</p>
<script async src="//assets.codepen.io/assets/embed/ei.js"></script>
