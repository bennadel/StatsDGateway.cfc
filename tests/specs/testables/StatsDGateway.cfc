component
	extends = "lib.StatsDGateway"
	output = false
	hint = "I provide a testable version of the StatsDGateway, that doesn't send over UDP."
	{

	/**
	* I sub-class the StatsDGateway.cfc in a way that stores the sent-messages internally
	* rather than sending them over a UDP socket.
	* 
	* @output false
	*/
	public any function init() {

		super.init( argumentCollection = arguments );

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


	// ---
	// PRIVATE METHODS.
	// ---


	/**
	* I OVERRIDE the sendMessage() method, preventing them from going over UDP.
	* 
	* @string I am the message being sent to statsD.
	* @output false
	*/
	private any function sendMessage( required string message ) {

		arrayAppend( sentMessages, message );

		return( this );

	}

}