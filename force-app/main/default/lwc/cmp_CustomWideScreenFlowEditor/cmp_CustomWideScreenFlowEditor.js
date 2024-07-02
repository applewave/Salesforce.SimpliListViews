/****************************************************************************************
 * File Name    : cmp_CustomWideScreenFlowEditor
 * Author       : ThienVM2
 * Date         : 2024-01-24
 * Description  : Screen Flow Enhencenment - Wide Screen Editor
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * ===============================================================
 * Ver      Date                Author              Modification
 * ===============================================================
 1.0        2024-01-24          ThienVM2            Create    
 1.1        2024-01-29          ThienVM2            Update    

 ****************************************************************************************/
import { LightningElement, api } from 'lwc';
import CustomMaxWidthLab from '@salesforce/label/c.CMP_CSF_Lab_CustomMaxWidth';
import CustomMinWidthLab from '@salesforce/label/c.CMP_CSF_Lab_CustomMinWidth';
import CustomWidthLab from '@salesforce/label/c.CMP_CSF_Lab_CustomWidth';
import MaxWidthCustom from '@salesforce/label/c.CMP_CSF_Msg_SOQLCheckSuccess';
import MaxWidthMsg from '@salesforce/label/c.CMP_CSF_Msg_MaxWidthErrorMsg';
import MinWidthCustom from '@salesforce/label/c.CMP_CSF_Lab_MinWidth';
import MinWidthMsg from '@salesforce/label/c.CMP_CSF_Msg_MinWidthErrorMsg';
import ScreenFlowCustomEvtMsg from '@salesforce/label/c.CMP_CSF_Msg_CustomEvtInputMsg';
import WidthMsg from '@salesforce/label/c.CMP_CSF_Msg_WidthErrorMsg';
import WidthOutOfRangeMsg from '@salesforce/label/c.CMP_CSF_Msg_WidthOutOfRangeErrorMsg';

export default class cmp_CustomWideScreenFlowEditor extends LightningElement {
    _inputVariables = [];
    _maxValueDefault = MaxWidthCustom ? Number(MaxWidthCustom) : 95;
    _minValueDefault = MinWidthCustom ? Number(MinWidthCustom) : 70;
    _msgMaxWidth = MaxWidthMsg;
    _msgMinWidth = MinWidthMsg;
    _msgScreenFlowCustomEvt = ScreenFlowCustomEvtMsg;
    _msgWidth = WidthMsg;
    _msgWidthOutOfRange = WidthOutOfRangeMsg;
    labCustomMaxWidth = CustomMaxWidthLab;
    labCustomMinWidth = CustomMinWidthLab;
    labCustomWidth = CustomWidthLab;

    /**
     * @description Get the value of the input variable.
     */
    @api
    get inputVariables() {
        return this._inputVariables;
    }

    /**
     * @description Set a field with the data that was stored from the flow.This data includes the public property of the custom property component.
     * @param {Array} variables the variables will be stored from the flow
     */
    set inputVariables(variables) {
        this._inputVariables = variables || [];
    }

    /**
     * @description Get the value of the width input variable.
     */
    get width() {
        const param = this.inputVariables.find(({ name }) => name === "width");
        return param && Number(param.value);
    }

    /**
     * @description Get the value of the max width input variable.
     */
    get maxWidth() {
        const param = this.inputVariables.find(({ name }) => name === "maxWidth");
        return param && Number(param.value);
    }

    /**
     * @description Get the value of the min width input variable.
     */
    get minWidth() {
        const param = this.inputVariables.find(({ name }) => name === "minWidth");
        return param && Number(param.value);
    }

    /**
     * @description Validate function from system, used for validate input of the user when entering the width/maxWidth/minWidth
     */
    @api
    validate() {
        const maxWidthInp = this.template.querySelector(".max-width-inp");
        const widthInp = this.template.querySelector(".width-inp");
        const minWidthInp = this.template.querySelector(".min-width-inp");
        const validity = [];

        if (maxWidthInp) {
            if (this?.maxWidth < this._minValueDefault || this?.maxWidth > this._maxValueDefault) {
                maxWidthInp.setCustomValidity(this._msgMaxWidth);
                validity.push({
                    key: "Max Width Range",
                    errorString: this._msgMaxWidth,
                });
            }
            else {
                maxWidthInp.setCustomValidity("");
            }
            maxWidthInp.reportValidity();
        }
        if (widthInp) {
            if (this?.width < this?._minValueDefault || this?.width > this?._maxValueDefault) {
                widthInp.setCustomValidity(this._msgWidth);
                validity.push({
                    key: "Width Range",
                    errorString: this._msgWidth,
                });
            }
            else if (this?.width < this?.minWidth || this?.width > this?.maxWidth) {
                widthInp.setCustomValidity(this._msgWidthOutOfRange);
                validity.push({
                    key: "Width Out Of Range",
                    errorString: this._msgWidthOutOfRange,
                });
            }
            else {
                widthInp.setCustomValidity("");
            }
            widthInp.reportValidity();
        }
        if (minWidthInp) {
            if (this?.minWidth < this?._minValueDefault || this?.minWidth > this?._maxValueDefault) {
                minWidthInp.setCustomValidity(this._msgMinWidth);
                validity.push({
                    key: "Min Width Range",
                    errorString: this._msgMinWidth,
                });
            }
            else {
                minWidthInp.setCustomValidity("");
            }
            minWidthInp.reportValidity();
        }

        return validity;       
    }

    /**
     * @description Handle change value for width/minWidth/maxWidth input
     * @param {Event} event to get the current value from inputs that entering from user
     */
    handleChangeVal(event) {
        if (event && event.detail) {
            const inputName = this._investigateInputName(event.currentTarget.dataset.id);
            const newValue = event.detail.value;
            const valueChangedEvent = new CustomEvent(this._msgScreenFlowCustomEvt, {
                bubbles: true,
                cancelable: false,
                composed: true,
                detail: {
                    name: inputName,
                    newValue,
                    newValueDataType: "Number",
                },
            });

            this.dispatchEvent(valueChangedEvent);
        }
    }

    /**
     * @description Investigate whether the input is maxWidth, minWidth or width
     * @param {String} inputName the name is config from html to distinguish input type
     * @returns {String} this name of the input
     */
    _investigateInputName(inputName) {
        switch (inputName) {
            case "maxWidth":
                return "maxWidth";
            case "minWidth":
                return "minWidth";
            default:
                return "width";
        }
    }

    /**
     * @description show error message when get data
     */
     _showToastMessage(message) {
        const event = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}