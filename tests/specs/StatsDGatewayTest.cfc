component
	extends = "TestCase"
	output = false
	hint = "I test the StatsDGateway component."
	{

	public void function test_that_create_client_factory_works() {

		var client = new lib.StatsDGateway().createClient();

		client.destroy();

	}


	public void function test_that_create_persisent_client_factory_works() {

		var client = new lib.StatsDGateway().createClient( persistent = true );

		client.destroy();

	}


	public void function test_that_create_buffered_client_factory_works() {

		var client = new lib.StatsDGateway().createClient( maxLength = 10 );

		client.destroy();

	}

}