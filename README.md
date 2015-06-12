
# StatsDGateway.cfc - ColdFusion Gateway To StatsD Server

by [Ben Nadel][1] (on [Google+][2])

This is a small ColdFusion gateway to facilitate the sending of metrics to a statsD
server.

## Constructor

* init( host, port )

## Metrics

### Count

* count( key, delta )
* decrement( key [, delta = 1] )
* increment( key [, delta = 1] )
* sampleCount( rate, key, delta )

### Gauge

* decrementGauge( key, delta )
* gauge( key, value )
* incrementGauge( key, delta )

### Timing

* sampleTiming( rate, key, duration )
* timing( key, duration )


[1]: http://www.bennadel.com
[2]: https://plus.google.com/108976367067760160494?rel=author
