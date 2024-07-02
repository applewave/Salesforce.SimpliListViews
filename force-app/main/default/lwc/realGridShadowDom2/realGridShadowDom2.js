/****************************************************************************************
 * File Name    : TestRealGrid
 * Author       : yj.lee
 * Date         : 2024-06-24
 * Description  : 기능 테스트용도로 작성함. 추후 삭제예정 
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * ===============================================================
 * Ver      Date 		Author    			Modification
 * ===============================================================
 1.0		2024-06-24 	yj.lee			    Create

 ****************************************************************************************/
const DEBUG = true;

import { LightningElement, api, track } from 'lwc';
import {loadScript, loadStyle} from "lightning/platformResourceLoader";
import realGrid from '@salesforce/resourceUrl/RealGrid';
import {InitData, setDefaultDataform} from './exampleData';
import {Fields, Columns, ColumnLayout, setFields, setColumns, setColumnLayout} from './columnInfo';

import LightningConfirm from 'lightning/confirm';

export default class RealGridShadowDom2 extends LightningElement {

    eventMsg = "test";
    data = [];
    
    exportGrid() {
        this.gridView.exportGrid({type: "excel", target: "local"});
    }

    _gridInitialized = false;
    async renderedCallback() {

        if (this._gridInitialized) {
            return;
        }
        this._gridInitialized = true;
        
        Promise.all([
            loadScript(this, realGrid + '/realgrid-lic.js'),
            loadScript(this, realGrid + '/realgrid.2.8.2.min.js'),
            loadScript(this, realGrid + '/libs/jszip.min.js'),
            loadStyle(this, realGrid + '/realgrid-style.css')
        ])
        .then(() => {
            this._initializeGrid();
        })
        .catch(error => {
            console.log(error.stack);
        });
        /*
        try {
            await loadScript(this, realGrid + '/realgrid-lic.js');
            await loadScript(this, realGrid + '/realgrid.2.8.2.min.js');
            await loadScript(this, realGrid + '/libs/jszip.min.js');
            await loadStyle(this, realGrid + '/realgrid-style.css');

            this._initializeGrid();
        } catch (error) {
            this.log('renderedCallback error -> ', error);
        }*/
    }

    async _initializeGrid(){
        console.info('%c==================================== RealGrid Support', 'color:red;');

        //* 반드시 setSlotMode(true)로 설정해야 세일즈포스에서 리얼그리드가 정상 동작함. */
        RealGrid.setSlotMode(true);
        var container = this.template.querySelector('[data-id="realgrid"]');
        this.gridView = new RealGrid.GridView(container);
        this.dataProvider = new RealGrid.LocalDataProvider();
        this.gridView.setDataSource(this.dataProvider);
        
        this.gridView.setFixedOptions({
            colCount: 6,
            resizable: true
        });

        // this.dataProvider.setFields(Fields);
        // this.gridView.setColumns(Columns);
        // this.gridView.setColumnLayout(ColumnLayout);
        this.dataProvider.setFields(await setFields(2025,3));
        this.gridView.setColumns(await setColumns(2025,3));
        this.gridView.setColumnLayout(await setColumnLayout(2025,3));
        this.gridView.displayOptions.emptyMessage = "표시할 데이타가 없습니다.";
        this.gridView.header.height = 63;

        // ## Data Setting ##
        this.data = [...InitData];
        this.dataProvider.setRows(this.data);
        // this.gridView.refresh();
        this.setRowGroup();

        // ## Event Setting ##
        this.registerCallback();

        // 행 수정 옵션
        this.gridView.editOptions.editable = this.editable;
        this.gridView.editOptions.commitWhenLeave = true;
        this.gridView.editOptions.commitByCell = true;

        // 행 삭제 옵션 => https://docs.realgrid.com/guides/tip/delete
        this.dataProvider.softDeleting = true;
        this.dataProvider.deleteCreated = true;
        this.gridView.hideDeletedRows = true;

    }

    editable = true;
    changeMode(){
        this.log('change mode');
        this.gridView.editOptions.editable = !this.gridView.editOptions.editable;
        this.editable = this.gridView.editOptions.editable;
        var editOptions = ['insertable', 'appendable', 'deletable', 'deleteSelection'];
        editOptions.forEach(option => {
            this.gridView.editOptions[option] = this.editable;
        });
        // if(this.editable){
        //     // this.gridView.editOptions.insertable = true;
        //     // this.gridView.editOptions.appendable = true;
        //     this.gridView.setEditOptions({
        //         insertable: true,
        //         appendable: true,
        //         deletable : true,
        //         deleteSelection : true
        //     });
        // } else {
        //     this.gridView.setEditOptions({
        //         insertable: false,
        //         appendable: false,
        //         deletable : false,
        //         deleteSelection : false
        //     });
        // }
    }

    insertEmptyRow() {
        var row = this.gridView.getCurrent().dataRow;
        
        if(!row || row === -1){
            var dataRow = this.dataProvider.addRow({});
            this.gridView.setCurrent({dataRow: dataRow}); 
            return;
        }
        var itemIndex = this.gridView.getCurrent().itemIndex;
        var name = this.gridView.getValues(itemIndex).Name;

        this.dataProvider.insertRow(row, {"Name": name});
        this.gridView.showEditor(); //바로 편집기를 표시하고 싶을때
    }
    
    async btnRemoveRow() {
        let curr = this.gridView.getCurrent();
        // let confirm = await this.confrim('delete', '해당 행이 영구적으로 삭제됩니다.', 'header', 'shade');
        // if(!confirm){
        //     return;
        // }
        this.dataProvider.removeRow(curr.dataRow);
    }
    
    registerCallback(){
        //클릭 이벤트
        this.gridView.onCellClicked = (grid, clickData)=>{
            this.eventMsg = "onCellClicked: " + JSON.stringify(clickData);
        }
            
        this.gridView.onCellDblClicked = (grid, clickData)=>{
            // this.eventMsg = "onCellDblClicked: " + JSON.stringify(clickData);
            this.eventMsg = "onCellDblClicked: ";
            this.eventMsg += "itemIndex >"+ clickData.itemIndex+" : " + JSON.stringify(this.gridView.getValues(clickData.itemIndex));
        }
        
        // this.gridView.onCellItemClicked = (grid, index, clickData)=>{
        //     this.eventMsg = "onCellItemClicked: idx(" + index + ")=>"+ JSON.stringify(clickData);
        //     return true;
        // }
        
        this.gridView.onItemAllChecked = (grid, checked)=>{
            this.eventMsg = "onItemAllChecked: " + checked;
        }
        
        // this.gridView.onItemChecked = (grid, itemIndex, checked)=>{
        //     this.eventMsg = "onItemChecked: " + checked + " at idx: " + itemIndex;
        // }
        
        // this.gridView.onItemsChecked = (grid, items, checked)=>{
        //     this.eventMsg = "onItemChecked: " + items.join() + " are checked as " + checked;
        // }
        
        // this.gridView.onSearchCellButtonClick = (grid, index, text)=>{
        //     this.eventMsg = "onSearchCellButtonClick: " + ' button was clicked!';
        // }

        //열 병합
        this.gridView.onLayoutCollapsed = (grid, CellLayoutGroupItem)=>{
            this.eventMsg = "onLayoutCollapsed: " + CellLayoutGroupItem;
        }

        this.gridView. onLayoutCollapsing = (grid, CellLayoutGroupItem)=>{
            this.eventMsg = "onLayoutCollapsing: " + CellLayoutGroupItem;
            // false반환시 접히지 않는다.
            // return false; 
        }

        this.gridView.onLayoutExpanded = (grid, CellLayoutGroupItem)=>{
            this.eventMsg = "onLayoutExpanded: " + CellLayoutGroupItem;
        } 

        this.gridView.onLayoutExpanding = (grid, CellLayoutGroupItem)=>{
            this.eventMsg = "onLayoutExpanding: " + CellLayoutGroupItem;
            // false반환시 펼쳐지지 않는다.
            // return false; 
        }
        
        //행 병합
        this.gridView.onCollapsed = (grid, itemIndex)=>{
            this.eventMsg = "onCollapsed: idx=> " + itemIndex;
        }

        this.gridView.onExpanded = (grid, itemIndex)=>{
            this.eventMsg = "onExpanded: idx=> " + itemIndex; //?? 왜 -1임???? itemIndex가 아닌거 같은데?
        }

        //행 삭제
        this.gridView.onRowsDeleting = (grid, rows) => { //안나옴
            this.eventMsg += "<br/> gridView.onRowsDeleting: rows=> " + rows;
            return true;
        };

        this.dataProvider.onRowsDeleted = (provider, rows) => { //안나옴
            this.eventMsg += "<br/> provider.onRowsDeleted: rows=> " + rows.join(', ');
        };

        this.dataProvider.onRowDeleting = (provider, row) => {
            this.eventMsg += "<br/> provider.onRowDeleting: row=> " + row;
            return true;
        };

        //스크롤
        this.gridView.onScrollToBottom = () => {
            this.eventMsg = "onScrollToBottom";
        };

        //행 그룹핑
        this.gridView.onGrouping = (grid) => {
            this.eventMsg = "onGrouping : ";// + Object.keys(grid);
            return true;
        };

        // this.gridView.onGrouped = (grid) => {
        //     alert(
        //     "onGrouped : isGrouped = " +
        //         grid.isGrouped() +
        //         ", isMergedGrouped  = " +
        //         grid.isMergedGrouped()
        //     );
        // };
    }

    setRowGroup() {
        console.log('set row group');
        this.gridView.groupPanel.visible = true;
        this.gridView.groupBy(["Name"]);
        this.gridView.setRowGroup({
            mergeMode:true, 
            expandedAdornments: "footer", //header, footer, both
            collapsedAdornments: "both",
            createFooterCallback: function(grid, group) {
                if (group.level >= 2) {
                    return false;
                }
                return true;
            }
        });
    }

    disconnectedCallback() {
        this.gridView = this.gridView.destroy();
        this.dataProvider = this.dataProvider.destroy();
    }

	log(msg, variable){ if(DEBUG){ console.log(msg, variable == undefined ? '' : variable); } }

    async confrim(label, message, variant, theme){
    
        const result = await LightningConfirm.open({
                message: message,
                variant: variant,
                label: label,
                theme : theme ? theme : 'default'
        });
        return result;
    }
}