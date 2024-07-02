/****************************************************************************************
 * File Name    : CMP_RelatedListHelperController.js
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

    fnRefresh: function (component, event, helper){
        console.info('%c==================================== CMP_RelatedListHelperController.fnRefresh', 'color:red;');
        helper._handleRefresh(component, component.get('v.query'), component.get('v.countQuery'));
    },

    fnClickMenu: function(component, event, helper){
        console.info('%c==================================== CMP_RelatedListHelperController.fnClickMenu', 'color:red;');
        const selectedMenuItemValue = event.getParam('value');

        switch(selectedMenuItemValue) {
            case 'ResetColumnWidth' :
                const columns = component.get('v.columns');
                component.set('v.columns', []);
                component.set('v.columns', columns);
                break;
        }
    },

    fnSort: function (component, event, helper){
        console.info('%c==================================== CMP_RelatedListHelperController.fnSort', 'color:red;');
        const sortedBy = event.getParam('fieldName');
        const sortedDirection = event.getParam('sortDirection');

        console.log(sortedBy);

        component.set('v.sortedBy', sortedBy);
        component.set('v.sortedDirection', sortedDirection);

        // 실제 쿼리를 위함
        const sortedByMap = component.get('v.sortedByMap');
        console.log('sortedByMap', sortedByMap);

        //
        const result = component.get('v.result');
        const query = `SELECT ${result.data.columns} ${result.data.fromClause} ORDER BY ${sortedByMap[sortedBy].api} ${sortedDirection} ${sortedDirection === 'asc' ? 'NULLS FIRST' : 'NULLS LAST'} LIMIT ${component.get('v.limitCount')}`;
        console.log('query', query);
        component.set('v.sortedByLabel', `${$A.get("$Label.c.CMP_CR_Lab_SortedBy").replace('{0}', sortedByMap[sortedBy].label)}`);

        helper._handleRefresh(component, query, result.data.countQuery);
    },

    /*fnStandardNew: function (component, event, helper){
        console.info('%c==================================== RelatedListHelperController.fnStandardNew', 'color:red;');

        const defaultFieldValues = {};
        defaultFieldValues[component.get('v.relationField')] = component.get('v.recordId');
        helper.createComponent(component, 'LGE_RecordTypeSelector', {
            targetObject: component.get('v.targetObject'),
            defaultFieldValues,
        });
    }*/

    fnRowAction: function(component, event, helper){
        const action = event.getParam('action'),
            row = event.getParam('row');

        switch (action.name) {
            case 'edit':
                const editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": row.Id
                });
                editRecordEvent.fire();
                break;

            case 'delete':
                const targetObjectLabel = component.get('v.result').relatedObject[component.get('v.targetObjectApi')].label;
                helper.LightningConfirm.open({
                    message: $A.get("$Label.c.CMP_CR_Msg_DeleteConfirm").replace('{0}', targetObjectLabel),
                    label: $A.get("$Label.c.CMP_CR_Lab_Delete").replace('{0}', targetObjectLabel),
                    theme: 'shade'
                }).then(function(result) {
                    if(!result) return;
                    helper.deleteRecord(component, row.Id);
                });
                break;

            case 'showDetail':
                event.preventDefault();
                const navService = component.find("navService");
                navService.navigate({
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": row.Id,
                        "objectApiName": component.get('v.targetObjectApi'),
                        "actionName": "view"
                    }
                });
                break;
        }
    },
});