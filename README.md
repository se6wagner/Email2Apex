# E2A - Email2Apex #

Toolkit for executing Apex Code from Apex Email Services.

## FEATURES ##
* batch job chaining / async execution
* support for parameters incl. complex data types through JSON serialization
* trigger Apex Code from any application with no need for Webservice Integration by just sending an email to SFDC
* simple API (check usage)

## SETUP ##
* 1) Register an Apex Email Service using the E2A_InboundEmailHandler class
* 2) In Custom Settings create E2A_CONFIG__c Org Default
* 3) Implement E2A.Executable or E2A.ExecuteableWithParams contracts in the classes you want to run (Check out E2A_SampleBatch1 and E2A_SampleBatch2 for more details)


## USAGE ##

### CAUTION:: Be careful when using custom data types as parameter objects, deserializing classes using (DATA_TYPE)JSON.deserialize((String)paramsObj, DATA_TYPE.class); causes an 'System.JSONException: Don't know the type of the Apex object to deserialize' error in production like EMEA (as of Winter '12) ###

	//
	// E2A.sendE2AMessage
	// 
	// Sends an E2A ready message with Attachments
	// class_name.e2b (Contains className)
	// param_class.json.e2a (Contains JSON serialized paramsObj if doSerialze is true)
	// to the E2A Apex Email Service you have setted up
	//
	// @params String className: Name of the Apex class to execute
	// @params Object paramsObj: Optional - Object holding parameters used by the executed class
	// @params Boolean doSerialize: Optional - True serializes the paramsObj to JSON
	// @params Boolean checkResult: True to throw an Exception if messaging result is negativ
	// @params String emailBody: Email plain text body
	//

	E2A.sendE2AMessage(
<<<<<<< HEAD
		  String emailBody // Plain Text Body to set
		, String className // Name of the Apex class to execute
		, Object paramsObj // Object holding parameters used by the executed class
		, Boolean doSerialze // True serializes the paramsObj to JSON
		, Boolean checkResult // True to throw an Exception if Email Service result is negativ
		);
=======
		  String className // Name of the Apex class to execute
		, Object paramsObj // Optional - Object holding parameters used by the executed class
		, Boolean doSerialize // Optional - True serializes the paramsObj to JSON
		, Boolean checkResult // True to throw an Exception if messaging result is negativ
		, String emailBody // Email plain text body
	);

	// SAMPLE
	// Execute a Database.Batchable class called 'IBaseImport_Batch'
	E2A.sendE2Message('IBaseImport_Batch',false,'Completed IBaseImport_Setup, start IBaseImport_Batch');
>>>>>>> updated README.md


_E2A accepts class names contained in the Email Subject as well, just sent an email to the Email Inbound Service with the plain class name in the subject_
