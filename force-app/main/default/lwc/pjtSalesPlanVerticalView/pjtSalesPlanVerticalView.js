/****************************************************************************************
 * File Name    : PjtSalesPlanVerticalView
 * Author       : ar.kim
 * Date         : 2024-07-01
 * Description  :
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * ===============================================================
 * Ver      Date 		Author    			Modification
 * ===============================================================
 1.0		2024-07-01 	ar.kim			    Create

 ****************************************************************************************/
 import {api, LightningElement, track} from 'lwc';
 import {loadScript, loadStyle} from 'lightning/platformResourceLoader';
 import realGrid from '@salesforce/resourceUrl/RealGrid';
 
 import init from '@salesforce/apex/PjtSalesPlanVerticalViewController.init';
 import getSalesPlanItem from '@salesforce/apex/PjtSalesPlanVerticalViewController.getSalesPlanItem';
 import getSalesPlanDetail from '@salesforce/apex/PjtSalesPlanVerticalViewController.getSalesPlanDetail';
 import setProjectSalesPlanList from '@salesforce/apex/PjtSalesPlanVerticalViewController.setProjectSalesPlanList';

export default class PjtSalesPlanVerticalView extends LightningElement {

    // =================================================================   realGridProjectSalesPlanVerticlSample
    // Grid
    gridView;
    dataProvider;

    // =================================================================
    // Data
    _result;
    _startYear;
    _term;
    _objectDescribeMap;
    _recordList=[];
    _dataSize;
    _startTime;
    loadingTime;

    @api
    _renderedData(recordId) {
        console.info('%c==================================== PjtSalesPlanVerticalViewController.renderedCallback', 'color:red;');
        console.log('recordId', recordId);
        this._startTime = new Date();
        console.log('this._startTime', this._startTime);

        init({recordId: recordId}).then(result => {
           this._result = result;
           this._objectDescribeMap = this._result.objectDescribeMap;
           console.info('%c==================================== RealGridProjectSalesPlanBulkController.getSalesPlanItem', 'color:gray;');
           return getSalesPlanItem({paramListId: this._result.pjtSalesPlanIdList});
       }).then(result => {
           this._result.itemList = result.itemList;
           this._result.itemListSize = result.itemListSize;
           this._startYear = result.pjtStartYear;
           this._term = result.pjtTerm;

           console.info('%c==================================== RealGridProjectSalesPlanBulkController.getSalesPlanDetail', 'color:gray;');
           return getSalesPlanDetail({paramListId: this._result.pjtSalesPlanIdList});
       }).then(result => {
           this._result.detailList = result.detailList;
           this._result.detailListSize = result.detailListSize;
           console.log('this._result', this._result);

           /*for(let i=0; i<this._result.itemListSize; i++){
               let itemList = [ this._result.itemList[i] ];
               console.log('itemList', itemList);
               setProjectSalesPlanList({itemList: itemList, detailList: this._result.detailList})
               .then(result => {
                   console.log('res', result);

                   this.dataProvider.fillJsonData(result, {
                       fillMode: "append",
                       noStates: true
                   });

                   if( i/10 == 0){
                       this.gridView.refresh();
                   }
               }).catch(error => {
                   console.info('%c==================================== ERROR', 'color:red;');
                   console.log(JSON.stringify(error));
               });
               
           }
           
           this._initializeGrid();*/

           // 대량 처리 필요
           // to do...
           // itemList, detailList를 분할하여 적재 후 최초 setProjectSaelsPlanList 호출하기
           // 한번에 몇건씩 할지 확인.... itemList와 detailList 갯수도 정리 

           /*let itemList = [];
           for(let i=0; i<this._dataSize ; i++){ 
               itemList.push(this._result.itemList[i]);
           }
           console.log(this._result.itemList.slice(this._dataSize));
           this._result.itemList = this._result.itemList.slice(this._dataSize);*/

           console.info('%c==================================== RealGridProjectSalesPlanBulkController.setProjectSalesPlanList', 'color:gray;');
           return setProjectSalesPlanList({itemList: this._result.itemList, detailList: this._result.detailList});
       }).then(result => {
           console.log('set data', result);
           this._recordList = result;
           var endTime = new Date();
           console.log('데이터 로딩 소요시간', (endTime-this._startTime)/1000);

           // data null 처리 필요
           this._initializeGrid();
       }).catch(error => {
           console.log('PjtSalesPlanVerticalView renderedData ERROR', JSON.stringify(error));
       });
    }

    @api
    _destroy(){
        console.log('call destroy method');
        if(this.gridView){
            this.gridView = this.gridView.destroy();
            
        }
        if(this.dataProvider){
            this.dataProvider = this.dataProvider.destroy();
        }
    }


    _initializeGrid(){
        console.info('%c==================================== PjtSalesPlanVerticalView._initializeGrid', 'color:red;');

        const container = this.template.querySelector("[data-id='realgrid']");
        console.log(container);
        RealGrid.setSlotMode(true);
        window.gridView = this.gridView = new RealGrid.GridView(container);
        this.dataProvider = new RealGrid.LocalDataProvider();
        this.gridView.setDataSource(this.dataProvider);

        this.gridView.displayOptions.emptyMessage = "표시할 데이타가 없습니다.";

        const {displayOptions} = this.gridView;
        // 컬럼 너비 자동 조정
        displayOptions.fitStyle = 'even';

        // =================================================================
        // Fields
        this.dataProvider.setFields(this._fields);

        // =================================================================
        // Grid Option
        this.gridView.setOptions({
            //gridView.setOptions() 안에서 옵션 설정할때는 set삭제, 첫글자 소문자, options도 삭제
            //ex1) setEditOptions() -> edit
            //ex2) setFixedOptions() -> fixed
            //ex3) setFilterPanel() -> filterPanel
            //ex4> setDisplayOptions() -> display

            // =================================================================
            // 컬럼 너비 자동 조정
            // todo: 특정 Cell의 너비만 유지하고, 나머지는 균등 분배
            display: {
                fitStyle: 'fill',
                //rowHeight: 36,
                fitStyleIncludeFixed: true
            },
            edit: {
                editable : false
            },
            checkBar: {
                visible: false,
            },
            stateBar: {
                visible: false,
            }, 
            header: {
                showTooltip: false,
            },
            fixed: {
                colCount: 2,
            },
            rowIndicator: {
                visible: false,
            },
            groupPanel: {
                visible: true,
            }
        });

        // =================================================================
        // Footer
        this.gridView.setRowIndicator({
            // Footer에 생기는 '∑' 기호를 안보이게 설정
            footText:' '
        });

        // =================================================================
        // Columns Groupping
        this.gridView.setColumns(this._columns);
        
        // =================================================================
        // #6. 레이아웃 설정은 모든 설정이 끝난 후(모든 컬럼이 생성되고 난 후) 
        this.gridView.setColumnLayout(this._layout);
        
       
       // =================================================================
       // Row Grouipping
       gridView.groupPanel.visible = true;
       gridView.groupBy(['quoteProdName']);
       this.gridView.setRowGroup({
           mergeMode:true, 
           expandedAdornments: "none", 
           collapsedAdornments: "none",
           //collapsedAdornments: $(':radio[name="collapsed"]:checked').val()
       });

        // =================================================================
        // 셀병합
       //  gridView.columnByName("quoteProdName").mergeRule = {criteria: "value"};
        gridView.columnByName("opptyName").mergeRule = {criteria: "prevvalues + value"};
        gridView.columnByName("coroprate").mergeRule = {criteria: "prevvalues + value"};
        gridView.columnByName("productionType").mergeRule = {criteria: "prevvalues + value"};
        gridView.columnByName("incoterms").mergeRule = {criteria: "prevvalues + value"};
        gridView.columnByName("dLocation").mergeRule = {criteria: "prevvalues + value"};
        gridView.columnByName("currencyIsoCode").mergeRule = {criteria: "prevvalues + value"};

       this.dataProvider.setRows(this._recordList);

       var endTime = new Date();
        console.log('데이터 렌더링 소요시간', (endTime-this._startTime)/1000);
        this.loadingTime = '로딩시간 : ' + (endTime-this._startTime)/1000 + '초';
    
    }

    /**
     * Fields
     * @returns 
     * @private
     */
    get _fields(){ 
       let defaultField = [
           /* 견적제품 기본 정보 */
           { fieldName: 'quoteProdName', dataType: 'text' },
           { fieldName: 'opptyName', dataType: 'text' },
           { fieldName: 'coroprate', dataType: 'text' },
           { fieldName: 'productionType', dataType: 'text' },
           { fieldName: 'incoterms', dataType: 'text' },
           { fieldName: 'dLocation', dataType: 'text' },
           { fieldName: 'currencyIsoCode', dataType: 'text' },
           /* 견적제품 전체 수량물량 정보 */
           { fieldName: 'div', dataType: 'text' },
           { fieldName: 'ttl', dataType: 'number' },

       ];

       // 년도별 정보
       for(let i=0; i<this._term; i++){
           let yearly;
           if(i==0){
               yearly = '1st';
           }else if(i==1){
               yearly = '2nd';
           }else if(i==2){
               yearly = '3rd';
           }else{
               yearly = i + 1 + 'th';
           }

           defaultField.push(
               { fieldName: 'ttl'+yearly, dataType: 'number' },
               { fieldName: 'no'+yearly+'JAN', dataType: 'number' },
               { fieldName: 'no'+yearly+'FEB', dataType: 'number' },
               { fieldName: 'no'+yearly+'MAR', dataType: 'number' },
               { fieldName: 'no'+yearly+'APR', dataType: 'number' },
               { fieldName: 'no'+yearly+'MAY', dataType: 'number' },
               { fieldName: 'no'+yearly+'JUN', dataType: 'number' },
               { fieldName: 'no'+yearly+'JUL', dataType: 'number' },
               { fieldName: 'no'+yearly+'AUG', dataType: 'number' },
               { fieldName: 'no'+yearly+'SEP', dataType: 'number' },
               { fieldName: 'no'+yearly+'OCT', dataType: 'number' },
               { fieldName: 'no'+yearly+'NOV', dataType: 'number' },
               { fieldName: 'no'+yearly+'DEC', dataType: 'number' }
           );
       }

       return defaultField;
    }

    /**
     *
     * @returns 
     * @private
     */
    get _columns(){
       const {VS_SalesPlanItem__c : {fieldMap: VS_SalesPlanItem__c}, VS_SalesPlanDetail__c: {fieldMap: VS_SalesPlanDetail__c}} = this._objectDescribeMap;

       let defaultColumns = [
           /* 견적제품 기본 정보 */
           { name: 'quoteProdName', fieldName: 'quoteProdName', header: { text: '견적제품',} },
           { name: 'opptyName', fieldName: 'opptyName', header: { text: VS_SalesPlanItem__c.fm_OpportunityName__c.label, } },
           { name: 'coroprate', fieldName: 'coroprate', header: { text: VS_SalesPlanItem__c.Corporate__c.label, } },
           { name: 'productionType', fieldName: 'productionType', header: { text: VS_SalesPlanItem__c.ProductionType__c.label, } },
           { name: 'incoterms', fieldName: 'incoterms', header: { text: VS_SalesPlanItem__c.Incoterms__c.label, } },
           { name: 'dLocation', fieldName: 'dLocation', header: { text: VS_SalesPlanItem__c.DLocation__c.label,}},
           { name: 'currencyIsoCode', fieldName: 'currencyIsoCode', header: { text: VS_SalesPlanItem__c.CurrencyIsoCode.label,}},
           /* 견적제품 전체 수량물량 정보 */
           { name: 'div', fieldName: 'div', header: { text: 'Unit',}},
           { name: 'ttl', fieldName: 'ttl', header: { text: 'Sum',}, styleName: "right-column"},

       ];

       for(let i=0; i<this._term; i++){
           let yearly;
           if(i==0){
               yearly = '1st';
           }else if(i==1){
               yearly = '2nd';
           }else if(i==2){
               yearly = '3rd';
           }else{
               yearly = i + 1 + 'th';
           }

           defaultColumns.push(
               { 
                   name: 'ttl'+yearly, 
                   fieldName: 'ttl'+yearly, 
                   header: { 
                       text: this._startYear+' Sum',
                   }, 
                   styleName: "cornsilk-column right-column"
               },
               {
                   name: 'no'+yearly+'JAN', 
                   fieldName: 'no'+yearly+'JAN', 
                   header: { 
                       text: this._startYear+'-01',
                   }, 
                   styleName: "right-column"
               },
               {
                   name: 'no'+yearly+'FEB', 
                   fieldName: 'no'+yearly+'FEB', 
                   header: { 
                       text: this._startYear+'-02',
                   }, 
                   styleName: "right-column"
               },
               {
                   name: 'no'+yearly+'MAR', 
                   fieldName: 'no'+yearly+'MAR', 
                   header: { 
                       text: this._startYear+'-03',
                   }, 
                   styleName: "right-column"
               },
               {
                   name: 'no'+yearly+'APR', 
                   fieldName: 'no'+yearly+'APR', 
                   header: { 
                       text: this._startYear+'-04',
                   },
                   styleName: "right-column"
               },
               {
                   name: 'no'+yearly+'MAY', 
                   fieldName: 'no'+yearly+'MAY', 
                   header: { 
                       text: this._startYear+'-05',
                   },
                   styleName: "right-column"
               },
               {
                   name: 'no'+yearly+'JUN', 
                   fieldName: 'no'+yearly+'JUN', 
                   header: { 
                       text: this._startYear+'-06',
                   },
                   styleName: "right-column"
               },
               {
                   name: 'no'+yearly+'JUL', 
                   fieldName: 'no'+yearly+'JUL', 
                   header: { 
                       text: this._startYear+'-07',
                   },
                   styleName: "right-column"
               },
               {
                   name: 'no'+yearly+'AUG', 
                   fieldName: 'no'+yearly+'AUG', 
                   header: { 
                       text: this._startYear+'-08',
                   },
                   styleName: "right-column"
               },
               {
                   name: 'no'+yearly+'SEP', 
                   fieldName: 'no'+yearly+'SEP', 
                   header: { 
                       text: this._startYear+'-09',
                   },
                   styleName: "right-column"
               },
               {
                   name: 'no'+yearly+'OCT', 
                   fieldName: 'no'+yearly+'OCT', 
                   header: { 
                       text: this._startYear+'-10',
                   },
                   styleName: "right-column"
               },
               {
                   name: 'no'+yearly+'NOV', 
                   fieldName: 'no'+yearly+'NOV', 
                   header: { 
                       text: this._startYear+'-11',
                   },
                   styleName: "right-column"
               },
               {
                   name: 'no'+yearly+'DEC', 
                   fieldName: 'no'+yearly+'DEC', 
                   header: { 
                       text: this._startYear+'-12',
                   },
                   styleName: "right-column"
               }
           );
       }

       return defaultColumns;
    }

    /**
     *
     * @returns 
     * @private
     */
    get _layout(){
        let defalutlayout = [
            'quoteProdName',
            'opptyName',
            'coroprate',
            'productionType',
            'incoterms',
            'dLocation', 
            'currencyIsoCode',
            'div',
            'ttl'
            /*{
                name: '전체',
                direction: 'horizontal',
                items: [
                  'ttlAmt',
                  'ttlQty',
                  'ttlPrice'
                ],
                header: {
                  text: '전체',
                }
            }*/
        ];

        let yearlylayout = [];

        for(let i=0; i<this._term; i++){
           let yearly;
           if(i==0){
               yearly = '1st';
           }else if(i==1){
               yearly = '2nd';
           }else if(i==2){
               yearly = '3rd';
           }else{
               yearly = i + 1 + 'th';
           }
           
           let yearLayout = {
               name: this._startYear+i,
               direction: 'horizontal',
               expandable: true,
               expanded: false,
               items:[
                 { column: 'ttl'+yearly, groupShowMode: "always" },
                 { column: 'no'+yearly+'JAN', groupShowMode: "expand" },
                 { column: 'no'+yearly+'FEB', groupShowMode: "expand" },
                 { column: 'no'+yearly+'MAR', groupShowMode: "expand" },
                 { column: 'no'+yearly+'APR', groupShowMode: "expand" },
                 { column: 'no'+yearly+'MAY', groupShowMode: "expand" },
                 { column: 'no'+yearly+'JUN', groupShowMode: "expand" },
                 { column: 'no'+yearly+'JUL', groupShowMode: "expand" },
                 { column: 'no'+yearly+'AUG', groupShowMode: "expand" },
                 { column: 'no'+yearly+'SEP', groupShowMode: "expand" },
                 { column: 'no'+yearly+'OCT', groupShowMode: "expand" },
                 { column: 'no'+yearly+'NOV', groupShowMode: "expand" },
                 { column: 'no'+yearly+'DEC', groupShowMode: "expand" },
               ]
           }

           yearlylayout.push(yearLayout);
       }
       
       return defalutlayout.concat(yearlylayout);
    }
    
}