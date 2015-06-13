component
	extends = "TestCase"
	output = false
	hint = "I test the StatsDGateway component."
	{

	public void function testNonSampleMethods() {

		// NOTE: This is the sub-classed version that captures the messages instead
		// of sending them over UDP.
		var gateway = new testables.StatsDGateway()
			.setPrefix( "head." )
			.setSuffix( ".tail" )
		;

		gateway
			.count( "a", 1 )
			.count( "b", -2 )
			.increment( "c" )
			.increment( "d", 14 )
			.increment( "e", -4 )
			.decrement( "f" )
			.decrement( "g", 3 )
			.decrement( "h", -2 )
			.gauge( "i", 1 )
			.gauge( "j", 2 )
			.gauge( "k", 3 )
			.incrementGauge( "l", 4 )
			.decrementGauge( "m", 5 )
			.timing( "n", 100 )
			.timing( "o", 200 )
			.unique( "p", "this" )
			.unique( "q", "that" )
		;

		var sentMessages = gateway.getSentMessages();

		var expectedMessages = [
			"head.a.tail:1|c",
			"head.b.tail:-2|c",
			"head.c.tail:1|c",
			"head.d.tail:14|c",
			"head.e.tail:-4|c",
			"head.f.tail:-1|c",
			"head.g.tail:-3|c",
			"head.h.tail:2|c",
			"head.i.tail:1|g",
			"head.j.tail:2|g",
			"head.k.tail:3|g",
			"head.l.tail:+4|g",
			"head.m.tail:-5|g",
			"head.n.tail:100|ms",
			"head.o.tail:200|ms",
			"head.p.tail:this|s",
			"head.q.tail:that|s"
		];

		assert( serializeJson( sentMessages ) == serializeJson( expectedMessages ) );
		
	}


	public void function testSampleMethods() {

		// NOTE: This is the sub-classed version that captures the messages instead
		// of sending them over UDP.
		var gateway = new testables.StatsDGateway()
			.setPrefix( "head." )
			.setSuffix( ".tail" )
		;

		gateway
			.count( "a", 1, 0.5 )
			.count( "a", 1, 0.5 )
			.count( "a", 1, 0.5 )
			.count( "a", 1, 0.5 )
			.count( "a", 1, 0.5 )
			.count( "a", 1, 0.5 )
			.count( "a", 1, 0.5 )
			.count( "a", 1, 0.5 )
			.count( "a", 1, 0.5 )
			.count( "a", 1, 0.5 )

			.increment( "b", 2, 0.5 )
			.increment( "b", 2, 0.5 )
			.increment( "b", 2, 0.5 )
			.increment( "b", 2, 0.5 )
			.increment( "b", 2, 0.5 )
			.increment( "b", 2, 0.5 )
			.increment( "b", 2, 0.5 )
			.increment( "b", 2, 0.5 )
			.increment( "b", 2, 0.5 )
			.increment( "b", 2, 0.5 )
			
			.decrement( "c", 3, 0.5 )
			.decrement( "c", 3, 0.5 )
			.decrement( "c", 3, 0.5 )
			.decrement( "c", 3, 0.5 )
			.decrement( "c", 3, 0.5 )
			.decrement( "c", 3, 0.5 )
			.decrement( "c", 3, 0.5 )
			.decrement( "c", 3, 0.5 )
			.decrement( "c", 3, 0.5 )
			.decrement( "c", 3, 0.5 )

			.gauge( "d", 4, 0.5 )
			.gauge( "d", 4, 0.5 )
			.gauge( "d", 4, 0.5 )
			.gauge( "d", 4, 0.5 )
			.gauge( "d", 4, 0.5 )
			.gauge( "d", 4, 0.5 )
			.gauge( "d", 4, 0.5 )
			.gauge( "d", 4, 0.5 )
			.gauge( "d", 4, 0.5 )
			.gauge( "d", 4, 0.5 )

			.incrementGauge( "e", 5, 0.5 )
			.incrementGauge( "e", 5, 0.5 )
			.incrementGauge( "e", 5, 0.5 )
			.incrementGauge( "e", 5, 0.5 )
			.incrementGauge( "e", 5, 0.5 )
			.incrementGauge( "e", 5, 0.5 )
			.incrementGauge( "e", 5, 0.5 )
			.incrementGauge( "e", 5, 0.5 )
			.incrementGauge( "e", 5, 0.5 )
			.incrementGauge( "e", 5, 0.5 )

			.decrementGauge( "f", 6, 0.5 )
			.decrementGauge( "f", 6, 0.5 )
			.decrementGauge( "f", 6, 0.5 )
			.decrementGauge( "f", 6, 0.5 )
			.decrementGauge( "f", 6, 0.5 )
			.decrementGauge( "f", 6, 0.5 )
			.decrementGauge( "f", 6, 0.5 )
			.decrementGauge( "f", 6, 0.5 )
			.decrementGauge( "f", 6, 0.5 )
			.decrementGauge( "f", 6, 0.5 )

			.timing( "g", 7, 0.5 )
			.timing( "g", 7, 0.5 )
			.timing( "g", 7, 0.5 )
			.timing( "g", 7, 0.5 )
			.timing( "g", 7, 0.5 )
			.timing( "g", 7, 0.5 )
			.timing( "g", 7, 0.5 )
			.timing( "g", 7, 0.5 )
			.timing( "g", 7, 0.5 )
			.timing( "g", 7, 0.5 )

			.unique( "h", "this", 0.5 )
			.unique( "h", "this", 0.5 )
			.unique( "h", "this", 0.5 )
			.unique( "h", "this", 0.5 )
			.unique( "h", "this", 0.5 )
			.unique( "h", "this", 0.5 )
			.unique( "h", "this", 0.5 )
			.unique( "h", "this", 0.5 )
			.unique( "h", "this", 0.5 )
			.unique( "h", "this", 0.5 )
		;

		var sentMessages = gateway.getSentMessages();

		// Since sampling won't sent every message, we are going to assert that less than 
		// 100% of the incoming metrics were sent to the UDP server.
		assert( arrayLen( sentMessages ) < 80 );

		var expectedMessages = [
			"head.a.tail:1|c|@0.500",
			"head.b.tail:2|c|@0.500",
			"head.c.tail:-3|c|@0.500",
			"head.d.tail:4|g|@0.500",
			"head.e.tail:+5|g|@0.500",
			"head.f.tail:-6|g|@0.500",
			"head.g.tail:7|ms|@0.500",
			"head.h.tail:this|s|@0.500"
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

}