/**************************************************************************************** 
 * File Name    : CMP_TriggerUtil_test
 * Author       : sy.lee
 * Date         : 2023-08-21
 * Description  :
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * ===============================================================
 * Ver      Date 		Author    			Modification
 * ===============================================================
   1.0		2023-08-21 	sy.lee			    Create

****************************************************************************************/
@IsTest
private class CMP_TriggerUtil_test {

    @TestSetup static void sample() {
        System.debug(LoggingLevel.INFO, '==================== CMP_TriggerUtil_test.sample ===============================');
    }

    @IsTest static void testBehavior() {
        System.debug(LoggingLevel.INFO, '==================== CMP_TriggerUtil_test.testBehavior ===============================');

        Test.startTest();

        try{
            CMP_TriggerUtil.IS_UNIT_TEST = true;
            CMP_TriggerUtil.run();
        }catch (Exception e){
            System.debug('error');
        }
        Test.stopTest();
    }
}