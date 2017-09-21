component
	extends = "TestCase"
	output = false
	hint = "I test the DogStatsDClient component."
	{

	public void function test_that_non_sample_method_calls_work() {

		// Since we want to test the through-put, we are going to manually construct a client
		// that uses a capturing transport rather than a UDP transport.
		var transport = new lib.transport.CaptureTransport();
		var sampler = new lib.sampler.RandomSampler();
		var client = new lib.client.DogStatsDClient( transport, sampler )
			.setPrefix( "head." )
			.setSuffix( ".tail" )
		;

		client
			.count( "a", 1 )
			.count( "b", -2 )
			.increment( "a" )
			.increment( "b", 14 )
			.increment( "c", -4 )
			.decrement( "d" )
			.decrement( "e", 3 )
			.decrement( "f", -2 )
			.gauge( "a", 1 )
			.gauge( "b", 2 )
			.gauge( "c", 3 )
			.incrementGauge( "d", 4 )
			.decrementGauge( "e", 5 )
			.histogram( "a", 1 )
			.histogram( "b", 2 )
			.timing( "a", 100 )
			.timing( "b", 200 )
			.unique( "a", "this" )
			.unique( "b", "that" )
		;

		var sentMessages = transport.getSentMessages();

		var expectedMessages = [
			"head.a.tail:1|c",
			"head.b.tail:-2|c",
			"head.a.tail:1|c",
			"head.b.tail:14|c",
			"head.c.tail:-4|c",
			"head.d.tail:-1|c",
			"head.e.tail:-3|c",
			"head.f.tail:2|c",
			"head.a.tail:1|g",
			"head.b.tail:2|g",
			"head.c.tail:3|g",
			"head.d.tail:+4|g",
			"head.e.tail:-5|g",
			"head.a.tail:1|h",
			"head.b.tail:2|h",
			"head.a.tail:100|ms",
			"head.b.tail:200|ms",
			"head.a.tail:this|s",
			"head.b.tail:that|s"
		];

		assert( serializeJson( sentMessages ) == serializeJson( expectedMessages ) );
		
	}


	public void function test_that_sampling_method_calls_work() {

		// Since we want to test the through-put, we are going to manually construct a client
		// that uses a capturing transport rather than a UDP transport.
		var transport = new lib.transport.CaptureTransport();
		var sampler = new lib.sampler.RandomSampler();
		var client = new lib.client.DogStatsDClient( transport, sampler )
			.setPrefix( "head." )
			.setSuffix( ".tail" )
		;

		client
			.count( "ck", 1, 0.5 )
			.count( "ck", 1, 0.5 )
			.count( "ck", 1, 0.5 )
			.count( "ck", 1, 0.5 )
			.count( "ck", 1, 0.5 )
			.count( "ck", 1, 0.5 )
			.count( "ck", 1, 0.5 )
			.count( "ck", 1, 0.5 )
			.count( "ck", 1, 0.5 )
			.count( "ck", 1, 0.5 )

			.increment( "ik", 2, 0.5 )
			.increment( "ik", 2, 0.5 )
			.increment( "ik", 2, 0.5 )
			.increment( "ik", 2, 0.5 )
			.increment( "ik", 2, 0.5 )
			.increment( "ik", 2, 0.5 )
			.increment( "ik", 2, 0.5 )
			.increment( "ik", 2, 0.5 )
			.increment( "ik", 2, 0.5 )
			.increment( "ik", 2, 0.5 )
			
			.decrement( "dk", 3, 0.5 )
			.decrement( "dk", 3, 0.5 )
			.decrement( "dk", 3, 0.5 )
			.decrement( "dk", 3, 0.5 )
			.decrement( "dk", 3, 0.5 )
			.decrement( "dk", 3, 0.5 )
			.decrement( "dk", 3, 0.5 )
			.decrement( "dk", 3, 0.5 )
			.decrement( "dk", 3, 0.5 )
			.decrement( "dk", 3, 0.5 )

			.histogram( "hk", 7, 0.5 )
			.histogram( "hk", 7, 0.5 )
			.histogram( "hk", 7, 0.5 )
			.histogram( "hk", 7, 0.5 )
			.histogram( "hk", 7, 0.5 )
			.histogram( "hk", 7, 0.5 )
			.histogram( "hk", 7, 0.5 )
			.histogram( "hk", 7, 0.5 )
			.histogram( "hk", 7, 0.5 )
			.histogram( "hk", 7, 0.5 )

			.timing( "tk", 7, 0.5 )
			.timing( "tk", 7, 0.5 )
			.timing( "tk", 7, 0.5 )
			.timing( "tk", 7, 0.5 )
			.timing( "tk", 7, 0.5 )
			.timing( "tk", 7, 0.5 )
			.timing( "tk", 7, 0.5 )
			.timing( "tk", 7, 0.5 )
			.timing( "tk", 7, 0.5 )
			.timing( "tk", 7, 0.5 )
		;

		var sentMessages = transport.getSentMessages();

		// Since sampling won't sent every message, we are going to assert that less than 
		// 100% of the incoming metrics were sent to the UDP server.
		assert( arrayLen( sentMessages ) < 90 );

		var expectedMessages = [
			"head.ck.tail:1|c|@0.50",
			"head.ik.tail:2|c|@0.50",
			"head.dk.tail:-3|c|@0.50",
			"head.hk.tail:7|h|@0.50",
			"head.tk.tail:7|ms|@0.50"
		];

		// Since sampling doesn't send every metric, it's hard for us to say *exactly* what
		// messages have been sent. But, we can safely assume that each metric was sent at
		// least once (statistically speaking).
		for ( var message in sentMessages ) {

			if ( arrayLen( expectedMessages ) && ( expectedMessages[ 1 ] == message ) ) {

				arrayDeleteAt( expectedMessages, 1 );

			}

		}

		assert( ! arrayLen( expectedMessages ) );

	}


	public void function test_that_tag_methods_work() {

		// Since we want to test the through-put, we are going to manually construct a client
		// that uses a capturing transport rather than a UDP transport.
		var transport = new lib.transport.CaptureTransport();
		var sampler = new lib.sampler.RandomSampler();
		var client = new lib.client.DogStatsDClient( transport, sampler )
			.setPrefix( "head." )
			.setSuffix( ".tail" )
			.setTags( [ "first:a", "first-b" ] )
		;

		client.count( "ck", 1, 1 );
		client.count( "ck", 1, [ "ct" ] );
		client.count( "ck", 1, 1, [ "ct" ] );
		client.count( "ck", 1, 1, [ "ct", "ct2" ] );
		client.increment( "ick", 1, 1 );
		client.increment( "ick", 1, [ "ict" ] );
		client.increment( "ick", 1, 1, [ "ict" ] );
		client.decrement( "dck", 1, 1 );
		client.decrement( "dck", 1, [ "dct" ] );
		client.decrement( "dck", 1, 1, [ "dct" ] );
		client.gauge( "gk", 1 );
		client.gauge( "gk", 1, [ "gt" ] );
		client.incrementGauge( "gk", 1 );
		client.incrementGauge( "gk", 1, [ "gt" ] );
		client.decrementGauge( "gk", 1 );
		client.decrementGauge( "gk", 1, [ "gt" ] );
		client.histogram( "hk", 1, 1 );
		client.histogram( "hk", 1, [ "ht" ] );
		client.histogram( "hk", 1, 1, [ "ht" ] );
		client.timing( "tk", 1, 1 );
		client.timing( "tk", 1, [ "tt" ] );
		client.timing( "tk", 1, 1, [ "tt" ] );
		client.unique( "uk", "uv" );
		client.unique( "uk", "uv", [ "ut" ] );

		var sentMessages = transport.getSentMessages();

		var expectedMessages = [
			"head.ck.tail:1|c|##first:a,first-b",
			"head.ck.tail:1|c|##first:a,first-b,ct",
			"head.ck.tail:1|c|##first:a,first-b,ct",
			"head.ck.tail:1|c|##first:a,first-b,ct,ct2",
			"head.ick.tail:1|c|##first:a,first-b",
			"head.ick.tail:1|c|##first:a,first-b,ict",
			"head.ick.tail:1|c|##first:a,first-b,ict",
			"head.dck.tail:-1|c|##first:a,first-b",
			"head.dck.tail:-1|c|##first:a,first-b,dct",
			"head.dck.tail:-1|c|##first:a,first-b,dct",
			"head.gk.tail:1|g|##first:a,first-b",
			"head.gk.tail:1|g|##first:a,first-b,gt",
			"head.gk.tail:+1|g|##first:a,first-b",
			"head.gk.tail:+1|g|##first:a,first-b,gt",
			"head.gk.tail:-1|g|##first:a,first-b",
			"head.gk.tail:-1|g|##first:a,first-b,gt",
			"head.hk.tail:1|h|##first:a,first-b",
			"head.hk.tail:1|h|##first:a,first-b,ht",
			"head.hk.tail:1|h|##first:a,first-b,ht",
			"head.tk.tail:1|ms|##first:a,first-b",
			"head.tk.tail:1|ms|##first:a,first-b,tt",
			"head.tk.tail:1|ms|##first:a,first-b,tt",
			"head.uk.tail:uv|s|##first:a,first-b",
			"head.uk.tail:uv|s|##first:a,first-b,ut"
		];

		assert( serializeJson( sentMessages ) == serializeJson( expectedMessages ) );

	}


	public void function test_that_destroy_method_propagates_to_capture_transport() {

		var transport = new lib.transport.CaptureTransport();
		var sampler = new lib.sampler.RandomSampler();
		var client = new lib.client.DogStatsDClient( transport, sampler );

		assert( ! client.isDestroyed() );
		assert( ! transport.isDestroyed() );
		assert( ! sampler.isDestroyed() );

		client.destroy();

		assert( client.isDestroyed() );
		assert( transport.isDestroyed() );
		assert( sampler.isDestroyed() );

	}


	public void function test_that_destroy_method_propagates_to_persistent_transport() {

		var transport = new lib.transport.PersistentUDPTransport();
		var sampler = new lib.sampler.RandomSampler();
		var client = new lib.client.DogStatsDClient( transport, sampler );

		assert( ! client.isDestroyed() );
		assert( ! transport.isDestroyed() );
		assert( ! sampler.isDestroyed() );

		client.destroy();

		assert( client.isDestroyed() );
		assert( transport.isDestroyed() );
		assert( sampler.isDestroyed() );

	}


	public void function test_that_destroy_method_propagates_to_udp_transport() {

		var transport = new lib.transport.UDPTransport();
		var sampler = new lib.sampler.RandomSampler();
		var client = new lib.client.DogStatsDClient( transport, sampler );

		assert( ! client.isDestroyed() );
		assert( ! transport.isDestroyed() );
		assert( ! sampler.isDestroyed() );

		client.destroy();

		assert( client.isDestroyed() );
		assert( transport.isDestroyed() );
		assert( sampler.isDestroyed() );

	}

}
