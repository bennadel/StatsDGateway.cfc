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
	* @output false
	*/
	public any function createClient(
		string host = "localhost",
		numeric port = 8125,
		string prefix = "",
		string suffix = ""
		) {

		var client = new client.StatsDClient(
			new transport.UDPTransport( host, port ),
			new sampler.RandomSampler(),
			prefix,
			suffix
		);

		return( client );

	}


	/**
	* I create a client that communicates with the statsD server over UDP. The underlying
	* UDP socket is persisted until the .destroy() method is called. This makes the client
	* a bit more efficient; but, it puts the burden of maintenance on the consumer.
	* 
	* @host I am the statsD host address (defaults to localhost).
	* @port I am the port that the statsD server is listening on (defaults to common statsD port).
	* @prefix I am the prefix to prepend to all metric keys.
	* @suffix I am the suffix to append to all metric keys.
	* @output false
	*/
	public any function createPersistentClient(
		string host = "localhost",
		numeric port = 8125,
		string prefix = "",
		string suffix = ""
		) {

		var client = new client.StatsDClient(
			new transport.PersistentUDPTransport( host, port ),
			new sampler.RandomSampler(),
			prefix,
			suffix
		);

		return( client );

	}

}