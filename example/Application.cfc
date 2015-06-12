component
	output = false
	hint = "I define the application settings and event handlers."
	{

	// I define the application settings.
	this.name = hash( getCurrentTemplatePath() );
	this.applicationTimeout = createTimeSpan( 0, 0, 10, 0 );
	this.sessionManagement = false;

	// Get the various directories needed for mapping.
	this.directory = getDirectoryFromPath( getCurrentTemplatePath() );
	this.projectDirectory = ( this.directory & "../" );

	// Map the library so we can instantiate components.
	this.mappings[ "/lib" ] = "#this.projectDirectory#lib/";


	/**
	* I initialize the application.
	* 
	* @output false
	*/
	public boolean function onApplicationStart() {

		// Cache an instance of our StatsDGateway. This is the same host and port that
		// our node.js server is going to be bound to.
		application.statsdGateway = new lib.StatsDGateway( "127.0.0.1", 8125 );

		// Return true so the application can load.
		return( true );

	}


	/**
	* I initialize the request.
	* 
	* @scriptName I am the script being requested.
	* @output false
	*/
	public boolean function onRequestStart( required string scriptName ) {

		// Check to see if we need to reset the application.
		if ( structKeyExists( url, "init" ) ) {

			onApplicationStart();

			writeOutput( "Application initialized." );
			abort;

		}

		// Return true so the request can load.
		return( true );

	}

}