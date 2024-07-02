/**************************************************************************************** 
 * File Name    : CMP_RelatedListController
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
public with sharing class CMP_RelatedListController {

    /** Whether Test or not */
    private final static Boolean IS_TEST = Test.isRunningTest();

    /**
     * @description CMP_RelatedListUtil 인스턴스 생성
     */
    public static CMP_RelatedListUtil instance;
    public static CMP_RelatedListUtil getInstance(CMP_RelatedListParameters params) {
        if (instance == null) {
            instance = params.isWithOutSharing ? (CMP_RelatedListUtil)new CMP_RelatedListUtil.WithoutSharing() : (CMP_RelatedListUtil)new CMP_RelatedListUtil.WithSharing();
        }
        return instance;
    }

    /**
     * @description 현재 사용자 아이디
     */
    private static String currentUserId {
        get{
            if(String.isBlank(currentUserId)){
                currentUserId = UserInfo.getUserId();
            }
            return currentUserId;
        }
        set;
    }

    /**
     * @description Desktop & Mobile 둘다 여기로 들어온다
     * @param params CMP_RelatedListParameters
     *
     * @return 상황에 맞는 데이터 리턴
     */
    @AuraEnabled
    public static InitCls init(CMP_RelatedListParameters params) {
        return params.isPhone ? initMobile(params) : initDesktop(params);
    }

    /**
     * @description 모바일 처음 화면
     * @param params CMP_RelatedListParameters
     *
     * @return InitCls
     */
    @AuraEnabled
    public static InitCls initMobile(CMP_RelatedListParameters params) {
        System.debug(LoggingLevel.INFO, '==================== CMP_RelatedListController.initMobile ===============================');
        InitCls ic = new InitCls();
        ic.currentObject = getInstance(params).getCurrentObject(params);
        ic.data = getInstance(params).getTotalRecordCount(params, ic.currentObject.record);
        ic.relatedObject = getInstance(params).getDescribedObjectMap(new Set<String>{params.targetObjectApi});
        return ic;
    }

    /**
     * @description Init - Desktop & Tablet
     * @param params CMP_RelatedListParameters
     *
     * @return InitCls
     */
    @AuraEnabled
    public static InitCls initDesktop (CMP_RelatedListParameters params) {
        System.debug(LoggingLevel.INFO, '==================== CMP_RelatedListController.initDesktop ===============================');
        System.debug(params);

        InitCls ic = new InitCls();
        // 현재 사용자
        ic.currentUser = CMP_UserUtil.getUserInfo(currentUserId);
        // 현재 오브젝트 및 레코드 정보
        ic.currentObject = getInstance(params).getCurrentObject(params);
        // 컬럼 정보
        ic.columnList = getInstance(params).getColumnList(params.fields);
        // 관련 오브젝트 및 레코드 정보
        ic.relatedObject = getInstance(params).getRelatedObject(params, ic.columnList);
        // 컬럼 맵
        ic.columnMap = getInstance(params).columnMap;
        // 데이터
        ic.data = getInstance(params).getRelatedRecord(params, ic.currentObject.record, ic.relatedObject);

        // 2023.10.17 - Allow users to relate a contact to multiple accounts - relationship name is different
        //ic.allowContactToMultipleAccount = CMP_SchemaUtil.GLOBAL_DESCRIBE.containsKey('AccountContactRelation');
        return ic;
    }

    /**
     * @description Refresh
     * @param query query
     * @param countQuery countQuery
     * @param needAccessCheck access 확인 여부
     *
     * @return RefreshCls
     */
    @AuraEnabled
    public static RefreshCls refresh(String query, String countQuery, Boolean needAccessCheck) {
        RefreshCls rc = new RefreshCls();
        // 레코드 수
        rc.totalRecordCount = Database.countQuery(countQuery);
        // 데이터
        List<SObject> recordList = Database.query(query);

        // todo
        needAccessCheck = false;
        // User Access
        Map<String, UserRecordAccess> accessMap = new Map<String, UserRecordAccess>();
        if(needAccessCheck) accessMap = CMP_UserUtil.getRecordAccess(UserInfo.getUserId(), recordList);

        // Approval Lock
        Map<Id, Boolean> isLockMap;
        try {
            isLockMap = Approval.isLocked(recordList);
        }catch(Exception e) {
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

    /**
     * @description 레코드 삭제
     * @param rowId
     */
    @AuraEnabled
    public static void deleteRecord(String rowId) {
        if(!IS_TEST) delete Database.query('SELECT Id FROM ' + CMP_SchemaUtil.getObjectApi(rowId) + ' WHERE Id = \'' + rowId +'\'');
    }

    /**
     * @description 데이터 excel 추출
     * @param query 쿼리
     *
     * @return List<SObject>
     */
    @AuraEnabled(Cacheable = true)
    public static List<SObject> export(String query) {
        return Database.query(query);
    }

    /** Init Class */
    public class InitCls {
        @AuraEnabled public String className = 'RelatedListController';
        @AuraEnabled public User currentUser;
        @AuraEnabled public CMP_RelatedListUtil.CurrentObjectCls currentObject;
        @AuraEnabled public Map<String, CMP_RelatedListUtil.RelatedObjectCls> relatedObject;
        @AuraEnabled public Boolean isCommunity = String.isNotBlank(Site.getSiteId());
        @AuraEnabled public String orgDomain = (isCommunity ? [SELECT SecureUrl FROM SiteDetail WHERE DurableId = :Site.getSiteId() LIMIT 1].SecureUrl : Url.getOrgDomainUrl().toExternalForm()) + '/';
        @AuraEnabled public Map<String, String> columnMap;
        @AuraEnabled public List<String> columnList;
        @AuraEnabled public CMP_RelatedListUtil.ResultCls data;
        @AuraEnabled public Boolean allowContactToMultipleAccount;
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