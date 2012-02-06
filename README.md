# E2A - Email2Apex #

Toolkit for executing Apex Code from Apex Email Service


## SETUP ##
* 1) Register an Apex Email Service using the E2A_InboundEmailHandler class
* 2) In Custom Settings create E2A_CONFIG__c Org Default
* 3) Implement E2A.Executable or E2A.ExecuteableWithParams contracts in the classes you want to run (Check out E2A_SampleBatch1 and E2A_SampleBatch2 for more details)


## USAGE ##

	//
	// Sends an E2A ready message with Attachments
	// class_name.e2b (Contains className)
	// param_class.json.e2a (Contains JSON serialized paramsObj if doSerialze is true)
	//
	E2A.sendE2AMessage(
		  String emailBody // Plain Text Body to set
		, String className // Name of the Apex class to execute
		, Object paramsObj // Object holding parameters used by the executed class
		, Boolean doSerialze // True serializes the paramsObj to JSON
		, Boolean checkResult // True to throw an Exception if result is negativ
		);


_E2A accepts class names contained in the Email Subject as well, just sent an email to the Email Inbound Service with the plain class name in the subject_
