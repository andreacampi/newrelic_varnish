newrelic\_varnish
=================

This is a working experiment in tracking metrics about [Varnish](http://varnish-cache.org)
performance using [NewRelic](http://newrelic.com).
It uses the [varnish-rb](http://github.com/andreacampi/varnish-rb) gem to access the Varnish
log SHM, which is then filtered and aggregated before being submitted using the newrelic\_rpm gem.

All caveats mentioned in the documentation for varnish-rb apply to this project too; in particular,
you should use JRuby for the best results.

In tests this code was able to handle about 2k HTTP request per second most of the time, but the
variance is high and you may well lose data points. Anything higher than that and you are on your
own; in other words, use it only in deployment and preproduction environments. Running this code
will not affect a Varnish instance in any way, but it will result in higher CPU load that may
affect Varnish anyway.


Contributing to newrelic\_varnish
=================================
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.


Copyright
=========

Copyright (c) 2011 ZephirWorks. See LICENSE.txt for
further details.