/****************************************************************************************
 * File Name    : cmp_Table
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
import LightningDatatable from "lightning/datatable";
import richTextTemplate from './richText.html';
import textAreaTemplate from './textArea.html';
import checkBoxTemplate from './checkbox.html';

export default class cmp_Table extends LightningDatatable {
    static customTypes = {
        richText: {
            template: richTextTemplate,
            standardCellLayout: true,
            typeAttributes: ['richText']
        },
        /*relation: {
            template: relationTemplate,
            standardCellLayout: true,
            typeAttributes: ['relation']
        }*/
        textArea: {
            template: textAreaTemplate,
            standardCellLayout: true,
            typeAttributes: ['textArea']
        },
        checkbox: {
            template: checkBoxTemplate,
            standardCellLayout: true,
            typeAttributes: ['checkbox']
        },
    }
}