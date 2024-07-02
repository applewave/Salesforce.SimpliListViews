/**************************************************************************************** 
 * File Name    : CMP_RelatedListParameters_test
 * Author       : sy.lee
 * Date         : 2023-12-12
 * Description  : 
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * =============================================================== 
 * Ver      Date 		Author    			Modification
 * ===============================================================
   1.0		2023-12-12 	sy.lee			    Create

****************************************************************************************/
@IsTest
private class CMP_RelatedListParameters_test {

    @TestSetup static void sample() {
        System.debug(LoggingLevel.INFO, '==================== CMP_RelatedListParameters_test.sample ===============================');

    }

    @IsTest static void testBehavior() {
        System.debug(LoggingLevel.INFO, '==================== CMP_RelatedListParameters_test.testBehavior ===============================');

        Test.startTest();

        CMP_RelatedListParameters cls = new CMP_RelatedListParameters();
        System.debug(cls.recordId);
        System.debug(cls.currentObjectApi);
        System.debug(cls.currentObjectFields);
        System.debug(cls.targetObjectApi);
        System.debug(cls.fields);
        System.debug(cls.condition);
        System.debug(cls.sortedBy);
        System.debug(cls.sortedDirection);
        System.debug(cls.limitCount);
        System.debug(cls.isWithOutSharing);
        System.debug(cls.needAccessCheck);
        System.debug(cls.applyApprovalLock);
        System.debug(cls.isPhone);

        Test.stopTest();
    }


}