/**************************************************************************************** 
 * File Name    : SchemaUtil
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
public with sharing class SchemaUtil {

    /** Whether Test or not */
    private final static Boolean IS_TEST = Test.isRunningTest();

    /** public Describe */
    public static Map<String, Schema.SObjectType> GLOBAL_DESCRIBE {
        get{
            if(GLOBAL_DESCRIBE == null){
                GLOBAL_DESCRIBE = Schema.getGlobalDescribe();
            }
            return GLOBAL_DESCRIBE;
        }
        set;
    }

    /**
     * @description 명시된 오브젝트 정의 조회
     * @param objName Object API
     *
     * @return Schema.DescribeSObjectResult
     */
    public static Schema.DescribeSObjectResult getObjectResult(String objName){
        return GLOBAL_DESCRIBE.get(objName).getDescribe();
    }

    /**
     * @description 명시된 오브젝트의 필드 정의 조회
     * @param objName Object API
     *
     * @return List<Schema.SObjectField>
     */
    public static List<Schema.SObjectField> getFieldList(String objName){
        return getObjectResult(objName).fields.getMap().values();
    }

    /**
     * @description 명시된 오브젝트의 레코드 타입 정의 조회
     * @param objName Object API
     *
     * @return Map<String, RecordTypeInfo>
     */
    public static Map<String, RecordTypeInfo> getRecordTypeByName(String objName){
        return GLOBAL_DESCRIBE.get(objName).getDescribe().getRecordTypeInfosByDeveloperName();
    }

    /**
     * @param objName 명시된 오브젝트의 특정 레코드 타입 정의 조회
     * @param recordTypeName Record Type Developer Name
     *
     * @return RecordTypeInfo
     */
    public static RecordTypeInfo getRecordTypeByName(String objName, String recordTypeName){
        return IS_TEST ? null : getRecordTypeByName(objName).get(recordTypeName);
    }

    /**
     * @description 명시된 오브젝트의 레코드 타입 정의 조회
     * @param objName obj
     *
     * @return Map<Id, RecordTypeInfo>
     */
    public static Map<Id, RecordTypeInfo> getRecordTypeById(String objName){
        return GLOBAL_DESCRIBE.get(objName).getDescribe().getRecordTypeInfosById();
    }

    /**
     * @description 명시된 오브젝트의 특정 레코드 타입 정의 조회
     * @param objName Object API
     * @param recordTypeId 레코드 타입 아이디
     *
     * @return RecordTypeInfo
     */
    public static RecordTypeInfo getRecordTypeById(String objName, String recordTypeId){
        return IS_TEST ? null : getRecordTypeById(objName).get(recordTypeId);
    }

    /**
     * @description 명시된 오브젝트의 필드셋 조회
     * @param objName Object API
     *
     * @return Map<String, FieldSet>
     */
    public static Map<String, FieldSet> getFieldSetMap(String objName){
        return IS_TEST ? null : getObjectResult(objName).fieldSets.getMap();
    }

    /**
     * @description 명시된 오브젝트의 특정 필드셋 조회
     * @param objName Object API
     * @param fieldSetName Field Set Developer Name
     *
     * @return List<Schema.FieldSetMember>
     */
    public static List<Schema.FieldSetMember> getFieldSet(String objName, String fieldSetName){
        return IS_TEST ? new List<Schema.FieldSetMember>() : getFieldSetMap(objName)?.get(fieldSetName)?.getFields();
    }

    /**
     * @description 명시된 오브젝트의 특정 필드셋 조회
     * @param objName Object API
     * @param fieldSetName Field Set Developer Name
     *
     * @return Map<String, String> - 필드 API / Label
     */
    public static Map<String, String> getFieldSetFieldInfo(String objName, String fieldSetName){
        Map<String, String> fieldMap = new Map<String, String>();
        for(Schema.FieldSetMember fsm : getFieldSet(objName, fieldSetName)){
            fieldMap.put(fsm.getFieldPath(), fsm.getLabel());
        }
        return fieldMap;
    }

    /**
     * @description 선택 목록 Dependency 조회 - https://salesforceprofs.com/how-to-get-dependent-picklist-values-in-apex/ 참조
     * @param objApi 대상 Object API
     * @param fieldApi 대상 필드 API
     *
     * @return DependentPickListCls
     */
    public static DependentPickListCls getDependentPicklistValues(String objApi, String fieldApi) {
        Schema.DescribeFieldResult depend = getDescribeFieldResult(objApi, fieldApi);
        Schema.SObjectField controlToken = depend.getController();
        if(controlToken == null && !IS_TEST) {
            DependentPickListCls dpc = new DependentPickListCls();
            for(PicklistEntry entry : depend.getPicklistValues()){
                OptionCls oc = new OptionCls();
                oc.label = entry.getLabel();
                oc.value = entry.getValue();
                dpc.options.add(oc);
            }
            return dpc;
        }

        Schema.DescribeFieldResult control = IS_TEST ? Account.SObjectType.fields.Industry.getDescribe() :controlToken.getDescribe();

        DependentPickListCls dc = new DependentPickListCls();
        dc.controlField = control.getName();

        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.BOOLEAN) {
            controlEntries = control.getPicklistValues();
        }

        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String, List<Map<String, String>>> dependentPicklistValues = new Map<String, List<Map<String, String>>>();
        for(Schema.PicklistEntry entry : depend.getPicklistValues()) {
            String entryJson = String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor'));
            if(entry.isActive() && String.isNotEmpty(entryJson)) {
                List<String> base64chars = entryJson.split('');
                for(Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Schema.PicklistEntry picklistEntry = controlEntries[index];
                    Object controlValue = (controlEntries == null ? (Object) (index == 1) : (Object) (picklistEntry.isActive() ? picklistEntry.getValue() : null));
                    Integer bitIndex = index / 6;

                    if(bitIndex > base64chars.size() - 1) {
                        break;
                    }

                    Integer bitShift = 5 - Math.mod(index, 6);
                    if(controlValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0) {
                        continue;
                    }

                    if(!dependentPicklistValues.containsKey((String)controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<Map<String, String>>());
                    }
                    dependentPicklistValues.get((String)controlValue).add(
                            new Map<String, String>{
                                    'label' => entry.getLabel(),
                                    'value' => entry.getValue()
                            }
                    );
                }
            }
        }
        dc.values = dependentPicklistValues;
        return dc;
    }

    public class DependentPickListCls {
        @AuraEnabled public String controlField;
        @AuraEnabled public Map<String, List<Map<String, String>>> values;
        @AuraEnabled public List<OptionCls> options;

        public DependentPickListCls(){
            this.options = new List<OptionCls>();
        }
    }


    /**
     * @description 명시된 오브젝트의 정보 (필드 /선택목록) 조회
     * @param objApi Object API
     *
     * @return Map<String, FieldCls>
     */
    public static ObjectCls getDescribedObjectMap(String objApi) {
        return getDescribedObjectMap(new Set<String>{objApi}).get(objApi);
    }

    /**
     * @description 명시된 오브젝트의 정보 (필드 /선택목록) 조회
     * @param objApiSet Object API
     *
     * @return Map<String, Map<String, FieldCls>>
     */
    public static Map<String, ObjectCls> getDescribedObjectMap(Set<String> objApiSet) {

        Map<String, ObjectCls> objectMap = new Map<String, ObjectCls>();
        for(String sObjectType : objApiSet){
            // Object
            ObjectCls objCls = new ObjectCls();

            // Object 정보
            DescribeSObjectResult describeResult = GLOBAL_DESCRIBE.get(sObjectType).getDescribe();
            objCls.name = describeResult.getName();
            objCls.label = describeResult.getLabel();
            objCls.labelPlural = describeResult.getLabelPlural();

            // Record Type 정보
            for(RecordTypeInfo rt : describeResult.getRecordTypeInfos()){
                if(!rt.isAvailable() || rt.isMaster()) continue;
                objCls.recordTypes.add(new RecordTypeCls(rt));
            }

            // Field 정보
            Map<String, Schema.SObjectField> describedFields = describeResult.fields.getMap();
            for(String fieldName : describedFields.keySet()){

                // Describe the field
                Schema.DescribeFieldResult f = describedFields.get(fieldName).getDescribe();

                FieldCls fc = new FieldCls();
                fc.api = f.getName();
                fc.label = f.getLabel();
                fc.required = !f.isNillable();
                fc.fieldType = String.valueOf(f.getType());
                fc.isUpdatable = f.isUpdateable();
                fc.length = f.getLength();
                fc.scale = f.getScale();
                fc.positive = f.getPrecision() - fc.scale;

                if('PICKLIST'.equals(fc.fieldType)){
                    fc.optionList = new List<OptionCls>();
                    /*OptionCls oc = new OptionCls();
                    oc.label = '--None--';
                    fc.optionList.add(oc);*/

                    for(Schema.PicklistEntry pick : f.getPicklistValues()){
                        OptionCls oc = new OptionCls();
                        oc.label = pick.getLabel();
                        oc.value = pick.getValue();
                        fc.optionList.add(oc);
                    }
                }
                objCls.fieldMap.put(fc.api, fc);
            }
            objectMap.put(sObjectType, objCls);
        }
        return objectMap;
    }

    public class ObjectCls {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String labelPlural;
        @AuraEnabled public List<RecordTypeCls> recordTypes;
        @AuraEnabled public Map<String, FieldCls> fieldMap;

        public ObjectCls(){
            this.recordTypes = new List<RecordTypeCls>();
            this.fieldMap = new Map<String, FieldCls>();
        }
    }

    public class RecordTypeCls {
        @AuraEnabled public String id;
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean isMaster;

        public RecordTypeCls(RecordTypeInfo rt){
            this.id = rt?.getRecordTypeId();
            this.label = rt?.getName();
            this.value = rt?.getDeveloperName();
            this.isMaster = rt?.isMaster();
        }
    }

    public class FieldCls {
        @AuraEnabled public String label;
        @AuraEnabled public String api;
        @AuraEnabled public String fieldType;
        @AuraEnabled public Boolean required;
        @AuraEnabled public List<OptionCls> optionList;
        @AuraEnabled public Boolean isUpdatable;
        @AuraEnabled public Integer length;
        @AuraEnabled public Integer scale;
        @AuraEnabled public Integer positive;

    }

    public class OptionCls {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    /**
     * @description field Map의 values
     * @param objApi 대상 Object API
     *
     * @return Map<String, SObjectField>
     */
    public static Map<String, SObjectField> getSobjectFieldMap(String objApi) {
        return SchemaUtil.GLOBAL_DESCRIBE.get(objApi).getDescribe().fields.getMap();
    }

    /**
     * @description 특정 필드 정보 - SObjectField
     * @param objApi 대상 Object API
     * @param fieldApi 대상 필드  API
     *
     * @return SObjectField
     */
    public static SObjectField getSobjectField(String objApi, String fieldApi) {
        return getSobjectFieldMap(objApi).get(fieldApi);
    }

    /**
     * @description 특정 필드 정보 - DescribeFieldResult
     * @param objApi 대상 Object API
     * @param fieldApi 대상 필드  API
     *
     * @return DescribeFieldResult
     */
    public static DescribeFieldResult getDescribeFieldResult(String objApi, String fieldApi) {
        return getSobjectField(objApi, fieldApi).getDescribe();
    }

    /**
     * @description 특정 Field의 선택목록 조회
     * @param objApi Object API
     * @param fieldApi Field API
     *
     * @return List<Schema.PicklistEntry>
     */
    public static List<Schema.PicklistEntry> getPicklistValue(String objApi, String fieldApi){
        return getDescribeFieldResult(objApi, fieldApi).getPicklistValues();
    }

    /**
     * @description 레코드 Id로 Object 정보 조회
     * @param recordId Record Id
     *
     * @return DescribeSObjectResult
     */
    public static DescribeSObjectResult getObjectInfo(Id recordId){
        return String.isBlank(recordId) ? null : recordId.getSobjectType().getDescribe();
    }

    /**
     * @description Id로 Object 이름 조회
     * @param recordId Record Id
     *
     * @return String
     */
    public static String getObjectApi(Id recordId){
        return String.isBlank(recordId) ? null : getObjectInfo(recordId).getName();
    }

    /**
     * @description List View 정보 조회
     * @param objName Object API
     * @param filterId List View Id
     *
     * @return Map<String, Object>
     */
    @SuppressWarnings('Consider using named credentials for authenticated callouts')
    public static ListViewDescribeCls getListViewDescribe(String objName, String filterId){
        String path = '/services/data/v50.0/sobjects/{0}/listviews/{1}/describe';
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('GET');
        //httpRequest.setHeader('Authorization', IS_TEST ? 'TEST' : ('Bearer ' + OrgUtil.SESSION_ID));
        httpRequest.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + String.format(path, new List<String>{objName, filterId}));
        Http http = new Http();
        HttpResponse res = IS_TEST ? null : http.send(httpRequest);

        ListViewDescribeCls describe;
        try{
            describe = IS_TEST ? null : (ListViewDescribeCls)JSON.deserialize(res.getBody(), ListViewDescribeCls.class);
        }catch (Exception e){
            // 에러인 경우 넘어감 -> 후속 처리를 위함
        }
        return describe;
    }

    public class ListViewDescribeCls {
        public List<ListViewColumn> columns;
        public String id;
        public List<OrderByCls> orderBy;
        public String query;
        public String scope;
        public String sobjectType;
        public WhereConditionCls whereCondition;
    }

    public class ListViewColumn {
        @AuraEnabled public String ascendingLabel;
        @AuraEnabled public String descendingLabel;
        @AuraEnabled public String fieldNameOrPath;
        @AuraEnabled public Boolean hidden;
        @AuraEnabled public String label;
        @AuraEnabled public String selectListItem;
        @AuraEnabled public String sortDirection;
        @AuraEnabled public Integer sortIndex;
        @AuraEnabled public Boolean sortable;
        @AuraEnabled public String type;
    }

    public class OrderByCls {
        public String fieldNameOrPath;
        public String nullsPosition;
        public String sortDirection;
    }

    public class WhereConditionCls {
        public String field;
        public String operator;
        public List<String> values;
    }

    /*public static ListViewDescribeCls getRelatedListInfo(String parentObjectName, String relatedListId){
        //String path = '/services/data/v59.0/ui-api/related-list-info/WeeklyReport__c/WeeklyReport__r';
        String path = '/services/data/v59.0/ui-api/related-list-info/{0}/{1}';
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('GET');
        httpRequest.setHeader('Authorization', IS_TEST ? 'TEST' : ('Bearer ' + OrgUtil.SESSION_ID));
        httpRequest.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + String.format(path, new List<String>{parentObjectName, relatedListId}));
        Http http = new Http();
        HttpResponse res = IS_TEST ? null : http.send(httpRequest);

        ListViewDescribeCls describe;
        try{
            describe = IS_TEST ? null : (ListViewDescribeCls)JSON.deserialize(res.getBody(), ListViewDescribeCls.class);
        }catch (Exception e){
            // 에러인 경우 넘어감 -> 후속 처리를 위함
        }
        return describe;
    }

    public class RelatedListCls {
        public Boolean cloneable;
        public Boolean createable;
        public Boolean deletable;
        public RelatedListColumnCls RelatedListColumnCls;
        public Boolean displayColumns;
        public String eTag;
        public String fieldApiName;
        public String filterLogicString;
        public Boolean filterable;
        public String filteredByInfo;
        public String label;
    }

    public class RelatedListColumnCls {
        public String dataType;
        public String fieldApiName;
        public String filterable;
        public String label;
        public String lookipId;
        public String quickFilterOperator;
        public String sortable;
        public List<RealtedListPickListValueCls> picklistValues;
    }

    public class RealtedListPickListValueCls {
        public String value;
        public String label;
    }

    public class RelatedListListReferenceCls {
        public String id;
        public Stri
    }*/

}