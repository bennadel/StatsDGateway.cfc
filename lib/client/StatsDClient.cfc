component
	output = false
	hint = "I am a statsD client for ColdFusion."
	{

	/**
	* I initialize the statsD client to send messages over the given transport.
	* 
	* @transport I am the communications transport implementation.
	* @sampler I am a sampling strategy for omitting metrics.
	* @prefix I am the prefix to prepend to all metric keys.
	* @suffix I am the suffix to append to all metric keys.
	* @output false
	*/
	public any function init(
		required any transport,
		required any sampler,
		string prefix = "",
		string suffix = ""
		) {

		// Store private variables.
		setTransport( transport );
		setSampler( sampler );
		setPrefix( prefix );
		setSuffix( suffix );

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I send a count metric to the statsD server. Returns [this].
	* 
	* @key I am the key being counted.
	* @delta I am the delta value being used to alter the count.
	* @rate I am the rate at which to sample the metric.
	* @output false
	*/
	public any function count(
		required string key,
		required numeric delta,
		numeric rate = 1
		) {

		testKey( key );
		testRate( rate );

		return( sendMetric( "c", key, delta, rate ) );

	}


	/**
	* I am a convenience method for sending a decrement-count value. Returns [this].
	* 
	* @key I am the key being counted.
	* @delta I am the delta value being used to decrement the count.
	* @rate I am the rate at which to sample the metric.
	* @output false
	*/
	public any function decrement(
		required string key,
		numeric delta = 1,
		numeric rate = 1
		) {

		return( count( key, -delta, rate ) );

	}


	/**
	* I send an decrement-gauge metric to the statsD server by prepending the given value
	* with a "-" sign. Returns [this].
	* 
	* @key I am the key being gauged.
	* @delta I am the delta value being used to alter the gauge.
	* @rate I am the rate at which to sample the metric.
	* @output false
	*/
	public any function decrementGauge(
		required string key,
		required numeric delta,
		numeric rate = 1
		) {

		testKey( key );
		testRate( rate );

		return( sendMetric( "g", key, "-#delta#", rate ) );

	}


	/**
	* I send a gauge metric to the statsD server. Returns [this] for method chaining.
	* 
	* @key I am the key being gauged.
	* @value I am the value of the gauge.
	* @rate I am the rate at which to sample the metric.
	* @output false
	*/
	public any function gauge(
		required string key,
		required numeric value,
		numeric rate = 1
		) {

		testKey( key );
		testRate( rate );

		return( sendMetric( "g", key, value, rate ) );

	}


	/**
	* I am a convenience method for sending an incremented-count value. Returns [this].
	* 
	* @key I am the key being counted.
	* @delta I am the delta value being used to increment the count.
	* @rate I am the rate at which to sample the metric.
	* @output false
	*/
	public any function increment(
		required string key,
		numeric delta = 1,
		numeric rate = 1
		) {

		return( count( key, delta, rate ) );

	}


	/**
	* I send an increment-gauge metric to the statsD server by prepending the given value
	* with a "+" sign. Returns [this].
	* 
	* @key I am the key being gauged.
	* @delta I am the delta value being used to alter the gauge.
	* @rate I am the rate at which to sample the metric.
	* @output false
	*/
	public any function incrementGauge(
		required string key,
		required numeric delta,
		numeric rate = 1
		) {

		testKey( key );
		testRate( rate );

		return( sendMetric( "g", key, "+#delta#", rate ) );

	}


	/**
	* I set the prefix to be perpended to all metric keys. Returns [this].
	* 
	* @newPrefix I am the new prefix being set.
	* @output false
	*/
	public any function setPrefix( required string newPrefix ) {

		testPrefix( newPrefix );

		prefix = newPrefix;

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

		suffix = newSuffix;

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
	* I test the given statsD key. If the value is invalid, I throw an error; otherwise,
	* I just return quietly.
	* 
	* @newKey I am new key being tested.
	* @output false
	*/
	public void function testKey( required string newKey ) {

		if ( ! len( newKey ) ) {

			throw(
				type = "StatsDClient.InvalidKey",
				message = "The given key is invalid.",
				detail = "The metric key cannot be empty."
			);

		}

		if ( newKey != trim( newKey ) ) {

			throw(
				type = "StatsDClient.InvalidKey",
				message = "The given key is invalid.",
				detail = "The metric key cannot contain leading or trailing whitespace."
			);

		}

		if ( find( ":", newKey ) ) {

			throw(
				type = "StatsDClient.InvalidKey",
				message = "The given key is invalid.",
				detail = "The metric key [#newKey#] cannot contain the reserved character [:]."
			);

		}

		if ( find( "|", newKey ) ) {

			throw(
				type = "StatsDClient.InvalidKey",
				message = "The given key is invalid.",
				detail = "The metric key [#newKey#] cannot contain the reserved character [|]."
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
				type = "StatsDClient.InvalidPrefix",
				message = "The given prefix is invalid.",
				detail = "The prefix cannot contain leading or trailing whitespace."
			);

		}

		if ( find( ":", newPrefix ) ) {

			throw(
				type = "StatsDClient.InvalidPrefix",
				message = "The given prefix is invalid.",
				detail = "The prefix [#newPrefix#] cannot contain the reserved character [:]."
			);

		}

		if ( find( "|", newPrefix ) ) {

			throw(
				type = "StatsDClient.InvalidPrefix",
				message = "The given prefix is invalid.",
				detail = "The prefix [#newPrefix#] cannot contain the reserved character [|]."
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
				type = "StatsDClient.InvalidRate",
				message = "The given sample rate is invalid.",
				detail = "The sample rate must be between zero (exclusive) and one (inclusive)."
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
				type = "StatsDClient.InvalidSuffix",
				message = "The given suffix is invalid.",
				detail = "The suffix cannot contain leading or trailing whitespace."
			);

		}

		if ( find( ":", newSuffix ) ) {

			throw(
				type = "StatsDClient.InvalidSuffix",
				message = "The given suffix is invalid.",
				detail = "The suffix [#newSuffix#] cannot contain the reserved character [:]."
			);

		}

		if ( find( "|", newSuffix ) ) {

			throw(
				type = "StatsDClient.InvalidSuffix",
				message = "The given suffix is invalid.",
				detail = "The suffix [#newSuffix#] cannot contain the reserved character [|]."
			);

		}

	}


	/**
	* I send a timing metric to the statsD server. Returns [this].
	* 
	* @key I am the key being timed.
	* @duration I am the duration value being recorded.
	* @rate I am the rate at which to sample the metric.
	* @output false
	*/
	public any function timing(
		required string key,
		required numeric duration,
		numeric rate = 1
		) {

		testKey( key );
		testRate( rate );

		return( sendMetric( "ms", key, duration, rate ) );

	}


	/**
	* I record the number of unique members inside the given group. Returns [this].
	* 
	* @group I am the group containing unique members.
	* @member I am the member value being recorded.
	* @rate I am the rate at which to sample the metric.
	* @output false
	*/
	public any function unique(
		required string group,
		required string member,
		numeric rate = 1
		) {

		return( sendMetric( "s", group, member, rate ) );

	}


	// ---
	// PRIVATE METHODS.
	// ---


	/**
	* I format the given sample rate for use in the metric payload.
	* 
	* @rate I am the sample rate to format.
	* @output false
	*/
	private string function formatRate( required numeric rate ) {

		return( numberFormat( rate, "0.000" ) );

	}


	/**
	* I create and send a metric with the given properties to the statsD server. Returns [this].
	* 
	* @type I am the type notation of the metric (ex, c, s, g).
	* @key I am the key (bucket) of the metric.
	* @value I am the value of the metric.
	* @rate I am the rate at which to sample this metric.
	* @output false
	*/
	private any function sendMetric( 
		required string type,
		required string key,
		required string value,
		required numeric rate
		) {

		if ( sampler.shouldSkip( rate, type, key ) ) {

			return( this );

		}

		var message = "#prefix##key##suffix#:#value#|#type#";

		if ( rate != 1 ) {

			message &= ( "|@" & formatRate( rate ) );

		}

		transport.sendMessage( message );

		return( this );

	}

}