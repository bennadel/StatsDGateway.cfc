
// I am a simple UDP server that will be listening for statsD metrics from the
// ColdFusion gateway for demonstration / testing.

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

// Create our UDP socket that will be listening for incoming messages.
var socket = require( "dgram" ).createSocket( "udp4" );

// Listen for message events on the socket.
socket.on(
	"message",
	function handleMessage( message, requestInfo ) {

		// Log the received message.
		console.log( "UDP Message:", message.toString() );

	}
);

// Log that the socket is ready to receive messages.
socket.on(
	"listening",
	function handleListening() {

		var address = socket.address();

		console.log( "UDP Socket Listening on %s:%d", address.address, address.port );

	}
);


// Start listening on the given port. Since we are not binding to an explicit address
// [just a port], Node.js will aattempt to listen to all addresses on the machine.
socket.bind( 8125 );
