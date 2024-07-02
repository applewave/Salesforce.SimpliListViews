/****************************************************************************************
 * File Name    : CNS_OrgUtil_test
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
private class CMP_OrgUtil_test {

    @TestSetup static void sample() {
        System.debug(LoggingLevel.INFO, '==================== CMP_OrgUtil_test.sample ===============================');

    }

    @IsTest static void testBehavior() {
        System.debug(LoggingLevel.INFO, '==================== CMP_OrgUtil_test.testBehavior ===============================');

        Test.startTest();

        System.debug(CMP_OrgUtil.ORG_INFO);
        System.debug(CMP_OrgUtil.ORG_NAME);
        System.debug(CMP_OrgUtil.IS_COMMUNITY);
        System.debug(CMP_OrgUtil.DOMAIN_URL);
        System.debug(CMP_OrgUtil.ORG_SETTING);
        System.debug(CMP_OrgUtil.INSTANCE_SETTING);
        System.debug(CMP_OrgUtil.SESSION_ID);
        System.debug(CMP_OrgUtil.OWE_LIST);

        Test.stopTest();
    }

}