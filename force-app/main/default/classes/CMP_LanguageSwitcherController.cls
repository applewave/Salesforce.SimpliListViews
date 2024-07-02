/**************************************************************************************** 
 * File Name    : CMP_LanguageSwitcherController
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
public with sharing class CMP_LanguageSwitcherController {

    /** Whether Test or not */
    private final static Boolean IS_TEST = Test.isRunningTest();

    /** Init */
    @AuraEnabled
    public static InitCls init() {
        InitCls ic = new InitCls();

        ic.languages = CMP_UserUtil.getUserLanguage();

        return ic;
    }

    @AuraEnabled
    public static void updateLanguage(String LanguageLocaleKey) {
        if(!IS_TEST) update new User(Id = UserInfo.getUserId(), LanguageLocaleKey = LanguageLocaleKey);
    }

    /** Init Class */
    public class InitCls {
        @AuraEnabled public String className = 'CMP_LanguageSwitcherController';
        @AuraEnabled public List<CMP_UserUtil.LanguageCls> languages;
    }

}