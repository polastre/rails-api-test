rails-api-test
==============

A sample API server using Rails.

This API application calculates the distance between points, assuming there's an external provider of names and coordinates.  It uses an [Apiary Mock Server](http://docs.nodejsapitestprovider.apiary.io/) to simulate the external provider.

To run, simply do:

```js
bundle exec rails s
```

To run the tests, it is just:

```js
bundle exec rspec
```