component
	output = false
	hint = "I provide random numbers between 0 (inclusive) and 1 (inclusive)."
	{

	/**
	* I initialize the random number generator.
	* 
	* @seed I am the value used to seed the random number generator.
	* @output false
	*/
	public any function init( numeric seed = getTickCount() ) {

		generator = createObject( "java", "java.util.Random" )
			.init( javaCast( "long", seed ) )
		;

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I return the next random value between 0 (inclusive) and 1 (inclusive).
	* 
	* @output false
	*/
	public numeric function nextFloat() {

		return( generator.nextFloat() );

	}

}