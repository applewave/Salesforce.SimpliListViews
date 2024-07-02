/**************************************************************************************** 
 * File Name    : SchemaUtil_test
 * Author       : sy.lee
 * Date         : 2023-12-11
 * Description  : 
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * =============================================================== 
 * Ver      Date 		Author    			Modification
 * ===============================================================
   1.0		2023-12-11 	sy.lee			    Create

****************************************************************************************/
@IsTest
private class SchemaUtil_test {

    @TestSetup static void sample() {
        System.debug(LoggingLevel.INFO, '==================== SchemaUtil_test.sample ===============================');

    }

    @IsTest static void testBehavior() {
        System.debug(LoggingLevel.INFO, '==================== SchemaUtil_test.testBehavior ===============================');

        Account acc = (Account)TestDataFactory.createSObject('Account', false);

        Test.startTest();

        SchemaUtil.getObjectResult('Account');
        SchemaUtil.getFieldList('Account');
        SchemaUtil.getRecordTypeByName('Account', null);
        SchemaUtil.getRecordTypeByName('Account');
        SchemaUtil.getRecordTypeById('Account', null);
        SchemaUtil.getRecordTypeById('Account');
        SchemaUtil.getFieldSet('Account', null);
        SchemaUtil.getDependentPicklistValues('Account', 'Industry');
        SchemaUtil.getDescribedObjectMap('Account');
        SchemaUtil.getFieldSetMap('Account');
        SchemaUtil.getPicklistValue('Account', 'Industry');
        SchemaUtil.getFieldSetFieldInfo('Account', 'Industry');
        SchemaUtil.getObjectInfo(acc.Id);
        SchemaUtil.getObjectApi(acc.Id);
        SchemaUtil.getListViewDescribe('Account', null);

        SchemaUtil.RecordTypeCls cls = new SchemaUtil.RecordTypeCls(null);
        Test.stopTest();
    }


}