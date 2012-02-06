/**
 * E2A_InboundEmailHandler
 *
 * Apex Email Service that handles E2A inbound messages 
 * 
 */
global class E2A_InboundEmailHandler implements Messaging.InboundEmailHandler
{


	global Messaging.InboundEmailResult handleInboundEmail
	(
		  Messaging.InboundEmail email
		, Messaging.InboundEnvelope envelope
	)
	{
		// if true subject is used as className 
		Boolean trySubject = true;
		// name of the apex class
		String className = null;
		// Object containing the parameters
		Object paramsObj = null;

		//
		// Attachment Support
		//
		// checks for Attachments containing the className and JSON serialzed params object
		//
		if (email.textAttachments != null && email.textAttachments.size() > 0)
		{

			system.debug(email.textAttachments.size() + ' Attachments found');

			for (Messaging.InboundEmail.TextAttachment ta:email.textAttachments)
			{

				system.debug('process Attachment: ' +  ta.fileName);

				// check for class name file
				if (ta.fileName == E2A.CLASS_NAME_FILE_NAME
					&& className == null)
				{
					className = ta.body;
					trySubject = false;
					continue;
				}
				// check for params files
				if (ta.fileName == E2A.PARAMS_FILE_NAME
					&& paramsObj == null)
				{
					 paramsObj = ta.body;
					 continue;
				}
			}

		}

		// Subject Support
		//
		//
		if (trySubject)
		{
			className = email.subject;
		}

		// process result
		Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

		try
		{
			E2A.execute(className, paramsObj);
			result.success = true;
			result.message = 'E2A:: Queued class ' + className + ' successfully'; 
		}
		catch(Exception ex)
		{
			result.success = false;
			result.message = ex.getMessage();
		}

		return result;

	}


}