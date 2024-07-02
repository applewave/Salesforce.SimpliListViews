/****************************************************************************************
 * File Name    : RealGridProjectSalesPlanBulkTest
 * Author       : ar.kim
 * Date         : 2024-06-28
 * Description  :
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * ===============================================================
 * Ver      Date 		Author    			Modification
 * ===============================================================
 1.0		2024-06-28 	ar.kim			    Create

 ****************************************************************************************/

 import {api, LightningElement, track} from 'lwc';
 import {loadScript, loadStyle} from 'lightning/platformResourceLoader';
 import realGrid from '@salesforce/resourceUrl/RealGrid';
 
 import getProjectOption from '@salesforce/apex/RealGridPjtSalesPlanBulkTestController.getProjectOption';
//  import init from '@salesforce/apex/RealGridPjtSalesPlanBulkTestController.init';
//  import getSalesPlanItem from '@salesforce/apex/RealGridPjtSalesPlanBulkTestController.getSalesPlanItem';
//  import getSalesPlanDetail from '@salesforce/apex/RealGridPjtSalesPlanBulkTestController.getSalesPlanDetail';
//  import setProjectSalesPlanList from '@salesforce/apex/RealGridPjtSalesPlanBulkTestController.setProjectSalesPlanList';

export default class RealGridProjectSalesPlanBulkTest extends LightningElement {

    @track pjtOptions;

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

    _pjtHorizontalGrid;
     
    connectedCallback() {

        console.info('%c==================================== realGridProjectSalesPlanSample.connectedCallback', 'color:red;');

        Promise.all([
            loadScript(this, realGrid + '/realgrid-lic.js'),
            loadScript(this, realGrid + '/realgrid.2.8.2.min.js'),
            loadScript(this, realGrid + '/libs/jszip.min.js'),
            loadStyle(this, realGrid + '/realgrid-style.css')
        ]).then(() => {
            console.info('%c==================================== RealGridProjectSalesPlanBulkController.getProjectOption', 'color:gray;');
            return getProjectOption({});
        }).then(result => {
            console.log('Project List', result);
            let options = [];

            if (result) {
                result.forEach(res => {
                    options.push({
                        label: res.Name,
                        value: res.Id,
                    });
                });
            }

            this.pjtOptions = options;
            //console.info('%c==================================== RealGridProjectSalesPlanBulkController.init', 'color:gray;');
            //this.renderedData(result[0].Id);
            //return init({recordId : result[0].Id});

            // =================================================================
            // Initialize Product Grid
            this._pjtHorizontalGrid = this.template.querySelector("c-pjt-sales-plan-vertical-view");
            this._pjtHorizontalGrid._renderedData(result[0].Id);
        }).catch(error => {
            console.log('connectedCallback ERROR',  JSON.stringify(error));
        });
    }

    disconnectedCallback() {

        if(this._pjtHorizontalGrid){
            this._pjtHorizontalGrid.gridView = this._pjtHorizontalGrid.gridView.destroy();
            this._pjtHorizontalGrid.dataProvider = this._pjtHorizontalGrid.dataProvider.destroy();
        }
         
    }

    handleChangeProject(event){
        console.log('change event', event.detail.value);
        if(this._pjtHorizontalGrid){
            console.log(this._pjtHorizontalGrid);
            this._pjtHorizontalGrid._destroy();
        }
        this._pjtHorizontalGrid._renderedData(event.detail.value);
    }

//     renderedData(recordId) {
//         console.info('%c==================================== realGridProjectSalesPlanSample.renderedCallback', 'color:red;');
//         console.log('recordId', recordId);
//         this._startTime = new Date();
//         console.log('this._startTime', this._startTime);

//         init({recordId: recordId}).then(result => {
//            this._result = result;
//            this._objectDescribeMap = this._result.objectDescribeMap;
//            console.info('%c==================================== RealGridProjectSalesPlanBulkController.getSalesPlanItem', 'color:gray;');
//            return getSalesPlanItem({paramListId: this._result.pjtSalesPlanIdList});
//        }).then(result => {
//            this._result.itemList = result.itemList;
//            this._result.itemListSize = result.itemListSize;
//            this._startYear = result.pjtStartYear;
//            this._term = result.pjtTerm;

//            console.info('%c==================================== RealGridProjectSalesPlanBulkController.getSalesPlanDetail', 'color:gray;');
//            return getSalesPlanDetail({paramListId: this._result.pjtSalesPlanIdList});
//        }).then(result => {
//            this._result.detailList = result.detailList;
//            this._result.detailListSize = result.detailListSize;
//            console.log('this._result', this._result);

//            /*for(let i=0; i<this._result.itemListSize; i++){
//                let itemList = [ this._result.itemList[i] ];
//                console.log('itemList', itemList);
//                setProjectSalesPlanList({itemList: itemList, detailList: this._result.detailList})
//                .then(result => {
//                    console.log('res', result);

//                    this.dataProvider.fillJsonData(result, {
//                        fillMode: "append",
//                        noStates: true
//                    });

//                    if( i/10 == 0){
//                        this.gridView.refresh();
//                    }
//                }).catch(error => {
//                    console.info('%c==================================== ERROR', 'color:red;');
//                    console.log(JSON.stringify(error));
//                });
               
//            }
           
//            this._initializeGrid();*/

//            // 대량 처리 필요
//            // to do...
//            // itemList, detailList를 분할하여 적재 후 최초 setProjectSaelsPlanList 호출하기
//            // 한번에 몇건씩 할지 확인.... itemList와 detailList 갯수도 정리 

//            /*let itemList = [];
//            for(let i=0; i<this._dataSize ; i++){ 
//                itemList.push(this._result.itemList[i]);
//            }
//            console.log(this._result.itemList.slice(this._dataSize));
//            this._result.itemList = this._result.itemList.slice(this._dataSize);*/

//            console.info('%c==================================== RealGridProjectSalesPlanBulkController.setProjectSalesPlanList', 'color:gray;');
//            return setProjectSalesPlanList({itemList: this._result.itemList, detailList: this._result.detailList});
//        }).then(result => {
//            console.log('set data', result);
//            this._recordList = result;
//            var endTime = new Date();
//            console.log('데이터 로딩 소요시간', (endTime-this._startTime)/1000);

//            // data null 처리 필요
//            this._initializeGrid();
//        }).catch(error => {
//            console.log('renderedData ERROR', JSON.stringify(error));
//        });
//     }

//     _initializeGrid(){
//         console.info('%c==================================== realGridSample._initializeGrid', 'color:red;');
//         //var startTime = new Date();

//         const container = this.template.querySelector("[data-id='realgrid']");
//         console.log('container', container);
//         RealGrid.setSlotMode(true);
//         window.gridView = this.gridView = new RealGrid.GridView(container);
//         this.dataProvider = new RealGrid.LocalDataProvider();
//         this.gridView.setDataSource(this.dataProvider);

//         this.gridView.displayOptions.emptyMessage = "표시할 데이타가 없습니다.";

//         const {displayOptions} = this.gridView;
//         // 컬럼 너비 자동 조정
//         displayOptions.fitStyle = 'even';

//         // =================================================================
//         // Fields
//         this.dataProvider.setFields(this._fields);

//         // =================================================================
//         // Grid Option
//         this.gridView.setOptions({
//             //gridView.setOptions() 안에서 옵션 설정할때는 set삭제, 첫글자 소문자, options도 삭제
//             //ex1) setEditOptions() -> edit
//             //ex2) setFixedOptions() -> fixed
//             //ex3) setFilterPanel() -> filterPanel
//             //ex4> setDisplayOptions() -> display

//             // =================================================================
//             // 컬럼 너비 자동 조정
//             // todo: 특정 Cell의 너비만 유지하고, 나머지는 균등 분배
//             display: {
//                 fitStyle: 'fill',
//                 //rowHeight: 36,
//                 fitStyleIncludeFixed: true
//             },
//             edit: {
//                 editable : false
//             },
//             checkBar: {
//                 visible: false,
//             },
//             stateBar: {
//                 visible: false,
//             }, 
//             header: {
//                 showTooltip: false,
//             },
//             fixed: {
//                 colCount: 2,
//             },
//             rowIndicator: {
//                 visible: false,
//             },
//             groupPanel: {
//                 visible: false,
//             }
//         });

//         // =================================================================
//         // Footer
//         this.gridView.setRowIndicator({
//             // Footer에 생기는 '∑' 기호를 안보이게 설정
//             footText:' '
//         });

//         // =================================================================
//         // Columns Groupping
//         this.gridView.setColumns(this._columns);
        
//         // =================================================================
//         // #6. 레이아웃 설정은 모든 설정이 끝난 후(모든 컬럼이 생성되고 난 후) 
//         this.gridView.setColumnLayout(this._layout);

//         // =================================================================
//         // Row Grouipping
//         //gridView.groupPanel.visible = true;
//        //  this.gridView.groupBy(['quoteProdName']);
//        //  this.gridView.setRowGroup({
//        //      mergeMode:true, 
//        //      expandedAdornments: "footer", 
//        //      collapsedAdornments: "footer",
//        //      //collapsedAdornments: $(':radio[name="collapsed"]:checked').val()
//        //  });
//         gridView.columnByName("quoteProdName").mergeRule = {criteria: "value"};
        
//         this.dataProvider.setRows(this._recordList);

//         this.gridView.onScrollToBottom = function() {
//            console.log('Scroll down'); 
//            /**let itemList = [];
//            console.log('define itemList'); 
//            console.log(this._result.itemList);
//            console.log(this._dataSize);
           
//            for(let i=0; i<this._dataSize ; i++){
//                console.log('for loop'); 
//                itemList.push(this._result.itemList[i]);
//                console.log('push'); 
//            }
//            this._result.itemList = this._result.itemList.slice(this._dataSize);

//            //console.info('%c==================================== RealGridProjectSalesPlanBulkController.setProjectSalesPlanList', 'color:gray;');
//            //return setProjectSalesPlanList({itemList: this._result.itemList, detailList: this._result.detailList});

//            console.info('%c==================================== RealGridProjectSalesPlanBulkController.setProjectSalesPlanList', 'color:gray;');
//            setProjectSalesPlanList({itemList: itemList, detailList: this._result.detailList})
//                .then(result => {
//                    console.log('res', result);

//                    this.dataProvider.fillJsonData(result, {
//                        fillMode: "append",
//                        noStates: true
//                    });

//                    this.gridView.refresh();
//                }).catch(error => {
//                    console.info('%c==================================== ERROR', 'color:red;');
//                    console.log(JSON.stringify(error));
//                });*/
//          };
         
//         var endTime = new Date();
//         console.log('데이터 렌더링 소요시간', (endTime-this._startTime)/1000);
//         this.loadingTime = '로딩시간 : ' + (endTime-this._startTime)/1000 + '초';
//     }

//     /**
//     * Fields
//     * @returns 
//     * @private
//     */
//    get _fields(){
//        let defaultfields = [
//             /* 견적제품 기본 정보 */
//             {fieldName: 'quoteProdName', dataType: 'text'},
//             {fieldName: 'opptyName', dataType: 'text'},
//             {fieldName: 'coroprate', dataType: 'text'},
//             {fieldName: 'productionType', dataType: 'text'},
//             {fieldName: 'incoterms', dataType: 'text'},
//             {fieldName: 'dLocation', dataType: 'text'},
//             {fieldName: 'currencyIsoCode', dataType: 'text'},
//             /* 견적제품 전체 수량물량 정보 */
//             {fieldName: 'ttlAmt', dataType: 'number'},
//             {fieldName: 'ttlQty', dataType: 'number'},
//             {fieldName: 'ttlPrice', dataType: 'number'}
//        ];
       
//        for(let i=0; i<this._term; i++){
//            let yearly;
//            if(i==0){
//                yearly = '1st';
//            }else if(i==1){
//                yearly = '2nd';
//            }else if(i==2){
//                yearly = '3rd';
//            }else{
//                yearly = i + 1 + 'th';
//            }

//            defaultfields.push(
//                {fieldName: 'ttlamt'+yearly, dataType: 'number'},{fieldName: 'ttlqty'+yearly, dataType: 'number'},{fieldName: 'ttlprice'+yearly, dataType: 'number'},
//                {fieldName: 'amt'+yearly+'JAN', dataType: 'number'},{fieldName: 'qty'+yearly+'JAN', dataType: 'number'},{fieldName: 'price'+yearly+'JAN', dataType: 'number'},
//                {fieldName: 'amt'+yearly+'FEB', dataType: 'number'},{fieldName: 'qty'+yearly+'FEB', dataType: 'number'},{fieldName: 'price'+yearly+'FEB', dataType: 'number'},
//                {fieldName: 'amt'+yearly+'MAR', dataType: 'number'},{fieldName: 'qty'+yearly+'MAR', dataType: 'number'},{fieldName: 'price'+yearly+'MAR', dataType: 'number'},
//                {fieldName: 'amt'+yearly+'APR', dataType: 'number'},{fieldName: 'qty'+yearly+'APR', dataType: 'number'},{fieldName: 'price'+yearly+'APR', dataType: 'number'},
//                {fieldName: 'amt'+yearly+'MAY', dataType: 'number'},{fieldName: 'qty'+yearly+'MAY', dataType: 'number'},{fieldName: 'price'+yearly+'MAY', dataType: 'number'},
//                {fieldName: 'amt'+yearly+'JUN', dataType: 'number'},{fieldName: 'qty'+yearly+'JUN', dataType: 'number'},{fieldName: 'price'+yearly+'JUN', dataType: 'number'},
//                {fieldName: 'amt'+yearly+'JUL', dataType: 'number'},{fieldName: 'qty'+yearly+'JUL', dataType: 'number'},{fieldName: 'price'+yearly+'JUL', dataType: 'number'},
//                {fieldName: 'amt'+yearly+'AUG', dataType: 'number'},{fieldName: 'qty'+yearly+'AUG', dataType: 'number'},{fieldName: 'price'+yearly+'AUG', dataType: 'number'},
//                {fieldName: 'amt'+yearly+'SEP', dataType: 'number'},{fieldName: 'qty'+yearly+'SEP', dataType: 'number'},{fieldName: 'price'+yearly+'SEP', dataType: 'number'},
//                {fieldName: 'amt'+yearly+'OCT', dataType: 'number'},{fieldName: 'qty'+yearly+'OCT', dataType: 'number'},{fieldName: 'price'+yearly+'OCT', dataType: 'number'},
//                {fieldName: 'amt'+yearly+'NOV', dataType: 'number'},{fieldName: 'qty'+yearly+'NOV', dataType: 'number'},{fieldName: 'price'+yearly+'NOV', dataType: 'number'},
//                {fieldName: 'amt'+yearly+'DEC', dataType: 'number'},{fieldName: 'qty'+yearly+'DEC', dataType: 'number'},{fieldName: 'price'+yearly+'DEC', dataType: 'number'}
//            );
//        }

//        return defaultfields;
//    }

//    /**
//     *
//     * @returns 
//     * @private
//     */
//    get _columns(){
//        const {VS_SalesPlanItem__c : {fieldMap: VS_SalesPlanItem__c}, VS_SalesPlanDetail__c: {fieldMap: VS_SalesPlanDetail__c}} = this._objectDescribeMap;

//        let defaultColumns = [
//            /* 견적제품 기본 정보 */
//            { name: 'quoteProdName', fieldName: 'quoteProdName', header: { text: '견적제품',} },
//            { name: 'opptyName', fieldName: 'opptyName', header: { text: VS_SalesPlanItem__c.fm_OpportunityName__c.label, } },
//            { name: 'coroprate', fieldName: 'coroprate', header: { text: VS_SalesPlanItem__c.Corporate__c.label, } },
//            { name: 'productionType', fieldName: 'productionType', header: { text: VS_SalesPlanItem__c.ProductionType__c.label, } },
//            { name: 'incoterms', fieldName: 'incoterms', header: { text: VS_SalesPlanItem__c.Incoterms__c.label, } },
//            { name: 'dLocation', fieldName: 'dLocation', header: { text: VS_SalesPlanItem__c.DLocation__c.label,}},
//            { name: 'currencyIsoCode', fieldName: 'currencyIsoCode', header: { text: VS_SalesPlanItem__c.CurrencyIsoCode.label,}},
//            /* 견적제품 전체 수량물량 정보 */
//            { name: 'ttlAmt', fieldName: 'ttlAmt', header: { text: 'Amt.',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//            { name:  'ttlQty', fieldName: 'ttlQty', header: { text: 'Qty',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//            { name: 'ttlPrice', fieldName: 'ttlPrice', header: { text: 'Price',}, styleName: "right-column"},
//        ];

//        for(let i=0; i<this._term; i++){
//            let yearly;
//            if(i==0){
//                yearly = '1st';
//            }else if(i==1){
//                yearly = '2nd';
//            }else if(i==2){
//                yearly = '3rd';
//            }else{
//                yearly = i + 1 + 'th';
//            }

//            defaultColumns.push(
//                { name: 'ttlamt'+yearly, fieldName: 'ttlamt'+yearly, header: { text: 'Amt.',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name:  'ttlqty'+yearly, fieldName: 'ttlqty'+yearly, header: { text: 'Qty',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name: 'ttlprice'+yearly, fieldName: 'ttlprice'+yearly, header: { text: 'Price',}, styleName: "right-column"},
//                { name: 'amt'+yearly+'JAN', fieldName: 'amt'+yearly+'JAN', header: { text: 'Amt.',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name:  'qty'+yearly+'JAN', fieldName: 'qty'+yearly+'JAN', header: { text: 'Qty',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name: 'price'+yearly+'JAN', fieldName: 'price'+yearly+'JAN', header: { text: 'Price',}, styleName: "right-column"},
//                { name: 'amt'+yearly+'FEB', fieldName: 'amt'+yearly+'FEB', header: { text: 'Amt.',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name:  'qty'+yearly+'FEB', fieldName: 'qty'+yearly+'FEB', header: { text: 'Qty',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name: 'price'+yearly+'FEB', fieldName: 'price'+yearly+'FEB', header: { text: 'Price',}, styleName: "right-column"},
//                { name: 'amt'+yearly+'MAR', fieldName: 'amt'+yearly+'MAR', header: { text: 'Amt.',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name:  'qty'+yearly+'MAR', fieldName: 'qty'+yearly+'MAR', header: { text: 'Qty',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name: 'price'+yearly+'MAR', fieldName: 'price'+yearly+'MAR', header: { text: 'Price',}, styleName: "right-column"},
//                { name: 'amt'+yearly+'APR', fieldName: 'amt'+yearly+'APR', header: { text: 'Amt.',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name:  'qty'+yearly+'APR', fieldName: 'qty'+yearly+'APR', header: { text: 'Qty',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name: 'price'+yearly+'APR', fieldName: 'price'+yearly+'APR', header: { text: 'Price',}, styleName: "right-column"},
//                { name: 'amt'+yearly+'MAY', fieldName: 'amt'+yearly+'MAY', header: { text: 'Amt.',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name:  'qty'+yearly+'MAY', fieldName: 'qty'+yearly+'MAY', header: { text: 'Qty',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name: 'price'+yearly+'MAY', fieldName: 'price'+yearly+'MAY', header: { text: 'Price',}, styleName: "right-column"},
//                { name: 'amt'+yearly+'JUN', fieldName: 'amt'+yearly+'JUN', header: { text: 'Amt.',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name:  'qty'+yearly+'JUN', fieldName: 'qty'+yearly+'JUN', header: { text: 'Qty',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name: 'price'+yearly+'JUN', fieldName: 'price'+yearly+'JUN', header: { text: 'Price',}, styleName: "right-column"},
//                { name: 'amt'+yearly+'JUL', fieldName: 'amt'+yearly+'JUL', header: { text: 'Amt.',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name:  'qty'+yearly+'JUL', fieldName: 'qty'+yearly+'JUL', header: { text: 'Qty',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name: 'price'+yearly+'JUL', fieldName: 'price'+yearly+'JUL', header: { text: 'Price',}, styleName: "right-column"},
//                { name: 'amt'+yearly+'AUG', fieldName: 'amt'+yearly+'AUG', header: { text: 'Amt.',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name:  'qty'+yearly+'AUG', fieldName: 'qty'+yearly+'AUG', header: { text: 'Qty',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name: 'price'+yearly+'AUG', fieldName: 'price'+yearly+'AUG', header: { text: 'Price',}, styleName: "right-column"},
//                { name: 'amt'+yearly+'SEP', fieldName: 'amt'+yearly+'SEP', header: { text: 'Amt.',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name:  'qty'+yearly+'SEP', fieldName: 'qty'+yearly+'SEP', header: { text: 'Qty',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name: 'price'+yearly+'SEP', fieldName: 'price'+yearly+'SEP', header: { text: 'Price',}, styleName: "right-column"},
//                { name: 'amt'+yearly+'OCT', fieldName: 'amt'+yearly+'OCT', header: { text: 'Amt.',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name:  'qty'+yearly+'OCT', fieldName: 'qty'+yearly+'OCT', header: { text: 'Qty',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name: 'price'+yearly+'OCT', fieldName: 'price'+yearly+'OCT', header: { text: 'Price',}, styleName: "right-column"},
//                { name: 'amt'+yearly+'NOV', fieldName: 'amt'+yearly+'NOV', header: { text: 'Amt.',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name:  'qty'+yearly+'NOV', fieldName: 'qty'+yearly+'NOV', header: { text: 'Qty',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name: 'price'+yearly+'NOV', fieldName: 'price'+yearly+'NOV', header: { text: 'Price',}, styleName: "right-column"},
//                { name: 'amt'+yearly+'DEC', fieldName: 'amt'+yearly+'DEC', header: { text: 'Amt.',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name:  'qty'+yearly+'DEC', fieldName: 'qty'+yearly+'DEC', header: { text: 'Qty',}, footer: { numberFormat: "#,##0", expression: "sum" }, styleName: "right-column"},
//                { name: 'price'+yearly+'DEC', fieldName: 'price'+yearly+'DEC', header: { text: 'Price',}, styleName: "right-column"},
//            );
//        }

//        return defaultColumns;
//    }

//    /**
//     *
//     * @returns 
//     * @private
//     */
//    get _layout(){
//        var defalutlayout = [
//            'quoteProdName',
//            'opptyName',
//            'coroprate',
//            'productionType',
//            'incoterms',
//            'dLocation', 
//            'currencyIsoCode',
//            {
//                name: '전체',
//                direction: 'horizontal',
//                items: [
//                  'ttlAmt',
//                  'ttlQty',
//                  'ttlPrice'
//                ],
//                header: {
//                  text: '전체',
//                }
//            }
//        ];

//        var yearlylayout = [];

//        for(var i=0; i<this._term; i++){
//            var yearly;
//            if(i==0){
//                yearly = '1st';
//            }else if(i==1){
//                yearly = '2nd';
//            }else if(i==2){
//                yearly = '3rd';
//            }else{
//                yearly = i + 1 + 'th';
//            }
           
//            var yearLayout = {
//                name: this._startYear+i,
//                direction: 'horizontal',
//                expandable: true,
//                expanded: false,
//                items:[
//                    {column: 'ttlamt'+yearly, groupShowMode:'always'},
//                    {column: 'ttlqty'+yearly, groupShowMode:'always'},
//                    {column: 'ttlprice'+yearly, groupShowMode:'always'},
//                    {
//                        name: yearly+'JAN',
//                        expandable: true,
//                        groupShowMode: 'expand',
//                        items:[
//                            {column: 'amt'+yearly+'JAN', groupShowMode:'expand'},
//                            {column: 'qty'+yearly+'JAN', groupShowMode:'expand'},
//                            {column: 'price'+yearly+'JAN', groupShowMode:'expand'},
//                        ],
//                        header: {
//                            text: this._startYear+i +'-01',
//                        }
//                    },
//                    {
//                        name: yearly+'FEB',
//                        expandable: true,
//                        groupShowMode: 'expand',
//                        items:[
//                            {column: 'amt'+yearly+'FEB', groupShowMode:'expand'},
//                            {column: 'qty'+yearly+'FEB', groupShowMode:'expand'},
//                            {column: 'price'+yearly+'FEB', groupShowMode:'expand'},
//                        ],
//                        header: {
//                            text: this._startYear+i +'-02',
//                        }
//                    },
//                    {
//                        name: yearly+'MAR',
//                        expandable: true,
//                        groupShowMode: 'expand',
//                        items:[
//                            {column: 'amt'+yearly+'MAR', groupShowMode:'expand'},
//                            {column: 'qty'+yearly+'MAR', groupShowMode:'expand'},
//                            {column: 'price'+yearly+'MAR', groupShowMode:'expand'},
//                        ],
//                        header: {
//                            text: this._startYear+i +'-03',
//                        }
//                    },
//                    {
//                        name: yearly+'APR',
//                        expandable: true,
//                        groupShowMode: 'expand',
//                        items:[
//                            {column: 'amt'+yearly+'APR', groupShowMode:'expand'},
//                            {column: 'qty'+yearly+'APR', groupShowMode:'expand'},
//                            {column: 'price'+yearly+'APR', groupShowMode:'expand'},
//                        ],
//                        header: {
//                            text: this._startYear+i +'-04',
//                        }
//                    },
//                    {
//                        name: yearly+'MAY',
//                        expandable: true,
//                        groupShowMode: 'expand',
//                        items:[
//                            {column: 'amt'+yearly+'MAY', groupShowMode:'expand'},
//                            {column: 'qty'+yearly+'MAY', groupShowMode:'expand'},
//                            {column: 'price'+yearly+'MAY', groupShowMode:'expand'},
//                        ],
//                        header: {
//                            text: this._startYear+i +'-05',
//                        }
//                    },
//                    {
//                        name: yearly+'JUN',
//                        expandable: true,
//                        groupShowMode: 'expand',
//                        items:[
//                            {column: 'amt'+yearly+'JUN', groupShowMode:'expand'},
//                            {column: 'qty'+yearly+'JUN', groupShowMode:'expand'},
//                            {column: 'price'+yearly+'JUN', groupShowMode:'expand'},
//                        ],
//                        header: {
//                            text: this._startYear+i +'-06',
//                        }
//                    },
//                    {
//                        name: yearly+'JUL',
//                        expandable: true,
//                        groupShowMode: 'expand',
//                        items:[
//                            {column: 'amt'+yearly+'JUL', groupShowMode:'expand'},
//                            {column: 'qty'+yearly+'JUL', groupShowMode:'expand'},
//                            {column: 'price'+yearly+'JUL', groupShowMode:'expand'},
//                        ],
//                        header: {
//                            text: this._startYear+i +'-07',
//                        }
//                    },
//                    {
//                        name: yearly+'AUG',
//                        expandable: true,
//                        groupShowMode: 'expand',
//                        items:[
//                            {column: 'amt'+yearly+'AUG', groupShowMode:'expand'},
//                            {column: 'qty'+yearly+'AUG', groupShowMode:'expand'},
//                            {column: 'price'+yearly+'AUG', groupShowMode:'expand'},
//                        ],
//                        header: {
//                            text: this._startYear+i +'-08',
//                        }
//                    },
//                    {
//                        name: yearly+'SEP',
//                        expandable: true,
//                        groupShowMode: 'expand',
//                        items:[
//                            {column: 'amt'+yearly+'SEP', groupShowMode:'expand'},
//                            {column: 'qty'+yearly+'SEP', groupShowMode:'expand'},
//                            {column: 'price'+yearly+'SEP', groupShowMode:'expand'},
//                        ],
//                        header: {
//                            text: this._startYear+i +'-09',
//                        }
//                    },
//                    {
//                        name: yearly+'OCT',
//                        expandable: true,
//                        groupShowMode: 'expand',
//                        items:[
//                            {column: 'amt'+yearly+'OCT', groupShowMode:'expand'},
//                            {column: 'qty'+yearly+'OCT', groupShowMode:'expand'},
//                            {column: 'price'+yearly+'OCT', groupShowMode:'expand'},
//                        ],
//                        header: {
//                            text: this._startYear+i +'-10',
//                        }
//                    },
//                    {
//                        name: yearly+'NOV',
//                        expandable: true,
//                        groupShowMode: 'expand',
//                        items:[
//                            {column: 'amt'+yearly+'NOV', groupShowMode:'expand'},
//                            {column: 'qty'+yearly+'NOV', groupShowMode:'expand'},
//                            {column: 'price'+yearly+'NOV', groupShowMode:'expand'},
//                        ],
//                        header: {
//                            text: this._startYear+i +'-11',
//                        }
//                    },
//                    {
//                        name: yearly+'DEC',
//                        expandable: true,
//                        groupShowMode: 'expand',
//                        items:[
//                            {column: 'amt'+yearly+'DEC', groupShowMode:'expand'},
//                            {column: 'qty'+yearly+'DEC', groupShowMode:'expand'},
//                            {column: 'price'+yearly+'DEC', groupShowMode:'expand'},
//                        ],
//                        header: {
//                            text: this._startYear+i +'-02',
//                        }
//                    }
//                ],
//                header: {
//                    text: this._startYear+i,
//                }
//            }
//            yearlylayout.push(yearLayout);
//        }
       
//        return defalutlayout.concat(yearlylayout);
//    }

}