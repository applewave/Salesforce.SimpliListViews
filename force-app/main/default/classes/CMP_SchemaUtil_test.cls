/**************************************************************************************** 
 * File Name    : CMP_SchemaUtil_test
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
private class CMP_SchemaUtil_test {

    @TestSetup static void sample() {
        System.debug(LoggingLevel.INFO, '==================== CMP_SchemaUtil_test.sample ===============================');

    }

    @IsTest static void testBehavior() {
        System.debug(LoggingLevel.INFO, '==================== CMP_SchemaUtil_test.testBehavior ===============================');

        Account acc = (Account)CMP_TestDataFactory.createSObject('Account', false);

        Test.startTest();

        CMP_SchemaUtil.getObjectResult('Account');
        CMP_SchemaUtil.getFieldList('Account');
        CMP_SchemaUtil.getRecordTypeByName('Account', null);
        CMP_SchemaUtil.getRecordTypeByName('Account');
        CMP_SchemaUtil.getRecordTypeById('Account', null);
        CMP_SchemaUtil.getRecordTypeById('Account');
        CMP_SchemaUtil.getFieldSet('Account', null);
        CMP_SchemaUtil.getDependentPicklistValues('Account', 'Industry');
        CMP_SchemaUtil.getDescribedObjectMap('Account');
        CMP_SchemaUtil.getFieldSetMap('Account');
        CMP_SchemaUtil.getPicklistValue('Account', 'Industry');
        CMP_SchemaUtil.getFieldSetFieldInfo('Account', 'Industry');
        CMP_SchemaUtil.getObjectInfo(acc.Id);
        CMP_SchemaUtil.getObjectApi(acc.Id);
        CMP_SchemaUtil.getListViewDescribe('Account', null);

        CMP_SchemaUtil.RecordTypeCls cls = new CMP_SchemaUtil.RecordTypeCls(null);
        Test.stopTest();
    }


}