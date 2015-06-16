component
	extends = "TestCase"
	output = false
	hint = "I test the sampler components."
	{

	public void function test_that_random_sampler_handles_outliers() {

		var sampler = new lib.sampler.RandomSampler();

		// Test outliers.
		assert( ! sampler.shouldSkip( 1, "metric", "key" ) );
		assert( sampler.shouldSkip( 0, "metric", "key" ) );
		
	}


	public void function test_that_random_sampler_distributes_results() {

		var sampler = new lib.sampler.RandomSampler();

		var skippedCount = 0;
		var testCount = 10000;

		for ( var i = 0 ; i < testCount ; i++ ) {

			if ( sampler.shouldSkip( 0.5, "metric", "key ") ) {

				skippedCount++;

			}

		}

		// Test extremes.
		assert( skippedCount != 0 );
		assert( skippedCount != testCount );

		// Test likelihood of middle 50% of the curve.
		assert( skippedCount >= fix( testCount / 4 ) );
		assert( skippedCount <= fix( testCount - ( testCount / 4 ) ) );

	}


	public void function test_that_destroy_works() {

		var sampler = new lib.sampler.RandomSampler();

		sampler.destroy();

		assert( sampler.isDestroyed() );

		try {

			sampler.shouldSkip( 0.5, "metric", "key ");
			
		} catch ( any error ) {

			return;

		}

		// If we made it this far, something went wrong.
		assert( false );

	}

}