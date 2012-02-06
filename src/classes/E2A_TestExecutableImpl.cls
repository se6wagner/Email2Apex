/**
 * E2A_TestExecutableImpl
 *
 * Mock Object for Testclass
 */
global class E2A_TestExecutableImpl implements E2A.ExecuteableWithParams
{

	global void e2a_setParams(Object obj)
	{
		system.debug('##E2A_TestExecutableImpl params set: ' + obj);
	}

	global void e2a_execute()
	{
		system.debug('##E2A_TestExecutableImpl executing');
	}

}