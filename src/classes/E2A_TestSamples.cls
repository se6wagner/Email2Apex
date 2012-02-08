/**
 * Test class for
 *
 * E2A_SampleBatch1
 * E2A_SampleBatch2
 * 
 */
@isTest
private class E2A_TestSamples
{

	static E2A_CONFIG__c config;

	private static void startTest(Boolean doStart)
	{

		if(config == null)
		{

			// find an OWEA for our config
			List<OrgWideEmailAddress> owea = [
				select Id
				  from OrgWideEmailAddress
				 where IsAllowAllProfiles = true 
				 limit 1];


			// new org default config
			config = new E2A_CONFIG__c();
			config.TO_ADDRESS__c = 'e2a_test@domain.test';
			config.CC_ADDRESSES__c = 'e2a_cc@domain.test';
			config.ORG_WIDE_EMAIL_ADDRESS_ID__c =
						!owea.isEmpty() ? owea[0].Id : null;
			config.SetupOwnerId = UserInfo.getOrganizationId();
			database.upsert(config,false);
			//upsert config;
			system.debug('####CONFIG ' + config);
		}

		if(doStart)
		{
			Test.startTest();
		}

	}


	private static testMethod void testBatch1()
	{

		startTest(true);
		Database.executeBatch(new E2A_SampleBatch1(),200);
		Test.stopTest();

	}


	private static testMethod void testBatch2()
	{

		startTest(true);

		E2A_SampleBatch2 b2 = new E2A_SampleBatch2();
		b2.e2a_execute();

		Test.stopTest();
	}

	private static testMethod void testBatch2WithParams()
	{
		
		startTest(false);

		// Init new ParamsObj
		E2A_SampleParamsObj paramsObj = new E2A_SampleParamsObj();
		paramsObj.accountList = new List<Account>();
		for(Integer i = 0;i<20;i++)
		{
			paramsObj.accountList.add(new Account(Name = 'Account ' + i));
		}

		Object params = JSON.serializePretty(paramsObj);

		// new instance handling execution
		E2A_SampleBatch2 b2 = new E2A_SampleBatch2();

		Test.startTest();

		b2.e2a_setParams(params);
		b2.e2a_execute();

		Test.stopTest();

	}
}