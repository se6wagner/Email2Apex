/**
 * E2A - Email 2 Apex
 *
 */
global class E2A
{


	//--------------------------------------------------------------
	// CONSTANTS && VARIABLES
	//--------------------------------------------------------------
	global static final String CLASS_NAME_FILE_NAME = 'class_name.e2a';
	global static final String PARAMS_FILE_NAME = 'param_class.json.e2a';

	static E2A_CONFIG__c E2A_CONFIG;

	/**
	 * getE2AConfig  
	 *
	 * Returns the OrgDefault setting from E2A_CONFIG__c
	 *
	 * @throws
	 *					: ConfigNotFoundException
	 * @returns E2A_CONFIG__c
	 */
	global static E2A_CONFIG__c getE2AConfig()
	{
		if (E2A_CONFIG == null)
		{
			E2A_CONFIG = E2A_CONFIG__c.getOrgDefaults();
			if (E2A_CONFIG == null)
			{
				throw new ConfigNotFoundException
				('No E2A_CONFIG record found. Go to custom settings and create one');
			}
		}
		return E2A_CONFIG;
	}

	//--------------------------------------------------------------
	// EXCEPTIONS
	//--------------------------------------------------------------
	global class ConfigNotFoundException extends Exception {}
	global class InvalidClassNameException extends Exception{}
	global class OutboundEmailException extends Exception {}

	//--------------------------------------------------------------
	// INTERFACES
	//--------------------------------------------------------------
	/**
	 * Executeable
	 *
	 * Interface class supporting parameters have to implement
	 *
	 */
	global virtual interface Executeable
	{
		void e2a_execute();
	}

	/**
	 * ExecuteableWithParams
	 *
	 * Interface class supporting parameters have to implement
	 *
	 */
	global interface ExecuteableWithParams extends Executeable
	{

		void e2a_setParams(Object paramsObject);

	}


	//--------------------------------------------------------------
	// API METHODS
	//--------------------------------------------------------------

	/**
	 * sendE2AMessage
	 *
	 * Initialzies an E2A_Executable class defined by it className using
	 * params defined by params parameters
	 *
	 * @params emailBody
	 *					: Plain Text Body to set
	 * @params className
	 *					: Name of the Apex class to execute
	 * @params paramsObj
	 *					: Object holding parameters used by the executed class
	 * @params doSerialze
	 *					: True serializes the paramsObj to JSON
	 * @params checkResult
	 *					: True to throw an Exception if result is negativ
	 *
	 * @throw OutboundEmailException
	 */
	global static void sendE2AMessage(
		  String emailBody
		, String className
		, Object paramsObj
		, Boolean doSerialze
		, Boolean checkResult)
	{

		// init new Message 
		Messaging.SinglEemailMessage email = 
				getNewE2AMessage(className,paramsObj,doSerialze);

		// sent
		Messaging.SendEmailResult res =
				Messaging.sendEmail(
					new Messaging.SinglEemailMessage[]{email}).get(0);

		if (checkResult && !res.isSuccess()) 
		{
			throw new OutboundEmailException(res.getErrors()[0].getMessage());
		}

	}


	/**
	 *
	 *
	 */
	global static Messaging.SinglEemailMessage getNewE2AMessage(
		  String className
		, Object paramsObj
		, Boolean doSerialze)
	{

		// new Message Object
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setSubject('E2A Message: ' + className);
		mail.setPlainTextBody('Email2Batch Message');

		// Load config to set addresses
		E2A_CONFIG__c config = getE2AConfig();
		mail.setToAddresses(new List<String>{config.TO_ADDRESS__c});

		// set CC
		if(config.CC_ADDRESSES__c != null)
		{
			mail.setCcAddresses(config.CC_ADDRESSES__c.split(';'));
		}

		// set ORG WIDE ADDRESS
		if(config.ORG_WIDE_EMAIL_ADDRESS_ID__c != null)
		{
			mail.setOrgWideEmailAddressId(config.ORG_WIDE_EMAIL_ADDRESS_ID__c);
		}


		mail.setFileAttachments(new List<Messaging.EmailFileattachment>());

		// add Attachment containing the class name
		mail.getFileAttachments()
			.add(E2A.getClassNameAttachmentFor(className));

		// add Attachment containg paramsObj		
		if (paramsObj != null)
		{
			mail.getFileAttachments()
				.add(E2A.getParamsAttachmentFor(paramsObj,doSerialze));	
		}

		return mail;
	}


	/**
	 * execute
	 *
	 * Initialzies an E2A_Executable class defined by it className using
	 * params defined by params parameters
	 *
	 * @params className
	 *					: Name of the Apex class to execute
	 * @params paramsObj
	 *					: Object holding parameters used by the executed class  
	 */
	global static void execute(String className, Object paramsObj)
	{

		//
		// validate class name to avoid
		// System.UnexpectedException: Salesforce System Error
		//
		E2A.isValidClassName(className);

		// construct new object to execute
		E2A.Executeable toExecute;

		// init new parser
		JSONParser parser = JSON.createParser('{}');

		// assign type
		Type paramType = Type.forName(className);
	
		// cast to type
		toExecute = (E2A.Executeable)parser.readValueAs(paramType);

		// set params if defined by casting to E2A.ExecuteableWithParams type
		if (paramsObj != null)
		{
			((E2A.ExecuteableWithParams)toExecute).e2a_setParams(paramsObj);
		}

		// run
		toExecute.e2a_execute();
	}




	/**
	 * isValidClassName
	 *
	 *
	 * Returns true if a String is valid className (NamespacePrefix supported)
	 *
	 * @params className
	 *					: Name of the Apex Class to execute 
	 * @returns Boolean
	 *					: True if valid
	 * @throws
	 * 					: InvalidClassNameException
	 */
	global static Boolean isValidClassName(String className)
	{

		// NamespacePrefix if found in className
		String nsp;
		// Query to validate className 
		String qry = 'select Id from ApexClass where Name =: className ';

		// check for Managed Package and filter on
		// Namespace Prefix if neccessary.
		if(className.contains('__'))
		{
			qry += ' and NamespacePrefix =: nsp';
		}

		// Exception if invalid class name
		if(Database.query(qry).isEmpty())
		{
			 throw new InvalidClassNameException(className + ' does not exist');
		}

		return true;
	}





	/**
	 * createClassNameFile
	 *
	 * Returns a TextAttachment containing the name of an Apex class
	 * to be executed 
	 *
	 * @params className
	 *					: Name of the Apex Class to execute
	 * @returns Messaging.Inboundemail.Textattachment
	 *					: E2A ready TextAttachment 
	 */
	global static Messaging.EmailFileAttachment getClassNameAttachmentFor(
		  String className
	)
	{
		isValidClassName(className);

		Messaging.EmailFileAttachment file
			= new Messaging.EmailFileAttachment();

		file.setFileName(CLASS_NAME_FILE_NAME);

		file.fileName = CLASS_NAME_FILE_NAME;
		file.setBody(Blob.valueOf(className));

		return file;
		
	}



	/**
	 * createParamsFile
	 *
	 * eturns a E2A ready TextAttachment object holding the JSON
	 * serialzed paramsObj to be executed 
	 *
	 * @params paramsObj
	 *					: Object to serialze 
	 * @returns Messaging.Inboundemail.Textattachment
	 *					: pretty JSON serialzed paramsObject 	 
	 */
	global static Messaging.EmailFileAttachment getParamsAttachmentFor(
		  Object paramsObj
		, Boolean doSerialze)
	{
		Messaging.EmailFileAttachment file
			= new Messaging.EmailFileAttachment();

		file.setFileName(PARAMS_FILE_NAME);

		// serialze to JSON
		if (doSerialze)
		{
			file.setBody(Blob.valueOf(JSON.serializePretty(paramsObj)));
		}
		// just store as blob
		else
		{
			file.setBody(Blob.valueOf(''+paramsObj));
		}		
		return file;

	}



}