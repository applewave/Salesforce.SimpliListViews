/****************************************************************************************
 * File Name    : CMP_RelatedListHelper.js
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
    /**
     * Title 설정
     * @param component component
     * @param labelPlural object label plural
     * @private
     */
    _handleTitle: function (component, labelPlural) {
        const title = component.get('v.title');
        if ($A.util.isEmpty(title)) {
            component.set('v.title', labelPlural);
        } else if (title.endsWith('.Label')) {
            component.set('v.title', $A.getReference("$Label.c." + title.replace('.Label', '')));
        }
    },

    /*_openConfirm: function(component, event, label, message, theme) {
        this.LightningConfirm.open({
            message,
            //theme,
            label,
        }).then(function(result) {
            // result is true if clicked "OK"
            // result is false if clicked "Cancel"
            console.log('confirm result is', result);
        });
    },*/

    /*_openDeleteConfirm: function(component, event, label, message, theme, recordId) {

    },*/

    deleteRecord: function (component, rowId) {
        console.info('%c==================================== CMP_RelatedListHelper.deleteRecord', 'color:red;');
        const params = {
            rowId
        }
        this.apex(component, 'deleteRecord', params)
            .then(result => {
                const toast = $A.get("e.force:showToast");
                toast.setParams({
                    message: $A.get('$Label.c.CMP_CR_Msg_DeleteSuccess'),
                    type: 'Success'
                });
                toast.fire();
                $A.get('e.force:refreshView').fire();
            });
    },


    // todo
    _handleInternalStandardViewAll: function (component) {
        console.info('%c==================================== CMP_RelatedListHelper._handleInternalStandardViewAll', 'color:red;');
        const relationShipName = component.get('v.relationShipName');
        const relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": relationShipName,
            "parentRecordId": component.get("v.recordId")
        });
        relatedListEvent.fire();
    },

    /**
     * View All - Custom - Internal
     * @param component
     * @param event
     * @param helper
     * @private
     */
    _handleInternalCustomViewAll: function (component, event, helper) {
        console.info('%c==================================== CMP_RelatedListHelper._handleInternalCustomViewAll', 'color:red;');
        event.preventDefault();

        try {
            sessionStorage.clear();

            // column을 넘기기전에 row action은 지우고 넘겨준다
            const columns = component.get(`v.columns`).filter(column => column.type !== `action`);

            // Header
            const result = component.get('v.result');
            const sortedByMap = component.get('v.sortedByMap');
            const sortedBy = component.get('v.sortedBy');
            const sortedDirection = component.get('v.sortedDirection');

            console.log(component.get('v.query'));

            sessionStorage.setItem('iconName', component.get(`v.iconName`));
            sessionStorage.setItem('columns', JSON.stringify(columns));
            sessionStorage.setItem('hideCheckboxColumn', component.get(`v.hideCheckboxColumn`));
            sessionStorage.setItem('sortedBy', component.get(`v.sortedBy`));
            sessionStorage.setItem('sortedDirection', component.get(`v.sortedDirection`));
            sessionStorage.setItem('maxRowSelection', component.get(`v.maxRowSelection`));
            sessionStorage.setItem('showRowNumberColumn', component.get(`v.showRowNumberColumn`));
            sessionStorage.setItem('query', `SELECT ${result.data.columns} ${result.data.fromClause} ORDER BY ${sortedByMap[sortedBy].api} ${sortedDirection}`);
            sessionStorage.setItem('countQuery', component.get(`v.countQuery`));
            sessionStorage.setItem('columnMap', result.columnMap);
            sessionStorage.setItem('result', JSON.stringify(result));
            sessionStorage.setItem('sortedByMap', JSON.stringify(component.get('v.sortedByMap')));
            sessionStorage.setItem('needAccessCheck', component.get('v.needAccessCheck'));
            sessionStorage.setItem('title', component.get('v.title'));
            sessionStorage.setItem('useShowDetailRowAction', component.get('v.useShowDetailRowAction'));
            sessionStorage.setItem('useEditRowAction', component.get('v.useEditRowAction'));
            sessionStorage.setItem('useDeleteRowAction', component.get('v.useDeleteRowAction'));
            sessionStorage.setItem('buttonComponentName', component.get('v.buttonComponentName'));
            sessionStorage.setItem('sortedByLabel', component.get('v.sortedByLabel'));
            sessionStorage.setItem('isInfinityLoading', component.get('v.isInfinityLoading'));
            sessionStorage.setItem('useExport', component.get('v.useExport'));

            // 같은 화면에서 두번 호출될때 해당 컴포넌트의 Init이 다시 수행되지 않으므로 window.open으로 연다
            const navService = component.find("navService");
            navService.generateUrl({
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__CMP_RelatedListViewAllAura',
                    },
                })
                .then($A.getCallback(function (url) {
                    window.open(url, '_self');
                }), $A.getCallback(function (error) {
                    const toast = $A.get("e.force:showToast");
                    toast.setParams({
                        message: `Please contact the administrator.`,
                        type: 'Error'
                    });
                    toast.fire();
                    $A.get('e.force:refreshView').fire();
            }));
        } catch (e) {
            console.log(e.stack);
        }

    },

    /**
     * View All - Custom - Community
     * @param component
     * @param event
     * @param helper
     */
    handleCommunityCustomViewAll: function (component, event, helper) {
        console.info('%c==================================== CMP_RelatedListHelper.handleCommunityCustomViewAll', 'color:red;');
        event.preventDefault();

        // column을 넘기기전에 row action은 지우고 넘겨준다
        const columns = component.get(`v.columns`).filter(column => column.type !== `action`);

        // Header
        const result = component.get('v.result');
        const sortedByMap = component.get('v.sortedByMap');
        const sortedBy = component.get('v.sortedBy');
        const sortedDirection = component.get('v.sortedDirection');

        sessionStorage.setItem('iconName', component.get(`v.iconName`));
        sessionStorage.setItem('columns', JSON.stringify(columns));
        sessionStorage.setItem('hideCheckboxColumn', component.get(`v.hideCheckboxColumn`));
        sessionStorage.setItem('sortedBy', component.get(`v.sortedBy`));
        sessionStorage.setItem('sortedDirection', component.get(`v.sortedDirection`));
        sessionStorage.setItem('maxRowSelection', component.get(`v.maxRowSelection`));
        sessionStorage.setItem('showRowNumberColumn', component.get(`v.showRowNumberColumn`));
        sessionStorage.setItem('query', `SELECT ${result.data.columns} ${result.data.fromClause} ORDER BY ${sortedByMap[sortedBy].api} ${sortedDirection}`);
        sessionStorage.setItem('countQuery', component.get(`v.countQuery`));
        sessionStorage.setItem('columnMap', result.columnMap);
        sessionStorage.setItem('result', JSON.stringify(result));
        sessionStorage.setItem('sortedByMap', JSON.stringify(component.get('v.sortedByMap')));
        sessionStorage.setItem('needAccessCheck', component.get('v.needAccessCheck'));
        sessionStorage.setItem('title', component.get('v.title'));
        sessionStorage.setItem('useEditRowAction', component.get('v.useEditRowAction'));
        sessionStorage.setItem('useShowDetailRowAction', component.get('v.useShowDetailRowAction'));
        sessionStorage.setItem('useDeleteRowAction', component.get('v.useDeleteRowAction'));
        sessionStorage.setItem('buttonComponentName', component.get('v.buttonComponentName'));
        sessionStorage.setItem('sortedByLabel', component.get('v.sortedByLabel'));
        sessionStorage.setItem('isInfinityLoading', component.get('v.isInfinityLoading'));
        sessionStorage.setItem('useExport', component.get('v.useExport'));

        const navService = component.find('navService');
        navService.navigate({
            type: 'comm__namedPage',
            attributes: {
                name: 'ViewAll__c'
            }
        });
    }
});