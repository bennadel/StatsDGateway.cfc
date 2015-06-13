
# StatsDGateway.cfc - ColdFusion Gateway To StatsD Server

by [Ben Nadel][1] (on [Google+][2])

This is a small ColdFusion gateway to facilitate the sending of metrics to a statsD
server.

## Constructor

* init( [ host = "localhost" [ , port = 8125 [ , prefix = "" [ , suffix = "" ]]]] )

## Metrics

### Count

* count( key, delta [ , rate = 1 ] )
* decrement( key [ , delta = 1 [ , rate = 1 ]] )
* increment( key [ , delta = 1 [ , rate = 1 ]] )

### Gauge

* decrementGauge( key, delta [ , rate = 1 ] )
* gauge( key, value [ , rate = 1 ] )
* incrementGauge( key, delta [ , rate = 1 ] )

### Timing

* timing( key, duration [ , rate = 1 ] )

### Unique Sets

* unique( group, member [ , rate = 1 ] )


[1]: http://www.bennadel.com
[2]: https://plus.google.com/108976367067760160494?rel=author
