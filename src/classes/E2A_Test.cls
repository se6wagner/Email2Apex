@isTest
private class E2A_Test
{

	//--------------------------------------------------------------
	// Setup
	//--------------------------------------------------------------
	private final static String TEST_IMPL_CLASS = 'E2A_TestExecutableImpl';
	static E2A_CONFIG__c config;
	private static void startTest(Boolean doStart)
	{

		if(config == null)
		{
			// test E2A.getE2AConfig() exception before creating new default
			try{
				delete E2A.getE2AConfig();
			} catch(Exception ex)
			{
				system.debug(ex);
			}

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
			system.debug('####CONFIG ' + config);
		}

		if(doStart)
		{
			Test.startTest();
		}
	}

	//--------------------------------------------------------------
	// Setup
	//--------------------------------------------------------------

	/**
	 * Test Clas Name validation
	 */
	private static testMethod void testValidateClassName()
	{

		startTest(true);
		// test isValidClassName with NamespacePrefix
		try
		{
			E2A.isValidClassName('e2aNSP__class');
		}
		catch(E2A.InvalidClassNameException ex)
		{
			system.debug('Caught E2A.InvalidClassNameException');
		}

		system.assert(E2A.isValidClassName('E2A'));

		// getNewE2AMessage
		Object paramsObj = 'PARAMS BODY';
		E2A.getNewE2AMessage(TEST_IMPL_CLASS, paramsObj, true);

		Test.stopTest();
	}

	/**
	 * Tests ParamsAttachmentGetter without serialization
	 */
	private static testMethod void testParamsAttachmentUnserizaled()
	{
		startTest(true);
		Object paramsObj = 'PARAMS BODY';
		Messaging.Emailfileattachment file = 
					E2A.getParamsAttachmentFor(paramsObj, false);

		system.assert(file.getBody().toString() == 'PARAMS BODY');

		Test.stopTest();
	}
	/**
	 * Tests E2A.sendE2AMessage
	 */
	private static testMethod void testSendMessage()
	{
		startTest(true);
		Object paramsObj = 'PARAMS BODY';
		E2A.sendE2AMessage(
			  TEST_IMPL_CLASS
			, paramsObj
			, true
			, true
			, 'Message Body'			
		);

		Test.stopTest();
		
	}

	private static testMethod void testSendMessage2()
	{
		startTest(true);
		E2A.sendE2AMessage(
			  TEST_IMPL_CLASS
			, true
			, 'Message Body'
		);

		Test.stopTest();
	}


	/**
	 * Test Exception for E2A_InboundEmailHandler with wrong class name
	 */
	private static testMethod void testInboundFail()
	{
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		email.Subject = TEST_IMPL_CLASS + '.WRONG_CLASS_NAME';

		startTest(true);

		E2A_InboundEmailHandler handler = new E2A_InboundEmailHandler();
		Messaging.InboundEmailResult res = 	
				handler.handleInboundEmail(email, null);

		system.assert(!res.success);

		Test.stopTest();
	}


	/**
	 * Tests E2A_InboundEmailHandler Subject Support
	 */
	private static testMethod void testInboundSubjectSuccess()
	{
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		email.Subject = TEST_IMPL_CLASS;

		startTest(true);

		E2A_InboundEmailHandler handler = new E2A_InboundEmailHandler();		
		Messaging.InboundEmailResult res = 	
				handler.handleInboundEmail(email, null);

		system.assert(res.success);

		Test.stopTest();
	}


	/**
	 * Tests E2A_InboundEmailHandler Attachment Support
	 */
	private static testMethod void testInboundAttachmentSuccess()
	{

		startTest(false);
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		email.Subject = 'testEmail';
		email.TextAttachments = new List<Messaging.Inboundemail.TextAttachment>();


		// setup class name attachment
		Messaging.InboundEmail.TextAttachment classNameFile =
			new Messaging.InboundEmail.TextAttachment();
		classNameFile.fileName = 'class_name.e2a';
		classNameFile.body = TEST_IMPL_CLASS;

		// setup params attachment
		Messaging.InboundEmail.TextAttachment paramsFile =
			new Messaging.InboundEmail.TextAttachment();
		paramsFile.fileName = E2A.PARAMS_FILE_NAME;
		paramsFile.body = 'PARAMS GO HERE';

		email.TextAttachments = new List<Messaging.Inboundemail.TextAttachment>{
			  classNameFile
			, paramsFile};

		system.debug('ATTACHMENTS ' + email.TextAttachments);

		Test.startTest();

		E2A_InboundEmailHandler handler = new E2A_InboundEmailHandler();		
		Messaging.InboundEmailResult res = 	
				handler.handleInboundEmail(email, null);

		system.assert(res.success);

		Test.stopTest();
	}


}