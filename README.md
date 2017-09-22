
# StatsDGateway.cfc - ColdFusion Gateway To StatsD Server

by [Ben Nadel][1] (on [Google+][2])

**VERSION**: 2.0.0

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

## DataDog / DogStatsD Extension

[DataDog][datadog] is an amazing platform monitoring and alerting tool that supports
StatsD metrics. And while DataDog is compatible with any StatsD library, DataDog provides
an extension to StatsD known as [DogStatsD][dogstatsd]. This extension adds **tagging**
semantics and **histograms**. To take advantage of DataDog's DogStatsD extensions, the
StatsDGatway.cfc provides a DogStatsD-specific client:

```cfc
// Create the default DogStatsD client to use a UDP transport.
var client = new lib.StatsDGateway().createDogStatsClient(
	string host = "localhost",
	numeric port = 8125,
	string prefix = "",
	string suffix = "",
	numeric rate = 1,
	array tags = [],
	boolean persistent = false,
	numeric maxLength = 0
);
```

In addition to the base tags that can be provided when creating client (above), you can
also provide tags in each of the metric methods. The tags collection is an array of 
string values that can been stand-alone values (ex, `value`) or key-value pairs 
(ex, `key:value`):

```cfc
client.increment( "incoming-request", [ "route:#path#", "user:#userID#" ] );
```

The DogStatsDClient provides all of the basic StatsD methods plus `.histogram()`. Many of
the methods allow for optional `rate` and `tags` arguments. As such, the method 
signatures are fairly flexible (with rate defaulting to `1` and tags defaulting to `[]`):

### Count

* count( key, delta )
* count( key, delta, rate )
* count( key, delta, tags )
* count( key, delta, rate, tags )
* increment( key )
* increment( key, delta )
* increment( key, delta, rate )
* increment( key, delta, tags )
* increment( key, delta, rate, tags )
* decrement( key )
* decrement( key, delta )
* decrement( key, delta, rate )
* decrement( key, delta, tags )
* decrement( key, delta, rate, tags )

### Gauge

_**NOTE**: DogStatsD does not support sampling on gauges. It will be ignored._

* gauge( key, value )
* gauge( key, value, tags )
* incrementGauge( key, delta )
* incrementGauge( key, delta, tags )
* decrementGauge( key, delta )
* decrementGauge( key, delta, tags )

### Timing

_**NOTE**: DogStatsD implements timings as histograms under the hood._

* timing( key, duration )
* timing( key, duration, rate )
* timing( key, duration, tags )
* timing( key, duration, rate, tags )

### Histograms

* histogram( key, value )
* histogram( key, value, rate )
* histogram( key, value, tags )
* histogram( key, value, rate, tags )

### Unique Sets

_**NOTE**: DogStatsD does not support sampling on sets. It will be ignored._

* unique( group, member )
* unique( group, member, tags )

### Events

The DogStatsDClient can also send arbitrary events to DataDogHQ that can be overlayed on
anyone of the dashboards. This can be helpful when trying to correlate changes in 
performance with system events.

* event( title, text, ... )

The `event()` method can take several additional named arguments, which can be used to 
search and filter events in DataDogHQ:

* title - I am the title of the event.
* text - I am the text of the event (can be empty, can contain line breaks).
* timestamp - I am the UTC **SECONDS** of the event (default is now).
* hostname - I am the hostname of the event.
* aggregationKey - I am the shared aggregation key of the event (allowing events to be grouped).
* priority - I am the priority of the event (default is "normal").
* sourceTypeName - I am the source type of the event.
* alertType - I am the alert level of the event (default is "info").
* tags - I am the collection of tags associated with the event.

----

## Change Log

### Version 2.0.0

* __Feature__: Added `.event()` method to send events to DataDogHQ.
* __Breaking Change__: Fixed `key` validation for metrics.
* __Breaking Change__: Fixed `tag` validation for metrics.
* __Breaking Change__: Normalized some of the error message and details.

### Version 1.1.0

* __Feature__: Added DataDog's DogStatsD extension for StatsD metrics.

### Version 1.0.0

Initial release of basic StatsDClient.


[1]: http://www.bennadel.com
[2]: https://plus.google.com/108976367067760160494?rel=author
[datadog]: https://www.datadoghq.com/
[dogstatsd]: https://docs.datadoghq.com/guides/dogstatsd/
