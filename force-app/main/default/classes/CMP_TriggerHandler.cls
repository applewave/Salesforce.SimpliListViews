/****************************************************************************************
 * File Name    : CMP_TriggerHandler
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
global virtual class CMP_TriggerHandler implements CMP_ITriggerHandler {

    /** Whether Test or not */
    private final static Boolean IS_TEST = Test.isRunningTest();

    // static map of handlername, times run() was invoked
    private static Map<String, LoopCount> loopCountMap;
    private static Set<String> bypassedHandlers;

    // the current context of the trigger, overridable in tests
    @TestVisible
    private TriggerContext context;

    // the current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;

    // static initialization
    static {
        loopCountMap = new Map<String, LoopCount>();
        bypassedHandlers = new Set<String>();
    }

    // constructor
    global CMP_TriggerHandler() {
        this.setTriggerContext();
    }

    /***************************************
     * public instance methods
     ***************************************/

    // main method that will be called during execution
    global void run() {

        if(!validateRun()) {
            return;
        }

        String targetObjectApi = Test.isRunningTest() ? 'TEST' : (String.valueOf((Trigger.new != null ? Trigger.new : Trigger.old).getSObjectType()));
        // Whether to use Custom Sync or not
        // Boolean enableSyncDataLogic = CMP_OrgUtil.ORG_SETTING.UseCustomSync__c == true && CMP_SyncDataUtil.OBJECT_API_NAME_FOR_SYNC_DATA.contains(targetObjectApi);
        // Whether to use Target
        // Boolean enableTargetLogic = CMP_OrgUtil.ORG_SETTING.UseTarget__c == true;
        // Whether to use Translation or not
        // Boolean enableTranslation = CMP_OrgUtil.ORG_SETTING.UseTranslation__c == true;
        // Whether to use Team Member or not
        // Boolean enableTeamMemberLogic = CMP_OrgUtil.ORG_SETTING.UseTeamMember__c == true;

        addToLoopCount();

        // dispatch to the correct handler method
        switch on this.context {
            when BEFORE_INSERT {
                // if (enableSyncDataLogic) {
                //     CMP_SyncDataUtil.handleBeforeInsert(targetObjectApi, Trigger.new, Trigger.newMap);
                // }
                // if (enableTargetLogic) {
                //     CMP_TargetUtil.handleBeforeInsert(targetObjectApi, Trigger.new, Trigger.newMap);
                // }
                this.beforeInsert();
            }
            when BEFORE_UPDATE {
                // if (enableTargetLogic) {
                //     CMP_TargetUtil.handleBeforeUpdate(targetObjectApi, Trigger.new, Trigger.newMap);
                // }
                this.beforeUpdate();
            }
            when BEFORE_DELETE {
                this.beforeDelete();
            }
            when AFTER_INSERT {
                // if (enableSyncDataLogic) {
                //     CMP_SyncDataUtil.handleAfterInsert(targetObjectApi, Trigger.new, Trigger.newMap);
                // }

                /*if(enableTranslation){
                    CMP_TranslationService.translate(targetObjectApi, Trigger.oldMap, Trigger.newMap);
                }*/

                this.afterInsert();
            }
            when AFTER_UPDATE {
                // if (enableSyncDataLogic) {
                //     CMP_SyncDataUtil.handleAfterUpdate(targetObjectApi, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
                // }

                /*if(enableTranslation){
                    CMP_TranslationService.translate(targetObjectApi, Trigger.oldMap, Trigger.newMap);
                }*/

                this.afterUpdate();
            }
            when AFTER_DELETE {
                // if (enableSyncDataLogic) {
                //     CMP_SyncDataUtil.handleAfterDelete(targetObjectApi,Trigger.old, Trigger.oldMap);
                // }
                this.afterDelete();
                // if (enableTeamMemberLogic) {
                //     CMP_TeamMemberUtil.handleAfterDelete(targetObjectApi,Trigger.old, Trigger.oldMap);
                // }
            }
            when AFTER_UNDELETE {
                this.afterUndelete();
            }
        }
    }

    public void setMaxLoopCount(Integer max) {
        String handlerName = getHandlerName();
        if(!CMP_TriggerHandler.loopCountMap.containsKey(handlerName)) {
            CMP_TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
        } else {
            CMP_TriggerHandler.loopCountMap.get(handlerName).setMax(max);
        }
    }

    public void clearMaxLoopCount() {
        this.setMaxLoopCount(-1);
    }

    /***************************************
     * public static methods
     ***************************************/

    global static void bypass(String handlerName) {
        CMP_TriggerHandler.bypassedHandlers.add(handlerName);
    }

    global static void clearBypass(String handlerName) {
        CMP_TriggerHandler.bypassedHandlers.remove(handlerName);
    }

    global static Boolean isBypassed(String handlerName) {
        return CMP_TriggerHandler.bypassedHandlers.contains(handlerName);
    }

    global static void clearAllBypasses() {
        CMP_TriggerHandler.bypassedHandlers.clear();
    }

    /***************************************
     * private instancemethods
     ***************************************/

    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }

    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
        if(!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }

        if((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
                (ctx != null && ctx == 'before insert')) {
            this.context = TriggerContext.BEFORE_INSERT;
        } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
                (ctx != null && ctx == 'before update')){
            this.context = TriggerContext.BEFORE_UPDATE;
        } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
                (ctx != null && ctx == 'before delete')) {
            this.context = TriggerContext.BEFORE_DELETE;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
                (ctx != null && ctx == 'after insert')) {
            this.context = TriggerContext.AFTER_INSERT;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
                (ctx != null && ctx == 'after update')) {
            this.context = TriggerContext.AFTER_UPDATE;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
                (ctx != null && ctx == 'after delete')) {
            this.context = TriggerContext.AFTER_DELETE;
        } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
                (ctx != null && ctx == 'after undelete')) {
            this.context = TriggerContext.AFTER_UNDELETE;
        }
    }

    // increment the loop count
    @TestVisible
    private void addToLoopCount() {
        String handlerName = getHandlerName();
        if(CMP_TriggerHandler.loopCountMap.containsKey(handlerName)) {
            Boolean exceeded = CMP_TriggerHandler.loopCountMap.get(handlerName).increment();
            if(exceeded) {
                Integer max = CMP_TriggerHandler.loopCountMap.get(handlerName).max;
                throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
            }
        }
    }

    // make sure this trigger should continue to run
    @TestVisible
    private Boolean validateRun() {
        if(!this.isTriggerExecuting || this.context == null) {
            throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
        }
        return !CMP_TriggerHandler.bypassedHandlers.contains(getHandlerName());
    }

    @TestVisible
    private String getHandlerName() {
        return this.toString().substringBefore(':');
    }

    /***************************************
     * context methods
     ***************************************/

    // context-specific methods for override
    global virtual void beforeInsert(){}
    global virtual void beforeUpdate(){}
    global virtual void beforeDelete(){}
    global virtual void afterInsert(){}
    global virtual void afterUpdate(){}
    global virtual void afterDelete(){}
    global virtual void afterUndelete(){}

    /***************************************
     * inner classes
     ***************************************/

    // inner class for managing the loop count per handler
    @TestVisible
    private class LoopCount {
        private Integer max;
        private Integer count;

        public LoopCount() {
            this.max = 5;
            this.count = 0;
        }

        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }

        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }

        public Boolean exceeded() {
            return this.max >= 0 && this.count > this.max;
        }

        public Integer getMax() {
            return this.max;
        }

        public Integer getCount() {
            return this.count;
        }

        public void setMax(Integer max) {
            this.max = max;
        }
    }

    // possible trigger contexts
    @TestVisible
    private enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
        AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
        AFTER_UNDELETE
    }

    // exception class
    public class TriggerHandlerException extends Exception {}
}