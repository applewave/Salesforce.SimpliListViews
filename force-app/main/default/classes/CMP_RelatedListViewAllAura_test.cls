/**************************************************************************************** 
 * File Name    : CMP_RelatedListViewAllAura_test
 * Author       : sy.lee
 * Date         : 2024-06-26
 * Description  : 
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * =============================================================== 
 * Ver      Date 		Author    			Modification
 * ===============================================================
   1.0		2024-06-26 	sy.lee			    Create

****************************************************************************************/
@IsTest
private class CMP_RelatedListViewAllAura_test {

    @TestSetup static void sample() {
        System.debug(LoggingLevel.INFO, '==================== CMP_RelatedListViewAllAura_test.sample ===============================');

    }

    @IsTest static void testBehavior() {
        System.debug(LoggingLevel.INFO, '==================== CMP_RelatedListViewAllAura_test.testBehavior ===============================');

        // Set mock callout class
        // Test.setMock(HttpCalloutMock.class, new CMP_RelatedListViewAll_test());

        Test.startTest();

        CMP_RelatedListViewAllAuraController.init('SELECT Id FROM User LIMIT 1', '1', false, false, false);
        CMP_RelatedListViewAllAuraController.refresh('SELECT Id FROM User LIMIT 1', 'SELECT COUNT() FROM User LIMIT 1', false);


        Test.stopTest();
    }

}