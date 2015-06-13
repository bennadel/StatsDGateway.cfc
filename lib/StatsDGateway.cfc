component
	output = false
	hint = "I provide a ColdFusion gateway to a StatsD server."
	{

	// Define the private variables. This isn't strictly needed, but it will provide some
	// insight into what to expect for the state of the component.
	variables.host = "";
	variables.hostInetAddress = "";
	variables.port = "";
	variables.prefix = "";
	variables.randomNumberGenerator = "";
	variables.suffix = "";


	/**
	* I initialize the statsD gateway to communicate with the given statsD server.
	* 
	* @host I am the statsD host address.
	* @port I am the port that the statsD server is listening on.
	* @prefix I am the prefix to prepend to all metric keys.
	* @suffix I am the suffix to append to all metric keys.
	* @output false
	*/
	public any function init(
		string host = "localhost",
		numeric port = 8125,
		string prefix = "",
		string suffix = ""
		) {

		// Store private variables.
		setHost( host );
		setPort( port );
		setPrefix( prefix );
		setSuffix( suffix );
		setRandomNumberGenerator( createRandomNumberGenerator() );

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I send a count metric to the statsD server. Returns [this] for method chaining.
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
	* I am a convenience method for sending a decrement-count value. Returns [this] for
	* method chaining.
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
	* with a "-" sign. Returns [this] for method chaining.
	* 
	* @key I am the key being gauged.
	* @delta I am the delta value being used to alter the gauge.
	* @rate I am the rate at which to sample the metric.
	* @output false
	*/
	public any function decrementGauge(
		required string key,
		required numeric delta
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
	* I am a convenience method for sending an incremented-count value. Returns [this] 
	* for method chaining.
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
	* with a "+" sign. Returns [this] for method chaining.
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
	* I set the statsD host address. Returns [this] for method chaining.
	* 
	* @newHost I am the new host being set.
	* @output false
	*/
	public any function setHost( required string newHost ) {

		testHost( newHost );

		host = newHost;
		hostInetAddress = createObject( "java", "java.net.InetAddress" ).getByName( javaCast( "string", host ) );

		return( this );

	}


	/**
	* I set the statsD port. Returns [this] for method chaining.
	* 
	* @newPort I am the new port being set.
	* @output false
	*/
	public any function setPort( required numeric newPort ) {

		testPort( newPort );

		port = newPort;

		return( this );

	}


	/**
	* I set the prefix to be perpended to all metric keys. Returns [this] for method
	* chaining.
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
	* I set the random number generator to be used when determining if a metric should
	* be sent based on the provided sampling rate. Returns [this] for method chaining.
	* 
	* @newRandomNumberGenerator I am the new random number generator.
	* @output false
	*/
	public any function setRandomNumberGenerator( required any newRandomNumberGenerator ) {

		randomNumberGenerator = newRandomNumberGenerator;

		return( this );

	}


	/**
	* I set the suffix to be appended to all metric keys. Returns [this] for method
	* chaining.
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
	* I test the given statsD host address. If the value is invalid, I throw an error;
	* otherwise, I just return quietly.
	* 
	* @newHost I am the new host being tested.
	* @output false
	*/
	public void function testHost( required string newHost ) {

		if ( ! len( newHost ) ) {

			throw(
				type = "StatsDGateway.InvalidHost",
				message = "The given host is invalid.",
				detail = "The host cannot be empty."
			);

		}

		if ( newHost != trim( newHost ) ) {

			throw(
				type = "StatsDGateway.InvalidHost",
				message = "The given host is invalid.",
				detail = "The host cannot contain leading or trailing whitespace."
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
				type = "StatsDGateway.InvalidKey",
				message = "The given key is invalid.",
				detail = "The metric key cannot be empty."
			);

		}

		if ( newKey != trim( newKey ) ) {

			throw(
				type = "StatsDGateway.InvalidKey",
				message = "The given key is invalid.",
				detail = "The metric key cannot contain leading or trailing whitespace."
			);

		}

		if ( find( ":", newKey ) ) {

			throw(
				type = "StatsDGateway.InvalidKey",
				message = "The given key is invalid.",
				detail = "The metric key [#newKey#] cannot contain the reserved character [:]."
			);

		}

		if ( find( "|", newKey ) ) {

			throw(
				type = "StatsDGateway.InvalidKey",
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
				type = "StatsDGateway.InvalidPrefix",
				message = "The given prefix is invalid.",
				detail = "The prefix cannot contain leading or trailing whitespace."
			);

		}

		if ( find( ":", newPrefix ) ) {

			throw(
				type = "StatsDGateway.InvalidPrefix",
				message = "The given prefix is invalid.",
				detail = "The prefix [#newPrefix#] cannot contain the reserved character [:]."
			);

		}

		if ( find( "|", newPrefix ) ) {

			throw(
				type = "StatsDGateway.InvalidPrefix",
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
				type = "StatsDGateway.InvalidRate",
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
				type = "StatsDGateway.InvalidSuffix",
				message = "The given suffix is invalid.",
				detail = "The suffix cannot contain leading or trailing whitespace."
			);

		}

		if ( find( ":", newSuffix ) ) {

			throw(
				type = "StatsDGateway.InvalidSuffix",
				message = "The given suffix is invalid.",
				detail = "The suffix [#newSuffix#] cannot contain the reserved character [:]."
			);

		}

		if ( find( "|", newSuffix ) ) {

			throw(
				type = "StatsDGateway.InvalidSuffix",
				message = "The given suffix is invalid.",
				detail = "The suffix [#newSuffix#] cannot contain the reserved character [|]."
			);

		}

	}


	/**
	* I test the given statsD port. If the value is invalid, I throw an error;
	* otherwise, I just return quietly.
	* 
	* @newPort I am the new port being tested.
	* @output false
	*/
	public void function testPort( required numeric newPort ) {

		// ... there's not much that can make a port strictly invalid.

	}


	/**
	* I send a timing metric to the statsD server. Returns [this] for method chaining.
	* 
	* @key I am the key being timed.
	* @duration I am the duration value being recorded.
	* @rate I am the rate at which to sample the metric.
	* @output false
	*/
	public any function timing(
		required string key,
		required numeric duration
		numeric rate = 1
		) {

		testKey( key );
		testRate( rate );

		return( sendMetric( "ms", key, duration, rate ) );

	}


	/**
	* I record the number of unique members inside the given group. Returns [this] for 
	* method chaining.
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
	* I create the base random number generator using Java.
	* 
	* @output false
	*/
	private any function createRandomNumberGenerator() {

		return(
			createObject( "java", "java.util.Random" )
				.init( javaCast( "long", getTickCount() ) )
		);

	}


	/**
	* I format the given sample rate for use in the metric payload.
	* 
	* @rate I am the sample rate to format.
	* @output false
	*/
	private string function formatRate( required numeric rate ) {

		return( numberFormat( rate, "0.0" ) );

	}


	/**
	* I use the random number generator to return the next random value between 0 and 1.
	* 
	* @output false
	*/
	private numeric function nextFloat() {

		return( randomNumberGenerator.nextFloat() );

	}


	/**
	* I send the given message over a UDP socket to the statsD server. I return [this] for 
	* method chaining.
	* 
	* @message I am the message being sent.
	* @output false
	*/
	private any function sendMessage( required string message ) {

		try {

			var socket = createObject( "java", "java.net.DatagramSocket" ).init();

			var packet = createObject( "java", "java.net.DatagramPacket" ).init(
				charsetDecode( message, "utf-8" ),
				javaCast( "int", len( message ) ),
				hostInetAddress,
				javaCast( "int", port )
			);

			socket.send( packet );

		} finally {

			if ( structKeyExists( local, "socket" ) ) {

				socket.close();

			}

		}

		return( this );

	}


	/**
	* I create and send a metric with the given properties to the statsD server. I return
	* [this] for method chaining.
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

		if ( shouldSkipBasedOnSampleRate( rate, type, key ) ) {

			return( this );

		}

		var message = "#prefix##key##suffix#:#value#|#type#";

		if ( rate != 1 ) {

			message &= ( "|@" & formatRate( rate ) );

		}

		return( sendMessage( message ) );

	}


	/**
	* I determine if the given key should be skipped due to the given sample rate.
	* 
	* NOTE: Internally, we are using pseudo-random generation to determine if the given
	* metric should be sampled; but, we are passing-in more values than are needed so 
	* that we can change the algorithm later on, especially if the component is sub-classed
	* and this method needs to be overridden. 
	* 
	* @rate I am the sample rate for the given key.
	* @metric I am the statsD metric type being sampled.
	* @key I am the statsD metric key being sampled.
	*/
	private boolean function shouldSkipBasedOnSampleRate(
		required numeric rate,
		required string metric,
		required string key
		) {

		if ( rate == 1 ) {

			return( false );

		}

		return( nextFloat() <= rate );

	}

}