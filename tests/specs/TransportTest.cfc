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


	public void function test_that_messages_can_be_sent_over_buffered_transport() {

		var transport = new lib.transport.CaptureTransport();
		var bufferedTransport = new lib.transport.BufferedTransport( transport, 1 );

		transport.sendMessage( "this should work" );

		transport.destroy();

	}


	public void function test_that_messages_cannot_be_sent_over_destroyed_buffered_transport() {

		var transport = new lib.transport.CaptureTransport();
		var bufferedTransport = new lib.transport.BufferedTransport( transport, 1 );

		bufferedTransport.destroy();

		assert( bufferedTransport.isDestroyed() );

		try {

			bufferedTransport.sendMessage( "this should fail" );
			
		} catch ( any error ) {

			return;

		}

		// If we made it this far, something went wrong.
		assert( false );

	}


	public void function test_that_buffered_transport_buffers_messages() {

		var transport = new lib.transport.CaptureTransport();
		var bufferedTransport = new lib.transport.BufferedTransport( transport, 10 );
		var newline = chr( 10 );

		bufferedTransport.sendMessage( "123" );
		bufferedTransport.sendMessage( "123" );
		bufferedTransport.sendMessage( "12345678" );
		bufferedTransport.sendMessage( "123456789012345" );
		bufferedTransport.sendMessage( "1" );
		bufferedTransport.sendMessage( "2" );
		bufferedTransport.sendMessage( "3" );
		bufferedTransport.sendMessage( "4" );
		bufferedTransport.sendMessage( "5" );
		bufferedTransport.sendMessage( "6" );
		bufferedTransport.sendMessage( "7" );
		bufferedTransport.sendMessage( "8" );
		bufferedTransport.sendMessage( "9" );
		bufferedTransport.sendMessage( "0" );
		bufferedTransport.sendMessage( "1" );
		bufferedTransport.sendMessage( "123456789012345" );

		var sentMessages = transport.getSentMessages();

		assert( arrayLen( sentMessages ) == 6 );
		assert( sentMessages[ 1 ] == "123#newline#123" );
		assert( sentMessages[ 2 ] == "12345678" );
		assert( sentMessages[ 3 ] == "123456789012345" );
		assert( sentMessages[ 4 ] == "1#newline#2#newline#3#newline#4#newline#5" );
		assert( sentMessages[ 5 ] == "6#newline#7#newline#8#newline#9#newline#0" );
		assert( sentMessages[ 6 ] == "1" );

	}


	public void function test_that_messages_can_be_sent_over_standard_out_transport() {

		var transport = new lib.transport.StandardOutTransport();

		transport.sendMessage( "this should work" );
		transport.destroy();

		var transport = new lib.transport.StandardOutTransport( "metric" );

		transport.sendMessage( "this ""should"" work" );
		transport.destroy();

	}


	public void function test_that_messages_cannot_be_sent_over_destroyed_standard_out_transport() {

		var transport = new lib.transport.StandardOutTransport();

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
