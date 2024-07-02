/****************************************************************************************
 * File Name    : table
 * Author       : sy.lee
 * Date         : 2024-06-24
 * Description  :
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * ===============================================================
 * Ver      Date 		Author    			Modification
 * ===============================================================
 1.0		2024-06-24 	sy.lee			    Create

 ****************************************************************************************/
const createData = (result) => {
    console.info('%c==================================== data.createData', 'color:red;');

    const {data: {recordList, accessMap, totalRecordCount}, orgDomain, columnList, columnMap, relatedObject} = result;


    // 데이터가 없는 경우
    if(!recordList){
        return;
    }

    //const temp = [recordList[0]];

    return recordList.map(recordOrigin => {
        // 복사안하면 터짐
        const record = {...recordOrigin};

        columnList.map(columnApi => {
            const {
                label: fieldLabel,
                fieldType,
                api: fieldApi,
                scale: fieldScale,
                isHtml: fieldIsHtml
            } = _getFieldInfo(columnMap, relatedObject, columnApi);

            if (_isRelationField(columnApi)) { // Relation Field
                console.log('relation', columnApi);
                // 관련 레코드에 대한 정보는 여기로 들어온다
                const relations = columnApi.split('.');
                // Relation 순회
                let recordLabel = record, recordValue = record;
                relations.map(relation => {
                    // 마지막에 도달하면 Name 값을 가져와야 한다
                    // ex) Opportunity.Account.Name인 경우, Opportunity의 정보를 recordValue에 넣고, 거기서 Account를 읽어서 recordValue에 넣은 다음 Name을 찾는다
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
                    console.log(recordValue);
                });

                // ex) Opportunity.Account.Name의 경우, OpportunityAccountName이 된다
                const resultProp = _removeDot(columnApi); // .을 제거한 Api Name 생성

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

                        console.log('label', label);

                        if(recordValue){
                            record[resultProp] = `${orgDomain}${recordValue}`;
                            record[label] = recordLabel;
                        }
                        break;
                    }
                    default : {
                        // 마지막은 여기로 들어온다
                        switch (fieldApi) {
                            // 링크 생성
                            case 'Name' :
                                // ex) Opportunity.Account.Name의 경우 Name을 Id로 치환하여 아이디를 가져올 수 있도록 한다
                                const idColumnApi = columnApi.replace('Name', 'Id').split('.');
                                let tempValue;
                                idColumnApi.map(col => {
                                    tempValue = tempValue ? tempValue[col] : record[col];
                                });
                                record[resultProp + 'Id'] = `${orgDomain}${tempValue}`;
                                break;
                        }
                        // 테이블에 보일 값
                        record[resultProp] = recordValue;
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
                                record.recordId = `${orgDomain}${record.Id}`;
                                break;
                            case 'QuoteNumber' : // Specific case
                                record.quoteId = `${orgDomain}${record.Id}`;
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
        if(accessMap) record.access = accessMap[record.Id];

        return record;
    });
};

/**
 * @description get field information from metadata
 * @param columnMap
 * @param relatedObject
 * @param columnApi
 * @returns {*}
 */
const _getFieldInfo = (columnMap, relatedObject, columnApi) =>{
    return relatedObject[columnMap[columnApi]].fieldMap[columnApi.includes('.') ? columnApi.substring(columnApi.lastIndexOf('.') + 1) : columnApi];
};

/**
 * @description whether the relation field or not
 * @param columnApi
 * @returns {*}
 */
const _isRelationField = (columnApi) => {
    return columnApi.includes('.');
}

/**
 * @description remove the . from string
 * @param columnApi
 * @returns {string}
 */
const _removeDot = (columnApi) => {
    return columnApi.replaceAll('.', '');
}

const _getColumnType = (fieldType) => {
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
        case 'DATETIME' :
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
            type = 'text';
            break;
    }
    return type;
};


const _reference = (fieldLabel, columnApi, fieldType, useSorting, label) => ({
    label: fieldLabel.endsWith(' ID') ? fieldLabel.replace(new RegExp(' ID$'), '') : fieldLabel, // Remove 'ID' from label
    fieldName: _removeDot(columnApi),
    type: 'url',
    sortable: useSorting,
    typeAttributes: {
        label: {fieldName: label},
        tooltip: {fieldName: label}
    }
});

const _currency = (fieldLabel, columnApi, fieldType, useSorting, scale) => ({
    label: fieldLabel,
    fieldName: _removeDot(columnApi),
    type: _getColumnType(fieldType),
    sortable: useSorting,
    /*typeAttributes: {
        currencyCode: currency,
        currencyDisplayAs: 'code'
    },*/
    cellAttributes: {
        alignment: 'left',
        minimumFractionDigits: scale,
    }
});

const _number = (fieldLabel, columnApi, fieldType, useSorting, scale) => ({
    label: fieldLabel,
    fieldName: _removeDot(columnApi),
    type: _getColumnType(fieldType),
    sortable: useSorting,
    cellAttributes: {
        alignment: 'left',
        minimumFractionDigits: scale,
    }
});

const _date = (fieldLabel, columnApi, fieldType, useSorting) => ({
    label: fieldLabel,
    fieldName: _removeDot(columnApi),
    type: _getColumnType(fieldType),
    sortable: useSorting,
    cellAttributes: {
        alignment: 'left'
    }
});

const _dateTime = (fieldLabel, columnApi, fieldType, useSorting) => ({
    label: fieldLabel,
    fieldName: _removeDot(columnApi),
    type: _getColumnType(fieldType),
    sortable: useSorting,
    typeAttributes: {
        year: 'numeric',
        month: 'numeric',
        day: 'numeric',
        hour: 'numeric',
        minute: 'numeric',
    },
    cellAttributes: {
        alignment: 'left'
    }
});

const _percent = (fieldLabel, columnApi, fieldType, useSorting, scale) => ({
    label: fieldLabel,
    fieldName: _removeDot(columnApi),
    type: _getColumnType(fieldType),
    sortable: useSorting,
    cellAttributes: {
        alignment: 'left',
        minimumFractionDigits: scale,
    }
});

const _relation = (fieldLabel, columnApi, fieldType, useSorting) => ({
    //label: fieldLabel,
    label: 'AAA',
    type: _getColumnType(fieldType),
    typeAttributes: {
        relation: {
            fieldName: _removeDot(columnApi),
        }
    },
    //sortable: false,
});

const _richText = (fieldLabel, columnApi, fieldType, useSorting) => ({
    label: fieldLabel,
    type: _getColumnType(fieldType),
    typeAttributes: {
        richText: {
            fieldName: _removeDot(columnApi),
        }
    },
    //sortable: false,
});

const _text = (fieldLabel, columnApi, fieldType, useSorting) => ({
    label: fieldLabel,
    fieldName: _removeDot(columnApi),
    type: _getColumnType(fieldType),
    sortable: useSorting,
});

const _textArea = (fieldLabel, columnApi, fieldType, useSorting) => ({
    label: fieldLabel,
    type: _getColumnType(fieldType),
    typeAttributes: {
        textArea: {
            fieldName: _removeDot(columnApi),
        }
    },
    sortable: useSorting,
});

const _url = (fieldLabel, columnApi, fieldType, useSorting) => ({
    label: fieldLabel,
    fieldName: _removeDot(columnApi),
    type: _getColumnType(fieldType),
    sortable: false,
    typeAttributes: {
        target: '_blank',
    }
});

const _checkbox = (fieldLabel, columnApi, fieldType, useSorting) => ({
    label: fieldLabel,
    fieldName: _removeDot(columnApi),
    type: _getColumnType(fieldType),
    typeAttributes: {
        checkbox: {
            fieldName: _removeDot(columnApi),
        }
    },
    sortable: useSorting,
});

const _name = (fieldLabel, columnApi, fieldType, useSorting) => ({
    label: fieldLabel,
    fieldName: _isRelationField(columnApi) ? (columnApi.split('.').join('') + 'Id') : 'recordId',
    type: 'url',
    sortable: useSorting,
    typeAttributes: {
        label: {fieldName: _isRelationField(columnApi) ? (columnApi.split('.').join('')) : 'Name'},
        tooltip: {fieldName: _isRelationField(columnApi) ? (columnApi.split('.').join('')) : 'Name'}
    }
});

const _quoteNumber = (fieldLabel, columnApi, fieldType, useSorting) => ({
    label: fieldLabel,
    fieldName: 'quoteId',
    type: 'url',
    sortable: useSorting,
    typeAttributes: {
        label: {fieldName: 'QuoteNumber'},
        tooltip: {fieldName: 'QuoteNumber'}
    }
});

const _nameLookup = (fieldLabel, columnApi, fieldType, useSorting) => ({
    label: fieldLabel,
    fieldName: 'recordId',
    type: 'button',
    sortable: useSorting,
    typeAttributes: {
        label: {fieldName: 'Name'},
        tooltip: {fieldName: 'Name'},
        variant : 'base'
    }
});

function createColumn(result, useSorting){

    const dataTableColumnList = [];
    result.columnList.map(columnApi => {
        const {
            label: fieldLabel,
            fieldType,
            api: fieldApi,
            scale: fieldScale,
            isHtml: fieldIsHtml,
            objectApi
        } = _getFieldInfo(result.columnMap, result.relatedObject, columnApi);

        let column;
        switch (fieldType) {
            case 'REFERENCE' : { // Lookup or Master-Detail Field ========================================
                /*if(isWithOutSharing){
                    column = this.getTextCol(fieldLabel, columnApi, 'TEXT');
                }else{*/
                let label;
                if(_isRelationField(columnApi)){
                    label = _removeDot(columnApi);
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
                column = _reference(fieldLabel, columnApi, fieldType, useSorting, label);
                //}
                break;
            }

            case 'CURRENCY' : {
                column = _currency(fieldLabel, columnApi, fieldType, useSorting, fieldScale);
                break;
            }

            case 'DOUBLE' : {
                column = _number(fieldLabel, columnApi, fieldType, useSorting, fieldScale);
                break;
            }

            case 'DATE' : {
                column = _date(fieldLabel, columnApi, fieldType, useSorting);
                break;
            }

            case 'PERCENT' : {
                column = _percent(fieldLabel, columnApi, fieldType, useSorting, fieldScale);
                break;
            }

            case 'TEXTAREA' : {
                //column = this.getRichTextCol(fieldLabel, columnApi, 'RICHTEXT', fieldScale);
                if (fieldIsHtml) { // Rich Text
                    column = _richText(fieldLabel, columnApi, 'RICHTEXT');
                } else { // Text Area
                    column = _textArea(fieldLabel, columnApi, fieldType, useSorting);
                }
                break;
            }

            case 'URL' : {
                column = _url(fieldLabel, columnApi, fieldType, useSorting);
                break;
            }

            case 'BOOLEAN' : {
                column = _checkbox(fieldLabel, columnApi, fieldType, useSorting);
                break;
            }

            case 'DATETIME' : {
                column = _dateTime(fieldLabel, columnApi, fieldType, useSorting);
                break;
            }

            default : { // Else ==========================================================================
                switch (fieldApi) {
                    case 'Name' : { // Name Field should be Link
                        console.log('465', fieldLabel, columnApi, fieldType);
                        column = _name(fieldLabel, columnApi, fieldType, useSorting);
                        //column = this.getRelationCol(fieldLabel, columnApi, 'RELATION', fieldScale);
                        break;
                    }

                    case 'QuoteNumber' : {
                        column = _quoteNumber(fieldLabel, columnApi, fieldType, useSorting);
                        break;
                    }

                    default : {

                        // Hyperlink 처리
                        if (fieldIsHtml) {
                            column = _reference(fieldLabel, columnApi, fieldType, useSorting, _removeDot(columnApi));
                        } else { // 일반 필드
                            column = _text(fieldLabel, columnApi, fieldType, useSorting);
                        }
                        break;
                    }
                }
                break;
            }

        }


        dataTableColumnList.push(column);
        /*
        console.log(column);
        // 사용자 정의 Sorting을 위한 정보를 저장한다
        sortMap[column.fieldName] = column.label;

        if (columnApi === sortedBy) {
            component.set('v.sortedBy', column.fieldName);
            component.set('v.sortedByLabel', column.label);
        }*/
    });

    return dataTableColumnList;
}

function createColumnLookup(result){

    const dataTableColumnList = [];
    result.columnList.map(columnApi => {
        const {
            label: fieldLabel,
            fieldType,
            api: fieldApi,
            scale: fieldScale,
            isHtml: fieldIsHtml
        } = _getFieldInfo(result.columnMap, result.relatedObject, columnApi);

        let column;
        switch (fieldType) {
            case 'REFERENCE' : { // Lookup or Master-Detail Field ========================================
                /*if(isWithOutSharing){
                    column = this.getTextCol(fieldLabel, columnApi, 'TEXT');
                }else{*/
                let label;
                if(_isRelationField(columnApi)){
                    label = _removeDot(columnApi);
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
                column = _reference(fieldLabel, columnApi, fieldType, label);
                //}
                break;
            }

            case 'CURRENCY' : {
                column = _currency(fieldLabel, columnApi, fieldType, fieldScale);
                break;
            }

            case 'DOUBLE' : {
                column = _number(fieldLabel, columnApi, fieldType, fieldScale);
                break;
            }

            case 'DATE' : {
                column = _date(fieldLabel, columnApi, fieldType);
                break;
            }

            case 'PERCENT' : {
                column = _percent(fieldLabel, columnApi, fieldType, fieldScale);
                break;
            }

            case 'TEXTAREA' : {
                //column = this.getRichTextCol(fieldLabel, columnApi, 'RICHTEXT', fieldScale);
                if (fieldIsHtml) { // Rich Text
                    column = _richText(fieldLabel, columnApi, 'RICHTEXT');
                } else { // Text Area
                    column = _textArea(fieldLabel, columnApi, fieldType);
                }
                break;
            }

            case 'URL' : {
                column = _url(fieldLabel, columnApi, fieldType);
                break;
            }

            case 'BOOLEAN' : {
                column = _checkbox(fieldLabel, columnApi, fieldType);
                break;
            }

            case 'DATETIME' : {
                column = _dateTime(fieldLabel, columnApi, fieldType);
                break;
            }

            default : { // Else ==========================================================================
                switch (fieldApi) {
                    case 'Name' : { // Name Field should be Link
                        column = _nameLookup(fieldLabel, columnApi, fieldType);
                        // column = _name(fieldLabel, columnApi, fieldType);
                        //column = this.getRelationCol(fieldLabel, columnApi, 'RELATION', fieldScale);
                        break;
                    }

                    case 'QuoteNumber' : {
                        column = _quoteNumber(fieldLabel, columnApi, fieldType);
                        break;
                    }

                    default : {
                        // Hyperlink 처리
                        if (fieldIsHtml) {
                            column = _reference(fieldLabel, columnApi, fieldType, _removeDot(columnApi));
                        } else { // 일반 필드
                            column = _text(fieldLabel, columnApi, fieldType);
                        }
                        break;
                    }
                }
                break;
            }

        }


        dataTableColumnList.push(column);
        /*
        console.log(column);
        // 사용자 정의 Sorting을 위한 정보를 저장한다
        sortMap[column.fieldName] = column.label;

        if (columnApi === sortedBy) {
            component.set('v.sortedBy', column.fieldName);
            component.set('v.sortedByLabel', column.label);
        }*/
    });

    return dataTableColumnList;
}

function createSortMap(columnList){
    const sortMap = {};

    columnList.map(col => {
        const {fieldName, label} = col;
        let fieldApi = fieldName;
        switch (col.type){
            case 'url' : {
                fieldApi = col.typeAttributes.label.fieldName;
                break;
            }
            case 'checkbox' : {
                fieldApi = col.typeAttributes.checkbox.fieldName;
                break;
            }
        }

        sortMap[fieldName] = {
            label,
            fieldApi
        };
    });
    return sortMap;
}


export {createData, createColumn, createColumnLookup, createSortMap}