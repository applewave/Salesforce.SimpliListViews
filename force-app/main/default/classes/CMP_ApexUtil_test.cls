/**************************************************************************************** 
 * File Name    : CMP_ApexUtil_test
 * Author       : sy.lee
 * Date         : 2023-10-31
 * Description  : 
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * =============================================================== 
 * Ver      Date 		Author    			Modification
 * ===============================================================
   1.0		2023-10-31 	sy.lee			    Create

****************************************************************************************/
@IsTest
private class CMP_ApexUtil_test {

    @TestSetup static void sample() {
        System.debug(LoggingLevel.INFO, '==================== CMP_ApexUtil_test.sample ===============================');

    }

    @IsTest static void testBehavior() {
        System.debug(LoggingLevel.INFO, '==================== CMP_ApexUtil_test.testBehavior ===============================');


        Test.startTest();

        System.debug(CMP_ApexUtil.getUrlEncode('TEST'));
        System.debug(CMP_ApexUtil.getEncrypted('MD5', 'TEST'));
        System.debug(CMP_ApexUtil.getAllFieldQuery('Account'));
        System.debug(CMP_ApexUtil.isValidEmail('sy.lee@lgcns.com'));

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 100; i ++) {
            opps.add(new Opportunity());
        }
        List<List<SObject>> actual = CMP_ApexUtil.split(opps, 5);

        CMP_ApexUtil.getChangedList(new Map<Id, SObject>(), new Map<Id, SObject>(), 'Name');
        CMP_ApexUtil.getUUID();
        CMP_ApexUtil.getDescribedObjectJSON(new List<String> {'Opportunity', 'Account'});
        CMP_ApexUtil.toDatetime(null);
        CMP_ApexUtil.formatDate(Date.newInstance(1990, 11, 21));
        CMP_ApexUtil.toString('TEST');
        CMP_ApexUtil.toString(opps.get(0), 'Id');
        CMP_ApexUtil.toDatetime(opps.get(0), 'CreatedDate');
        Test.stopTest();
    }
}