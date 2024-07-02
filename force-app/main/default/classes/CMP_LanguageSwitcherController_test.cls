/**************************************************************************************** 
 * File Name    : CMP_LanguageSwitcherController_test
 * Author       : sy.lee
 * Date         : 2024-04-04
 * Description  : 
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * =============================================================== 
 * Ver      Date 		Author    			Modification
 * ===============================================================
   1.0		2024-04-04 	sy.lee			    Create

****************************************************************************************/
@IsTest
private class CMP_LanguageSwitcherController_test {
//private class CMP_LanguageSwitcherController_test implements HttpCalloutMock {

    @TestSetup static void sample() {
        System.debug(LoggingLevel.INFO, '==================== CMP_LanguageSwitcherController_test.sample ===============================');

    }

    @IsTest static void testBehavior() {
        System.debug(LoggingLevel.INFO, '==================== CMP_LanguageSwitcherController_test.testBehavior ===============================');

        // Set mock callout class 
        // Test.setMock(HttpCalloutMock.class, new CMP_LanguageSwitcherController_test());

        Test.startTest();

        CMP_LanguageSwitcherController.init();

        CMP_LanguageSwitcherController.updateLanguage('ko-KR');


        Test.stopTest();
    }

    /*
    public static HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }
    */
}