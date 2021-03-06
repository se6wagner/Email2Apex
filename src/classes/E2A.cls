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
	 * @returns E2A_CONFIG__c
	 * @throws ConfigNotFoundException
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
		ExecutionResult e2a_execute();
	}

	/**
	 * ExecuteableWithParams
	 *
	 * Interface class supporting parameters have to implement
	 *
	 */
	global interface ExecuteableWithParams extends Executeable
	{

		/**
		 * Method for setting parameter object
		 *
		 * NOTE
		 		: below is an example to deserialze a JSON string into
		          a custom data type. 
		   CAREFUL
		   		: Be careful when using custom data types as parameter
				  objects, deserializing classes using the code sample
				  below causes an 'System.JSONException: Don't know
				  the type of the Apex object to deserialize' error
				 in production like EMEA (as of Winter '12) ###
		 */

		 /**
		  	global void e2a_setParams(Object paramsObj)
			{
				params = (<CONCRETE_TYPE>)JSON.deserialize(
							(String)paramsObj,
							<CONCRETE_TYPE>.class);
			}
		**/
		void e2a_setParams(Object paramsObject);

	}

	//--------------------------------------------------------------
	// RESULT DATA TYPE
	//--------------------------------------------------------------
	/**
	 * ExecutionResult
	 *
	 * Object returned by e2a_execute method to check result of the execution 
	 */
	global class ExecutionResult
	{

		Boolean isSuccess;
		String message;

		/**
		 * Standard Constructor
		 *
		 * @params isSuccess
	 	 *					: true if the execution was successful
		 * @params message
	 	 *					: message for more detailed information
		 */
		global ExecutionResult(
			  Boolean isSuccess
			, String message)
		{
			this.isSuccess = isSuccess;
			this.message = message;
		}


		global Boolean isSuccess()
		{
			return this.isSuccess;
		}

		global String getMessage()
		{
			return this.message != null
					? this.message
					: '';
		}

	}

	//--------------------------------------------------------------
	// MAIN API METHODS
	//--------------------------------------------------------------

	//
	// SENDING
	//

	/**
	 * sendE2AMessage
	 *
	 * Create an E2A Message and sends it to the E2A Email Service
	 *
	 * @params className
	 *					: Name of the Apex class to execute
	 * @params checkResult
	 * 					: True to throw an Exception if result is negativ
	 * @params emailBody
	 *					: Plain Text Body to set
	 * @throws OutboundEmailException
	 */
	global static void sendE2AMessage(
		  String className	
		, Boolean checkResult
		, String emailBody
	)
	{
		E2A.sendE2AMessage(
			  className
			, null
			, false
			, checkResult
			, emailBody);
	}


	/**
	 * sendE2AMessage
	 *
	 * Create an E2A Message and sends it to the E2A Email Service
	 *
	 * @params className
	 *					: Name of the Apex class to execute
	 * @params paramsObj
	 *					: Object holding parameters used by the executed class
	 * @params doSerialze
	 *					: True serializes the paramsObj to JSON
	 * @params checkResult
	 * 					: True to throw an Exception if result is negativ
	 * @params emailBody
	 *					: Plain Text Body to set
	 * @throws OutboundEmailException
	 */
	global static void sendE2AMessage(
		  String className
		, Object paramsObj
		, Boolean doSerialze
		, Boolean checkResult
		, String emailBody
		)
	{
		// init new Message 
		Messaging.SinglEemailMessage email = 
				getNewE2AMessage(className,paramsObj,doSerialze);
		// sent
		Messaging.SendEmailResult res =
			Messaging.sendEmail(new Messaging.SinglEemailMessage[]{email}).get(0);

		if (checkResult && !res.isSuccess()) 
		{
			throw new OutboundEmailException(res.getErrors()[0].getMessage());
		}

	}


	/**
	 * execute
	 *
	 * Initialzies an E2A_Executable class defined by its className and executes
	 * e2a_execute() method
	 *
	 * @params className
	 *					: Name of the Apex class to execute
	 * @params paramsObj
	 *					: Object holding parameters used by the executed class
	 * @returns E2A.ExecutionResult
	 */
	global static E2A.ExecutionResult execute(String className, Object paramsObj)
	{

		E2A.isValidClassName(className); // validate class name to avoid System.UnexpectedException: Salesforce System Error
		
		E2A.Executeable toExecute; // construct new object to execute
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
		return toExecute.e2a_execute();
	}



	//--------------------------------------------------------------
	// API UTIL METHODS
	//--------------------------------------------------------------

	/**
	 * getNewE2AMessage
	 * 
	 * Generates a new Messaging.SinglEemailMessage Object for E2A
	 *
	 * @params className
	 *					: Name of the Apex class to execute
	 * @params paramsObj
	 *					: Object holding parameters used by the executed class
	 * @params doSerialze
	 *					: True serializes the paramsObj to JSON
	 *	 
	 * @returns Messaging.SinglEemailMessage
	 */
	global static Messaging.SinglEemailMessage getNewE2AMessage(
		  String className
		, Object paramsObj
		, Boolean doSerialze)
	{

		// new Message Object
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setSubject('E2A Message: ' + className);
		mail.setPlainTextBody('Email2Apex Message');

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


		List<Messaging.EmailFileattachment> files =
			new List<Messaging.EmailFileattachment>();

		// add class name file
		files.add(E2A.getClassNameAttachmentFor(className));

		// if params defined attach it
		if (paramsObj != null)
		{
			files.add(E2A.getParamsAttachmentFor(paramsObj,doSerialze));
		}

		// set file attachments
		mail.setFileAttachments(files);
	
		return mail;
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
		file.setContentType('text/plain;charset=utf8');
		file.setBody(Blob.valueOf(className));

		return file;

	}



	/**
	 * createParamsFile
	 *
	 * Returns a E2A ready TextAttachment object holding the JSON
	 * serialzed paramsObj to be executed 
	 *
	 * @params paramsObj
	 *					: Object to serialze
	 *
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
		file.setContentType('text/plain;charset=utf8');

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
	
	

	/**
	 * isValidClassName
	 *
	 * Returns true if a String is valid className (NamespacePrefix supported)
	 *
	 * @params className 
	 *					: Name of the Apex Class to execute 
	 * @returns Boolean
	 *					: True if valid
	 * @throws  InvalidClassNameException
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
}