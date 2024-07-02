/* =====================## 필드 ##========================*/
export const Fields = [
    {
        fieldName: "Id",
    },
    {
        fieldName: "Name",
    },
    {
        fieldName: "Oppy",
    },
    {
        fieldName: "Where"
    },
    {
        fieldName: "Incotearms"
    },
    {
        fieldName: "ShipTo"
    },
    {
        fieldName: "Currency"
    },
    {
        fieldName: "TotalAmt"
        ,dataType: "number"
    },
    {
        fieldName: "TotalQty"
        ,dataType: "number"
    },
    {
        fieldName: "TotalPrice"
        ,dataType: "number"
    }
]

export async function setFields(firstYear, cnt){
    var yearFields = [];
    for (let year = firstYear; year < (firstYear+cnt); year++) {
        yearFields.push(
            {
                fieldName: year + "_Total_Amt"
                ,dataType: "number"
            },
            {
                fieldName: year + "_Total_Qty"
                ,dataType: "number"
            },
            {
                fieldName: year + "_Total_Price"
                ,dataType: "number"
            },
        )
        for (let month = 1; month < 13; month++) {
            yearFields.push(
                {
                    fieldName: year + "_"+ month +"_Amt"
                    ,dataType: "number"
                },
                {
                    fieldName: year + "_"+ month +"_Qty"
                    ,dataType: "number"
                },
                {
                    fieldName: year + "_"+ month +"_Price"
                    ,dataType: "number"
                }
            )
        }
    }
    var defaultFlds = [...Fields];
    return defaultFlds.concat(yearFields);
}

/* =====================## 컬럼 ##========================*/
export const Columns = [
    {
        name: "Name",
        fieldName: "Name",
        width: "80",
        header: {
            text: "견적모델",
        },
        // button:"action",
        // buttonVisibility: "default"
        // autoFilter: true,
        // editable : false,
    },
    {
        name: "Oppy",    
        fieldName: "Oppy",
        width: "80",
        header: {
            text: "Oppy",
        }
    },
    {
        name: "Where",    
        fieldName: "Where",
        width: "80",
        header: {
            text: "생산지",
        }
    },
    {
        name: "Incotearms",    
        fieldName: "Incotearms",
        width: "80",
        header: {
            text: "인코텀즈",
        }
    },
    {
        name: "ShipTo",    
        fieldName: "ShipTo",
        width: "80",
        header: {
            text: "Ship to",
        }
    },
    {
        name: "Currency",    
        fieldName: "Currency",
        width: "80",
        header: {
            text: "통화",
        },
        groupFooter: {
            text: "소계"
        },
        // footer: {
        //     text: "합계",
        //     expression: "sum",
        // },
    },
    {
        name: "TotalAmt",    
        fieldName: "TotalAmt",
        width: "80",
        header: {
            text: "Amt.",
        },
        editor: {
            type: "number",
        },
        // numberFormat: "0.#########",
        numberFormat: "#,##0",
        groupFooter: {//소계
            expression: "sum",
            numberFormat: "#,##0",
        },
        // footer: {//합계
        //     expression: "sum",
        //     numberFormat: "#,##0",
        //     // styleName:"orange-column"
        // },
        styleName: "right-column"//??뭐여 안먹는디 어이없네
    },
    {
        name: "TotalQty",    
        fieldName: "TotalQty",
        width: "80",
        header: {
            text: "Qty.",
        },
        numberFormat: "#,##0",
        groupFooter: {
            expression: "sum",
            numberFormat: "#,##0",
        },
        // footer: {
        //     expression: "sum",
        //     numberFormat: "#,##0",
        // },
        styleName: "right-column",
    },
    {
        name: "TotalPrice",    
        fieldName: "TotalPrice",
        width: "80",
        header: {
            text: "Price.",
        },
        numberFormat: "#,##0",
        groupFooter: {
            expression: "sum",
            numberFormat: "#,##0",
        },
        // footer: {
        //     expression: "sum",
        //     numberFormat: "#,##0",
        // },
        styleName: "right-column",
    }
]

export async function setColumns(firstYear, cnt){
    var yearColumns = [];
    for (let year = firstYear; year < (firstYear+cnt); year++) {
        yearColumns.push(
            {
                name: year + "_Total_Amt",    
                fieldName: year + "_Total_Amt",
                width: "80",
                header: {
                    text: "Amt.",
                },
                numberFormat: "#,##0",
                styleName: "right-column",
            },
            {
                name: year + "_Total_Qty",    
                fieldName: year + "_Total_Qty",
                width: "80",
                header: {
                    text: "Qty.",
                },
                numberFormat: "#,##0",
                styleName: "right-column",
            },
            {
                name: year + "_Total_Price",    
                fieldName: year + "_Total_Price",
                width: "80",
                header: {
                    text: "Price.",
                },
                numberFormat: "#,##0",
                styleName: "right-column",
            }
        )

        for (let month = 1; month < 13; month++) {
            yearColumns.push(
                {
                    name: year + "_"+month+"_Amt",    
                    fieldName: year + "_"+month+"_Amt",
                    width: "80",
                    header: {
                        text: "Amt.",
                    },
                    numberFormat: "#,##0",
                    styleName: "right-column",
                },
                {
                    name: year + "_"+month+"_Qty",    
                    fieldName: year+"_"+month+"_Qty",
                    width: "80",
                    header: {
                        text: "Qty.",
                    },
                    numberFormat: "#,##0",
                    styleName: "right-column",
                },
                {
                    name: year + "_"+month+"_Price",    
                    fieldName: year + "_"+month+"_Price",
                    width: "80",
                    header: {
                        text: "Price.",
                    },
                    numberFormat: "#,##0",
                    styleName: "right-column",
                }
            )
        }
    }

    var defaultCol = [...Columns];
    return defaultCol.concat(yearColumns);
}

/* =====================## 컬럼 레이아웃 ##========================*/
export const ColumnLayout = [
    "Name",
    "Oppy",
    "Where",
    "Incotearms",
    "ShipTo",
    "Currency",
    {
        name:"Total",
        expandable: false,
        header:{text: "전체", height:21},//높이 안먹네
        items:[
            {column: "TotalAmt", groupShowMode:"always"},
            {column: "TotalQty", groupShowMode:"always"},
            {column: "TotalPrice", groupShowMode:"always"},
            // {column: "Gender", groupShowMode:"expand"},
            // {column: "Age", groupShowMode:"collapse"},
        ]
    },
]

export async function setColumnLayout(firstYear, cnt){
    var yearColumnLayout = [];
    for (let year = firstYear; year < (firstYear+cnt); year++) {
        yearColumnLayout.push(
            {
                name: year,
                expandable: true,
                expanded: false,
                items:[
                    {column: year +"_Total_Amt", groupShowMode:"always"},
                    {column: year +"_Total_Qty", groupShowMode:"always"},
                    {column: year +"_Total_Price", groupShowMode:"always"},
                    {
                        name:"JAN",
                        expandable: false,
                        groupShowMode: "expand",
                        items:[
                            {column: year +"_1_Amt", groupShowMode:"always"},
                            {column: year +"_1_Qty", groupShowMode:"always"},
                            {column: year +"_1_Price", groupShowMode:"always"},
                        ]
                    },
                    {
                        name:"FEB",
                        expandable: false,
                        groupShowMode: "expand",
                        items:[
                            {column: year +"_2_Amt", groupShowMode:"always"},
                            {column: year +"_2_Qty", groupShowMode:"always"},
                            {column: year +"_2_Price", groupShowMode:"always"},
                        ]
                    },
                    {
                        name:"MAR",
                        expandable: false,
                        groupShowMode: "expand",
                        items:[
                            {column: year +"_3_Amt", groupShowMode:"always"},
                            {column: year +"_3_Qty", groupShowMode:"always"},
                            {column: year +"_3_Price", groupShowMode:"always"},
                        ]
                    },
                    {
                        name:"APR",
                        expandable: false,
                        groupShowMode: "expand",
                        items:[
                            {column: year +"_4_Amt", groupShowMode:"always"},
                            {column: year +"_4_Qty", groupShowMode:"always"},
                            {column: year +"_4_Price", groupShowMode:"always"},
                        ]
                    },
                    {
                        name:"MAY",
                        expandable: false,
                        groupShowMode: "expand",
                        items:[
                            {column: year +"_5_Amt", groupShowMode:"always"},
                            {column: year +"_5_Qty", groupShowMode:"always"},
                            {column: year +"_5_Price", groupShowMode:"always"},
                        ]
                    },
                    {
                        name:"JUN",
                        expandable: false,
                        groupShowMode: "expand",
                        items:[
                            {column: year +"_6_Amt", groupShowMode:"always"},
                            {column: year +"_6_Qty", groupShowMode:"always"},
                            {column: year +"_6_Price", groupShowMode:"always"},
                        ]
                    },
                    {
                        name:"JUL",
                        expandable: false,
                        groupShowMode: "expand",
                        items:[
                            {column: year +"_7_Amt", groupShowMode:"always"},
                            {column: year +"_7_Qty", groupShowMode:"always"},
                            {column: year +"_7_Price", groupShowMode:"always"},
                        ]
                    },
                    {
                        name:"AUG",
                        expandable: false,
                        groupShowMode: "expand",
                        items:[
                            {column: year +"_8_Amt", groupShowMode:"always"},
                            {column: year +"_8_Qty", groupShowMode:"always"},
                            {column: year +"_8_Price", groupShowMode:"always"},
                        ]
                    },
                    {
                        name:"SEP",
                        expandable: false,
                        groupShowMode: "expand",
                        items:[
                            {column: year +"_9_Amt", groupShowMode:"always"},
                            {column: year +"_9_Qty", groupShowMode:"always"},
                            {column: year +"_9_Price", groupShowMode:"always"},
                        ]
                    },
                    {
                        name:"OCT",
                        expandable: false,
                        groupShowMode: "expand",
                        items:[
                            {column: year +"_10_Amt", groupShowMode:"always"},
                            {column: year +"_10_Qty", groupShowMode:"always"},
                            {column: year +"_10_Price", groupShowMode:"always"},
                        ]
                    },
                    {
                        name:"NOV",
                        expandable: false,
                        groupShowMode: "expand",
                        items:[
                            {column: year +"_11_Amt", groupShowMode:"always"},
                            {column: year +"_11_Qty", groupShowMode:"always"},
                            {column: year +"_11_Price", groupShowMode:"always"},
                        ]
                    },
                    {
                        name:"DEC",
                        expandable: false,
                        groupShowMode: "expand",
                        items:[
                            {column: year +"_12_Amt", groupShowMode:"always"},
                            {column: year +"_12_Qty", groupShowMode:"always"},
                            {column: year +"_12_Price", groupShowMode:"always"},
                        ]
                    },
                ]
            }
        )
    }

    var defaultColumnLayout = [...ColumnLayout];
    return defaultColumnLayout.concat(yearColumnLayout);
}