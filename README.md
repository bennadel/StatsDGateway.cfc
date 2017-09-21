
# StatsDGateway.cfc - ColdFusion Gateway To StatsD Server

by [Ben Nadel][1] (on [Google+][2])

**VERSION**: 1.0.0

This is a small ColdFusion module to facilitate the sending of metrics to a statsD 
server. In order to create the statsD client, you can either use the StatsDGateway.cfc
to compose the default client:

```cfc
// Creates the default client using the UDP transport.
var client = new lib.StatsDGateway().createClient();

// Creates a client with persistent UDP socket.
var client = new lib.StatsDGateway().createClient( persistent = true );

// Creates a client with message buffering.
var client = new lib.StatsDGateway().createClient( maxLength = 1000 );
```

* StatsDGateway.createClient( host = "localhost", port = 8125, prefix = "", suffix = "", persistent = false, maxLength = 0 );

Or, you can create and inject the components manually:

```cfc
// Create the composable components first.
var transport = new lib.transport.UDPTransport();
var sampler = new lib.sampler.RandomSampler();

// Then, manually create and inject dependencies.
var client = new lib.client.StatsDClient( transport, sampler );
```

* StatsDClient.init( transport, sampler, prefix = "", suffix = "" )

Building the client manually can be helpful if you need to create a new type of 
transport, such as an HTTP-based transport, or need to add logging.

## Metrics

Once you have a reference to the statsD client instance, you can use the following 
methods to send metrics to the statsD server.

### Count

* count( key, delta, rate = 1 )
* decrement( key, delta = 1, rate = 1 )
* increment( key, delta = 1, rate = 1 )

### Gauge

* decrementGauge( key, delta, rate = 1 )
* gauge( key, value, rate = 1 )
* incrementGauge( key, delta, rate = 1 )

### Timing

* timing( key, duration, rate = 1 )

### Unique Sets

* unique( group, member, rate = 1 )


----

## Change Log

### Version 1.0.0

Initial release of basic StatsDClient.


[1]: http://www.bennadel.com
[2]: https://plus.google.com/108976367067760160494?rel=author
