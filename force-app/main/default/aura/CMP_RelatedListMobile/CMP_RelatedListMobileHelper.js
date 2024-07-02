/****************************************************************************************
 * File Name    : CMP_RelatedListMobileHelper.js
 * Author       : sy.lee
 * Date         : 2024-06-21
 * Description  :
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * ===============================================================
 * Ver      Date 		Author    			Modification
 * ===============================================================
 1.0		2024-06-21 	sy.lee			    Create

 ****************************************************************************************/
({
    _refineData: function (columnLabelList, recordList){
        console.info('%c==================================== RelatedListMobileAuraHelper._refineData', 'color:red;');

        const refinedRecordList = [];
        recordList.map(record => {
            const data = {
                recordId: record.Id,
                fieldList: []
            };

            const refinedApi = columnLabelList[0].api.replace('.', '');
            data.header = record[refinedApi]; // 값만

            columnLabelList.map((columnInfo, idx)=> {
                // 첫번째 필드는 Header로 들어간다
                if(idx > 0){
                    data.fieldList.push({
                        label: columnInfo.label,
                        value: record[columnInfo.api],
                    });
                }
            });
            refinedRecordList.push(data);
        });
        return refinedRecordList;
    },

    _getColumnLabelList: function (component, event, helper){
        console.info('%c==================================== RelatedListMobileAuraHelper._getColumnLabelList', 'color:red;');
        const result = component.get('v.result');
        return result.columnList.map(columnApi => {
            const {
                label: fieldLabel,
                fieldType,
                api: fieldApi,
                scale: fieldScale,
                isHtml: fieldIsHtml,
                objectApi
            } = this._getFieldInfo(result.columnMap, result.relatedObject, columnApi);

            // 2024.02.28 - sy.lee - fieldType이 REFERENCE인 경우, 그대로 조회하면 아이디 값이 되므로 Name으로 보여줄 필요가 있다. API명을 변경한다
            let api = columnApi;
            if(fieldType === 'REFERENCE'){
                //label = fieldLabel.endsWith(' ID') ? fieldLabel.replace(new RegExp(' ID$'), '') : fieldLabel;
                if(this._isRelationField(columnApi)){ // A__r.B__c
                    api = this._removeDot(columnApi);
                    if(fieldApi.endsWith('__c')){ // Custom Field
                        api = api.replace('__c', 'Name');
                    }else if(fieldApi.endsWith('Id')){ // Ex. Owner Id, CreatedById, ModifiedById
                        api = api.replace('Id', 'Name');
                    }
                }else{ // A__c or CreatedById
                    if(fieldApi.endsWith('__c')){ // Custom Field
                        api = fieldApi.replace('__c', 'Name');
                    }else if(fieldApi.endsWith('Id')){ // Ex. Owner Id, CreatedById, ModifiedById
                        api = fieldApi.replace('Id', 'Name');
                    }
                }
            }

            return {
                label: fieldLabel,
                api
            }
        });
    },
});