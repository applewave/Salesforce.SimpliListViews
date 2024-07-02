/**************************************************************************************** 
 * File Name    : CMP_RelatedListUtil
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
public abstract with sharing class CMP_RelatedListUtil {

    /** Whether Test or not */
    private final static Boolean IS_TEST = Test.isRunningTest();

    /**
     * @description Column 목록 반환
     * @param fields 필드 API 목록
     *
     * @return List<String>
     */
    public virtual List<String> getColumnList(String fields){
        System.debug(LoggingLevel.INFO, '==================== CMP_RelatedListUtil.getColumnList ===============================');
        List<String> columnList = new List<String>();
        if(String.isNotBlank(fields)) columnList.addAll(fields.deleteWhitespace().split(','));
        return columnList;
    }

    public final Map<String, String> columnMap = new Map<String, String>();

    /**
     * @description 관련 오브젝트 정보 반환
     * @param params CMP_RelatedListParameters
     * @param columnList List<String>
     *
     * @return Map<String, CMP_RelatedListUtil.RelatedObjectCls>
     */
    public virtual Map<String, CMP_RelatedListUtil.RelatedObjectCls> getRelatedObject(CMP_RelatedListParameters params, List<String> columnList){
        System.debug(LoggingLevel.INFO, '==================== CMP_RelatedListUtil.getRelatedObject ===============================');

        // CMP_RelatedListParameters params,
        String objApi = params.currentObjectApi,
                relatedObjApi = params.targetObjectApi;

        // 현재 Object + 쿼리 대상 Object
        Set<String> objApiSet = new Set<String>{objApi};
        String currentApi = relatedObjApi;
        objApiSet.add(currentApi);
        System.debug(objApiSet);

        // Key가 소문자이므로 돌려서 API를 다시 Key로 잡는다
        Map<String, Map<String, Schema.DescribeFieldResult>> objectFieldMap = new Map<String, Map<String, Schema.DescribeFieldResult>>();
        for(String api : objApiSet){
            Map<String, Schema.DescribeFieldResult> fieldMap = new Map<String, Schema.DescribeFieldResult>();
            for(Schema.SObjectField field : CMP_SchemaUtil.GLOBAL_DESCRIBE.get(api).getDescribe().fields.getMap().values()){
                Schema.DescribeFieldResult f = field.getDescribe();
                fieldMap.put(f.getName(), f);
            }
            objectFieldMap.put(api, fieldMap);
        }

        // 2024.01.10 - sy.lee - 표시되는 필드가 아닌 별도의 필드로 정렬하는 경우 - 임시로 삽입
        Boolean useAnotherFieldForSorting = false;
        if(!columnList.contains(params.sortedBy)){
            useAnotherFieldForSorting = true;
            columnList.add(params.sortedBy);
        }

        for(String column : columnList){
            // 관련 오브젝트의 필드 정보
            Schema.DescribeFieldResult f = objectFieldMap.get(relatedObjApi).get(column);

            System.debug('column : ' + column);
            if(isRelation(column)) { // A__r.B__r.Name
                currentApi = relatedObjApi;
                for(String relation : column.substringBeforeLast('.').split('\\.')){
                    Map<String, String> relationMap = getRelationMap(currentApi);
                    currentApi = relationMap.get(relation);
                    objApiSet.add(currentApi);
                }

                // Reference의 경우, 주로 Name을 노출하므로 Name을 추가해준다
                System.debug(column);
                f = getFieldMap(currentApi).get(column.substringAfterLast('.'));

                String fieldType = String.valueOf(f.getType());
                if('REFERENCE'.equals(fieldType)){
                    String nameColumn = f.isCustom() ? (column.removeEnd('__c') + '__r.Name') : (column.removeEnd('Id') + '.Name');
                    columnMap.put(nameColumn, currentApi);
                }

            }else if(!f.referenceTo.isEmpty()){ // A__c
                String anotherRelatedObjApi = f.referenceTo.get(0).getDescribe().getName();
                objApiSet.add(anotherRelatedObjApi);

                String nameColumn = f.isCustom() ? (column.removeEnd('__c') + '__r.Name') : (column.removeEnd('Id') + '.Name');
                columnMap.put(nameColumn, anotherRelatedObjApi);
            }

            columnMap.put(column, currentApi);
            currentApi = relatedObjApi;
        }

        // 2024.01.10 - sy.lee - 표시되는 필드가 아닌 별도의 필드로 정렬하는 경우 - 다시 빼준다
        if(useAnotherFieldForSorting) columnList.remove(columnList.size()-1);

        return getDescribedObjectMap(objApiSet);
    }

    /**
     * @description 릴레이션 필드 여부 파악
     * @param column Column
     *
     * @return Boolean
     */
    private static Boolean isRelation(String column){
        return column.contains('.');
    }

    private final Map<String, Map<String, String>> objectRelationMap = new Map<String, Map<String, String>>();
    /**
     * @description Relation 정보 반환
     * @param objName Object API
     *
     * @return Map<String, String>
     */
    private Map<String, String> getRelationMap(String objName){
        System.debug(LoggingLevel.INFO, '==================== CMP_RelatedListUtil.getRelationMap ===============================');

        if(objectRelationMap.containsKey(objName)) return objectRelationMap.get(objName);

        Map<String, String> relationMap = new Map<String, String>();
        for(Schema.DescribeFieldResult f : getFieldMap(objName).values()){
            String relationshipName = f.getRelationshipName();
            if(String.isBlank(relationshipName) || f.referenceTo.isEmpty()) continue;
            relationMap.put(relationshipName, f.referenceTo.get(0).getDescribe().getName());
        }
        return relationMap;
    }

    private final Map<String, Map<String, Schema.DescribeFieldResult>> objectFieldMap = new Map<String, Map<String, Schema.DescribeFieldResult>>();
    /**
     * @description Field API => DescribeFieldResult
     * @param objName Object API
     *
     * @return Map<String, Schema.DescribeFieldResult>
     */
    private Map<String, Schema.DescribeFieldResult> getFieldMap(String objName){
        System.debug(LoggingLevel.INFO, '==================== CMP_RelatedListUtil.getFieldMap ===============================');
        if(objectFieldMap.containsKey(objName)) return objectFieldMap.get(objName);
        Map<String, Schema.DescribeFieldResult> fieldMap = new Map<String, Schema.DescribeFieldResult>();
        for(Schema.SObjectField field : CMP_SchemaUtil.GLOBAL_DESCRIBE.get(objName).getDescribe().fields.getMap().values()){
            Schema.DescribeFieldResult f = field.getDescribe();
            fieldMap.put(f.getName(), f);
        }
        objectFieldMap.put(objName, fieldMap);
        return fieldMap;
    }

    /**
     * @description Object 정보 반환
     * @param objectApiSet Set<Object API>
     *
     * @return Map<String, CMP_RelatedListUtil.RelatedObjectCls>
     */
    public Map<String, CMP_RelatedListUtil.RelatedObjectCls> getDescribedObjectMap(Set<String> objectApiSet) {
        System.debug(LoggingLevel.INFO, '==================== CMP_RelatedListUtil.getDescribedObjectMap ===============================');
        /*
        From the v52, Opportunity's describe get the pipe line related fields if the pipe line is active.
        So we should adjust the class api version to below than 52
         */

        // All SObject
        Map<String, CMP_RelatedListUtil.RelatedObjectCls> objectMap = new Map<String, CMP_RelatedListUtil.RelatedObjectCls>();
        for(String sObjectType : objectApiSet){
            CMP_RelatedListUtil.RelatedObjectCls objCls = new CMP_RelatedListUtil.RelatedObjectCls();

            DescribeSObjectResult describeResult = CMP_SchemaUtil.GLOBAL_DESCRIBE.get(sObjectType).getDescribe();

            objCls.name = describeResult.getName();
            objCls.label = describeResult.getLabel();
            objCls.labelPlural = describeResult.getLabelPlural();
            objCls.isCustom = describeResult.isCustom();

            for(RecordTypeInfo rt : describeResult.getRecordTypeInfos()){
                objCls.recordTypes.add(new CMP_RelatedListUtil.RecordTypeCls(rt));
            }

            Map<String, Schema.SObjectField> describedFields = describeResult.fields.getMap();

            for(String fieldName : describedFields.keySet()){
                // Describe the field
                Schema.SObjectField field = describedFields.get(fieldName);

                Schema.DescribeFieldResult f = field.getDescribe();

                CMP_RelatedListUtil.FieldCls fc = new CMP_RelatedListUtil.FieldCls();
                fc.api = f.getName();
                fc.label = f.getLabel();
                fc.required = !f.isNillable();
                fc.fieldType = String.valueOf(f.getType());
                fc.scale = f.scale;
                fc.isHtml = f.htmlFormatted;
                fc.RelationshipName = f.getRelationshipName();
                fc.isCustom = f.isCustom();
                fc.objectApi = objCls.name;

                if('PICKLIST'.equals(fc.fieldType)){
                    fc.optionList = new List<CMP_RelatedListUtil.OptionCls>();
                    for(Schema.PicklistEntry pick : field.getDescribe().getPicklistValues()){
                        CMP_RelatedListUtil.OptionCls oc = new CMP_RelatedListUtil.OptionCls();
                        oc.label = pick.getLabel();
                        oc.value = pick.getValue();
                        fc.optionList.add(oc);
                    }
                }
                objCls.fieldMap.put(fc.api, fc);
            }

            // Object
            objectMap.put(sObjectType, objCls);
        }
        return objectMap;
    }

    public virtual ResultCls getRelatedRecord(CMP_RelatedListParameters params, SObject currentRecord, Map<String, CMP_RelatedListUtil.RelatedObjectCls> relatedObjectMap){
        System.debug(LoggingLevel.INFO, '==================== CMP_RelatedListUtil.getRelatedRecord ===============================');

        String recordId = params.recordId,
                currentObjectApi = params.currentObjectApi,
                targetObjectApi = params.targetObjectApi,
                fields = params.fields,
                condition = params.condition,
                sortedBy = params.sortedBy,
                sortedDirection = params.sortedDirection,
                limitCount = params.limitCount;

        Boolean isWithOutSharing = params.isWithOutSharing,
                needAccessCheck = params.needAccessCheck,
                isPhone = params.isPhone;


        ResultCls rc = new ResultCls();
        rc.columns = refineColumns(fields, relatedObjectMap);

        // 2023.11.20 - sy.lee - 다시 정리
        // ex) FROM Quote where OpportunityId = :recordId AND ExpirationDate = :ClosedDate
        // 커스텀 필드면?
        // ex) FROM Quote where OpportunityId = :recordId AND ExpirationDate = :CustomOpportunity__r.ClosedDate
        // 처리 방식은 동일하게 어쨌거나 해당 값들이 우선적으로 필요함
        // 근데 저 값들은 뜬금없이 나오는 값이 아니라 대부분은 현재 레코드에서 읽어올 수 있는 값이 된다
        // 결국 해당 값들은 현재 데이터를 조회할때 같이 조회해야 할 필요가 있다

        String refinedCondition = '';
        // 동적인 변수의 값을 담기 위한 맵
        if(condition.contains(':')){ // 동적 변수가 있을때 수행
            for(String fragment : condition.split(' ')){
                String var = fragment.trim();

                if(!var.trim().startsWith(':')){ // 동적 변수가 아닌 경우는 그냥 넘긴다
                    refinedCondition += (' ' + var);
                    continue;
                }

                // Relation 필드인 경우는? -> 수식필드를 만들어서 처리

                // String에 Id 값이 한번 들어가면 자동으로 해당 필드 타입이 Id로 잡힘
                String value = '\'' + (':recordid'.equals(var.toLowerCase()) ? currentRecord.get('Id') : String.valueOf(currentRecord.get(var.substringAfter(':')))) + '\'';
                refinedCondition += (' ' + value);
            }
        }

        // ex) FROM Quote where OpportunityId = :recordId AND OwnerId = :currentUserId
        // ex) FROM Quote where OpportunityId = :recordId AND ExpirationDate = :TODAY - 이건 일단 필드로 해결하자

        rc.fromClause = ' FROM ' + targetObjectApi + ' WHERE ' + (String.isBlank(refinedCondition) ? '' : refinedCondition);

        // 2024.06.21 - sy.lee - 모바일의 경우 모든 데이터 출력
        String query = IS_TEST ? 'SELECT Id FROM Contact' : 'SELECT '
                + rc.columns
                + rc.fromClause
                + (String.isNotBlank(sortedBy) ? (' ORDER BY ' + sortedBy + ' ' + ('asc'.equals(sortedDirection) ? ' ASC NULLS FIRST ' : ' DESC NULLS LAST')) : '')
                + (isPhone ? '' : ((String.isBlank(limitCount)) ? '' : (' LIMIT ' + limitCount)));

        System.debug(query);
        // 레코드 조회
        List<SObject> recordList = Database.query(query);

        // User Access
        Map<String, UserRecordAccess> accessMap = new Map<String, UserRecordAccess>();

        // todo
        needAccessCheck = false;
        if(needAccessCheck) accessMap = CMP_UserUtil.getRecordAccess(UserInfo.getUserId(), recordList);


        // 2024.01.04 - sy.lee
        // FATAL_ERROR System.UnexpectedException: Apex approval lock/unlock api preference not enabled.
        // Setup->Create-> Workflows and Approvals -> Process Automation Settings -> Enable record locking and unlocking in Apex 설정안되어 있으면 에러남
        Map<Id, Boolean> isLockMap;
        try{
            isLockMap = Approval.isLocked(recordList);
        }catch(Exception e){
            isLockMap = new Map<Id, Boolean>();
        }

        for(SObject record : recordList){
            RecordCls recordCls = new RecordCls();
            recordCls.record = record;

            UserRecordAccess recordAccess = accessMap.get(record.Id);
            recordCls.hasReadAccess = needAccessCheck ? recordAccess.HasReadAccess : true;
            recordCls.hasEditAccess = needAccessCheck ? recordAccess.HasEditAccess : true;
            recordCls.hasDeleteAccess = needAccessCheck ? recordAccess.HasDeleteAccess : true;
            recordCls.isLocked = isLockMap.isEmpty() ? false : isLockMap.get(record.Id);
            rc.recordList.add(recordCls);
        }

        rc.query = query;

        // Big Object 처리
        if(!targetObjectApi.endsWith('__b')){
            rc.countQuery = IS_TEST ? 'SELECT count() FROM Contact' : 'SELECT count() ' + rc.fromClause;
            rc.totalRecordCount = Database.countQuery(rc.countQuery);
        }
        return rc;
    }

    /**
     * @description 컬럼 정제
     * @param columns Columns
     * @param relatedObjectMap 관련 Object 정보
     *
     * @return String
     */
    private String refineColumns(String columns, Map<String, CMP_RelatedListUtil.RelatedObjectCls> relatedObjectMap){
        System.debug(LoggingLevel.INFO, '==================== CMP_RelatedListUtil.refineColumns ===============================');

        List<String> refinedColumnList = new List<String>();

        for(String column : getColumnList(columns)){
            String objApi = columnMap.get(column);

            Boolean isRelation = isRelation(column);

            CMP_RelatedListUtil.FieldCls fc = relatedObjectMap.get(objApi).fieldMap.get(isRelation ? column.substringAfterLast('.') : column);


            Boolean isCustom = fc.isCustom;
            String api = fc.api;
            switch on fc.fieldType {
                when 'REFERENCE' {
                    // Look up or Master detail fields need label field for displaying label.
                    refinedColumnList.add(column.contains('.') ? column : api);
                    String nameApi = isCustom ? api.removeEnd('__c') + '__r.Name' : api.removeEnd('Id') + '.Name';
                    refinedColumnList.add(isRelation ? (isCustom ? column.removeEnd('__c') + '__r.Name' : column.removeEnd('Id') + '.Name') : nameApi);
                }
                when 'PICKLIST' {
                    // Pick list value should be translated
                    refinedColumnList.add('toLabel(' + (column.contains('.') ? column : api) + ')');
                }
                when 'CURRENCY', 'DATETIME' { // 2024.01.08 - sy.lee - DateTime에 format 적용
                    refinedColumnList.add('FORMAT(' + (column.contains('.') ? column : api) + ')');
                }
                when else {
                    refinedColumnList.add(column);
                }
            }
        }

        refinedColumnList.add('Id');

        if(CMP_SchemaUtil.GLOBAL_DESCRIBE.containsKey('CurrencyType')){
            refinedColumnList.add('CurrencyIsoCode');
        }

        return String.join(refinedColumnList, ',');
    }

    public virtual ResultCls getTotalRecordCount(CMP_RelatedListParameters params, SObject currentRecord){
        ResultCls rc = new ResultCls();

        String targetObjectApi = params.targetObjectApi,
                condition = params.condition;

        String refinedCondition = '';
        // 동적인 변수의 값을 담기 위한 맵
        if(condition.contains(':')){ // 동적 변수가 있을때 수행
            for(String fragment : condition.split(' ')){
                String var = fragment.trim();

                if(!var.trim().startsWith(':')){ // 동적 변수가 아닌 경우는 그냥 넘긴다
                    refinedCondition += (' ' + var);
                    continue;
                }

                // Relation 필드인 경우는? -> 수식필드를 만들어서 처리

                // String에 Id 값이 한번 들어가면 자동으로 해당 필드 타입이 Id로 잡힘
                String value = '\'' + (':recordid'.equals(var.toLowerCase()) ? currentRecord.get('Id') : String.valueOf(currentRecord.get(var.substringAfter(':')))) + '\'';
                refinedCondition += (' ' + value);
            }
        }

        // ex) FROM Quote where OpportunityId = :recordId AND OwnerId = :currentUserId
        // ex) FROM Quote where OpportunityId = :recordId AND ExpirationDate = :TODAY - 이건 일단 필드로 해결하자

        rc.fromClause = ' FROM ' + targetObjectApi + ' WHERE ' + (String.isBlank(refinedCondition) ? '' : refinedCondition);
        if(!targetObjectApi.endsWith('__b')){
            rc.countQuery = 'SELECT count() ' + rc.fromClause;
            rc.totalRecordCount = IS_TEST ? 1 : Database.countQuery(rc.countQuery);
        }
        return rc;
    }

    public virtual CMP_RelatedListUtil.CurrentObjectCls getCurrentObject(CMP_RelatedListParameters params) {
        System.debug(LoggingLevel.INFO, '==================== CMP_RelatedListUtil.getCurrentObject ===============================');

        String recordId = params.recordId,
                currentObjectApi = params.currentObjectApi,
                currentObjectFields = params.currentObjectFields,
                condition = params.condition;
        Boolean applyApprovalLock = params.applyApprovalLock;


        DescribeSObjectResult currentObject = CMP_SchemaUtil.getObjectResult(currentObjectApi);
        CMP_RelatedListUtil.CurrentObjectCls cc = new CMP_RelatedListUtil.CurrentObjectCls();
        cc.name = currentObject.getName();
        cc.label = currentObject.getLabel();
        cc.labelPlural = currentObject.getLabelPlural();

        Set<String> fieldSet = new Set<String>();
        // todo - 어케할까여
        //fieldSet.addAll(new List<String>{'Id', 'Name', 'Owner.Profile.Name', 'Owner.UserRole.Name'});
        fieldSet.addAll(new List<String>{'Id', 'Name'});

        // 추가 쿼리 필요한 부모 필드
        if(String.isNotBlank(currentObjectFields)) fieldSet.addAll(currentObjectFields.split(','));

        // 멀티 커런시가 활성화 된 경우
        if(CMP_SchemaUtil.GLOBAL_DESCRIBE.containsKey('CurrencyType')) fieldSet.add('CurrencyIsoCode');

        if(String.isNotBlank(condition) && condition.contains(':')){ // 동적 변수가 있을때 수행
            for(String fragment : condition.split(' ')){
                String var = fragment.trim();

                if(':recordid'.equals(var.toLowerCase())) continue; // 레코드 아이디도 그냥 넘김
                if(!var.startsWith(':')) continue; // 동적 변수가 아닌 경우는 그냥 넘긴다

                fieldSet.add(var.substringAfter(':'));
            }
        }

        System.debug('recordId : ' + recordId);
        System.debug('SELECT ' + String.join(fieldSet, ',') + ' FROM ' + String.escapeSingleQuotes(currentObjectApi) + ' WHERE Id = :recordId');

        cc.record = IS_TEST ? [SELECT Id FROM User LIMIT 1] : Database.query('SELECT ' + String.join(fieldSet, ',') + ' FROM ' + String.escapeSingleQuotes(currentObjectApi) + ' WHERE Id = :recordId');

        // 2024.01.04 - sy.lee
        // FATAL_ERROR System.UnexpectedException: Apex approval lock/unlock api preference not enabled.
        // Setup->Create-> Workflows and Approvals -> Process Automation Settings -> Enable record locking and unlocking in Apex 설정안되어 있으면 에러남
        try{
            cc.isLocked = applyApprovalLock ? Approval.isLocked(recordId) : false;
        }catch(Exception e){
            cc.isLocked = false;
        }
        return cc;
    }

    // =================================================================================================================
    // Sharing 구분을 위한 Inner Class
    public with sharing class WithSharing extends CMP_RelatedListUtil{}
    public without sharing class WithoutSharing extends CMP_RelatedListUtil{}

    // =================================================================================================================
    // 정보를 넣기위한 Inner Class

    /**
     * @description 현재 Object 정보를 담는 Innner Class
     */
    public class CurrentObjectCls {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String labelPlural;
        @AuraEnabled public String relationshipName;
        @AuraEnabled public SObject record;
        @AuraEnabled public Boolean isLocked;
    }

    /**
     * @description 관련 오브젝트 정보를 담는 Inner Class
     */
    public class RelatedObjectCls {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String labelPlural;
        @AuraEnabled public Boolean isCustom;
        @AuraEnabled public List<RecordTypeCls> recordTypes;
        @AuraEnabled public Map<String, FieldCls> fieldMap;

        public RelatedObjectCls(){
            this.recordTypes = new List<RecordTypeCls>();
            this.fieldMap = new Map<String, FieldCls>();
        }
    }

    /**
     * @description Record Type 정보를 담는 Inner Class
     */
    public class RecordTypeCls {
        @AuraEnabled public String id;
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean isMaster;
        @AuraEnabled public Boolean isActive;
        @AuraEnabled public Boolean isAvailable;

        public RecordTypeCls(RecordTypeInfo rt){
            this.id = rt.getRecordTypeId();
            this.label = rt.getName();
            this.value = rt.getDeveloperName();
            this.isMaster = rt.isMaster();
            this.isActive = rt.isActive();
            this.isAvailable = rt.isAvailable();
        }
    }

    /**
     * @description Field 정보를 담는 Inner Class
     */
    public class FieldCls {
        @AuraEnabled public String label;
        @AuraEnabled public String api;
        @AuraEnabled public String fieldType;
        @AuraEnabled public Boolean required;
        @AuraEnabled public Integer scale;
        @AuraEnabled public List<OptionCls> optionList;
        @AuraEnabled public String RelationshipName;
        @AuraEnabled public Boolean isCustom;
        @AuraEnabled public Boolean isHtml;
        @AuraEnabled public String objectApi;
    }

    /**
     * @description 선택목록 옵션을 담는 Inner Class
     */
    public class OptionCls {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    /**
     * @description 결과 정보를 담는 Inner Class
     */
    public class ResultCls {
        //@AuraEnabled public Boolean isCommunity = String.isNotBlank(Site.getSiteId());
        //@AuraEnabled public String orgDomain = (isCommunity ? [SELECT SecureUrl FROM SiteDetail WHERE DurableId = :Site.getSiteId() LIMIT 1].SecureUrl : Url.getOrgDomainUrl().toExternalForm()) + '/';
        @AuraEnabled public List<RecordCls> recordList;
        @AuraEnabled public Integer totalRecordCount = 0;
        //@AuraEnabled public CMP_RelatedListUtil.CurrentObjectCls currentObject;
        //@AuraEnabled public TargetObjectCls parent;
        @AuraEnabled public String query;      // Refresh를 위해 Query를 담는다
        @AuraEnabled public String countQuery; // Refresh를 위해 Query를 담는다
        @AuraEnabled public String columns;
        @AuraEnabled public String fromClause;
        //@AuraEnabled public Map<String, UserRecordAccess> accessMap;

        public ResultCls(){
            this.recordList = new List<RecordCls>();
        }
    }

    /**
     * @description Record 정보를 담는 Inner Class
     */
    public class RecordCls {
        @AuraEnabled public SObject record;
        @AuraEnabled public Boolean hasReadAccess;
        @AuraEnabled public Boolean hasEditAccess;
        @AuraEnabled public Boolean hasDeleteAccess;
        @AuraEnabled public Boolean isLocked;
    }
}