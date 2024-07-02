/**************************************************************************************** 
 * File Name    : CMP_RelatedListParameters
 * Author       : sy.lee
 * Date         : 2024-04-03
 * Description  : 
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * =============================================================== 
 * Ver      Date 		Author    			Modification
 * ===============================================================
   1.0		2024-04-03 	sy.lee			    Create

****************************************************************************************/
public with sharing class CMP_RelatedListParameters {

    @AuraEnabled public String recordId {get;set;}
    @AuraEnabled public String currentObjectApi {get;set;}
    @AuraEnabled public String currentObjectFields {get;set;}
    @AuraEnabled public String targetObjectApi {get;set;}
    @AuraEnabled public String fields {get;set;}
    @AuraEnabled public String condition {get;set;}
    @AuraEnabled public String sortedBy {get;set;}
    @AuraEnabled public String sortedDirection {get;set;}
    @AuraEnabled public String limitCount {get;set;}
    @AuraEnabled public Boolean isWithOutSharing {get;set;}
    @AuraEnabled public Boolean needAccessCheck {get;set;}
    @AuraEnabled public Boolean applyApprovalLock {get;set;}
    @AuraEnabled public Boolean isPhone {get;set;}

    //@AuraEnabled public String viewAllTargetObjectApi {get;set;}
    //@AuraEnabled public String viewAllTargetFieldApi {get;set;}

}