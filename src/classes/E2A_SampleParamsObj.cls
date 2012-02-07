/**
 * E2A_SampleParamsObj
 * ParamsObj for E2A_Sample classes
 */
global class E2A_SampleParamsObj
{

	global E2A_SampleParamsObj()
	{
		this.accountList = new List<Account>();
	}
	

	global E2A_SampleParamsObj(List<Account> accList)
	{
		this.accountList = accList;
	}

	global List<Account> accountList {get;set;}

}