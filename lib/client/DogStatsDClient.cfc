component
	output = false
	hint = "I am a specialized statsD client for DataDog (DogStatsD)."
	{

	this.ALERT_TYPE = {
		ERROR: "error",
		WARNING: "warning",
		INFO: "info",
		SUCCESS: "success"
	};

	this.PRIORITY = {
		NORMAL: "normal",
		LOW: "low"
	};

	variables.NEWLINE_PATTERN = "\r\n?|\n";


	/**
	* I initialize the DogStatsD client to send messages over the given transport. The
	* DogStatsD client is a specialized StatsD client that adds support for histograms,
	* tagging, system checks, and events.
	* 
	* @transport I am the communications transport implementation.
	* @sampler I am a sampling strategy for omitting metrics.
	* @prefix I am the prefix to prepend to all metric keys.
	* @suffix I am the suffix to append to all metric keys.
	* @rate I am the default sampling rate to use for all metrics.
	* @tags I am the collection of tags associated with every metric.
	* @output false
	*/
	public any function init(
		required any transport,
		required any sampler,
		string prefix = "",
		string suffix = "",
		numeric rate = 1,
		array tags = []
		) {

		// Store private variables.
		setTransport( transport );
		setSampler( sampler );
		setPrefix( prefix );
		setSuffix( suffix );
		setRate( rate );
		setTags( tags );

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I send a count metric to the statsD server. Returns [this].
	* 
	* Accepts multiple signatures:
	* 
	* count( key, delta )
	* count( key, delta, rate )
	* count( key, delta, tags )
	* count( key, delta, rate, tags )
	* 
	* @key I am the key being counted.
	* @delta I am the delta value being used to alter the count.
	* @rate I am the rate at which to sample the metric.
	* @tags I am the collection of tags associated with the metric.
	* @output false
	*/
	public any function count(
		required string key,
		required numeric delta
		) {

		var metricArguments = {
			type: "c",
			key: key,
			value: delta,
			rate: baseRate,
			tags: []
		};

		var length = arrayLen( arguments );

		// SIGNATURE: count( key, delta, rate )
		if ( ( length == 3 ) && isNumeric( arguments[ 3 ] ) ) {

			metricArguments.rate = arguments[ 3 ];

		// SIGNATURE: count( key, delta, tags )
		} else if ( length == 3 ) {

			metricArguments.tags = arguments[ 3 ];

		// SIGNATURE: count( key, delta, rate, tags )
		} else if ( length == 4 ) {

			metricArguments.rate = arguments[ 3 ];
			metricArguments.tags = arguments[ 4 ];

		}

		return( sendMetric( argumentCollection = metricArguments ) );

	}


	/**
	* I am a convenience method for sending a decrement-count value. Returns [this].
	* 
	* Accepts multiple signatures:
	* 
	* decrement( key )
	* decrement( key, delta )
	* decrement( key, delta, rate )
	* decrement( key, delta, tags )
	* decrement( key, delta, rate, tags )
	* 
	* @key I am the key being counted.
	* @delta I am the delta value being used to decrement the count.
	* @rate I am the rate at which to sample the metric.
	* @tags I am the collection of tags associated with the metric.
	* @output false
	*/
	public any function decrement(
		required string key,
		numeric delta = 1
		) {

		var metricArguments = {
			type: "c",
			key: key,
			value: -delta,
			rate: baseRate,
			tags: []
		};

		var length = arrayLen( arguments );

		// SIGNATURE: decrement( key, delta, rate )
		if ( ( length == 3 ) && isNumeric( arguments[ 3 ] ) ) {

			metricArguments.rate = arguments[ 3 ];

		// SIGNATURE: decrement( key, delta, tags )
		} else if ( length == 3 ) {

			metricArguments.tags = arguments[ 3 ];

		// SIGNATURE: decrement( key, delta, rate, tags )
		} else if ( length == 4 ) {

			metricArguments.rate = arguments[ 3 ];
			metricArguments.tags = arguments[ 4 ];

		}

		return( sendMetric( argumentCollection = metricArguments ) );

	}


	/**
	* I send an decrement-gauge metric to the statsD server by prepending the given value
	* with a "-" sign. Returns [this].
	* 
	* Accepts multiple signatures:
	* 
	* decrementGauge( key, delta )
	* decrementGauge( key, delta, tags )
	* 
	* @key I am the key being gauged.
	* @delta I am the delta value being used to alter the gauge.
	* @tags I am the collection of tags associated with the metric.
	* @output false
	*/
	public any function decrementGauge(
		required string key,
		required numeric delta,
		array tags = []
		) {

		var metricArguments = {
			type: "g",
			key: key,
			value: "-#delta#",
			rate: baseRate,
			tags: tags
		};

		return( sendMetric( argumentCollection = metricArguments ) );

	}


	/**
	* I destroy the statsD client, cleaning up any data that needs to be cleaned up.
	* After the client is destroyed, no more messages can be sent. Subsequent calls to
	* .destroy() are ignored.
	* 
	* @output false
	*/
	public void function destroy() {

		transport.destroy();
		sampler.destroy();

		transport = "";
		sampler = "";

	}


	/**
	* I send an event to DataDogHQ.
	*
	* @title I am the title of the event.
	* @text I am the text of the event (can be empty, can contain line breaks).
	* @timestamp I am the UTC ** SECONDS ** of the event (default is now).
	* @hostname I am the hostname of the event.
	* @aggregationKey I am the shared aggregation key of the event (allowing events to be grouped).
	* @priority I am the priority of the event (default is "normal").
	* @sourceTypeName I am the source type of the event.
	* @alertType I am the alert level of the event (default is "info").
	* @tags I am the collection of tags associated with the event.
	* @output false
	*/
	public any function event(
		required string title,
		required string text,
		numeric timestamp = 0,
		string hostname = "",
		string aggregationKey = "",
		string priority = "",
		string sourceTypeName = "",
		string alertType = "",
		array tags = []
		) {

		testEventTitle( title );
		testEventText( text );
		testEventTimestamp( timestamp );
		testEventHostname( hostname );
		testEventPriority( priority );
		testEventSourceTypeName( sourceTypeName );
		testEventAlertType( alertType );
		testTags( tags );

		var normalizedText = reReplace( trim( text ), NEWLINE_PATTERN, "\\n", "all" );

		var segments = [
			"_e{#len( title )#,#len( normalizedText )#}:#title#|#normalizedText#"	
		];

		// If no timestamp is provided, let's create one so that our event timing is
		// accurate, regardless of when the message is actually flushed to the server.
		if ( timestamp ) {

			arrayAppend( segments, "d:#fix( timestamp )#" );

		} else {

			arrayAppend( segments, "d:#fix( getTickCount() / 1000 )#" );

		}

		if ( len( hostname ) ) {

			arrayAppend( segments, "h:#hostname#" );

		}

		if ( len( aggregationKey ) ) {

			arrayAppend( segments, "k:#aggregationKey#" );

		}

		if ( len( priority ) ) {

			arrayAppend( segments, "p:#priority#" );

		}

		if ( len( sourceTypeName ) ) {

			arrayAppend( segments, "s:#sourceTypeName#" );

		}

		if ( len( alertType ) ) {

			arrayAppend( segments, "t:#alertType#" );

		}

		if ( arrayLen( baseTags ) && arrayLen( tags ) ) {

			arrayAppend( segments, ( "##" & listAppend( arrayToList( baseTags ), arrayToList( tags ) ) ) );

		} else if ( arrayLen( baseTags ) || arrayLen( tags ) ) {

			arrayAppend( segments, ( "##" & arrayToList( baseTags ) & arrayToList( tags ) ) );

		}

		transport.sendMessage( arrayToList( segments, "|" ) );

		return( this );

	}


	/**
	* I send a gauge metric to the statsD server. Returns [this] for method chaining.
	* 
	* Accepts multiple signatures:
	* 
	* gauge( key, value )
	* gauge( key, value, tags )
	* 
	* @key I am the key being gauged.
	* @value I am the value of the gauge.
	* @tags I am the collection of tags associated with the metric.
	* @output false
	*/
	public any function gauge(
		required string key,
		required numeric value,
		array tags = []
		) {

		var metricArguments = {
			type: "g",
			key: key,
			value: value,
			rate: baseRate,
			tags: tags
		};

		return( sendMetric( argumentCollection = metricArguments ) );

	}


	/**
	* I send a timing metric to the statsD server. Returns [this].
	* 
	* Accepts multiple signatures:
	* 
	* histogram( key, value )
	* histogram( key, value, rate )
	* histogram( key, value, tags )
	* histogram( key, value, rate, tags )
	* 
	* @key I am the key being measured.
	* @value I am the value being recorded.
	* @rate I am the rate at which to sample the metric.
	* @tags I am the collection of tags associated with the metric.
	* @output false
	*/
	public any function histogram(
		required string key,
		required numeric value
		) {

		var metricArguments = {
			type: "h",
			key: key,
			value: value,
			rate: baseRate,
			tags: []
		};

		var length = arrayLen( arguments );	

		// SIGNATURE: histogram( key, value, rate )
		if ( ( length == 3 ) && isNumeric( arguments[ 3 ] ) ) {

			metricArguments.rate = arguments[ 3 ];

		// SIGNATURE: histogram( key, value, tags )
		} else if ( length == 3 ) {

			metricArguments.tags = arguments[ 3 ];

		// SIGNATURE: histogram( key, value, rate, tags )
		} else if ( length == 4 ) {

			metricArguments.rate = arguments[ 3 ];
			metricArguments.tags = arguments[ 4 ];

		}

		return( sendMetric( argumentCollection = metricArguments ) );

	}


	/**
	* I am a convenience method for sending an incremented-count value. Returns [this].
	* 
	* Accepts multiple signatures:
	* 
	* increment( key )
	* increment( key, delta )
	* increment( key, delta, rate )
	* increment( key, delta, tags )
	* increment( key, delta, rate, tags )
	* 
	* @key I am the key being counted.
	* @delta I am the delta value being used to increment the count.
	* @rate I am the rate at which to sample the metric.
	* @tags I am the collection of tags associated with the metric.
	* @output false
	*/
	public any function increment(
		required string key,
		numeric delta = 1
		) {

		var metricArguments = {
			type: "c",
			key: key,
			value: delta,
			rate: baseRate,
			tags: []
		};

		var length = arrayLen( arguments );

		// SIGNATURE: increment( key, delta, rate )
		if ( ( length == 3 ) && isNumeric( arguments[ 3 ] ) ) {

			metricArguments.rate = arguments[ 3 ];

		// SIGNATURE: increment( key, delta, tags )
		} else if ( length == 3 ) {

			metricArguments.tags = arguments[ 3 ];

		// SIGNATURE: increment( key, delta, rate, tags )
		} else if ( length == 4 ) {

			metricArguments.rate = arguments[ 3 ];
			metricArguments.tags = arguments[ 4 ];

		}

		return( sendMetric( argumentCollection = metricArguments ) );

	}


	/**
	* I send an increment-gauge metric to the statsD server by prepending the given value
	* with a "+" sign. Returns [this].
	* 
	* Accepts multiple signatures:
	* 
	* incrementGauge( key, delta )
	* incrementGauge( key, delta, tags )
	* 
	* @key I am the key being gauged.
	* @delta I am the delta value being used to alter the gauge.
	* @tags I am the collection of tags associated with the metric.
	* @output false
	*/
	public any function incrementGauge(
		required string key,
		required numeric delta,
		array tags = []
		) {

		var metricArguments = {
			type: "g",
			key: key,
			value: "+#delta#",
			rate: baseRate,
			tags: tags
		};

		return( sendMetric( argumentCollection = metricArguments ) );

	}


	/**
	* I determine if the client has been destroyed.
	* 
	* @output false
	*/
	public boolean function isDestroyed() {

		return( isSimpleValue( transport ) );

	}


	/**
	* I set the prefix to be perpended to all metric keys. Returns [this].
	* 
	* @newPrefix I am the new prefix being set.
	* @output false
	*/
	public any function setPrefix( required string newPrefix ) {

		testPrefix( newPrefix );
		basePrefix = newPrefix;

		return( this );

	}


	/**
	* I set the default sample rate to be used for all metrics. This can be overridden at
	* each method call (if applicable). Returns [this].
	* 
	* @newRate I am the new default sampling rate being set.
	* @output false
	*/
	public any function setRate( required string newRate ) {

		testRate( newRate );
		baseRate = newRate;

		return( this );

	}


	/**
	* I set the sampler that will help determine if metrics should be omitted based on 
	* sample rate. Returns [this].
	* 
	* @newSampler I am the new sampler.
	* @output false
	*/
	public any function setSampler( required any newSampler ) {

		sampler = newSampler;

		return( this );

	}


	/**
	* I set the suffix to be appended to all metric keys. Returns [this].
	* 
	* @newSuffix I am the new suffix being set.
	* @output false
	*/
	public any function setSuffix( required string newSuffix ) {

		testSuffix( newSuffix );
		baseSuffix = newSuffix;

		return( this );

	}


	/**
	* I set the collection of tags to be associated with all metrics. Returns [this].
	* 
	* @newTags I am the collection of tags being set.
	* @output false
	*/
	public any function setTags( required array newTags ) {

		testTags( newTags );
		baseTags = newTags;

		return( this );

	}


	/**
	* I set the transport implementation used to send the statsD messages. Returns [this].
	* 
	* @newTransport I am the new suffix being set.
	* @output false
	*/
	public any function setTransport( required any newTransport ) {

		transport = newTransport;

		return( this );

	}


	/**
	* I test the given DogStatsD event alert type. If the value is invalid, I throw an
	* error; otherwise, I just return quietly.
	* 
	* @newKey I am the new event alert type being tested.
	* @output false
	*/
	public void function testEventAlertType( required string newAlertType ) {

		if ( len( newAlertType ) && ! structKeyExists( this.ALERT_TYPE, newAlertType ) ) {

			throw(
				type = "DogStatsDClient.InvalidEventAlertType",
				message = "Event alert type is invalid.",
				detail = "The event alert type [#newAlertType#] must be one of the following: 'error', 'warning', 'info', or 'success'."
			);

		}

	}


	/**
	* I test the given DogStatsD event hostname. If the value is invalid, I throw an
	* error; otherwise, I just return quietly.
	* 
	* @newKey I am the new event hostname being tested.
	* @output false
	*/
	public void function testEventHostname( required string newHostname ) {

		if ( newHostname != trim( newHostname ) ) {

			throw(
				type = "DogStatsDClient.InvalidEventHostname",
				message = "Event hostname is invalid.",
				detail = "The event hostname [#newHostname#] cannot contain leading or trailing whitespace."
			);

		}

		if ( reFind( NEWLINE_PATTERN, newHostname ) ) {

			throw(
				type = "DogStatsDClient.InvalidEventHostname",
				message = "Event hostname is invalid.",
				detail = "The event hostname [#newHostname#] cannot contain line breaks."
			);

		}

		if ( reFind( "[|:]", newHostname ) ) {

			throw(
				type = "DogStatsDClient.InvalidEventHostname",
				message = "Event hostname is invalid.",
				detail = "The event hostname [#newHostname#] cannot contain the reserved characters: '|' or ':'."
			);

		}

	}


	/**
	* I test the given DogStatsD event priority. If the value is invalid, I throw an
	* error; otherwise, I just return quietly.
	* 
	* @newKey I am the new event priority being tested.
	* @output false
	*/
	public void function testEventPriority( required string newPriority ) {

		if ( len( newPriority ) && ! structKeyExists( this.PRIORITY, newPriority ) ) {

			throw(
				type = "DogStatsDClient.InvalidEventPriority",
				message = "Event priority is invalid.",
				detail = "The event priority [#newPriority#] must be one of the following: 'low' or 'normal'."
			);

		}

	}


	/**
	* I test the given DogStatsD event source type name. If the value is invalid, I throw
	* an error; otherwise, I just return quietly.
	* 
	* @newKey I am the new event source type name being tested.
	* @output false
	*/
	public void function testEventSourceTypeName( required string newSourceTypeName ) {

		if ( newSourceTypeName != trim( newSourceTypeName ) ) {

			throw(
				type = "DogStatsDClient.InvalidEventSourceTypeName",
				message = "Event source type name is invalid.",
				detail = "The event source type name [#newSourceTypeName#] cannot contain leading or trailing whitespace."
			);

		}

		if ( reFind( NEWLINE_PATTERN, newSourceTypeName ) ) {

			throw(
				type = "DogStatsDClient.InvalidEventSourceTypeName",
				message = "Event source type name is invalid.",
				detail = "The event source type name [#newSourceTypeName#] cannot contain line breaks."
			);

		}

		if ( reFind( "[|:]", newSourceTypeName ) ) {

			throw(
				type = "DogStatsDClient.InvalidEventSourceTypeName",
				message = "Event source type name is invalid.",
				detail = "The event source type name [#newSourceTypeName#] cannot contain the reserved characters: '|' or ':'."
			);

		}

	}


	/**
	* I test the given DogStatsD event text. If the value is invalid, I throw an error;
	* otherwise, I just return quietly.
	* 
	* @newKey I am the new event text being tested.
	* @output false
	*/
	public void function testEventText( required string newText ) {

		// CAUTION: The validation on the event text is very loose because this is not
		// necessarily a value that is provided by the developer; it may be a value that
		// is thrown and caught, resulting in a wildly unpredictable format.

	}


	/**
	* I test the given DogStatsD event timestamp. If the value is invalid, I throw an
	* error; otherwise, I just return quietly.
	* 
	* @newKey I am the new event timestamp being tested.
	* @output false
	*/
	public void function testEventTimestamp( required numeric newTimestamp ) {

		// ... not sure if there is anything to validate here?

	}


	/**
	* I test the given DogStatsD event title. If the value is invalid, I throw an error;
	* otherwise, I just return quietly.
	* 
	* @newKey I am the new event title being tested.
	* @output false
	*/
	public void function testEventTitle( required string newTitle ) {

		if ( ! len( newTitle ) ) {

			throw(
				type = "DogStatsDClient.InvalidEventTitle",
				message = "Event title is invalid.",
				detail = "The event title cannot be empty."
			);

		}

		if ( newTitle != trim( newTitle ) ) {

			throw(
				type = "DogStatsDClient.InvalidEventTitle",
				message = "Event title is invalid.",
				detail = "The event title [#newTitle#] cannot contain leading or trailing whitespace."
			);

		}

		if ( reFind( NEWLINE_PATTERN, newTitle ) ) {

			throw(
				type = "DogStatsDClient.InvalidEventTitle",
				message = "Event title is invalid.",
				detail = "The event title [#newTitle#] cannot contain line breaks."
			);

		}

	}


	/**
	* I test the given statsD key. If the value is invalid, I throw an error; otherwise,
	* I just return quietly.
	* 
	* @newKey I am new key being tested.
	* @output false
	*/
	public void function testKey( required string newKey ) {

		if ( ! len( newKey ) ) {

			throw(
				type = "DogStatsDClient.InvalidKey",
				message = "Metric key is invalid.",
				detail = "The metric key cannot be empty."
			);

		}

		if ( newKey != trim( newKey ) ) {

			throw(
				type = "DogStatsDClient.InvalidKey",
				message = "Metric key is invalid.",
				detail = "The metric key cannot contain leading or trailing whitespace."
			);

		}

		if ( ! reFind( "^[a-zA-Z]", newKey ) ) {

			throw(
				type = "DogStatsDClient.InvalidKey",
				message = "Metric key is invalid.",
				detail = "The metric key [#newKey#] must start with a letter."
			);

		}

		if ( reFind( "[:|@]", newKey ) ) {

			throw(
				type = "DogStatsDClient.InvalidKey",
				message = "Metric key is invalid.",
				detail = "The metric key [#newKey#] cannot contain the reserved characters: '|', ':', or '@'."
			);

		}

	}


	/**
	* I test the key prefix. If the value is invalid, I throw an error; otherwise, I just
	* return quietly.
	* 
	* @newPrefix I am new prefix being tested.
	* @output false
	*/
	public void function testPrefix( required string newPrefix ) {

		if ( newPrefix != trim( newPrefix ) ) {

			throw(
				type = "DogStatsDClient.InvalidPrefix",
				message = "Metric prefix is invalid.",
				detail = "The metric prefix cannot contain leading or trailing whitespace."
			);

		}

		if ( reFind( "[:|@]", newPrefix ) ) {

			throw(
				type = "DogStatsDClient.InvalidPrefix",
				message = "Metric prefix is invalid.",
				detail = "The metric prefix [#newPrefix#] cannot contain the reserved characters: ':', '|', or '@'."
			);

		}

	}


	/**
	* I test the given sample rate. If the value is invalid, I throw an error; otherwise,
	* I just return quietly.
	* 
	* @newRate I am the new sample rate being tested.
	* @output false
	*/
	public void function testRate( required numeric newRate ) {

		if ( ( newRate <= 0 ) || ( newRate > 1 ) ) {

			throw(
				type = "DogStatsDClient.InvalidRate",
				message = "Metric sample rate is invalid.",
				detail = "The metric sample rate must be between zero (exclusive) and one (inclusive)."
			);

		}

	}


	/**
	* I test the key suffix. If the value is invalid, I throw an error; otherwise, I just
	* return quietly.
	* 
	* @newSuffix I am new suffix being tested.
	* @output false
	*/
	public void function testSuffix( required string newSuffix ) {

		if ( newSuffix != trim( newSuffix ) ) {

			throw(
				type = "DogStatsDClient.InvalidSuffix",
				message = "Metric suffix is invalid.",
				detail = "The metric suffix cannot contain leading or trailing whitespace."
			);

		}

		if ( reFind( "[:|]", newSuffix ) ) {

			throw(
				type = "DogStatsDClient.InvalidSuffix",
				message = "Metric suffix is invalid.",
				detail = "The metric suffix [#newSuffix#] cannot contain the reserved characters: ':' or '|'."
			);

		}

	}


	/**
	* I test the DogStatsD tag. If the value is invalid, I throw an error; otherwise, I
	* just return quietly.
	* 
	* @newTag I am new tag being tested.
	* @output false
	*/
	public void function testTag( required string newTag ) {

		if ( newTag != trim( newTag ) ) {

			throw(
				type = "DogStatsDClient.InvalidTag",
				message = "Tag is invalid.",
				detail = "The tag [#newTag#] cannot contain leading or trailing whitespace."
			);

		}

		if ( ! reFind( "^[a-zA-Z]", newTag ) ) {

			throw(
				type = "DogStatsDClient.InvalidTag",
				message = "Tag is invalid.",
				detail = "The tag [#newTag#] must start with a letter."
			);

		}

		if ( reFindNoCase( "^(device|host|source):", newTag ) ) {

			throw(
				type = "DogStatsDClient.InvalidTag",
				message = "Tag is invalid.",
				detail = "The tag [#newTag#] cannot contain the reserved keys: 'device:', 'host:', or 'source:'."
			);

		}

		if ( len( newTag ) > 200 ) {

			throw(
				type = "DogStatsDClient.InvalidTag",
				message = "Tag is invalid.",
				detail = "The tag [#newTag#] must be less than or equal to 200 characters."
			);

		}

	}


	/**
	* I test the DogStatsD tags collection. If the value is invalid, I throw an error;
	* otherwise, I just return quietly.
	* 
	* @newTags I am new tags collection being tested.
	* @output false
	*/
	public void function testTags( required array newTags ) {

		for ( var tag in newTags ) {

			testTag( tag );

		}

	}


	/**
	* I send a timing metric to the statsD server. Returns [this].
	* 
	* Accepts multiple signatures:
	* 
	* timing( key, duration )
	* timing( key, duration, rate )
	* timing( key, duration, tags )
	* timing( key, duration, rate, tags )
	* 
	* @key I am the key being timed.
	* @duration I am the duration value being recorded.
	* @rate I am the rate at which to sample the metric.
	* @tags I am the collection of tags associated with the metric.
	* @output false
	*/
	public any function timing(
		required string key,
		required numeric duration
		) {

		var metricArguments = {
			type: "ms",
			key: key,
			value: duration,
			rate: baseRate,
			tags: []
		};

		var length = arrayLen( arguments );

		// SIGNATURE: timing( key, duration, rate )
		if ( ( length == 3 ) && isNumeric( arguments[ 3 ] ) ) {

			metricArguments.rate = arguments[ 3 ];

		// SIGNATURE: timing( key, duration, tags )
		} else if ( length == 3 ) {

			metricArguments.tags = arguments[ 3 ];

		// SIGNATURE: timing( key, duration, rate, tags )
		} else if ( length == 4 ) {

			metricArguments.rate = arguments[ 3 ];
			metricArguments.tags = arguments[ 4 ];

		}

		return( sendMetric( argumentCollection = metricArguments ) );

	}


	/**
	* I record the number of unique members inside the given group. Returns [this].
	* 
	* Accepts multiple signatures:
	* 
	* unique( group, member )
	* unique( group, member, tags )
	* 
	* @group I am the group containing unique members.
	* @member I am the member value being recorded.
	* @tags I am the collection of tags associated with the metric.
	* @output false
	*/
	public any function unique(
		required string group,
		required string member,
		array tags = []
		) {

		var metricArguments = {
			type: "s",
			key: group,
			value: member,
			rate: baseRate,
			tags: tags
		};

		return( sendMetric( argumentCollection = metricArguments ) );

	}


	// ---
	// PRIVATE METHODS.
	// ---


	/**
	* I create and send a metric with the given properties to the statsD server. Returns [this].
	* 
	* @type I am the type notation of the metric (ex, c, s, g, h, ms).
	* @key I am the key (bucket) of the metric.
	* @value I am the value of the metric.
	* @rate I am the rate at which to sample this metric.
	* @tags I am the collection of tags associated with the metric.
	* @output false
	*/
	private any function sendMetric( 
		required string type,
		required string key,
		required string value,
		required numeric rate,
		required array tags
		) {

		testKey( key );
		testRate( rate );
		testTags( tags );

		// For DogStatsD, sampling only works with counters, histograms, and timers.
		if ( reFind( "(c|h|ms)", type ) && sampler.shouldSkip( rate, type, key ) ) {

			return( this );

		}

		var message = "#basePrefix##key##baseSuffix#:#value#|#type#";

		if ( rate != 1 ) {

			message &= ( "|@" & numberFormat( rate, "0.00" ) );

		}

		if ( arrayLen( baseTags ) && arrayLen( tags ) ) {

			message &= ( "|##" & listAppend( arrayToList( baseTags ), arrayToList( tags ) ) );

		} else if ( arrayLen( baseTags ) || arrayLen( tags ) ) {

			message &= ( "|##" & arrayToList( baseTags ) & arrayToList( tags ) );

		}

		transport.sendMessage( message );

		return( this );

	}

}
