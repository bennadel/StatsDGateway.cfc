component
	output = false
	hint = "I buffer messages and then send them to the given transport after the exceed a certain length."
	{

	/**
	* I proxy a transport instance, buffering messages until they reach the given max 
	* length. At that point, the buffered messages a concatenated into a single message
	* and sent to the transport.
	* 
	* @transport I am the transport being used to send the messages.
	* @maxLength I am the max length the buffered message can reach before it is sent.
	* @output false
	*/
	public any function init(
		required any transport,
		required any maxLength
		) {

		// Store private properties. 
		setTransport( transport );
		setMaxLength( maxLength );

		// I am the collection of buffered messages.
		messages = [];

		// I am the running total of the message length (ie, what the length of the 
		// concatenated messages would be).
		runningLength = 0;

		// The buffered messages are joined using the New Line when they are sent to 
		// the underlying transport implementation.
		delimiter = chr( 10 );

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I destroy the underlying transport. After this, no more messages can be sent. 
	* Subsequent calls to .destroy() are ignored.
	* 
	* @output false
	*/
	public void function destroy() {

		if ( isSimpleValue( transport ) ) {

			return;

		}
		
		transport.destroy();
		transport = "";
		maxLength = 0;
		messages = "";
		runningLength = 0;
		delimiter = "";
	
	}


	/**
	* I determine if the transport has been destroyed. If so, no more messages can be sent.
	* 
	* @output false
	*/
	public boolean function isDestroyed() {

		return( isSimpleValue( transport ) );

	}


	/**
	* I send the given message over the given transport. Messages will be buffered until 
	* they exceed the current maxLength value. Returns [this].
	* 
	* @message I am the message being sent.
	* @output false
	*/
	public any function sendMessage( required string message ) {

		// If we already have buffered messages, check to see if adding the new message 
		// will exceed the maximum length. If so, let's send out the buffered messages
		// before we push the new one onto the buffer.
		if ( 
			runningLength &&
			( ( runningLength + len( delimiter ) + len( message ) ) > maxLength )
			) {

			transport.sendMessage( arrayTolist( messages, delimiter ) );

			messages = [];
			runningLength = 0;

		}

		runningLength += ( ( runningLength ? len( delimiter ) : 0 ) + len( message ) );

		arrayAppend( messages, message );

		return( this );

	}


	/**
	* I set the max length of the buffered message. Returns [this].
	* 
	* @newMaxLength I am the new max length of the buffered message.
	* @output false
	*/
	public any function setMaxLength( required numeric newMaxLength ) {

		testMaxLength( newMaxLength );

		maxLength = newMaxLength;

		return( this );

	}

	/**
	* I set the transport implementation. Returns [this].
	* 
	* @newTransport I am the new transport implementation being set.
	* @output false
	*/
	public any function setTransport( required any newTransport ) {

		testTransport( newTransport );

		transport = newTransport;

		return( this );

	}


	/**
	* I test the given max length. If the value is invalid, I throw an error; otherwise,
	* I just return quietly.
	* 
	* @newMaxLength I am the new max length being tested.
	* @output false
	*/
	public void function testMaxLength( required numeric newMaxLength ) {

		if ( newMaxLength <= 0 ) {

			throw(
				type = "BufferedTransport.InvalidMaxLength",
				message = "The given max length is invalid.",
				detail = "The max length [#newMaxLength#] cannot be less than or equal to zero."
			);

		}

	}


	/**
	* I test the given transport. If the value is invalid, I throw an error; otherwise,
	* I just return quietly.
	* 
	* @newTransport I am the new transport being tested.
	* @output false
	*/
	public void function testTransport( required any newTransport ) {

		// ... other than testing method signatures, no way to validate.

	}

}