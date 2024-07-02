/****************************************************************************************
 * File Name    : cmp_CustomReadOnlyField
 * Author       : TungDx13
 * Date         : 2024-01-24
 * Description  : Screen Flow Enhencenment - Custom Read Only Field
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * ===============================================================
 * Ver      Date                Author              Modification
 * ===============================================================
 1.0        2024-01-24          TungDX13            Create 

 ****************************************************************************************/
import { LightningElement, wire, api} from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class cmp_CustomReadOnlyField extends LightningElement {
    @api fieldType;
    @api fieldLabel;
    @api fieldValue;

    _isCheckboxField = false;
    _isTextField = false;
    _isDateField = false;
    _isDateTimeField = false;
    _isNumberField = false;
    _isPercentField = false;
    _isCurrencyField = false;

    _objectApiName;
    _fieldApiName = [];
    _translateType;

    /**
    * @description get field info from object API name
    * @param {Object} getObjectInfo import library uiObjectInfoApi
    * @param {array} objectApiName object API name
    */
    @wire(getObjectInfo, {objectApiName: '$_objectApiName'})
    wiredObjectInfo({ error, data }) {
        if (data) {
            for (const item of this._fieldApiName) {
                const fieldInfo = data.fields[item.value];
                if (fieldInfo) {
                    if (item.type == 'value') {
                        this.fieldValue = fieldInfo.label;
                    }
                    if (item.type == 'label') {
                        this.fieldLabel = fieldInfo.label;
                    }
                }
            }
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    /**
    * @description determine value from flow after rendered
    */
    connectedCallback() {
        if (this.fieldType != null) {
            const fieldType = this.fieldType.toLowerCase();
            switch (fieldType) {
                case 'checkbox':

                    break;
                case 'date':
                    this._isDateField = true;
                    const regexDate1 = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,3})?Z$/;
                    if (regexDate1.test(this.fieldValue)) {
                        const dateObject = new Date(this.fieldValue);
                        // Extract the date part (YYYY-MM-DD)
                        const formattedDate = dateObject.toISOString().split('T')[0];
                        this.fieldValue = formattedDate;
                    }
                    break;
                case 'datetime':
                    this._isDateTimeField = true;
                    const regexDate2 = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,3})?Z$/;
                    if (regexDate2.test(this.fieldValue)) {
                        this.fieldValue = new Date(this.fieldValue).toISOString().slice(0, 16);
                    }
                    break;
                case 'number':
                    this._isNumberField = true;
                    break;
                case 'percent':
                    this._isPercentField = true;
                    break;
                case 'currency':
                    this._isCurrencyField = true;
                    break;
                case 'text':
                    this._isTextField = true;
                    break;
                default:
                    this._isTextField = true;
            }
        } else {
            this._isTextField = true;
        }

        if (this.fieldLabel) {
            this._detectFieldValueType(this.fieldLabel, 'label');
        }

        if (this.fieldValue) {
            this.fieldType = this.fieldType.toLowerCase();
            this._detectFieldValueType(this.fieldValue, 'value');
        }
    }

    /**
    * @description detect type of field value
    * @param {string} fieldValue value of fielValue input
    * @param {string} type is value or label
    */
    _detectFieldValueType(fieldValue, type) {
        const patternField = fieldValue.toString().match(/^\{?([^\.]+)\.([^\.]+)\}?$/);
        if (patternField){
            var objAPIName = patternField[1];
            var fieldAPIName = patternField[2];
            this._isTextField = true;
            this.fieldType = 'text';

            this._translateFieldLabel(objAPIName, fieldAPIName, type);

        } else {
            if (this.fieldType == 'checkbox') {
                this._isCheckboxField = true;
            } 
            else if (this._isPercentField && !isNaN(fieldValue)) {
                this.fieldValue =  new Intl.NumberFormat(undefined, { style: 'percent' }).format(this.fieldValue / 100);
            }
        }
    }

    /**
    * @description translate field label
    * @param {string} objectApiName value of object API name
    * @param {string} fieldApiName value of field API name
    * @param {string} type is value or label
    */
    _translateFieldLabel(objectApiName, fieldApiName, type) {
        this._objectApiName = objectApiName;
        this._fieldApiName.push({ type: type, value: fieldApiName });
    }
}