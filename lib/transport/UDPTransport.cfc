component
	output = false
	hint = "I transport the given message over UDP. The socket is opened and closed for each message, removing the ability to maintain the connection."
	{

	/**
	* I create a transportation mechanism for sending messages over UDP.
	* 
	* @host I am the target host (defaults to localhost).
	* @port I am the target port (defaults to the common statsD port).
	* @output false
	*/
	public any function init(
		string host = "localhost",
		numeric port = 8125
		) {

		// Store private properties. 
		setHost( host );
		setPort( port );

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I send the given message over a UDP socket to the target server. Returns [this].
	* 
	* @message I am the message being sent.
	* @output false
	*/
	public any function sendMessage( required string message ) {

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
	* I validate and set the host address. Returns [this].
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
	* I validate and set the port. Returns [this].
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
	* I test the given host address. If the value is invalid, I throw an error; otherwise,
	* I just return quietly.
	* 
	* @newHost I am the new host being tested.
	* @output false
	*/
	public void function testHost( required string newHost ) {

		if ( ! len( newHost ) ) {

			throw(
				type = "UDPTransport.InvalidHost",
				message = "The given host is invalid.",
				detail = "The host cannot be empty."
			);

		}

		if ( newHost != trim( newHost ) ) {

			throw(
				type = "UDPTransport.InvalidHost",
				message = "The given host is invalid.",
				detail = "The host cannot contain leading or trailing whitespace."
			);

		}

	}


	/**
	* I test the given port. If the value is invalid, I throw an error; otherwise, I just
	* return quietly.
	* 
	* @newPort I am the new port being tested.
	* @output false
	*/
	public void function testPort( required numeric newPort ) {

		// ... there's not much that can make a port strictly invalid.

	}

}