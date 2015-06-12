component
	output = false
	hint = "I provide a ColdFusion gateway to a StatsD server."
	{

	// Define the private variables. This isn't strictly needed, but it will provide some
	// insight into what to expect for the state of the component.
	variables.host = "";
	variables.hostInetAddress = "";
	variables.port = "";
	variables.randomNumberGenerator = "";


	/**
	* I initialize the statsD gateway to communicate with the given statsD server.
	* 
	* @host I am the statsD host address.
	* @port I am the port that the statsD server is listening on.
	* @output false
	*/
	public any function init(
		required string host,
		required numeric port
		) {

		// Store private variables.
		setHost( host );
		setPort( port );

		// Create our random number generator (used for sampling).
		randomNumberGenerator = createObject( "java", "java.util.Random" )
			.init( javaCast( "long", getTickCount() ) )
		;

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
	* @output false
	*/
	public any function count(
		required string key,
		required numeric delta
		) {

		testKey( key );

		return( sendMetric( "#key#:#delta#|c" ) );

	}


	/**
	* I am a convenience method for sending a decrement-count value. Returns [this] for
	* method chaining.
	* 
	* @key I am the key being counted.
	* @delta I am the delta value being used to decrement the count.
	* @output false
	*/
	public any function decrement(
		required string key,
		numeric delta = 1
		) {

		return( count( key, -delta ) );

	}


	/**
	* I send an decrement-gauge metric to the statsD server by prepending the given value
	* with a "-" sign. Returns [this] for method chaining.
	* 
	* @key I am the key being gauged.
	* @delta I am the delta value being used to alter the gauge.
	* @output false
	*/
	public any function decrementGauge(
		required string key,
		required numeric delta
		) {

		testKey( key );

		return( sendMetric( "#key#:-#delta#|g" ) );

	}


	/**
	* I send a gauge metric to the statsD server. Returns [this] for method chaining.
	* 
	* @key I am the key being gauged.
	* @value I am the value of the gauge.
	* @output false
	*/
	public any function gauge(
		required string key,
		required numeric value
		) {

		testKey( key );

		return( sendMetric( "#key#:#value#|g" ) );

	}


	/**
	* I am a convenience method for sending an incremented-count value. Returns [this] 
	* for method chaining.
	* 
	* @key I am the key being counted.
	* @delta I am the delta value being used to increment the count.
	* @output false
	*/
	public any function increment(
		required string key,
		numeric delta = 1
		) {

		return( count( key, delta ) );

	}


	/**
	* I send an increment-gauge metric to the statsD server by prepending the given value
	* with a "+" sign. Returns [this] for method chaining.
	* 
	* @key I am the key being gauged.
	* @delta I am the delta value being used to alter the gauge.
	* @output false
	*/
	public any function incrementGauge(
		required string key,
		required numeric delta
		) {

		testKey( key );

		return( sendMetric( "#key#:+#delta#|g" ) );

	}


	/**
	* I send a count metric to the statsD server using the given sampling. Returns [this]
	* for method chaining.
	* 
	* @rate I a the rate at which to sample the given metric.
	* @key I am the key being counted.
	* @delta I am the delta value being used to alter the count.
	* @output false
	*/
	public any function sampleCount(
		required numeric rate,
		required string key,
		required numeric delta
		) {

		testRate( rate );
		testKey( key );

		if ( shouldSkipBasedOnSampleRate( rate, "count", key ) ) {

			return( this );

		}

		return( sendMetric( "#key#:#delta#|c|@" & formatRate( rate ) ) );

	}


	/**
	* I send a timing metric to the statsD server using the given sampling. Returns [this]
	* for method chaining.
	* 
	* @rate I a the rate at which to sample the given metric.
	* @key I am the key being timed.
	* @duration I am the duration value being recorded.
	* @output false
	*/
	public any function sampleTiming(
		required numeric rate,
		required string key,
		required numeric duration
		) {

		testRate( rate );
		testKey( key );

		if ( shouldSkipBasedOnSampleRate( rate, "timing", key ) ) {

			return( this );

		}

		return( sendMetric( "#key#:#duration#|ms|@" & formatRate( rate ) ) );

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
				detail = "The metric key [#newKey#] cannot contain the reserved [:] character."
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
	* I send a timing metric to the statsD server. Returns [this] for method chaining.
	* 
	* @key I am the key being timed.
	* @duration I am the duration value being recorded.
	* @output false
	*/
	public any function timing(
		required string key,
		required numeric duration
		) {

		testKey( key );

		return( sendMetric( "#key#:#duration#|ms" ) );

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

		return( numberFormat( rate, "0.0" ) );

	}


	/**
	* I send the given metric over a UDP socket to the statsD server. I return [this] for 
	* method chaining.
	* 
	* @metric I am the metric being sent.
	* @output false
	*/
	private any function sendMetric( required string metric ) {

		try {

			var socket = createObject( "java", "java.net.DatagramSocket" ).init();

			var packet = createObject( "java", "java.net.DatagramPacket" ).init(
				charsetDecode( metric, "utf-8" ),
				javaCast( "int", len( metric ) ),
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
	* I determine if the given key should be skipped due to the given sample rate.
	* 
	* NOTE: Internally, we are using pseudo-random generation to determine if the given
	* metric should be sampled; but, we are passing-in more values than are needed so 
	* that we can change the algorithm later on.
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

		return( randomNumberGenerator.nextFloat() <= rate );

	}

}