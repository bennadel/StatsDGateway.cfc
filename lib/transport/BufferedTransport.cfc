component
	output = false
	hint = "I store the messages in an internal buffer, rather than sending them to a target server."
	{

	/**
	* I create a transportation mechanism for sending messages to an internal buffer.
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
	* I return the collection of sent messages.
	* 
	* @output false
	*/
	public array function getSentMessages() {

		return( sentMessages );

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