component
	extends = "TestCase"
	output = false
	hint = "I test the StatsDGateway component."
	{

	public void function test_that_create_client_factory_works() {

		var gateway = new lib.StatsDGateway();
		var defaultClient = gateway.createClient();
		var dogStatsClient = gateway.createDogStatsClient();

		defaultClient.destroy();
		dogStatsClient.destroy();

	}


	public void function test_that_create_persisent_client_factory_works() {

		var gateway = new lib.StatsDGateway();
		var defaultClient = gateway.createClient( persistent = true );
		var dogStatsClient = gateway.createDogStatsClient( persistent = true );

		defaultClient.destroy();
		dogStatsClient.destroy();

	}


	public void function test_that_create_buffered_client_factory_works() {

		var gateway = new lib.StatsDGateway();
		var defaultClient = gateway.createClient( maxLength = 10 );
		var dogStatsClient = gateway.createDogStatsClient( maxLength = 10 );

		defaultClient.destroy();
		dogStatsClient.destroy();

	}

}
