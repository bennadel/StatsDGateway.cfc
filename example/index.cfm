<cfscript>
	
	// Param the incoming variables.
	param name="url.action" type="string" default="";
	param name="url.rate" type="string" default="";
	param name="url.key" type="string" default="";
	param name="url.value" type="string" default="";

	// Check to see which action we are sending.
	if ( url.action == "count" ) {

		application.statsdGateway.count( key, value );

	} else if ( url.action == "increment" ) {

		application.statsdGateway.increment( key, value );

	} else if ( url.action == "decrement" ) {

		application.statsdGateway.decrement( key, value );

	} else if ( url.action == "gauge" ) {

		application.statsdGateway.gauge( key, value );

	} else if ( url.action == "incrementGauge" ) {

		application.statsdGateway.incrementGauge( key, value );

	} else if ( url.action == "decrementGauge" ) {

		application.statsdGateway.decrementGauge( key, value );

	} else if ( url.action == "timing" ) {

		application.statsdGateway.timing( key, value );

	} else if ( url.action == "sampleCount" ) {

		application.statsdGateway.sampleCount( rate, key, value );

	} else if ( url.action == "sampleTiming" ) {

		application.statsdGateway.sampleTiming( rate, key, value );

	}

</cfscript>

<!--- Reset the output buffer. --->
<cfcontent type="text/html; charset=utf-8" />

<cfoutput>

	<!doctype html>
	<html>
	<head>
		<meta charset="utf-8" />

		<title>StatsDGateway.cfc Example</title>
	</head>
	<body>

		<h1>
			StatsDGateway.cfc Example
		</h1>

		<p>
			<strong>Setup</strong>: This example expects the "server.js" node process
			to be running (which is where you will see the output).
		</p>

		<h2>
			Send Metrics
		</h2>

		<ul>
			<li>
				<a href="#cgi.script_name#?action=count&key=foo&value=1">Count "foo" 1</a>
			</li>
			<li>
				<a href="#cgi.script_name#?action=increment&key=foo&value=5">Increment "foo" 5</a>
			</li>
			<li>
				<a href="#cgi.script_name#?action=decrement&key=foo&value=3">Decrement "foo" 3</a>
			</li>
			<li>
				<a href="#cgi.script_name#?action=gauge&key=foo&value=7">Gauge "foo" 7</a>
			</li>
			<li>
				<a href="#cgi.script_name#?action=incrementGauge&key=foo&value=4">Increment Gauge "foo" 4</a>
			</li>
			<li>
				<a href="#cgi.script_name#?action=decrementGauge&key=foo&value=4">Decrement Gauge "foo" 6</a>
			</li>
			<li>
				<a href="#cgi.script_name#?action=timing&key=foo&value=250">Timing "foo" 250ms</a>
			</li>
		</ul>

		<h2>
			Sampling Metrics
		</h2>

		<p>
			Sampling sends metrics, but drops some messages based on the given sample rate (0 &gt; rate &gt; 1).
		</p>

		<ul>
			<li>
				<a href="#cgi.script_name#?action=sampleCount&rate=0.5&key=foo&value=-1">Sample (0.5) Count "foo" -1</a>
			</li>
			<li>
				<a href="#cgi.script_name#?action=sampleTiming&rate=0.5&key=foo&value=300">Timing (0.5) "foo" 300ms</a>
			</li>
		</ul>

	</body>
	</html>

</cfoutput>