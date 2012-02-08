/**
 * E2A_SampleBatch2
 *
 * Demo class 
 */
global class E2A_SampleBatch2 implements 
	  Database.Batchable<sObject>
	, Database.Stateful
	, E2A.ExecuteableWithParams
{

	E2A_SampleParamsObj params;

	//--------------------------------------------------------------
	// Constructor
	//--------------------------------------------------------------
	global E2A_SampleBatch2(){}

	global E2A_SampleBatch2(E2A_SampleParamsObj paramsObj)
	{
		this.params = paramsObj;
	}

	//--------------------------------------------------------------
	// E2A.Executebale Implementation
	//--------------------------------------------------------------
	global E2A.ExecutionResult e2a_execute()
	{
		E2A_SampleBatch2 sb = params == null
							? new E2A_SampleBatch2()
							: new E2A_SampleBatch2(params);

		system.debug('e2a_execute : ' + sb);
		Id jobId = Database.executeBatch(sb , 200);

		return new E2A.ExecutionResult(
					  true
					, 'Queued new Batch Job with ID ' + jobID);

	}

	/**
	 * e2a_setParams
	 *
	 * Create ParamsObj instance for serialized JSON String
	 *  CAREFUL
	 * 		: Be careful when using custom data types as parameter
	 *		  objects, deserializing classes using the code sample
	 *		  below causes an 'System.JSONException: Don't know
	 *		  the type of the Apex object to deserialize' error
	 *		  in production like EMEA (as of Winter '12)
	 */
	global void e2a_setParams(Object paramsObj)
	{
		// Commented out due to deserialize bug in production
		//params = (E2A_SampleParamsObj)JSON.deserialize(
		//	  (String)paramsObj
		//	, E2A_SampleParamsObj.class);
	}


	//--------------------------------------------------------------
	// Database.Batchable Implentation
	//--------------------------------------------------------------
	global List<sObject> start(Database.BatchableContext bc)
	{
		List<Account> accList = new List<Account>();
		if (params != null)
		{
			for(Account account:params.accountList)
			{
				accList.add(account);
			}
		}
		return accList;
	}


	global void execute(Database.BatchableContext BC, list<sObject> scope)
	{
		//
		// Code to execute
		//
	}

	global void finish(Database.BatchableContext BC)
	{
		//
		// Finish it
		//
	}
}