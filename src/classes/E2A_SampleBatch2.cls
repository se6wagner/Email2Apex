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
	global void e2a_execute()
	{
		E2A_SampleBatch2 sb = params == null
							? new E2A_SampleBatch2()
							: new E2A_SampleBatch2(params);
		system.debug('e2a_execute : ' + sb);
		Database.executeBatch(sb , 200);
	}

	/**
	 * Create ParamsObj instance for serialized JSON String
	 */
	global void e2a_setParams(Object paramsObj)
	{
		params = (E2A_SampleParamsObj)JSON.deserialize((String)paramsObj, E2A_SampleParamsObj.class);
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