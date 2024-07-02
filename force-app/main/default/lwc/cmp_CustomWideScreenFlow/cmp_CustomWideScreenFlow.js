/****************************************************************************************
 * File Name    : cmp_CustomWideScreenFlow
 * Author       : TungDx13
 * Date         : 2024-01-24
 * Description  : Screen Flow Enhencenment - Wide Screen
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * ===============================================================
 * Ver      Date                Author              Modification
 * ===============================================================
 1.0        2024-01-24          TungDX13            Create    
 1.1        2024-01-25          ThienVM2            Update    

 ****************************************************************************************/
import { LightningElement, api } from 'lwc';

export default class cmp_CustomWideScreenFlow extends LightningElement {
    @api width;
    @api maxWidth;
    @api minWidth;

    /**
    * @description custom style config for screen flow after rendered
    */
    renderedCallback() {
        const styleContainer = this.template.querySelector("div.style-overwrite__style-container");
        const styleTag = `
                            <style>
                                .uiModal--medium .modal-container {
                                    width: ${this.width}%;
                                    max-width: ${this.maxWidth}%;
                                    min-width: ${this.minWidth}%;
                                }
                            </style>
                        `;

        styleContainer.innerHTML = styleTag;
    }
}