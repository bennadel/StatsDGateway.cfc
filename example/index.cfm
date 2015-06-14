<cfscript>
	
	// Param the incoming variables.
	param name="url.action" type="string" default="";
	param name="url.key" type="string" default="";
	param name="url.value" type="string" default="";
	param name="url.rate" type="numeric" default="1";

	// Check to see which action we are sending.
	if ( url.action == "count" ) {

		application.statsdClient.count( key, value, rate );

	} else if ( url.action == "increment" ) {

		application.statsdClient.increment( key, value, rate );

	} else if ( url.action == "decrement" ) {

		application.statsdClient.decrement( key, value, rate );

	} else if ( url.action == "gauge" ) {

		application.statsdClient.gauge( key, value, rate );

	} else if ( url.action == "incrementGauge" ) {

		application.statsdClient.incrementGauge( key, value, rate );

	} else if ( url.action == "decrementGauge" ) {

		application.statsdClient.decrementGauge( key, value, rate );

	} else if ( url.action == "timing" ) {

		application.statsdClient.timing( key, value, rate );

	} else if ( url.action == "unique" ) {

		application.statsdClient.unique( key, value, rate );

	}

</cfscript>

<!--- Reset the output buffer. --->
<cfcontent type="text/html; charset=utf-8" />

<cfoutput>

	<!doctype html>
	<html>
	<head>
		<meta charset="utf-8" />

		<title>statsdClient.cfc Example</title>
	</head>
	<body>

		<h1>
			statsdClient.cfc Example
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
				<a href="#cgi.script_name#?action=decrementGauge&key=foo&value=6">Decrement Gauge "foo" 6</a>
			</li>
			<li>
				<a href="#cgi.script_name#?action=timing&key=foo&value=250">Timing "foo" 250ms</a>
			</li>
			<li>
				<a href="#cgi.script_name#?action=unique&key=userids&value=1">Unique "userids" 1</a>
			</li>
			<li>
				<a href="#cgi.script_name#?action=unique&key=userids&value=2">Unique "userids" 2</a>
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
				<a href="#cgi.script_name#?action=count&key=foo&value=-1&rate=0.5">Sample (0.5) Count "foo" -1</a>
			</li>
			<li>
				<a href="#cgi.script_name#?action=timing&key=foo&value=300&rate=0.5">Sample (0.5) Timing "foo" 300ms</a>
			</li>
		</ul>

	</body>
	</html>

</cfoutput>