/****************************************************************************************
 * File Name    : CMP_LanguageSwitcherController.js
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
({

    /** 2024-01-25 - sy.lee - Init */
    fnInit: function (component, event, helper) {

        const recordId = component.get('v.recordId');
        console.log('recordId', recordId);

        const action = component.get("c.init");
        //action.setParams({ firstName : component.get("v.firstName") });

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const result = response.getReturnValue();
                console.log(result);

                if(!result) return;

                //const language = result.usr.LanguageLocaleKey;
                //component.find(language).set('v.disabled', true);

                component.set('v.languageList', result.languages);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                const errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    fnChangeLanguage: function (component, event, helper){
        const selectedLanguage = event.target.value;
        console.log(selectedLanguage);

        const action = component.get("c.updateLanguage");
        action.setParams({ LanguageLocaleKey : selectedLanguage });

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "업데이트 되었습니다",
                    "type": "success"
                });
                toastEvent.fire();

                window.location.reload();
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                const errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
});