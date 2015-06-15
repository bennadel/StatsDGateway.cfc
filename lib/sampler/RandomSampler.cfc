component
	output = false
	hint = "I provide a sampling strategy based on pseudo-random number generation."
	{

	/**
	* I initialize the sampler.
	* 
	* @output false
	*/
	public any function init() {

		generator = createObject( "java", "java.util.Random" )
			.init( javaCast( "long", getTickCount() ) )
		;

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I determine if the given key should be skipped due to the given sample rate.
	* 
	* @rate I am the sample rate for the given key.
	* @metric I am the statsD metric type being sampled.
	* @key I am the statsD metric key being sampled.
	* @output false
	*/
	public boolean function shouldSkip(
		required numeric rate,
		required string metric,
		required string key
		) {

		if ( rate == 1 ) {

			return( false );

		}

		return( generator.nextFloat() <= rate );

	}

}