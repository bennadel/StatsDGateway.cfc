component
	extends = "UDPTransport"
	output = false
	hint = "I build on the existing UDP transport, but persist the open socket for the duration of the component's lifetime (performance optimization)."
	{

	/**
	* I create a transportation mechanism for sending messages over UDP. The UDP socket
	* is created during initialization and then persisted for the lifetime of the component.
	* This means that the subsequent messages can be sent without having to re-create a socket.
	* This is a small performance optimization; but, it does mean that you have to be careful
	* about managing the transport, calling .destroy() when you are done with it.
	* 
	* @host I am the target host (defaults to localhost).
	* @port I am the target port (defaults to the common statsD port).
	* @output false
	*/
	public any function init(
		string host = "localhost",
		numeric port = 8125
		) {

		super.init( host, port );

		// Persist the socket for the lifetime of the component and keep it open until the
		// component is destroyed.
		socket = createObject( "java", "java.net.DatagramSocket" ).init();

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I close the underlying socket. After this, no more messages can be sent. Subsequent
	* calls to .destroy() are ignored.
	* 
	* @output false
	*/
	public void function destroy() {

		super.destroy();

		if ( ! isSimpleValue( socket ) ) {

			socket.close();
			socket = "";
	
		}

	}


	/**
	* I send the given message over a UDP socket to the target server. Returns [this].
	* 
	* @message I am the message being sent.
	* @output false
	*/
	public any function sendMessage( required string message ) {

		var packet = createObject( "java", "java.net.DatagramPacket" ).init(
			charsetDecode( message, "utf-8" ),
			javaCast( "int", len( message ) ),
			hostInetAddress,
			javaCast( "int", port )
		);

		socket.send( packet );

		return( this );

	}

}