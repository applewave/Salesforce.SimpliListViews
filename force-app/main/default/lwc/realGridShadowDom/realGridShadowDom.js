/****************************************************************************************
 * File Name    : TestRealGrid
 * Author       : ey.choi
 * Date         : 2024-06-24
 * Description  : 기능 테스트용도로 작성함. 추후 삭제예정 
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * ===============================================================
 * Ver      Date 		Author    			Modification
 * ===============================================================
 1.0		2024-06-24 	ey.choi			    Create

 ****************************************************************************************/

import {api, LightningElement} from 'lwc';
import {loadScript, loadStyle} from "lightning/platformResourceLoader";
import realGrid from '@salesforce/resourceUrl/RealGrid';

export default class TestRealGrid extends LightningElement {
    static delegatesFocus = true;
    title ='프로젝트 Sales Plan';
    iconName = 'standard:snippet_alt';

    
    /* 
    [라벨규칙]

	# 전체 토탈값 
    AMT_T
    QTY_T
    PRI_T

    # 년 토탈값 
    AMT_{year}
    QTY_{year}
    PRI_{year}
	
	# 월별 값 
    AMT_{year}_{month}
    QTY_{year}_{month}
    PRI_{year}_{month}

    */

    @api recordId;
    currentYear = new Date().getFullYear();
    years = 3;
    months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
    staticWidth = '80';
    numberFormat = '#,##0';

    types = [
        { suffix: "AMT", label: "Amt." },
        { suffix: "QTY", label: "Qty." },
        { suffix: "PRI", label: "Price" }
    ];

    /* 
     - field 세팅 -> column 속성정의 -> layout 세팅 순으로 진행해야함
     - field 선언 순으로  data배열값이 들어감 
    */
    fields = [
        { fieldName: "OrderID" },
        { fieldName: "Oppty" },
        { fieldName: "Region" },
        { fieldName: "Incoterms" },
        { fieldName: "ShipTo" },
        { fieldName: "Currency" },
    ];

    /* 
    컬럼속성정의 
    footer를 정의해야 하단 total 값 구해짐
    */ 
    columns = [
        this.columnSetting("OrderID", "OrderID", "견적모델", 140 , true),
        this.columnSetting("Oppty", "Oppty", "Oppty", this.staticWidth ),
        {
            name: "Region",
            fieldName: "Region",
            width: this.staticWidth ,
            sortable: false,
            lookupDisplay: true,
            values: [
                "VINET",
                "HANAR",
                "SUPRD",
                "VICTE",
                "RATTC",
                "WARTH"
            ],
            labels: [
                "VINET",
                "HANAR",
                "SUPRD",
                "VICTE",
                "RATTC",
                "WARTH"
            ],
            editor: {
                type: "dropdown",
                dropDownCount: 4,
                domainOnly: true,
                textReadOnly: true
            },
            header: {
                text: "생산지",
                styleName: "orange-column"
            }
        },
        this.columnSetting("Incoterms", "Incoterms", "인코텀즈", this.staticWidth),
        this.columnSetting("ShipTo", "ShipTo", "ShipTo", this.staticWidth),
        this.columnSetting("Currency", "Currency", "통화", this.staticWidth),
    ];

    // 컬럼 layout 정의(컬럼위치조정)
    layout = [
        "OrderID",
        "Oppty",
        "Region",
        "Incoterms",
        "ShipTo",
        "Currency",
        {
            name: "Total",
            expandable: false,
            header: {
                text: "전체" 
            },
            items: [
                {column: "AMT_T", groupShowMode:"always"},
                {column: "PRI_T", groupShowMode:"always"},
                {column: "QTY_T", groupShowMode:"always"},
            ],
        }
    ];
    
    /* 필드 세팅  */
    handleField(){

        const fieldList = [];

        // 전체 
        this.types.forEach(type => {
            this.fields.push({ fieldName: `${type.suffix}_T`, dataType: "number" });
        });

        // 년월별 
        for (let year = 1; year <= this.years; year++) {

            fieldList.push(
                { fieldName: `AMT_${year}`, dataType: "number" },
                { fieldName: `QTY_${year}`, dataType: "number" },
                { fieldName: `PRI_${year}`, dataType: "number" }
            );

            this.months.forEach(month => {
                const fields = this.createField(month, year);
                fieldList.push(...fields); 
            });
            
        }
        return fieldList;
    }
    
    /* 
    레이아웃세팅 
    */
    handleLayout(){

        const items = [];

        //향후 5년 
        for (let year = 1; year <= this.years; year++) {
            const yearItem = {
                name: this.currentYear + year,
                expandable: true, 
                groupShowMode: "expand", // 접힘
                header: {
                    text: this.currentYear + year, // 컬럼 노출 TEXT
                },
                items: [
                    { column: "AMT_"  + year , groupShowMode: "always" },
                    { column: "QTY_"  + year , groupShowMode: "always" },
                    { column: "PRI_"  + year , groupShowMode: "always" }
                ],
            };
        
            // months 만큼 반복하여 월 그룹 생성
            this.months.forEach(month => {
                yearItem.items.push(this.createMonthGroup(month, year));
            });
            // 최종 items 배열에 추가
            items.push(yearItem);
        }

        return items;

    }

    /* 
    컬럼세팅 
    */
    handleColumn() {

        const formatData = [];

        // 전체 
        this.types.forEach(type => {
            const format = this.decimalSetting(`${type.suffix}_T`, `${type.suffix}_T`, type.label);
            formatData.push(format);
        });
        
        for (let year = 1; year <= this.years; year++) {

            // 월별 데이터 추가
            this.months.forEach(month => {
                this.types.forEach(type => {
                    const format = this.decimalSetting(`${type.suffix}_${year}_${month}`, `${type.suffix}_${year}_${month}`, type.label);
                    formatData.push(format); // 각 월별 데이터를 연도별 배열에 추가
                });
            });
    
            // 연간 총합 데이터 추가
            this.types.forEach(type => {
                const suffix = `${type.suffix}_${year}`;
                const format = this.decimalSetting(suffix, suffix, type.label);
                formatData.push(format);   // 각 연간 총합 데이터를 연도별 배열에 추가
            });
    
        }

        return formatData;
    }
    
    /* 숫자 컬럼세팅 */
    decimalSetting(name, fieldName, headerText) {
        return {
            name: name,
            fieldName: fieldName,
            width: this.staticWidth,
            numberFormat: this.numberFormat,
            styleName: "right-column",
            header: {
                text: headerText
            },
            headerSummary: {
                expression: "sum",
                numberFormat: this.numberFormat
            },
            footer: {
                expression: "sum",
                numberFormat: this.numberFormat
            }
        };
    }

    /* 
    layout : 년/월 세팅
    */
    createMonthGroup(month , year){ 
        return {
            name: month,
            expandable: true,
            groupShowMode: "collapse", // 접었을때 없어짐
            header: {
                text: month
            },
            items: [
                {column: "AMT_" + year + "_" + month , groupShowMode: "always"},
                {column: "QTY_" + year + "_" + month , groupShowMode: "always"},
                {column: "PRI_" + year + "_" + month , groupShowMode: "always"},
            ]
        };
    }

    /* 
    field : 년/월 세팅
    */
    createField(month, year){
        return [
            {fieldName : "AMT_" + year + "_" + month , dataType : "number"},
            {fieldName : "QTY_" + year + "_" + month , dataType : "number"},
            {fieldName : "PRI_" + year + "_" + month , dataType : "number"}
        ];
    }

    planData = [
        ["VTGMABTC0E0ARFQ", "원수주"    , "VINET"  ,"CIP" ,"VATNAM" , "USD" , 10,20,30,40,50,60,70,80 ,90,100],
        ["VTGMABTC0E0ARFQ", "추가수주1" , "HANAR"  ,"CIP" ,"VATNAM" , "USD" , 10,20,30,40,50,60,70,80 ,90,100],
        ["VTGMABTC0E0ARFQ", "추가수주2" , "SUPRD"  ,"CIP" ,"VATNAM" , "USD" , 10,20,30,40,50,60,70,80 ,90,100],
        ["ATGMABTC0E0ARFQ", "원수주"    , "VICTE"  ,"CIP" ,"VATNAM" , "USD" , 10,20,30,40,50,60,70,80 ,90,100],
        ["BTGMABTC0E0ARFQ", "추가수주"  , "RATTC"  ,"CIP" ,"VATNAM" , "USD" , 10,20,30,40,50,60,70,80 ,90,100],
        ["BTGMABTC0E0ARFQ", "추가수주2" , "WARTH"  ,"CIP" ,"VATNAM" , "USD" , 10,20,30,40,50,60,70,80 ,90,100],
        ["CTGMABTC0E0ARFQ", "추가수주3" , "VINET"  ,"CIP" ,"VATNAM" , "USD" , 10,20,30,40,50,60,70,80 ,90,100],
        ["CTGMABTC0E0ARFQ", "원수주"    , "VINET"  ,"CIP" ,"VATNAM" , "USD" , 10,20,30,40,50,60,70,80 ,90,100],
        ["CTGMABTC0E0ARFQ", "원수주"    , "VINET"  ,"CIP" ,"VATNAM" , "USD" , 10,20,30,40,50,60,70,80 ,90,100],
        ["DTGMABTC0E0ARFQ", "원수주"    , "VINET"  ,"CIP" ,"VATNAM" , "USD" , 10,20,30,40,50,60,70,80 ,90,100],
        ["DTGMABTC0E0ARFQ", "원수주"    , "VINET"  ,"CIP" ,"VATNAM" , "USD" , 10,20,30,40,50,60,70,80 ,90,100],
    ];

    menu = [
        {
          label: "menu1 입니다.",
          enabled: true,
          children: [
            {
              label: "submenu1 입니다."
            },
            {
              label: "submenu2 입니다."
            }
          ]
        },
        {
          label: "menu2 입니다",
          enabled: false
        },
        {
          label: "-"
        },
        {
          label: "menu3 입니다",
          type: "check", //check 설정
          checked: true, //check 상태
          tag: "check_menu"
        },
        {
          label: "group menu", //group 및 radio
          children: [
            {
              label: "group1 - 첫번째",
              type: "radio",
              group: "group1",
              checked: true
            },
            {
              label: "group1 - 두번째",
              type: "radio",
              group: "group1"
            },
            {
              label: "group1 - 세번째",
              type: "radio",
              group: "group1"
            }
          ]
        }
    ];


    connectedCallback(){
        const field = this.handleField();
        this.fields = this.fields.concat(field);
        // console.log(' * 필드 확인  => ' , JSON.stringify(this.fields) ); 

        const check = this.handleColumn();
        this.columns = this.columns.concat(check)
        // console.log(' * 컬럼 확인  => ' , JSON.parse(JSON.stringify(this.columns)) ); 

        const layout = this.handleLayout();
        this.layout = this.layout.concat(layout);
        // console.log(' * 레이아웃 확인  =>', JSON.stringify(this.layout, null, 2));
    }

    /* 엑셀 Export
     */
    exportGrid() {
        console.log(' real grid Excel 버튼 클릭!!');
        try{
            this.gridView.exportGrid({
                type: "excel", 
                target: "local",
                fileName : "SalesPalnExcel", // 엑셀파일명
                documentTitle: { 
                    message: "SalesPaln Excel Down",
                    visible: true,
                    spaceTop: 1,
                    spaceBottom: 0,
                    height: 60,
                    styleName: "documentStyle"
                },
                documentSubtitle: { //부제
                message: "작성자 : 리얼그리드\n작성일 : " + new Date().toLocaleDateString().replace(/\./g, '').replace(/\s/g, '-'),
                visible: true,
                height: 60,
                styleName: "documentSubtitleStyle"
                },
                documentTail: { //꼬릿말
                message: "파일보안에 주의해주세요",
                visible: true,
                styleName: "documentTailStyle"
                }
            });
            console.error(' 성공 ');
        }catch(error){
            console.error('Export failed:', JSON.stringify(error));
        }

    }

    setProvider(filename) {
        httpRequest = new XMLHttpRequest();
        httpRequest.onreadystatechange = loadData;
        httpRequest.open("GET", "/data/" + filename);
        httpRequest.send();
    }

    loadData() {
        if (httpRequest.readyState === XMLHttpRequest.DONE) {
          if (httpRequest.status === 200) {
            var data = JSON.parse(httpRequest.responseText);
            dataProvider.setRows(data);
            gridView.refresh();
          }
        }
    }

    _gridInitialized = false;

    renderedCallback() {
        console.log(' # renderedCallback # realGrid 로드');

        if (this._gridInitialized) return;

        this._gridInitialized = true;

        Promise.all([

            loadScript(this, realGrid + '/realgrid-lic.js'),
            loadScript(this, realGrid + '/realgrid.2.8.2.min.js'),
            loadStyle(this, realGrid + '/realgrid-sky-blue.css')

        ]).then(() => {
            this.defaultSetting();
        })
        .catch(error => {
            console.log(error.stack);
        });
    }

    disconnectedCallback() {
        this.gridView = this.gridView.destroy();
        this.dataProvider = this.dataProvider.destroy();
    }

    /*  
    초기 그리드 디폴트 세팅 
    */
    defaultSetting(){
        console.info('#defaultSetting # grid 불러오기 ~ ');

        const container = this.template.querySelector('[data-id="realgrid"]');
        console.log(container);

        RealGrid.setSlotMode(true);
        window.gridView = this.gridView = new RealGrid.GridView(container);
        gridView.displayOptions.emptyMessage = "표시할 데이타가 없습니다."; 
        
        this.dataProvider = new RealGrid.LocalDataProvider();
        this.gridView.setDataSource(this.dataProvider);
        this.gridView.headerSummaries.visible = false; // 상단 합계 
        this.gridView.editOptions.editable = true; // edit 가능하도록 추가
        this.gridView.editOptions.movable  = true; // 드레그앤 드롭 가능하도록 
        this.gridView.setStateBar({ visible: false });  // 상태바 표시 X
        this.gridView.addPopupMenu("menu1", this.menu); // 팝업메뉴
        const {displayOptions} = this.gridView;
        this.dataProvider.setFields(this.fields);   // 필드세팅
        this.gridView.setColumns(this.columns);      // 컬럼세팅
        this.gridView.setColumnLayout(this.layout); // 레이아웃 세팅
        this.gridView.setColumnProperty("OrderID", "mergeRule", { criteria: "value" }); // 동일행 병합 
        this.gridView.sortingOptions.enabled = true;      // 데이터 소팅

        // 데이터변경감지
        gridView.onEditChange = function (grid, index, value) {
            console.log("grid.onEditChange driven, " + index.column + ' at ' + index.dataRow + ' was replaced by value: ' + value);
        };

        displayOptions.fitStyle = 'even'; // 가로스크롤 가능 
        this.dataProvider.setRows(this.planData);

        setRowGroup(gridView);

        // 컬럼 고정 
        this.gridView.setFixedOptions({
            colCount: 7,
            resizable: true
        });

    }

    setRowGroup(grid) {
        grid.setGroupPanel({visible:true})
        grid.groupBy(["Gender"]);
    }

    /* 타입이 data 인 컬럼세팅 */
    columnSetting(name, fieldName, headerText, width , isMarge ){

        const column = {
            name: name,
            fieldName: fieldName,
            type: "data",
            width: width,
            header: {
                text: headerText
            }
        };
    
        // isMarge가 true 이면 mergeRule을 추가
        if (isMarge) {
            column.mergeRule = {
                criteria: "value"
            };
        }
        return column;

    }


}