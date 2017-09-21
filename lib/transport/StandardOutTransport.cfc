component
	output = false
	hint = "I send the outgoing messages the standard out stream."
	{

	/**
	* I create a transportation mechanism for sending messages to the standard out
	* stream. If a JSON key is provided, the message will be wrapped in a JSON log item.
	* If no JSON key is provided, the message will be written as-is.
	* 
	* @output false
	*/
	public any function init( string jsonKey = "" ) {

		// If a JSON key is provided, all messages will be wrapped in a JSON payload 
		// before being flushed to the output.
		variables.jsonKey = arguments.jsonKey;

		// This is the stdout owned by the current ColdFusion process.
		stdout = createObject( "java", "java.lang.System" ).out;

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I destroy the transport, cleaning up any data that needs to be cleaned up. Subsequent
	* calls to .destroy() are ignored.
	* 
	* @output false
	*/
	public void function destroy() {

		// ... I don't think we want to mess with the stream. Since the standard out 
		// stream is owned by ColdFusion, we'll assume that the application server is
		// taking care of the stream.
		stdout = "";

	}


	/**
	* I determine if the transport has been destroyed.
	* 
	* @output false
	*/
	public boolean function isDestroyed() {

		return( isSimpleValue( stdout ) );

	}


	/**
	* I send the given message to the standard output stream. Returns [this].
	* 
	* @message I am the message being sent.
	* @output false
	*/
	public any function sendMessage( required string message ) {

		var payload = len( jsonKey )
			? serializeJson({ "#jsonKey#": message })
			: message
		;

		stdout.println( javaCast( "string", payload ) );

		return( this );

	}

}
