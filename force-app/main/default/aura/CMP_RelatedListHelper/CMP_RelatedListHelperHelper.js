/****************************************************************************************
 * File Name    : CMP_RelatedListHelperHelper.js
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
    apex: function(component, method, param) {
        const self = this;
        return new Promise($A.getCallback((resolve, reject) => {
            const action = component.get(`c.${method}`);
            !$A.util.isEmpty(param) && action.setParams(param);
            action.setCallback(this, response => {
                const state = response.getState();
                switch (state) {
                    case 'SUCCESS' :
                        const result = response.getReturnValue();
                        /*self.log(component, method, {
                            'result': response.getReturnValue(),
                        });*/
                        resolve(result);
                        break;
                    case 'INCOMPLETE' :

                        break;
                    case 'ERROR' :
                        const errors = response.getError();
                        console.log(errors);
                        if(errors){
                            if(errors[0]){
                                if(!$A.util.isEmpty(errors[0].message)){
                                    console.error("Error message: " + errors[0].message);
                                    const toast = $A.get("e.force:showToast");
                                    toast.setParams({
                                        message : errors[0].message,
                                        type: 'Error'
                                    });
                                    toast.fire();
                                    reject(errors[0].message);
                                }else if(!$A.util.isEmpty(errors[0].pageErrors)){
                                    console.log(errors[0].pageErrors);
                                    reject(errors[0].pageErrors);
                                }else if(!$A.util.isEmpty(errors[0].fieldErrors)){
                                    const fieldErrors = errors[0].fieldErrors;

                                    const fieldList = Object.keys(fieldErrors);
                                    console.log(fieldErrors);
                                    const toast = $A.get("e.force:showToast");
                                    toast.setParams({
                                        title : `Error - ${fieldList[0]}`,
                                        message : fieldErrors[fieldList[0]][0].message,
                                        type: 'Error'
                                    });
                                    toast.fire();
                                    component.set('v.isLoading', false);

                                    reject(fieldErrors[fieldList[0]][0].message);
                                }
                            }
                            component.destroy();
                        }else{
                            console.error("Unknown error");
                            reject("Unknown error");
                        }
                        break;
                }
            });
            $A.enqueueAction(action);
        }));
    },

    _createButtonComponent: function(component, buttonComponentName){
        console.info('%c==================================== CMP_RelatedListHelperHelper._createButtonComponent', 'color:red;');
        console.log(component.get('v.currentObjectApi'));

        const table = component.get('v.result').isCommunity ? component.find('communityTable') : component.find('table');
        try{
            $A.createComponent(
                // `c:testButton`,
                `c:${buttonComponentName}`,
                {
                    result: component.get('v.result'),
                    table: table,
                },
                (newComponent, status, errorMessage) => {
                    switch (status){
                        case 'SUCCESS' :  //Add the new button to the body array
                            const buttons = component.get("v.buttons");
                            buttons.push(newComponent);
                            component.set("v.buttons", buttons);
                            component.set('v.isLoading', false);
                            break;
                        case 'INCOMPLETE' :
                            console.log("No response from server or client is offline.");
                            break;
                        case 'ERROR' :
                            console.log("Error: " + errorMessage);
                            break;
                    }
                }
            );
        }catch (e) {
            console.log(e.stack);
        }

    },

    _createExcelColumn: function (component, recordList){

        const {columnList, columnMap, relatedObject} = component.get('v.result');

        const labelObj = {};
        columnList.map(columnApi => {
            const {
                label: fieldLabel,
                api: fieldApi,
                fieldType,
                RelationshipName

            } = this._getFieldInfo(columnMap, relatedObject, columnApi);
            console.log(this._getFieldInfo(columnMap, relatedObject, columnApi));
            // 2024.01.15 - sy.lee
            /*
            l_PrefixModelCode__r.OpportunityPrefixProduct__c 이렇게 들어가므로 뒤에를 일단 Name으로 치환
            나중에 수정필요하면..뭐..그때가서
             */
            labelObj['REFERENCE' === fieldType ? RelationshipName + '.' + 'Name' : columnApi] = fieldLabel;
        });

        console.log(labelObj);
        return labelObj;
    },

    _createColumn: function(component, result, useSorting){

        const dataTableColumnList = [];

        const sortedByMap = {};
        const sortedBy = component.get('v.sortedBy');

        // 2024.01.04 - sy.lee - Datetime 표시에 locale을 적용하기 위한 로직 추가
        const {TimeZoneSidKey} = result.currentUser;

        result.columnList.map(columnApi => {
            const {
                label: fieldLabel,
                fieldType,
                api: fieldApi,
                scale: fieldScale,
                isHtml: fieldIsHtml,
                objectApi
            } = this._getFieldInfo(result.columnMap, result.relatedObject, columnApi);

            let column;
            switch (fieldType) {
                case 'REFERENCE' : { // Lookup or Master-Detail Field ========================================
                    /*if(isWithOutSharing){
                        column = this.getTextCol(fieldLabel, columnApi, 'TEXT');
                    }else{*/
                    let label;
                    if(this._isRelationField(columnApi)){
                        label = this._removeDot(columnApi);
                        if(fieldApi.endsWith('__c')){ // Custom Field
                            label = label.replace('__c', 'Name');
                        }else if(fieldApi.endsWith('Id')){ // Ex. Owner Id, CreatedById, ModifiedById
                            label = label.replace('Id', 'Name');
                        }
                    }else{
                        if(fieldApi.endsWith('__c')){ // Custom Field
                            label = fieldApi.replace('__c', 'Name');
                        }else if(fieldApi.endsWith('Id')){ // Ex. Owner Id, CreatedById, ModifiedById
                            label = fieldApi.replace('Id', 'Name');
                        }
                    }
                    column = this._reference(fieldLabel, columnApi, fieldType, useSorting, label);
                    //}
                    break;
                }

                case 'CURRENCY' : {
                    column = this._currency(fieldLabel, columnApi, fieldType, useSorting, fieldScale);
                    break;
                }

                case 'DOUBLE' : {
                    column = this._number(fieldLabel, columnApi, fieldType, useSorting, fieldScale);
                    break;
                }

                case 'DATE' : {
                    column = this._date(fieldLabel, columnApi, fieldType, useSorting);
                    break;
                }

                case 'PERCENT' : {
                    column = this._percent(fieldLabel, columnApi, fieldType, useSorting, fieldScale);
                    break;
                }

                case 'TEXTAREA' : {
                    //column = this.getRichTextCol(fieldLabel, columnApi, 'RICHTEXT', fieldScale);
                    if (fieldIsHtml) { // Rich Text
                        column = this._richText(fieldLabel, columnApi, 'RICHTEXT');
                    } else { // Text Area
                        column = this._textArea(fieldLabel, columnApi, fieldType, useSorting);
                    }
                    break;
                }

                case 'URL' : {
                    column = this._url(fieldLabel, columnApi, fieldType, useSorting);
                    break;
                }

                case 'BOOLEAN' : {
                    column = this._checkbox(fieldLabel, columnApi, fieldType, useSorting);
                    break;
                }

                /* 2024.01.08 - sy.lee - Datetime 값의 translation을 위하여 text로 넘김
                case 'DATETIME' : {
                    column = this._dateTime(fieldLabel, columnApi, fieldType, useSorting, TimeZoneSidKey);
                    break;
                }*/

                default : { // Else ==========================================================================
                    switch (fieldApi) {
                        case 'Name' : { // Name Field should be Link
                            column = this._name(fieldLabel, columnApi, fieldType, useSorting);
                            //column = this.getRelationCol(fieldLabel, columnApi, 'RELATION', fieldScale);
                            break;
                        }

                        case 'QuoteNumber' : {
                            column = this._quoteNumber(fieldLabel, columnApi, fieldType, useSorting);
                            break;
                        }

                        default : {
                            // Hyperlink 처리
                            if (fieldIsHtml) {
                                column = this._reference(fieldLabel, columnApi, fieldType, useSorting, this._removeDot(columnApi));
                            } else { // 일반 필드
                                column = this._text(fieldLabel, columnApi, fieldType, useSorting);
                            }
                            break;
                        }
                    }
                    break;
                }
            }

            dataTableColumnList.push(column);

            // 초기 Sort Label 설정을 위함
            if (columnApi === sortedBy) {
                component.set('v.sortedBy', column.fieldName);
                component.set('v.sortedByLabel', `${$A.get("$Label.c.CMP_CR_Lab_SortedBy").replace('{0}', column.label)}`);
            }

            // Sort에서 써먹기 위해 저장
            sortedByMap[column.fieldName] = {label: column.label, api: columnApi};
        });

        // 2024.01.10 - sy.lee - 표시되는 필드가 아닌 다른 필드로 정렬을 하는 경우 처리
        if($A.util.isEmpty(component.get('v.sortedByLabel'))){
            const {label, fieldType, api} = this._getFieldInfo(result.columnMap, result.relatedObject, sortedBy);
            component.set('v.sortedBy', api);
            component.set('v.sortedByLabel', `${$A.get("$Label.c.CMP_CR_Lab_SortedBy").replace('{0}', label)}`);
            sortedByMap[api] = {label, api};
        }

        console.log('sortedByMap', sortedByMap);
        component.set('v.sortedByMap', sortedByMap);

        return dataTableColumnList;
    },

    /**
     * @description get field information from metadata
     * @param columnMap
     * @param relatedObject
     * @param columnApi
     * @returns {*}
     */
    _getFieldInfo: function(columnMap, relatedObject, columnApi){
        return relatedObject[columnMap[columnApi]].fieldMap[columnApi.includes('.') ? columnApi.substring(columnApi.lastIndexOf('.') + 1) : columnApi];
    },

    /**
     * @description whether the relation field or not
     * @param columnApi
     * @returns {*}
     */
    _isRelationField: function(columnApi){
        return columnApi.includes('.');
    },

    /**
     * @description remove the . from string
     * @param columnApi
     * @returns {string}
     */
    _removeDot: function(columnApi){
        return columnApi.replace(/\./gi, '');
    },

    _getColumnType: function(fieldType){
        let type;
        switch (fieldType) {
            case 'BOOLEAN' :
                type = 'checkbox';
                break;
            case 'REFERENCE' :
                type = 'url';
                break;
            case 'DOUBLE' :
                type = 'number';
                break;
            case 'DATE' :
                type = 'date';
                break;
            case 'PERCENT' :
                type = 'percent';
                break;
            case 'RICHTEXT' :
                type = 'richText';
                break;
            /*case 'RELATION' :
                type = 'relation';
                break;*/
            case 'TEXTAREA' :
                type = 'textArea';
                break;
            case 'URL' :
                type = 'url';
                break;
            case 'STRING' :
            case 'PICKLIST' :
            case 'CURRENCY' :
            case 'DATETIME' :
                type = 'text';
                break;
        }
        return type;
    },


    _reference: function(fieldLabel, columnApi, fieldType, useSorting, label){
        return {
            label: fieldLabel.endsWith(' ID') ? fieldLabel.replace(new RegExp(' ID$'), '') : fieldLabel, // Remove 'ID' from label
            fieldName: this._removeDot(columnApi),
            type: 'url',
            sortable: useSorting,
            typeAttributes: {
                label: {fieldName: label},
                tooltip: {fieldName: label}
            }
        }
    },

    _currency: function(fieldLabel, columnApi, fieldType, useSorting, scale){
        return {
            label: fieldLabel,
            fieldName: this._removeDot(columnApi),
            type: this._getColumnType(fieldType),
            sortable: useSorting,
            /*typeAttributes: {
                currencyCode: currency,
                currencyDisplayAs: 'code'
            },*/
            cellAttributes: {
                alignment: 'left',
                minimumFractionDigits: scale,
            }
        }
    },

    _number: function(fieldLabel, columnApi, fieldType, useSorting, scale){
        return {
            label: fieldLabel,
            fieldName: this._removeDot(columnApi),
            type: this._getColumnType(fieldType),
            sortable: useSorting,
            cellAttributes: {
                alignment: 'left',
                minimumFractionDigits: scale,
            }
        }
    },

    _date: function(fieldLabel, columnApi, fieldType, useSorting){
        return {
            label: fieldLabel,
            fieldName: this._removeDot(columnApi),
            type: this._getColumnType(fieldType),
            sortable: useSorting,
            cellAttributes: {
                alignment: 'left'
            },
            typeAttributes:{
                day: "numeric",
                month: "numeric",
                year: "numeric"
            }
        }
    },

    _dateTime: function(fieldLabel, columnApi, fieldType, useSorting, TimeZoneSidKey){
        return {
            label: fieldLabel,
            fieldName: this._removeDot(columnApi),
            type: this._getColumnType(fieldType),
            sortable: useSorting,
            typeAttributes: {
                year: 'numeric',
                month: 'numeric',
                day: 'numeric',
                hour: 'numeric',
                minute: 'numeric',
                timeZone: TimeZoneSidKey
            },
            cellAttributes: {
                alignment: 'left'
            }
        }
    },

    _percent: function(fieldLabel, columnApi, fieldType, useSorting, scale){
        return {
            label: fieldLabel,
            fieldName: this._removeDot(columnApi),
            type: this._getColumnType(fieldType),
            sortable: useSorting,
            cellAttributes: {
                alignment: 'left',
            },
            typeAttributes: {
                minimumFractionDigits: scale,
            }
        }
    },

    _relation: function(fieldLabel, columnApi, fieldType, useSorting){
        return {
            label: 'AAA',
            type: this._getColumnType(fieldType),
            typeAttributes: {
                relation: {
                    fieldName: this._removeDot(columnApi),
                }
            },
            //sortable: false,
        }
    },

    _richText: function(fieldLabel, columnApi, fieldType, useSorting){
        return {
            label: fieldLabel,
            type: this._getColumnType(fieldType),
            typeAttributes: {
                richText: {
                    fieldName: this._removeDot(columnApi),
                }
            },
            sortable: false,
        }
    },

    _text: function(fieldLabel, columnApi, fieldType, useSorting){
        return {
            label: fieldLabel,
            fieldName: this._removeDot(columnApi),
            type: this._getColumnType(fieldType),
            sortable: useSorting,
        }

    },

    _textArea: function(fieldLabel, columnApi, fieldType, useSorting){
        return {
            label: fieldLabel,
            type: this._getColumnType(fieldType),
            typeAttributes: {
                textArea: {
                    fieldName: this._removeDot(columnApi),
                }
            },
            sortable: false,
        }
    },

    _url: function(fieldLabel, columnApi, fieldType, useSorting){
        return {
            label: fieldLabel,
            fieldName: this._removeDot(columnApi),
            type: this._getColumnType(fieldType),
            sortable: false,
            typeAttributes: {
                target: '_blank',
            }
        }
    },

    _checkbox: function(fieldLabel, columnApi, fieldType, useSorting){
        return {
            label: fieldLabel,
            fieldName: this._removeDot(columnApi),
            type: this._getColumnType(fieldType),
            typeAttributes: {
                checkbox: {
                    fieldName: this._removeDot(columnApi),
                }
            },
            sortable: useSorting,
        }
    },

    _name: function(fieldLabel, columnApi, fieldType, useSorting){
        return {
            label: fieldLabel,
            fieldName: this._isRelationField(columnApi) ? (columnApi.split('.').join('') + 'Id') : 'recordId',
            type: 'url',
            sortable: useSorting,
            typeAttributes: {
                label: {fieldName: this._isRelationField(columnApi) ? (columnApi.split('.').join('')) : 'Name'},
                tooltip: {fieldName: this._isRelationField(columnApi) ? (columnApi.split('.').join('')) : 'Name'}
            }
        }
    },

    _quoteNumber: function(fieldLabel, columnApi, fieldType, useSorting){
        return {
            label: fieldLabel,
            fieldName: 'quoteId',
            type: 'url',
            sortable: useSorting,
            typeAttributes: {
                label: {fieldName: 'QuoteNumber'},
                tooltip: {fieldName: 'QuoteNumber'}
            }
        }
    },

    _nameLookup: function(fieldLabel, columnApi, fieldType, useSorting){
        return {
            label: fieldLabel,
            fieldName: 'recordId',
            type: 'button',
            sortable: useSorting,
            typeAttributes: {
                label: {fieldName: 'Name'},
                tooltip: {fieldName: 'Name'},
                variant: 'base'
            }
        }
    },

    _createData: function(component, recordList){
        console.info('%c==================================== RelatedListAuraHelper._createData', 'color:red;');
        const {data: {accessMap, totalRecordCount}, orgDomain, columnList, columnMap, relatedObject, isCommunity} = component.get('v.result');

        // 데이터가 없는 경우
        if(!recordList){
            return;
        }

        return recordList.map(recordInfo => {
            // 복사안하면 터짐
            const record = recordInfo.record;

            columnList.map(columnApi => {
                const {
                    label: fieldLabel,
                    fieldType,
                    api: fieldApi,
                    scale: fieldScale,
                    isHtml: fieldIsHtml
                } = this._getFieldInfo(columnMap, relatedObject, columnApi);

                if (this._isRelationField(columnApi)) { // Relation Field
                    //console.log('relation', columnApi);
                    // 관련 레코드에 대한 정보는 여기로 들어온다
                    const relations = columnApi.split('.');
                    // Relation 순회
                    let recordLabel = record, recordValue = record;
                    relations.map(relation => {
                        // 마지막에 도달하면 Name 값을 가져와야 한다
                        // ex) Opportunity.Account.Name인 경우, Opportunity의 정보를 recordValue에 넣고, 거기서 Account를 읽어서 recordValue에 넣은 다음 Name을 찾는다

                        // Account.Name
                        if(relation.endsWith('__c') && fieldType === 'REFERENCE'){
                            recordLabel = recordLabel[relation.replace('__c', '__r')] && recordLabel[relation.replace('__c', '__r')].Name;
                        }else if (relation.endsWith('Id')) {
                            recordLabel = recordLabel[relation.replace(new RegExp('Id$'), '')] && recordLabel[relation.replace(new RegExp('Id$'), '')].Name;
                        }else{
                            if(recordLabel){
                                recordLabel = recordLabel[relation];
                            }
                        }
                        recordValue = recordValue && recordValue[relation];
                    });

                    // ex) Opportunity.Account.Name의 경우, OpportunityAccountName이 된다
                    const resultProp = this._removeDot(columnApi); // .을 제거한 Api Name 생성

                    // 프로퍼티 생성
                    switch (fieldType) {
                        case 'REFERENCE' : {
                            let label;
                            if (columnApi.endsWith('__c')) {
                                label = resultProp.replace('__c', 'Name');
                                //target = columnApi.replace('__c', '__r');
                            } else if (columnApi.endsWith('Id')) {
                                label = resultProp.replace(new RegExp('Id$'), 'Name');
                                //target = columnApi.replace(new RegExp('Id$'), '');
                            }

                            console.log('label', label, recordLabel);

                            if(recordValue){
                                record[resultProp] = isCommunity ? `${orgDomain}detail/${recordValue}` : `${orgDomain}${recordValue}`;
                                record[label] = recordLabel;
                            }
                            break;
                        }
                        default : {
                            // 2023.12.13 - 값이 없을때 링크형태로 표시되는 현상이 있으므로 값이 없을때는 그냥 로직을 스킵하는 형태로 변경
                            if(recordValue){
                                // 마지막은 여기로 들어온다
                                switch (fieldApi) {
                                    // 링크 생성
                                    case 'Name' :
                                        /* 예를 들어 RiskVersionTest__r.Name 경우는 아래처럼 된다
                                        * idColumnApi = ['RiskVersionTest__r', 'Id']
                                        *
                                        *
                                        * */

                                        // ex) Opportunity.Account.Name의 경우 Name을 Id로 치환하여 아이디를 가져올 수 있도록 한다
                                        const idColumnApi = columnApi.replace('Name', 'Id').split('.');

                                        // Object를 순회하면서 결국 Id값을 가져온다
                                        let tempValue;
                                        idColumnApi.map(col => {
                                            tempValue = tempValue ? tempValue[col] : record[col];
                                        });

                                        // ex) record['RiskVersionTest__rId] = value;
                                        record[resultProp + 'Id'] = isCommunity ? `${orgDomain}detail/${tempValue}` : `${orgDomain}${tempValue}`;
                                        break;
                                }
                                record[resultProp] = recordValue;
                            }

                            break;
                        }
                    }
                } else { // 일반 필드
                    switch (fieldType) {
                        case 'REFERENCE' : {
                            let label, target;
                            if (columnApi.endsWith('__c')) {
                                label = columnApi.replace('__c', 'Name');
                                target = columnApi.replace('__c', '__r');
                            } else if (columnApi.endsWith('Id')) {
                                label = columnApi.replace(new RegExp('Id$'), 'Name');
                                target = columnApi.replace(new RegExp('Id$'), '');
                            }

                            if (record[target]) {
                                record[label] = record[target].Name;
                                record[columnApi] = `${orgDomain}${record[columnApi]}`;
                            }
                            break;
                        }
                        case 'PERCENT' : {
                            //record[columnApi] = record[columnApi].toFixed(scale);
                            record[columnApi] = record[columnApi] ? (record[columnApi] / 100) : null;
                            break;
                        }
                        default : {
                            // 현재 레코드
                            switch (fieldApi) {
                                case 'Name' :
                                    record.recordId = isCommunity ? `${orgDomain}detail/${record.Id}` : `${orgDomain}${record.Id}`;
                                    break;
                                case 'QuoteNumber' : // Specific case
                                    record.quoteId = isCommunity ? `${orgDomain}detail/${record.Id}` : `${orgDomain}${record.Id}`;
                                    break;
                                default :
                                    // todo hyper link
                                    /*if(isHtml){
                                        record[columnApi] = record[columnApi].replaceAll('\\', '').replace(/(<([^>]+)>)/gi, "")
                                    }*/
                                    break;
                            }
                        }
                    }
                }
            });

            // Access 프로퍼티 추가
            record.hasEditAccess = recordInfo.hasEditAccess;
            record.hasReadAccess = recordInfo.hasReadAccess;
            record.hasDeleteAccess = recordInfo.hasDeleteAccess;
            record.isLocked = recordInfo.isLocked;
            //record.isLocked = true;

            //if(accessMap) record.access = accessMap[record.Id];

            return record;
        });
    },


    _registerRecordChangeListener: function(component){
        component.addEventHandler('force:recordChange', component.getReference('c.fnRefresh'));
    },

    _registerDetailChangeListener: function(component){
        component.addEventHandler('force:refreshView', component.getReference('c.fnRefresh'));
    },

    _handleRefresh: function (component, query, countQuery) {
        console.info('%c==================================== RelatedListHelperHelper._handleRefresh', 'color:red;');
        component.set('v.isLoading', true);

        const params = {
            query: `${query}`,
            countQuery,
            needAccessCheck: component.get('v.needAccessCheck'),
        }

        console.log(params);

        // 선택된 항목 초기화
        // View All의 경우 테이블의 아이디가 다르므로, 테이블을 찾는 로직이 필요함
        // 2024.01.29 - sy.lee - 데이터가 하나도 없는 경우에 초기화 할 테이블이 없으므로 에러가 발생한다
        // - 테이블 존재 유무를 확인해서 메소드를 수행하는 로직 추가함
        const table = $A.util.isEmpty(component.find('table')) ? component.find('communityTable') : component.find('table');
        table && table.set('v.selectedRows', []);
        //component.set('v.data', []);

        this.apex(component, 'refresh', params)
            .then(result => {
                console.log('result', result);

                const {recordList, query, countQuery, totalRecordCount} = result;
                component.set('v.data', this._createData(component, recordList));
                component.set('v.query', query);
                component.set('v.countQuery', countQuery);

                // 2024.01.29 - sy.lee - 데이터 개수 출력 로직 추가
                // 레코드 카운트
                const {length} = recordList;
                component.set('v.recordCount', (length < totalRecordCount) ? `(${length}+)` : `(${length})`);
                // 아이템 카운트
                component.set('v.itemCount', `${$A.get("$Label.c.CMP_CR_Lab_NItems").replace('{0}', (length < totalRecordCount) ? `${length}+` : `${length}`)}`);

                component.set('v.isLoading', false);
            });
    },

    _handleTitle: function(component, labelPlural){
        const title = component.get('v.title');
        if($A.util.isEmpty(title)){
            component.set('v.title', labelPlural);
        }else if(title.endsWith('.Label')){
            component.set('v.title', $A.getReference("$Label.c." + title.replace('.Label', '')));
        }
    },

    _createRowAction: function(component, columnList){

        // 레코드 Approval Lock인 경우
        const isLocked = component.get('v.result').currentObject.isLocked;
        if(isLocked) return;

        const useEditRowAction = component.get('v.useEditRowAction');
        const useDeleteRowAction = component.get('v.useDeleteRowAction');
        const useShowDetailRowAction = component.get('v.useShowDetailRowAction');

        // 모든걸 다 막아야 하는 경우
        if(!useEditRowAction && !useDeleteRowAction && !useShowDetailRowAction) return;
        console.log('here');

        columnList.push({
            type: 'action',
            typeAttributes: {
                rowActions: this._getRowActions.bind(this, component),
            }
        });
    },

    //
    _getRowActions: function(component, row, doneCallback){

        console.info('%c==================================== RelatedListAuraHelper._getRowActions', 'color:red;');
        console.log(row);

        const useEditRowAction = component.get('v.useEditRowAction');
        const useDeleteRowAction = component.get('v.useDeleteRowAction');
        const useShowDetailRowAction = component.get('v.useShowDetailRowAction');

        const actions = [];
        const showDetailAction = {label: 'Show Detail', name: 'showDetail'};
        const editAction = {label: 'Edit', name:'edit'};
        const deleteAction = {label: 'Delete', name:'delete'};

        // todo 수정 필요
        // isLocked랑 access 처리 필요함

        if(row.isLocked) {
            showDetailAction.disabled = useShowDetailRowAction && row.hasReadAccess;
            editAction.disabled = true;
            deleteAction.disabled = true;
        } else {
            showDetailAction.disabled =  !row.hasReadAccess || !useShowDetailRowAction;
            editAction.disabled = !row.hasEditAccess || !useEditRowAction;
            deleteAction.disabled = !row.hasDeleteAccess || !useDeleteRowAction;
        }

        actions.push(showDetailAction);
        actions.push(editAction);
        actions.push(deleteAction);
        doneCallback(actions);
    },
});