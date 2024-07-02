/**************************************************************************************** 
 * File Name    : RealGridPjtSalesPlanBulkTestController
 * Author       : ar.kim
 * Date         : 2024-06-28
 * Description  : 
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * =============================================================== 
 * Ver      Date 		Author    			Modification
 * ===============================================================
   1.0		2024-06-28 	ar.kim			    Create

****************************************************************************************/
public with sharing class RealGridPjtSalesPlanBulkTestController {

    /** Whether Test or not */
    //private final static Boolean IS_TEST = Test.isRunningTest();

    /**
     * @description getProjectOption 메소드 : get Project List 
     * @param 
     * @return 
     */
    @AuraEnabled
    public static LIst<VS_Project__c> getProjectOption() {
        LIst<VS_Project__c> pjtList = new List<VS_Project__c>();

        String query = 'SELECT';
        query += ' Id, Name';
        query += ' FROM VS_Project__c';
        query += ' WHERE Name LIKE \'SalesPlanItem%\'';
        query += ' ORDER BY Name ASC';

        return Database.query(query);
    }
   
}