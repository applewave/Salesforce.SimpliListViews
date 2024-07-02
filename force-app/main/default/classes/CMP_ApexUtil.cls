/**************************************************************************************** 
 * File Name    : CMP_ApexUtil
 * Author       : sy.lee
 * Date         : 2023-10-17
 * Description  : 
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * =============================================================== 
 * Ver      Date 		Author    			Modification
 * ===============================================================
   1.0		2023-10-17 	sy.lee			    Create
   1.1      2024-02.21  sy.lee              Modified
                - getUUID 메소드 추가

****************************************************************************************/
public with sharing class CMP_ApexUtil {

    /** Whether Test or not */
    private static final Boolean IS_TEST = Test.isRunningTest();

    // 배치 여부
    public final static Boolean IS_BATCH = System.isBatch();
    // Future 여부
    public final static Boolean IS_FUTURE = System.isFuture();
    // Queueable 여부
    public final static Boolean IS_QUEUEABLE = System.isQueueable();
    // Async 여부
    public final static Boolean IS_ASYNC = (IS_BATCH || IS_FUTURE || IS_QUEUEABLE);

    /**
     * @description URL Encode
     * @param str String
     *
     * @return String
     */
    public static String getUrlEncode(String str) {
        return String.isBlank(str) ? null : EncodingUtil.urlEncode(str, 'UTF-8');
    }

    /**
     * @description 암호화 - SHA1 등등
     * @param method 암호화 방법
     * @param key Key
     *
     * @return String
     */
    public static String getEncrypted(String method, String key) {
        return EncodingUtil.convertToHex(Crypto.generateDigest(method, Blob.valueOf(key)));
    }

    /**
     * @description 모든 필드를 포함한 쿼리 String을 반환
     * @param objApi Object API
     *
     * @return String
     */
    public static String getAllFieldQuery(String objApi) {
        String query = 'SELECT ';

        query += String.join(getAllField(objApi), ',');
        query += ' FROM ' + objApi;

        return query;
    }

    /**
     * @description 모든 필드 API 리스트 반환
     * @param objApi Object API
     *
     * @return List<String>
     */
    public static List<String> getAllField(String objApi) {
        List<String> fieldList = new List<String>();
        for (SObjectField field : CMP_SchemaUtil.getFieldList(objApi)) {
            fieldList.add(field.getDescribe().name);
        }
        return fieldList;
    }

    /**
     * @description Email 유효성 검사
     * @param email String
     *
     * @return 유효 여부
     */
    public static Boolean isValidEmail(String email) {
        return String.isBlank(email) ? false : Pattern.matches('[a-zA-Z0-9]+[a-zA-Z0-9\\.\\_]*[a-zA-Z0-9]+@[a-zA-Z0-9\\-]+(\\.[a-zA-Z]+)+', email);
    }

    /**
     * @description split list to list of list
     * @param source List<SObject>
     * @param size size
     *
     * @return List<List<SObject>>
     */
    public static List<List<SObject>> split(List<SObject> source, Integer size) {
        List<List<SObject>> ret = new List<List<SObject>>();
        if (source == null) return ret;

        // If the source size is equal to or smaller than our partition size, just return it
        if (source.size() <= size) {
            ret.add(source);
            return ret;
        }

        // Initialize the partitions
        Integer partition = 0;
        ret.add(new List<SObject>());

        for (SObject obj : source) {
            // Create a new partition when we fill one up
            if (ret[partition].size() == size) {
                partition++;
                ret.add(new List<SObject>());
            }
            // Add object to current partition
            ret[partition].add(obj);
        }
        return ret;
    }

    /**
     * @description return changed List
     * @param oldMap oldMap
     * @param newMap newMap
     * @param targetFieldList target Field List - List<String>
     *
     * @return List<SObject>
     */
    public static List<SObject> getChangedList(Map<Id, SObject> oldMap, Map<Id, SObject> newMap, List<String> targetFieldList) {

        List<SObject> changedList = new List<SObject>();
        for (SObject newOne : newMap.values()) {
            SObject oldOne = oldMap.get(newOne.Id);

            for (String sourceField : targetFieldList) {
                if (oldOne.get(sourceField) == newOne.get(sourceField)) continue;
                changedList.add(newOne);
            }
        }
        return changedList;
    }

    /**
     * @description return changed List
     * @param oldMap oldMap
     * @param newMap newMap
     * @param targetFieldSet target Field List - Set<String>
     *
     * @return List<SObject>
     */
    public static List<SObject> getChangedList(Map<Id, SObject> oldMap, Map<Id, SObject> newMap, Set<String> targetFieldSet) {
        List<String> targetFieldList = new List<String>();
        targetFieldList.addAll(targetFieldSet);
        return getChangedList(oldMap, newMap, targetFieldList);
    }

    /**
     * @description return changed List
     * @param oldMap oldMap
     * @param newMap newMap
     * @param targetField target Field List - String
     *
     * @return List<SObject>
     */
    public static List<SObject> getChangedList(Map<Id, SObject> oldMap, Map<Id, SObject> newMap, String targetField) {
        return getChangedList(oldMap, newMap, new List<String>{
                targetField
        });
    }

    /**
     * @description Object -> String
     * @param obj Object
     *
     * @return String
     */
    public static String toString(Object obj) {
        return obj == null ? null : String.valueOf(obj);
    }

    /**
     * @description SObject에서 해당 필드를 추출하여 String으로 변환
     * @param sObj SObject API
     * @param fieldApi Field API
     *
     * @return String
     */
    public static String toString(SObject sObj, String fieldApi) {
        Object value = sObj.get(fieldApi);
        return toString(value);
    }

    /**
     * @description Object -> Datetime
     * @param obj Object
     *
     * @return Datetime
     */
    public static Datetime toDatetime(Object obj) {
        return obj == null ? null : Datetime.valueOf(obj);
    }

    /**
     * @description SObject에서 해당 필드를 추출하여 Datetime으로 변환
     * @param sObj SObject
     * @param fieldApi Field API
     *
     * @return Datetime
     */
    public static Datetime toDatetime(SObject sObj, String fieldApi) {
        Object value = sObj.get(fieldApi);
        return toDatetime(value);
    }

    public static String formatDate(Date d) {
        return formatDate(d, 'yyyyMMdd');
    }

    public static String formatDate(Date d, String format) {
        Datetime dt = d;
        return formatDate(dt, format);
    }
    public static String formatDate(Datetime dt) {
        return formatDate(dt, 'yyyyMMdd');
    }
    /**
     * @param dt
     * @param format : yyyyMMdd, yyMMdd, yyyy-MM-dd, yyyy.MM.dd
     *
     * @return
     */
    public static String formatDate(Datetime dt, String format) {
        return dt.format(format);
    }
    public static String getLocalDateTime(Datetime dt, String timeZoneKey) {
        return dt?.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ', timeZoneKey);
    }
    public static String getDescribedObjectJSON(List<String> lstSObjectType) {
        // 전체 SObject
        Map<String, SObjectType> globalDescribe = Schema.getGlobalDescribe();
        // Field 정보 JSON생성
        Map<String, Object> allObjMap = new Map<String, Object>();
        for (String sObjectType : lstSObjectType) {
//            Map<String, Object> objMap = new Map<String, Object>();

            DescribeSObjectResult describeResult = globalDescribe.get(sObjectType).getDescribe();
            Map<String, Schema.SObjectField> describedFields = describeResult.fields.getMap();
            Map<String, Object> fieldMap = new Map<String, Object>();
            for (String fieldName : describedFields.keySet()) {
                // Describe the field
                Schema.SObjectField field = describedFields.get(fieldName);
                Schema.DescribeFieldResult f = field.getDescribe();

                Map<String, Object> valueMap = new Map<String, Object>();
                valueMap.put('label', f.getLabel());

                if (field.getDescribe().getType() == Schema.DisplayType.PICKLIST) {
                    List <Schema.PicklistEntry> picklistValues = field.getDescribe().getPicklistValues();
                    List<Map<String, Object>> pickListOptions = new List<Map<String, Object>>();

                    for (Schema.PicklistEntry pe : picklistValues) {
                        Map<String, String> optionMap = new Map<String, String>();

                        optionMap.put('label', pe.getLabel());
                        optionMap.put('value', pe.getValue());

                        pickListOptions.add(optionMap);
                    }
                    valueMap.put('picklistOptions', pickListOptions);
                }
                fieldMap.put(f.getName(), valueMap);
            }
//            objMap.put(sObjectType, fieldMap);
            allObjMap.put(sObjectType, fieldMap);
        }
        return JSON.serialize(allObjMap);
    }

    /**
     * 2024.02.21 - sy.lee
     * @description UUID 생성 & 반환
     * @return String
     */
    public static String getUUID(){
        return UUID.randomUUID().toString();
    }
}