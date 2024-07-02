/**************************************************************************************** 
 * File Name    : CMP_DateUtil_test
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
private class CMP_DateUtil_test {

    @TestSetup static void sample() {
        System.debug(LoggingLevel.INFO, '==================== CMP_DateUtil_test.sample ===============================');

    }

    @IsTest static void testBehavior() {
        System.debug(LoggingLevel.INFO, '==================== CMP_DateUtil_test.testBehavior ===============================');


        Test.startTest();

        Date today = Date.today();

        System.debug(CMP_DateUtil.COMPANY_NOW);
        System.debug(CMP_DateUtil.COMPANY_MONTH);
        System.debug(CMP_DateUtil.COMPANY_YEAR);
        System.debug(CMP_DateUtil.getGmt(today));
        System.debug(CMP_DateUtil.getGmt(today, 'YYYY-MM-DD'));

        User usr = [SELECT Id, TimeZoneSidKey FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.debug(CMP_DateUtil.getLocalDateTime(today, usr));
        System.debug(CMP_DateUtil.getLocalDateTime(today, usr, 'YYYY-MM-DD'));


        Test.stopTest();
    }


}