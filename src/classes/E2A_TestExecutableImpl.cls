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

	global E2A.ExecutionResult e2a_execute()
	{
		system.debug('##E2A_TestExecutableImpl executing');
		return new E2A.ExecutionResult(true,'E2A_TestExecutableImpl executing');
	}

}