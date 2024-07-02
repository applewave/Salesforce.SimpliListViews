/**************************************************************************************** 
 * File Name    : CMP_TriggerUtil
 * Author       : sy.lee
 * Date         : 2023-07-25
 * Description  :
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * ===============================================================
 * Ver      Date 		Author    			Modification
 * ===============================================================
   1.0		2023-07-25 	sy.lee			    Create

****************************************************************************************/
public without sharing class CMP_TriggerUtil {


    /** Whether Test or not */
    private final static Boolean IS_TEST = Test.isRunningTest();

    public static Boolean IS_DEPLOY = false;

    @TestVisible
    private static Boolean IS_UNIT_TEST = false;

    private static Map<String, CMP_TriggerHandler__mdt> TRIGGER_HANDLER {
        get{
            if(TRIGGER_HANDLER == null){
                TRIGGER_HANDLER = CMP_TriggerHandler__mdt.getAll();
            }
            return TRIGGER_HANDLER;
        }
        set;
    }

    /**
     * @description 트리거 호출 코드
     */
    public static void run() {

        // 트리거 전체 비활성화 된 경우
        if(!IS_TEST && !CMP_OrgUtil.ORG_SETTING.IsTriggerActive__c){
            System.debug(LoggingLevel.WARN, 'All the Triggers are inactive. Please check the Org Setting.');
            return;
        }
        // 현재 사용자 Profile 에 대해 비활성화 된 경우
        if(!IS_TEST && !CMP_OrgUtil.INSTANCE_SETTING.IsTriggerActive__c) {
            System.debug(LoggingLevel.WARN, 'The Trigger is inactive for this Profile');
            return;
        }
        // 트리거 대상이 되는 Object
        String targetObjectApi = IS_UNIT_TEST ? 'Account' : (IS_DEPLOY ? 'Test__c' : (String.valueOf((Trigger.new != null ? Trigger.new : Trigger.old).getSObjectType())));

        CMP_TriggerHandler__mdt handler = TRIGGER_HANDLER.get(targetObjectApi.replace('__c', '_c').replace('__e', '_e'));

        // 핸들러가 없는 경우
        if(!IS_UNIT_TEST && !IS_DEPLOY && handler == null){
            throw new HandledException('There is no trigger setting for this object : ' + targetObjectApi);
        }

        System.debug(LoggingLevel.INFO, '==================== ' + handler?.SObject__c + ' - ' + handler?.Handler__c + ' ===============================');
        CMP_ITriggerHandler instance = (CMP_ITriggerHandler)Type.forName('', handler.Handler__c).newInstance();
        if(instance != null) instance.run();
    }
}