/**
 * E2A_SampleBatch1
 *
 * Demo class 
 */
global class E2A_SampleBatch1 implements
	  Database.Batchable<sObject>
	, Database.Stateful
{

	List<Account> accounts = new List<Account>();
	Integer countX = 0;

	global List<sObject> start(Database.BatchableContext bc) {

		List<Account> sc = new List<Account>();

		for(Integer i = 1;i<101;i++)
		{
			sc.add(new Account(Name = 'Account ' + i));
		}
		return sc;
	}


	global void execute(Database.BatchableContext BC, list<sObject> scope)
	{

		for(Account account:(List<Account>)scope)
		{
			account.Website = 'www.domain-'+countX + '.com';
			accounts.add(account);
			countX++;	
		}

	}


	global void finish(Database.BatchableContext BC)
	{

		// call E2A API to send message
		E2A.sendE2AMessage(
			'E2A_SampleBatch1 finished - start E2A_SampleBatch2'
		  , 'E2A_SampleBatch2'
		  , new E2A_SampleParamsObj(accounts)
		  , true
		  , true
		);
	}

}