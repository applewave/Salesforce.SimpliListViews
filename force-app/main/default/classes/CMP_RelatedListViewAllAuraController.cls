/**************************************************************************************** 
 * File Name    : CMP_RelatedListViewAllAuraController
 * Author       : sy.lee
 * Date         : 2023-11-21
 * Description  : 
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * =============================================================== 
 * Ver      Date 		Author    			Modification
 * ===============================================================
   1.0		2023-11-21 	sy.lee			    Create

****************************************************************************************/
public abstract with sharing class CMP_RelatedListViewAllAuraController {

    /** Whether Test or not */
    //private final static Boolean IS_TEST = Test.isRunningTest();

    /**
     * @description with out instance
     */
    public static CMP_RelatedListViewAllAuraController instance;
    public static CMP_RelatedListViewAllAuraController getInstance(Boolean isWithOutSharing) {
        if (instance == null) {
            instance = isWithOutSharing ? (CMP_RelatedListViewAllAuraController)new CMP_RelatedListViewAllAuraController.WithoutSharing() : (CMP_RelatedListViewAllAuraController)new CMP_RelatedListViewAllAuraController.WithSharing();
        }
        return instance;
    }

    @AuraEnabled
    public static InitCls init(String query, String limitCount, Boolean isWithOutSharing, Boolean needAccessCheck, Boolean applyApprovalLock){
        InitCls ic = new InitCls();

        // 레코드 조회
        List<SObject> recordList = getInstance(isWithOutSharing).queryRecord(query);

        // User Access
        //Map<String, UserRecordAccess> accessMap = new Map<String, UserRecordAccess>();
        //if(needAccessCheck) accessMap = CMP_UserUtil.getRecordAccess(UserInfo.getUserId(), recordList);

        // Approval Lock
        Map<Id, Boolean> isLockMap;
        try{
            isLockMap = Approval.isLocked(recordList);
        }catch(Exception e){
            isLockMap = new Map<Id, Boolean>();
        }

        /*for(SObject record : recordList) {
            CMP_RelatedListUtil.RecordCls recordCls = new CMP_RelatedListUtil.RecordCls();
            recordCls.record = record;

            *//*UserRecordAccess recordAccess = accessMap.get(record.Id);
            recordCls.hasReadAccess = needAccessCheck ? recordAccess.HasReadAccess : true;
            recordCls.hasEditAccess = needAccessCheck ? recordAccess.HasEditAccess : true;
            recordCls.hasDeleteAccess = needAccessCheck ? recordAccess.HasDeleteAccess : true;*//*
            recordCls.isLocked = isLockMap.get(record.Id);
            ic.recordList.add(recordCls);
        }*/

        CMP_RelatedListUtil.ResultCls rc = new CMP_RelatedListUtil.ResultCls();
        for(SObject record : recordList){
            CMP_RelatedListUtil.RecordCls recordCls = new CMP_RelatedListUtil.RecordCls();
            recordCls.record = record;

            // todo
            /*
            UserRecordAccess recordAccess = accessMap.get(record.Id);
            recordCls.hasReadAccess = needAccessCheck ? recordAccess.HasReadAccess : true;
            recordCls.hasEditAccess = needAccessCheck ? recordAccess.HasEditAccess : true;
            recordCls.hasDeleteAccess = needAccessCheck ? recordAccess.HasDeleteAccess : true;
             */
            recordCls.isLocked = isLockMap.isEmpty() ? false : isLockMap.get(record.Id);
            rc.recordList.add(recordCls);
        }

        ic.data = rc;

        return ic;
    }

    @AuraEnabled(Cacheable = true)
    public static RefreshCls refresh(String query, String countQuery, Boolean needAccessCheck) {
        RefreshCls rc = new RefreshCls();
        // todo
        rc.totalRecordCount = getInstance(false).countQueryRecord(countQuery);
        List<SObject> recordList = Database.query(query);

        // todo
        // User Access
        Map<String, UserRecordAccess> accessMap = new Map<String, UserRecordAccess>();
        if(needAccessCheck) accessMap = CMP_UserUtil.getRecordAccess(UserInfo.getUserId(), recordList);

        // Approval Lock
        Map<Id, Boolean> isLockMap;
        try{
            isLockMap = Approval.isLocked(recordList);
        }catch(Exception e){
            isLockMap = new Map<Id, Boolean>();
        }

        for(SObject record : recordList){
            CMP_RelatedListUtil.RecordCls recordCls = new CMP_RelatedListUtil.RecordCls();
            recordCls.record = record;

            UserRecordAccess recordAccess = accessMap.get(record.Id);
            recordCls.hasReadAccess = needAccessCheck ? recordAccess.HasReadAccess : true;
            recordCls.hasEditAccess = needAccessCheck ? recordAccess.HasEditAccess : true;
            recordCls.hasDeleteAccess = needAccessCheck ? recordAccess.HasDeleteAccess : true;
            recordCls.isLocked = isLockMap.isEmpty() ? false : isLockMap.get(record.Id);
            rc.recordList.add(recordCls);
        }

        rc.query = query;
        rc.countQuery = countQuery;
        return rc;
    }

    private List<SObject> queryRecord(String query){
        return Database.query(query);
    }

    private Integer countQueryRecord(String countQuery){
        return Database.countQuery(countQuery);
    }

    // =================================================================================================================
    // Sharing 구분을 위한 Inner Class
    public with sharing class WithSharing extends CMP_RelatedListViewAllAuraController{}
    public without sharing class WithoutSharing extends CMP_RelatedListViewAllAuraController{}

    // =================================================================================================================
    // 정보를 넣기위한 Inner Class

    public class InitCls {
        @AuraEnabled public String className = 'CMP_RelatedListViewAllAuraController';
        @AuraEnabled public CMP_RelatedListUtil.ResultCls data;
    }

    public class RefreshCls {
        @AuraEnabled public Integer totalRecordCount;
        @AuraEnabled public List<CMP_RelatedListUtil.RecordCls> recordList;
        @AuraEnabled public String query;
        @AuraEnabled public String countQuery;

        public RefreshCls(){
            this.recordList = new List<CMP_RelatedListUtil.RecordCls>();
        }
    }



}