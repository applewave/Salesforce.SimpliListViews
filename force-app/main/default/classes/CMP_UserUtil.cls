/**************************************************************************************** 
 * File Name    : CMP_UserUtil
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
public with sharing class CMP_UserUtil {

    /** Whether Test or not */
    //private final static Boolean IS_TEST = Test.isRunningTest();

    /**
     * @description 현재 레코드에 대한 유저 권한 확인
     * @param userId User Id
     * @param recordId Record Id
     *
     * @return UserRecordAccess
     */
    public static UserRecordAccess getRecordAccess(Id userId, Id recordId) {
        return getRecordAccess(userId, new Set<Id>{recordId}).get(recordId);
    }

    /**
     * @description 여러 레코드에 대한 유저 권한 확인
     * @param userId User Id
     * @param recordIdSet Set<Record Id>
     *
     * @return Map<String, UserRecordAccess>
     */
    public static Map<String, UserRecordAccess> getRecordAccess(Id userId, Set<Id> recordIdSet) {
        System.debug(LoggingLevel.INFO, '==================== CMP_UserUtil.getRecordAccess ===============================');
        Map<String, UserRecordAccess> accessMap = new Map<String, UserRecordAccess>();
        for(UserRecordAccess access : [SELECT RecordId, HasEditAccess, HasReadAccess, HasDeleteAccess, HasTransferAccess FROM UserRecordAccess WHERE UserId = :userId AND RecordId IN :recordIdSet]){
            accessMap.put(access.RecordId, access);
        }
        return accessMap;
    }

    /**
     * @description 여러 레코드에 대한 유저 권한 확인
     * @param userId  User Id
     * @param recordList List<SObject>
     *
     * @return Map<String, UserRecordAccess>
     */
    public static Map<String, UserRecordAccess> getRecordAccess(Id userId, List<SObject> recordList) {
        System.debug(LoggingLevel.INFO, '==================== CMP_UserUtil.getRecordAccess ===============================');
        Set<Id> recordIdSet = new Set<Id>();
        for(SObject record : recordList){
            recordIdSet.add(record.Id);
        }
        return getRecordAccess(userId, recordIdSet);
    }

    /**
     * @description 유저 정보 반환
     * @param userId User Id
     *
     * @return User
     */
    public static User getUserInfo(String userId){
        String objApi = 'User';
        List<String> fieldList = CMP_ApexUtil.getAllField(objApi);
        fieldList.addAll(new Set<String>{'Profile.Name', 'UserRole.Name'});
        return Database.query('SELECT ' +  String.join(fieldList, ',') + ' FROM ' + objApi + ' WHERE Id = :userId');
    }

    /*global static Boolean checkPartner(User userId){
        System.debug(LoggingLevel.INFO, '==================== LGE_OpportunityTeamMemberButtons.checkPartner ===============================');
        return String.isNotBlank(usr.ContactId);
    }*/

    /**
     * @description 사용자가 사용 가능한 언어의 목록을 반환한다
     * @return List<LanguageCls>
     */
    public static List<LanguageCls> getUserLanguage(){
        Schema.DescribeFieldResult fieldResult = User.LanguageLocaleKey.getDescribe();
        List<LanguageCls> lcList = new List<LanguageCls>();
        for(Schema.PicklistEntry entry : fieldResult.getPicklistValues()){
            LanguageCls lc = new LanguageCls();
            lc.label = entry.getLabel();
            lc.value = entry.getValue();
            lc.isActive = entry.isActive();
            lc.isDefaultValue = entry.isDefaultValue();
            lcList.add(lc);
        }
        return lcList;
    }

    public class LanguageCls {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean isActive;
        @AuraEnabled public Boolean isDefaultValue;
    }

    /**
     * 2024.04.22 - sy.lee
     * @description 현재 사용자가 Guest User인지 확인
     */
    public static Boolean IS_GUEST {
        get{
            if(IS_GUEST == null){
                IS_GUEST = Auth.CommunitiesUtil.isGuestUser();
            }
            return IS_GUEST;
        }
        set;
    }

    /**
     * 2024.05.17 - hkc
     * @description 현재 사용자가 Partner User인지 확인
     */
    public static Boolean IS_PARTNER {
        get{
            if(IS_PARTNER == null){
                IS_PARTNER = !Auth.CommunitiesUtil.isInternalUser();
            }
            return IS_PARTNER;
        }
        set;
    }

}