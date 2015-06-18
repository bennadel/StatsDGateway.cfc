component
	output = false
	hint = "I provide a ColdFusion gateway to a StatsD server."
	{

	/**
	* I initialize the statsD gateway. The gateway doesn't actually do the communication; it
	* creates clients that do.
	* 
	* @output false
	*/
	public any function init() {

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I create a client that communicates with the statsD server over UDP.
	* 
	* @host I am the statsD host address (defaults to localhost).
	* @port I am the port that the statsD server is listening on (defaults to common statsD port).
	* @prefix I am the prefix to prepend to all metric keys.
	* @suffix I am the suffix to append to all metric keys.
	* @persistent I indicate the UDP socket should be persisted (required .destroy() to be called when done).
	* @maxLength I indicate that messages should be buffered (to the given length) before being sent.
	* @output false
	*/
	public any function createClient(
		string host = "localhost",
		numeric port = 8125,
		string prefix = "",
		string suffix = "",
		boolean persistent = false,
		numeric maxLength = 0
		) {

		if ( persistent ) {

			var transport = new transport.PersistentUDPTransport( host, port );

		} else {

			var transport = new transport.UDPTransport( host, port );

		}

		if ( maxLength ) {

			transport = new transport.BufferedTransport( transport, maxLength );

		}

		var sampler = new sampler.RandomSampler();

		var client = new client.StatsDClient( transport, sampler, prefix, suffix );

		return( client );

	}

}