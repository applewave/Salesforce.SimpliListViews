/**************************************************************************************** 
 * File Name    : CMP_UserUtil_test
 * Author       : sy.lee
 * Date         : 2023-08-24
 * Description  :
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * ===============================================================
 * Ver      Date 		Author    			Modification
 * ===============================================================
   1.0		2023-08-24 	sy.lee			    Create

****************************************************************************************/
@IsTest
private class CMP_UserUtil_test {

    @TestSetup static void sample() {
        System.debug(LoggingLevel.INFO, '==================== CMP_UserUtil_test.sample ===============================');

    }

    @IsTest static void testBehavior() {
        System.debug(LoggingLevel.INFO, '==================== CMP_UserUtil_test.testBehavior ===============================');



        String userId = UserInfo.getUserId();

        Test.startTest();

        CMP_UserUtil.getRecordAccess(userId, userId);
        CMP_UserUtil.getUserInfo(userId);
        CMP_UserUtil.getRecordAccess(userId, new List<SObject>{new User(Id = userId)});
        Boolean isGuest = CMP_UserUtil.IS_GUEST;
        Boolean isPartner = CMP_UserUtil.IS_PARTNER;

        Test.stopTest();
    }

}