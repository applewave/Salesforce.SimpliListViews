/****************************************************************************************
 * File Name    : realGridUtil
 * Author       : sy.lee
 * Date         : 2024-02-27
 * Description  :
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * ===============================================================
 * Ver      Date 		Author    			Modification
 * ===============================================================
 1.0		2024-02-27 	sy.lee			    Create

 ****************************************************************************************/

// =================================================================
// Row
export function clearRows(){
    console.info('%c==================================== realGridUtil.clearRows', 'color:red;');
    this.dataProvider.clearRows();
}

export function setRows(recordList){
    console.info('%c==================================== realGridUtil.setRows', 'color:red;');
    this._recordList = recordList;
    this.dataProvider.setRows(this._refineRecordList(recordList));
}

// =================================================================
// Spinner
export function setIsLoading(){
    console.info('%c==================================== realGridUtil.setIsLoading', 'color:red;');
    this._isLoading = true;
}

export function unsetIsLoading(){
    console.info('%c==================================== realGridUtil.unsetIsLoading', 'color:red;');
    this._isLoading = false;
}

// =================================================================
// SavePoint
export function setSavePoint(){
    console.info('%c==================================== realGridUtil.setSavePoint', 'color:red;');
    this.dataProvider.savePoint(true);
}

export function rollback(){
    console.info('%c==================================== realGridUtil.rollback', 'color:red;');
    this.dataProvider.rollback();
}

export function clearSavePoints(){
    console.info('%c==================================== realGridUtil.clearSavePoints', 'color:red;');
    this.dataProvider.clearSavePoints();
}

// =================================================================
// Cancel
export function cancel(){
    console.info('%c==================================== realGridUtil.cancel', 'color:red;');
    this.gridView.cancel();
}

export function cancelEditor(){
    console.info('%c==================================== realGridUtil.cancelEditor', 'color:red;');
    this.gridView.cancelEditor();
}

// =================================================================
//  Salesforce Field Type -> RealGrid Column Type
export function getDataType(dataType){
    let gridDataType;
    switch (dataType) {
        case 'STRING' :
            gridDataType = 'text';
            break;
        case 'DOUBLE' :
        case 'INTEGER':
        case 'DECIMAL':
        case 'CURRENCY' : {
            gridDataType = 'number';
            break;
        }
        case 'PICKLIST' : {

        }
    }
    return gridDataType;
    // https://docs.realgrid.com/refs/value-type
}