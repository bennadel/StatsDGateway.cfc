component
	extends = "TestCase"
	output = false
	hint = "I test the transport components."
	{

	public void function test_that_messages_can_be_sent_over_capture_transport() {

		var transport = new lib.transport.CaptureTransport();

		transport.sendMessage( "this should work" );

		var sentMessages = transport.getSentMessages();

		assert( sentMessages[ 1 ] == "this should work" );

		transport.destroy();

	}


	public void function test_that_messages_cannot_be_sent_over_destroyed_capture_transport() {

		var transport = new lib.transport.CaptureTransport();

		transport.destroy();

		assert( transport.isDestroyed() );

		try {

			transport.sendMessage( "this should fail" );
			
		} catch ( any error ) {

			return;

		}

		// If we made it this far, something went wrong.
		assert( false );

	}


	public void function test_that_messages_can_be_sent_over_persisted_transport() {

		var transport = new lib.transport.PersistentUDPTransport();

		// Since UDP doesn't wait for a response, this shouldn't throw an error, even when
		// no statsD server is running.
		transport.sendMessage( "this should work" );

		transport.destroy();

	}


	public void function test_that_messages_cannot_be_sent_over_destroyed_persistent_transport() {

		var transport = new lib.transport.PersistentUDPTransport();

		transport.destroy();

		assert( transport.isDestroyed() );

		try {

			transport.sendMessage( "this should fail" );
			
		} catch ( any error ) {

			return;

		}

		// If we made it this far, something went wrong.
		assert( false );

	}


	public void function test_that_messages_can_be_sent_over_udp_transport() {

		var transport = new lib.transport.UDPTransport();

		// Since UDP doesn't wait for a response, this shouldn't throw an error, even when
		// no statsD server is running.
		transport.sendMessage( "this should work" );

		transport.destroy();

	}


	public void function test_that_messages_cannot_be_sent_over_destroyed_udp_transport() {

		var transport = new lib.transport.UDPTransport();

		transport.destroy();

		assert( transport.isDestroyed() );

		try {

			transport.sendMessage( "this should fail" );
			
		} catch ( any error ) {

			return;

		}

		// If we made it this far, something went wrong.
		assert( false );

	}

}