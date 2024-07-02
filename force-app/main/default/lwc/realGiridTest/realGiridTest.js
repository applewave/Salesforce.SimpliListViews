/****************************************************************************************
 * File Name    : realGridSample
 * Author       : sy.lee
 * Date         : 2024-01-29
 * Description  :
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * ===============================================================
 * Ver      Date 		Author    			Modification
 * ===============================================================
 1.0		2024-01-29 	sy.lee			    Create

 ****************************************************************************************/

import {api, LightningElement} from 'lwc';
import {loadScript, loadStyle} from "lightning/platformResourceLoader";
import realGrid from '@salesforce/resourceUrl/RealGrid';

export default class realGiridTest extends LightningElement {
   
    @api recordId;
    _gridInitialized = false;


    renderedCallback() {
        console.info('%c==================================== realGridSample.renderedCallback', 'color:red;');

        if (this._gridInitialized) return;

        this._gridInitialized = true;

        Promise.all([
            loadScript(this, realGrid + '/realgrid-lic.js'),
            loadScript(this, realGrid + '/realgrid.2.8.2.min.js'),
            loadStyle(this, realGrid + '/realgrid-sky-blue.css')
        ]).then(() => {
            this._initializeGrid();
        })
        .catch(error => {
            console.log(error.stack);
        });
    }

    disconnectedCallback() {
        this.gridView = this.gridView.destroy();
        this.dataProvider = this.dataProvider.destroy();
    }

    _initializeGrid(){
        console.info('%c==================================== realGridSample._initializeGrid', 'color:red;');

        const container = this.template.querySelector('[data-id="realgrid"]');
        console.log(container);
        RealGrid.setSlotMode(true);
        window.gridView = this.gridView = new RealGrid.GridView(container);
        this.dataProvider = new RealGrid.LocalDataProvider();
        this.gridView.setDataSource(this.dataProvider);

        this.gridView.editOptions.editable = true;

        const {displayOptions} = this.gridView;
        // 컬럼 너비 자동 조정
        displayOptions.fitStyle = 'even';

        this.dataProvider.setFields([
            {
                fieldName: "Name",
            },
            {
                fieldName: "Age",
            },
            {
                fieldName: "Company"
            }
        ]);

        this.gridView.setColumns([
            {
                name: "Name",
                fieldName: "Name",
                width: "80",
                header: {
                    text: "Name",
                }
            },
            {
                name: "Age",
                fieldName: "Age",
                width: "80",
                header: {
                    text: "Age",
                }
            },
            {
                name: "Company",
                fieldName: "Company",
                width: "220",
                header: {
                    text: "Company Name",
                }
            }
        ]);

        this.dataProvider.setRows([
            ["aaa", "10", "ccc"],
            ["aaa", "10", "aaa"],
            ["aaa", "10", "bbb"],
            ["aaa", "10", "ccc"],
            ["aaa", "10", "ccc"],
            ["aaa", "10", "ccc"],
            ["aaa", "10", "ccc"],
            ["aaa", "10", "ccc"],
        ]);
    }

}