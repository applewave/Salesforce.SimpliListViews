/**************************************************************************************** 
 * File Name    : CMP_RelatedListController_test
 * Author       : sy.lee
 * Date         : 2023-10-17
 * Description  : 
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * =============================================================== 
 * Ver      Date 		Author    			Modification
 * ===============================================================
   1.0		2023-10-17 	sy.lee			    Create

****************************************************************************************/
@IsTest
private class CMP_RelatedListController_test {

    @TestSetup static void sample() {
        System.debug(LoggingLevel.INFO, '==================== CMP_RelatedListController_test.sample ===============================');

    }

    @IsTest static void testBehavior() {
        System.debug(LoggingLevel.INFO, '==================== CMP_RelatedListController_test.testBehavior ===============================');


        Account acc = (Account)CMP_TestDataFactory.createSObject('Account', false);

        CMP_RelatedListParameters params = new CMP_RelatedListParameters();
        params.recordId = acc.Id;
        params.currentObjectApi = 'Account';
        params.targetObjectApi = 'Contact';
        params.fields = 'Name, AccountId, Account.Name';
        params.condition = '';
        params.sortedBy = 'Name';
        params.sortedDirection = 'ASC';
        params.limitCount = '5';
        params.isWithOutSharing = false;
        params.needAccessCheck = true;
        params.isPhone = false;
        Test.startTest();

        CMP_RelatedListController.init(params);

        CMP_RelatedListController.refresh('SELECT Id FROM User LIMIT 1', 'SELECT COUNT() FROM User', false);

        CMP_RelatedListController.deleteRecord('TEST');

        CMP_RelatedListController.export('SELECT Id FROM User LIMIT 1');

        Test.stopTest();
    }

    @IsTest static void testBehavior2() {
        System.debug(LoggingLevel.INFO, '==================== CMP_RelatedListController_test.testBehavior2 ===============================');


        Account acc = (Account)CMP_TestDataFactory.createSObject('Account', false);

        CMP_RelatedListParameters params = new CMP_RelatedListParameters();
        params.recordId = acc.Id;
        params.currentObjectApi = 'Account';
        params.targetObjectApi = 'Contact';
        params.fields = 'Name, AccountId, Account.Name';
        params.condition = '';
        params.sortedBy = 'Name';
        params.sortedDirection = 'ASC';
        params.limitCount = '5';
        params.isWithOutSharing = false;
        params.needAccessCheck = true;
        params.isPhone = true;
        Test.startTest();

        CMP_RelatedListController.init(params);

        Test.stopTest();
    }

}