component
	output = false
	hint = "I capture the outgoing messages in an internal buffer, rather than sending them to a target server."
	{

	/**
	* I create a transportation mechanism for sending messages to an internal buffer.
	* These messages can then be retrieved and checked (helpful for testing).
	* 
	* @output false
	*/
	public any function init() {

		sentMessages = [];

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

		sentMessages = "";

	}


	/**
	* I return the collection of sent messages.
	* 
	* @output false
	*/
	public array function getSentMessages() {

		return( sentMessages );

	}


	/**
	* I determine if the transport has been destroyed.
	* 
	* @output false
	*/
	public boolean function isDestroyed() {

		return( isSimpleValue( sentMessages ) );

	}


	/**
	* I send the given message to the internal buffer of sent messages. Returns [this].
	* 
	* @message I am the message being sent.
	* @output false
	*/
	public any function sendMessage( required string message ) {

		arrayAppend( sentMessages, message );

		return( this );

	}

}