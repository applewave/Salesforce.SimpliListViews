/**************************************************************************************** 
 * File Name    : RealGridProjectSalesPlanBulkController
 * Author       : ar.kim
 * Date         : 2024-06-24
 * Description  : 
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * =============================================================== 
 * Ver      Date 		Author    			Modification
 * ===============================================================
   1.0		2024-06-24 	ar.kim			    Create

****************************************************************************************/
public with sharing class RealGridProjectSalesPlanBulkController {

    /** Whether Test or not */
    //private final static Boolean IS_TEST = Test.isRunningTest();

    /**
     * @description init 메소드 : 화면에 표시할 ProjectSalesPlan을 리턴
     * @param 화면의 record Id
     * @return InitCls
     */
    @AuraEnabled
    public static InitCls init(String recordId) {
        InitCls ic = new InitCls();

        ic.pjtSalesPlanIdList = getProjectSalesPlanId(recordId);

        return ic;
    }

    /**
     * @description Project의 SalesPlanDetail을 Product별 현재 현황을 화면에 표시하기 위하여 wrapper class로 세팅
     * @param SalesPlan목록 : List<VS_SalesPlanItem__c> itemList, SalesPlan Detail 목록 : List<VS_SalesPlanDetail__c> detailList
     * @return ProjectSalesPlan 현황(wrapper class) : ResData
     */
    @AuraEnabled(cacheable=true)
    public static List<ResProjectSalesPlan> setProjectSalesPlanList(List<VS_SalesPlanItem__c> itemList, List<VS_SalesPlanDetail__c> detailList){
        System.debug('*************setProjectSalesPlanList Start*************');

        List<ResProjectSalesPlan> recordList = new List<ResProjectSalesPlan>();

        /** to do 전달받은 SalesPlanDetailList를 제품별(행) 년월(열)별로 표시하기 위하여 data를 세팅한다.
         * 1. ResProjectSalesPlan에 견적제품별/oppty별로 데이터 세팅 : 전체 수량 물량 정보까지
         * 2. ResProjectSalesPlan에 Oppty별 제품의 Detail을 년월별로 세팅
         *  item Map<String,VS_SalesPlanItem__c> key : l_OpportunityItem__c + l_SalesPlan__r.l_Opportunity__c + Id
         *  detail Map<String,VS_SalesPlanDetail__c> key : l_SalesPlanItem__r.l_OpportunityItem__c + l_SalesPlan__r.l_Opportunity__c + l_SalesPlanItem__c + Year__c + Month__c
        */

        Map<String,VS_SalesPlanItem__c> itemMap = new Map<String,VS_SalesPlanItem__c>();
        Map<String,VS_SalesPlanDetail__c> detailMap = new Map<String,VS_SalesPlanDetail__c>();

        if(itemList.Size()>0){
            for(VS_SalesPlanItem__c item : itemList){
                String key = item.l_OpportunityItem__c +'_'+ item.l_SalesPlan__r.l_Opportunity__c +'_'+ item.Id;
                itemMap.put(key, item);
            }
    
            for(VS_SalesPlanDetail__c detail : detailList){
                String key = detail.l_SalesPlanItem__r.l_OpportunityItem__c +'_'+ detail.l_SalesPlan__r.l_Opportunity__c +'_'+ detail.l_SalesPlanItem__c +'_'+ detail.Year__c +'_'+ detail.Month__c;
                detailMap.put(key, detail);
            }
    
            for(VS_SalesPlanItem__c item : itemList){
                String itemKey      = item.l_OpportunityItem__c +'_'+ item.l_SalesPlan__r.l_Opportunity__c +'_'+ item.Id;
                Integer startYear   = (item.SOP__c).year();
    
                ResProjectSalesPlan newRes = new ResProjectSalesPlan();        
                
                /* 견적제품 기본 정보 */
                newRes.quoteProdName            = getMapString(itemKey, 'fm_OpportunityItemName__c', itemMap);
                newRes.opptyName                = getMapString(itemKey, 'fm_OpportunityName__c', itemMap);
                newRes.coroprate                = getMapString(itemKey, 'Corporate__c', itemMap);
                newRes.productionType           = getMapString(itemKey, 'ProductionType__c', itemMap);
                newRes.incoterms                = getMapString(itemKey, 'Incoterms__c', itemMap);
                newRes.dLocation                = getMapString(itemKey, 'DLocation__c', itemMap);
                newRes.currencyIsoCode          = getMapString(itemKey, 'CurrencyIsoCode', itemMap);
    
                /* 견적제품 전체 수량물량 정보 */
                newRes.ttlAmt                   = getMapDecimal(itemKey, 'ru_TotalAmount__c', itemMap);
                newRes.ttlQty                   = getMapDecimal(itemKey, 'ru_TotalQuantity__c', itemMap);
                newRes.ttlPrice                 = getMapDecimal(itemKey, 'fm_AveragePrice__c', itemMap);
    
                /* 1년차 수량물량 정보 */
                newRes.ttlamt1st                = getMapDecimal(itemkey, 'ru_PlanAmt1st__c', itemMap);
                newRes.ttlqty1st                = getMapDecimal(itemkey, 'ru_PlanQty1st__c', itemMap);
                newRes.ttlprice1st              = getMapDecimal(itemkey, 'fm_AvgPrice1st__c', itemMap);
    
                newRes.amt1stJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_01', 'PlanAmount__c', detailMap);
                newRes.qty1stJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_01', 'PlanQty__c', detailMap);
                newRes.price1stJAN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_01', 'PlanPrice__c', detailMap);
                newRes.amt1stFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_02', 'PlanAmount__c', detailMap);
                newRes.qty1stFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_02', 'PlanQty__c', detailMap);
                newRes.price1stFEB              = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_02', 'PlanPrice__c', detailMap);
                newRes.amt1stMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_03', 'PlanAmount__c', detailMap);
                newRes.qty1stMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_03', 'PlanQty__c', detailMap);
                newRes.price1stMAR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_03', 'PlanPrice__c', detailMap);
                newRes.amt1stAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_04', 'PlanAmount__c', detailMap);
                newRes.qty1stAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_04', 'PlanQty__c', detailMap);
                newRes.price1stAPR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_04', 'PlanPrice__c', detailMap);
                newRes.amt1stMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_05', 'PlanAmount__c', detailMap);
                newRes.qty1stMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_05', 'PlanQty__c', detailMap);
                newRes.price1stMAY              = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_05', 'PlanPrice__c', detailMap);
                newRes.amt1stJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_06', 'PlanAmount__c', detailMap);
                newRes.qty1stJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_06', 'PlanQty__c', detailMap);
                newRes.price1stJUN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_06', 'PlanPrice__c', detailMap);
                newRes.amt1stJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_07', 'PlanAmount__c', detailMap);
                newRes.qty1stJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_07', 'PlanQty__c', detailMap);
                newRes.price1stJUL              = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_07', 'PlanPrice__c', detailMap);
                newRes.amt1stAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_08', 'PlanAmount__c', detailMap);
                newRes.qty1stAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_08', 'PlanQty__c', detailMap);
                newRes.price1stAUG              = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_08', 'PlanPrice__c', detailMap);
                newRes.amt1stSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_09', 'PlanAmount__c', detailMap);
                newRes.qty1stSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_09', 'PlanQty__c', detailMap);
                newRes.price1stSEP              = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_09', 'PlanPrice__c', detailMap);
                newRes.amt1stOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_10', 'PlanAmount__c', detailMap);
                newRes.qty1stOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_10', 'PlanQty__c', detailMap);
                newRes.price1stOCT              = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_10', 'PlanPrice__c', detailMap);
                newRes.amt1stNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_11', 'PlanAmount__c', detailMap);
                newRes.qty1stNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_11', 'PlanQty__c', detailMap);
                newRes.price1stNOV              = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_11', 'PlanPrice__c', detailMap);
                newRes.amt1stDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_12', 'PlanAmount__c', detailMap);
                newRes.qty1stDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_12', 'PlanQty__c', detailMap);
                newRes.price1stDEC              = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_12', 'PlanPrice__c', detailMap);
    
                /* 2년차 수량물량 정보 */
                newRes.ttlamt2nd                = getMapDecimal(itemkey, 'ru_PlanAmt2nd__c', itemMap);
                newRes.ttlqty2nd                = getMapDecimal(itemkey, 'ru_PlanQty2nd__c', itemMap);
                newRes.ttlprice2nd              = getMapDecimal(itemkey, 'fm_AvgPrice2nd__c', itemMap);
    
                newRes.amt2ndJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_01', 'PlanAmount__c', detailMap);
                newRes.qty2ndJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_01', 'PlanQty__c', detailMap);
                newRes.price2ndJAN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_01', 'PlanPrice__c', detailMap);
                newRes.amt2ndFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_02', 'PlanAmount__c', detailMap);
                newRes.qty2ndFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_02', 'PlanQty__c', detailMap);
                newRes.price2ndFEB              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_02', 'PlanPrice__c', detailMap);
                newRes.amt2ndMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_03', 'PlanAmount__c', detailMap);
                newRes.qty2ndMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_03', 'PlanQty__c', detailMap);
                newRes.price2ndMAR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_03', 'PlanPrice__c', detailMap);
                newRes.amt2ndAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_04', 'PlanAmount__c', detailMap);
                newRes.qty2ndAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_04', 'PlanQty__c', detailMap);
                newRes.price2ndAPR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_04', 'PlanPrice__c', detailMap);
                newRes.amt2ndMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_05', 'PlanAmount__c', detailMap);
                newRes.qty2ndMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_05', 'PlanQty__c', detailMap);
                newRes.price2ndMAY              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_05', 'PlanPrice__c', detailMap);
                newRes.amt2ndJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_06', 'PlanAmount__c', detailMap);
                newRes.qty2ndJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_06', 'PlanQty__c', detailMap);
                newRes.price2ndJUN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_06', 'PlanPrice__c', detailMap);
                newRes.amt2ndJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_07', 'PlanAmount__c', detailMap);
                newRes.qty2ndJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_07', 'PlanQty__c', detailMap);
                newRes.price2ndJUL              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_07', 'PlanPrice__c', detailMap);
                newRes.amt2ndAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_08', 'PlanAmount__c', detailMap);
                newRes.qty2ndAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_08', 'PlanQty__c', detailMap);
                newRes.price2ndAUG              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_08', 'PlanPrice__c', detailMap);
                newRes.amt2ndSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_09', 'PlanAmount__c', detailMap);
                newRes.qty2ndSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_09', 'PlanQty__c', detailMap);
                newRes.price2ndSEP              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_09', 'PlanPrice__c', detailMap);
                newRes.amt2ndOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_10', 'PlanAmount__c', detailMap);
                newRes.qty2ndOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_10', 'PlanQty__c', detailMap);
                newRes.price2ndOCT              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_10', 'PlanPrice__c', detailMap);
                newRes.amt2ndNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_11', 'PlanAmount__c', detailMap);
                newRes.qty2ndNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_11', 'PlanQty__c', detailMap);
                newRes.price2ndNOV              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_11', 'PlanPrice__c', detailMap);
                newRes.amt2ndDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_12', 'PlanAmount__c', detailMap);
                newRes.qty2ndDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_12', 'PlanQty__c', detailMap);
                newRes.price2ndDEC              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_12', 'PlanPrice__c', detailMap);
    
                /* 3년차 수량물량 정보 */
                newRes.ttlamt3rd                = getMapDecimal(itemkey, 'ru_PlanAmt3rd__c', itemMap);
                newRes.ttlqty3rd                = getMapDecimal(itemkey, 'ru_PlanQty3rd__c', itemMap);
                newRes.ttlprice3rd              = getMapDecimal(itemkey, 'fm_AvgPrice3rd__c', itemMap);
    
                newRes.amt3rdJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_01', 'PlanAmount__c', detailMap);
                newRes.qty3rdJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_01', 'PlanQty__c', detailMap);
                newRes.price3rdJAN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_01', 'PlanPrice__c', detailMap);
                newRes.amt3rdFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_02', 'PlanAmount__c', detailMap);
                newRes.qty3rdFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_02', 'PlanQty__c', detailMap);
                newRes.price3rdFEB              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_02', 'PlanPrice__c', detailMap);
                newRes.amt3rdMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_03', 'PlanAmount__c', detailMap);
                newRes.qty3rdMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_03', 'PlanQty__c', detailMap);
                newRes.price3rdMAR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_03', 'PlanPrice__c', detailMap);
                newRes.amt3rdAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_04', 'PlanAmount__c', detailMap);
                newRes.qty3rdAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_04', 'PlanQty__c', detailMap);
                newRes.price3rdAPR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_04', 'PlanPrice__c', detailMap);
                newRes.amt3rdMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_05', 'PlanAmount__c', detailMap);
                newRes.qty3rdMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_05', 'PlanQty__c', detailMap);
                newRes.price3rdMAY              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_05', 'PlanPrice__c', detailMap);
                newRes.amt3rdJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_06', 'PlanAmount__c', detailMap);
                newRes.qty3rdJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_06', 'PlanQty__c', detailMap);
                newRes.price3rdJUN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_06', 'PlanPrice__c', detailMap);
                newRes.amt3rdJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_07', 'PlanAmount__c', detailMap);
                newRes.qty3rdJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_07', 'PlanQty__c', detailMap);
                newRes.price3rdJUL              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_07', 'PlanPrice__c', detailMap);
                newRes.amt3rdAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_08', 'PlanAmount__c', detailMap);
                newRes.qty3rdAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_08', 'PlanQty__c', detailMap);
                newRes.price3rdAUG              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_08', 'PlanPrice__c', detailMap);
                newRes.amt3rdSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_09', 'PlanAmount__c', detailMap);
                newRes.qty3rdSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_09', 'PlanQty__c', detailMap);
                newRes.price3rdSEP              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_09', 'PlanPrice__c', detailMap);
                newRes.amt3rdOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_10', 'PlanAmount__c', detailMap);
                newRes.qty3rdOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_10', 'PlanQty__c', detailMap);
                newRes.price3rdOCT              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_10', 'PlanPrice__c', detailMap);
                newRes.amt3rdNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_11', 'PlanAmount__c', detailMap);
                newRes.qty3rdNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_11', 'PlanQty__c', detailMap);
                newRes.price3rdNOV              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_11', 'PlanPrice__c', detailMap);
                newRes.amt3rdDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_12', 'PlanAmount__c', detailMap);
                newRes.qty3rdDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_12', 'PlanQty__c', detailMap);
                newRes.price3rdDEC              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_12', 'PlanPrice__c', detailMap);
    
                /* 4년차 수량물량 정보 */
                newRes.ttlamt4th                = getMapDecimal(itemkey, 'ru_PlanAmt4th__c', itemMap);
                newRes.ttlqty4th                = getMapDecimal(itemkey, 'ru_PlanQty4th__c', itemMap);
                newRes.ttlprice4th              = getMapDecimal(itemkey, 'fm_AvgPrice4th__c', itemMap);
    
                newRes.amt4thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_01', 'PlanAmount__c', detailMap);
                newRes.qty4thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_01', 'PlanQty__c', detailMap);
                newRes.price4thJAN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_01', 'PlanPrice__c', detailMap);
                newRes.amt4thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_02', 'PlanAmount__c', detailMap);
                newRes.qty4thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_02', 'PlanQty__c', detailMap);
                newRes.price4thFEB              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_02', 'PlanPrice__c', detailMap);
                newRes.amt4thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_03', 'PlanAmount__c', detailMap);
                newRes.qty4thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_03', 'PlanQty__c', detailMap);
                newRes.price4thMAR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_03', 'PlanPrice__c', detailMap);
                newRes.amt4thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_04', 'PlanAmount__c', detailMap);
                newRes.qty4thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_04', 'PlanQty__c', detailMap);
                newRes.price4thAPR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_04', 'PlanPrice__c', detailMap);
                newRes.amt4thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_05', 'PlanAmount__c', detailMap);
                newRes.qty4thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_05', 'PlanQty__c', detailMap);
                newRes.price4thMAY              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_05', 'PlanPrice__c', detailMap);
                newRes.amt4thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_06', 'PlanAmount__c', detailMap);
                newRes.qty4thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_06', 'PlanQty__c', detailMap);
                newRes.price4thJUN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_06', 'PlanPrice__c', detailMap);
                newRes.amt4thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_07', 'PlanAmount__c', detailMap);
                newRes.qty4thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_07', 'PlanQty__c', detailMap);
                newRes.price4thJUL              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_07', 'PlanPrice__c', detailMap);
                newRes.amt4thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_08', 'PlanAmount__c', detailMap);
                newRes.qty4thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_08', 'PlanQty__c', detailMap);
                newRes.price4thAUG              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_08', 'PlanPrice__c', detailMap);
                newRes.amt4thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_09', 'PlanAmount__c', detailMap);
                newRes.qty4thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_09', 'PlanQty__c', detailMap);
                newRes.price4thSEP              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_09', 'PlanPrice__c', detailMap);
                newRes.amt4thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_10', 'PlanAmount__c', detailMap);
                newRes.qty4thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_10', 'PlanQty__c', detailMap);
                newRes.price4thOCT              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_10', 'PlanPrice__c', detailMap);
                newRes.amt4thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_11', 'PlanAmount__c', detailMap);
                newRes.qty4thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_11', 'PlanQty__c', detailMap);
                newRes.price4thNOV              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_11', 'PlanPrice__c', detailMap);
                newRes.amt4thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_12', 'PlanAmount__c', detailMap);
                newRes.qty4thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_12', 'PlanQty__c', detailMap);
                newRes.price4thDEC              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_12', 'PlanPrice__c', detailMap);
    
                /* 5년차 수량물량 정보 */
                newRes.ttlamt5th                = getMapDecimal(itemkey, 'ru_PlanAmt5th__c', itemMap);
                newRes.ttlqty5th                = getMapDecimal(itemkey, 'ru_PlanQty5th__c', itemMap);
                newRes.ttlprice5th              = getMapDecimal(itemkey, 'fm_AvgPrice5th__c', itemMap);
    
                newRes.amt5thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_01', 'PlanAmount__c', detailMap);
                newRes.qty5thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_01', 'PlanQty__c', detailMap);
                newRes.price5thJAN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_01', 'PlanPrice__c', detailMap);
                newRes.amt5thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_02', 'PlanAmount__c', detailMap);
                newRes.qty5thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_02', 'PlanQty__c', detailMap);
                newRes.price5thFEB              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_02', 'PlanPrice__c', detailMap);
                newRes.amt5thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_03', 'PlanAmount__c', detailMap);
                newRes.qty5thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_03', 'PlanQty__c', detailMap);
                newRes.price5thMAR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_03', 'PlanPrice__c', detailMap);
                newRes.amt5thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_04', 'PlanAmount__c', detailMap);
                newRes.qty5thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_04', 'PlanQty__c', detailMap);
                newRes.price5thAPR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_04', 'PlanPrice__c', detailMap);
                newRes.amt5thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_05', 'PlanAmount__c', detailMap);
                newRes.qty5thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_05', 'PlanQty__c', detailMap);
                newRes.price5thMAY              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_05', 'PlanPrice__c', detailMap);
                newRes.amt5thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_06', 'PlanAmount__c', detailMap);
                newRes.qty5thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_06', 'PlanQty__c', detailMap);
                newRes.price5thJUN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_06', 'PlanPrice__c', detailMap);
                newRes.amt5thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_07', 'PlanAmount__c', detailMap);
                newRes.qty5thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_07', 'PlanQty__c', detailMap);
                newRes.price5thJUL              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_07', 'PlanPrice__c', detailMap);
                newRes.amt5thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_08', 'PlanAmount__c', detailMap);
                newRes.qty5thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_08', 'PlanQty__c', detailMap);
                newRes.price5thAUG              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_08', 'PlanPrice__c', detailMap);
                newRes.amt5thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_09', 'PlanAmount__c', detailMap);
                newRes.qty5thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_09', 'PlanQty__c', detailMap);
                newRes.price5thSEP              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_09', 'PlanPrice__c', detailMap);
                newRes.amt5thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_10', 'PlanAmount__c', detailMap);
                newRes.qty5thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_10', 'PlanQty__c', detailMap);
                newRes.price5thOCT              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_10', 'PlanPrice__c', detailMap);
                newRes.amt5thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_11', 'PlanAmount__c', detailMap);
                newRes.qty5thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_11', 'PlanQty__c', detailMap);
                newRes.price5thNOV              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_11', 'PlanPrice__c', detailMap);
                newRes.amt5thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_12', 'PlanAmount__c', detailMap);
                newRes.qty5thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_12', 'PlanQty__c', detailMap);
                newRes.price5thDEC              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_12', 'PlanPrice__c', detailMap);
    
                /* 6년차 수량물량 정보 */
                newRes.ttlamt6th                = getMapDecimal(itemkey, 'ru_PlanAmt6th__c', itemMap);
                newRes.ttlqty6th                = getMapDecimal(itemkey, 'ru_PlanQty6th__c', itemMap);
                newRes.ttlprice6th              = getMapDecimal(itemkey, 'fm_AvgPrice6th__c', itemMap);
    
                newRes.amt6thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_01', 'PlanAmount__c', detailMap);
                newRes.qty6thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_01', 'PlanQty__c', detailMap);
                newRes.price6thJAN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_01', 'PlanPrice__c', detailMap);
                newRes.amt6thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_02', 'PlanAmount__c', detailMap);
                newRes.qty6thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_02', 'PlanQty__c', detailMap);
                newRes.price6thFEB              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_02', 'PlanPrice__c', detailMap);
                newRes.amt6thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_03', 'PlanAmount__c', detailMap);
                newRes.qty6thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_03', 'PlanQty__c', detailMap);
                newRes.price6thMAR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_03', 'PlanPrice__c', detailMap);
                newRes.amt6thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_04', 'PlanAmount__c', detailMap);
                newRes.qty6thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_04', 'PlanQty__c', detailMap);
                newRes.price6thAPR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_04', 'PlanPrice__c', detailMap);
                newRes.amt6thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_05', 'PlanAmount__c', detailMap);
                newRes.qty6thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_05', 'PlanQty__c', detailMap);
                newRes.price6thMAY              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_05', 'PlanPrice__c', detailMap);
                newRes.amt6thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_06', 'PlanAmount__c', detailMap);
                newRes.qty6thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_06', 'PlanQty__c', detailMap);
                newRes.price6thJUN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_06', 'PlanPrice__c', detailMap);
                newRes.amt6thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_07', 'PlanAmount__c', detailMap);
                newRes.qty6thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_07', 'PlanQty__c', detailMap);
                newRes.price6thJUL              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_07', 'PlanPrice__c', detailMap);
                newRes.amt6thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_08', 'PlanAmount__c', detailMap);
                newRes.qty6thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_08', 'PlanQty__c', detailMap);
                newRes.price6thAUG              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_08', 'PlanPrice__c', detailMap);
                newRes.amt6thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_09', 'PlanAmount__c', detailMap);
                newRes.qty6thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_09', 'PlanQty__c', detailMap);
                newRes.price6thSEP              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_09', 'PlanPrice__c', detailMap);
                newRes.amt6thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_10', 'PlanAmount__c', detailMap);
                newRes.qty6thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_10', 'PlanQty__c', detailMap);
                newRes.price6thOCT              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_10', 'PlanPrice__c', detailMap);
                newRes.amt6thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_11', 'PlanAmount__c', detailMap);
                newRes.qty6thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_11', 'PlanQty__c', detailMap);
                newRes.price6thNOV              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_11', 'PlanPrice__c', detailMap);
                newRes.amt6thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_12', 'PlanAmount__c', detailMap);
                newRes.qty6thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_12', 'PlanQty__c', detailMap);
                newRes.price6thDEC              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_12', 'PlanPrice__c', detailMap);
    
                /* 7년차 수량물량 정보 */
                newRes.ttlamt7th                = getMapDecimal(itemkey, 'ru_PlanAmt7th__c', itemMap);
                newRes.ttlqty7th                = getMapDecimal(itemkey, 'ru_PlanQty7th__c', itemMap);
                newRes.ttlprice7th              = getMapDecimal(itemkey, 'fm_AvgPrice7th__c', itemMap);
    
                newRes.amt7thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_01', 'PlanAmount__c', detailMap);
                newRes.qty7thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_01', 'PlanQty__c', detailMap);
                newRes.price7thJAN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_01', 'PlanPrice__c', detailMap);
                newRes.amt7thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_02', 'PlanAmount__c', detailMap);
                newRes.qty7thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_02', 'PlanQty__c', detailMap);
                newRes.price7thFEB              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_02', 'PlanPrice__c', detailMap);
                newRes.amt7thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_03', 'PlanAmount__c', detailMap);
                newRes.qty7thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_03', 'PlanQty__c', detailMap);
                newRes.price7thMAR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_03', 'PlanPrice__c', detailMap);
                newRes.amt7thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_04', 'PlanAmount__c', detailMap);
                newRes.qty7thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_04', 'PlanQty__c', detailMap);
                newRes.price7thAPR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_04', 'PlanPrice__c', detailMap);
                newRes.amt7thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_05', 'PlanAmount__c', detailMap);
                newRes.qty7thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_05', 'PlanQty__c', detailMap);
                newRes.price7thMAY              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_05', 'PlanPrice__c', detailMap);
                newRes.amt7thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_06', 'PlanAmount__c', detailMap);
                newRes.qty7thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_06', 'PlanQty__c', detailMap);
                newRes.price7thJUN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_06', 'PlanPrice__c', detailMap);
                newRes.amt7thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_07', 'PlanAmount__c', detailMap);
                newRes.qty7thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_07', 'PlanQty__c', detailMap);
                newRes.price7thJUL              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_07', 'PlanPrice__c', detailMap);
                newRes.amt7thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_08', 'PlanAmount__c', detailMap);
                newRes.qty7thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_08', 'PlanQty__c', detailMap);
                newRes.price7thAUG              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_08', 'PlanPrice__c', detailMap);
                newRes.amt7thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_09', 'PlanAmount__c', detailMap);
                newRes.qty7thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_09', 'PlanQty__c', detailMap);
                newRes.price7thSEP              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_09', 'PlanPrice__c', detailMap);
                newRes.amt7thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_10', 'PlanAmount__c', detailMap);
                newRes.qty7thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_10', 'PlanQty__c', detailMap);
                newRes.price7thOCT              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_10', 'PlanPrice__c', detailMap);
                newRes.amt7thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_11', 'PlanAmount__c', detailMap);
                newRes.qty7thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_11', 'PlanQty__c', detailMap);
                newRes.price7thNOV              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_11', 'PlanPrice__c', detailMap);
                newRes.amt7thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_12', 'PlanAmount__c', detailMap);
                newRes.qty7thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_12', 'PlanQty__c', detailMap);
                newRes.price7thDEC              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+6)+'_12', 'PlanPrice__c', detailMap);
    
                /* 8년차 수량물량 정보 */
                newRes.ttlamt8th                = getMapDecimal(itemkey, 'ru_PlanAmt8th__c', itemMap);
                newRes.ttlqty8th                = getMapDecimal(itemkey, 'ru_PlanQty8th__c', itemMap);
                newRes.ttlprice8th              = getMapDecimal(itemkey, 'fm_AvgPrice8th__c', itemMap);
    
                newRes.amt8thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_01', 'PlanAmount__c', detailMap);
                newRes.qty8thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_01', 'PlanQty__c', detailMap);
                newRes.price8thJAN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_01', 'PlanPrice__c', detailMap);
                newRes.amt8thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_02', 'PlanAmount__c', detailMap);
                newRes.qty8thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_02', 'PlanQty__c', detailMap);
                newRes.price8thFEB              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_02', 'PlanPrice__c', detailMap);
                newRes.amt8thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_03', 'PlanAmount__c', detailMap);
                newRes.qty8thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_03', 'PlanQty__c', detailMap);
                newRes.price8thMAR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_03', 'PlanPrice__c', detailMap);
                newRes.amt8thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_04', 'PlanAmount__c', detailMap);
                newRes.qty8thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_04', 'PlanQty__c', detailMap);
                newRes.price8thAPR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_04', 'PlanPrice__c', detailMap);
                newRes.amt8thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_05', 'PlanAmount__c', detailMap);
                newRes.qty8thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_05', 'PlanQty__c', detailMap);
                newRes.price8thMAY              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_05', 'PlanPrice__c', detailMap);
                newRes.amt8thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_06', 'PlanAmount__c', detailMap);
                newRes.qty8thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_06', 'PlanQty__c', detailMap);
                newRes.price8thJUN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_06', 'PlanPrice__c', detailMap);
                newRes.amt8thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_07', 'PlanAmount__c', detailMap);
                newRes.qty8thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_07', 'PlanQty__c', detailMap);
                newRes.price8thJUL              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_07', 'PlanPrice__c', detailMap);
                newRes.amt8thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_08', 'PlanAmount__c', detailMap);
                newRes.qty8thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_08', 'PlanQty__c', detailMap);
                newRes.price8thAUG              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_08', 'PlanPrice__c', detailMap);
                newRes.amt8thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_09', 'PlanAmount__c', detailMap);
                newRes.qty8thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_09', 'PlanQty__c', detailMap);
                newRes.price8thSEP              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_09', 'PlanPrice__c', detailMap);
                newRes.amt8thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_10', 'PlanAmount__c', detailMap);
                newRes.qty8thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_10', 'PlanQty__c', detailMap);
                newRes.price8thOCT              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_10', 'PlanPrice__c', detailMap);
                newRes.amt8thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_11', 'PlanAmount__c', detailMap);
                newRes.qty8thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_11', 'PlanQty__c', detailMap);
                newRes.price8thNOV              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_11', 'PlanPrice__c', detailMap);
                newRes.amt8thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_12', 'PlanAmount__c', detailMap);
                newRes.qty8thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_12', 'PlanQty__c', detailMap);
                newRes.price8thDEC              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_12', 'PlanPrice__c', detailMap);
    
                /* 9년차 수량물량 정보 */
                newRes.ttlamt9th                = getMapDecimal(itemkey, 'ru_PlanAmt9th__c', itemMap);
                newRes.ttlqty9th                = getMapDecimal(itemkey, 'ru_PlanQty9th__c', itemMap);
                newRes.ttlprice9th              = getMapDecimal(itemkey, 'fm_AvgPrice9th__c', itemMap);
    
                newRes.amt9thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_01', 'PlanAmount__c', detailMap);
                newRes.qty9thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_01', 'PlanQty__c', detailMap);
                newRes.price9thJAN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_01', 'PlanPrice__c', detailMap);
                newRes.amt9thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_02', 'PlanAmount__c', detailMap);
                newRes.qty9thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_02', 'PlanQty__c', detailMap);
                newRes.price9thFEB              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_02', 'PlanPrice__c', detailMap);
                newRes.amt9thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_03', 'PlanAmount__c', detailMap);
                newRes.qty9thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_03', 'PlanQty__c', detailMap);
                newRes.price9thMAR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_03', 'PlanPrice__c', detailMap);
                newRes.amt9thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_04', 'PlanAmount__c', detailMap);
                newRes.qty9thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_04', 'PlanQty__c', detailMap);
                newRes.price9thAPR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_04', 'PlanPrice__c', detailMap);
                newRes.amt9thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_05', 'PlanAmount__c', detailMap);
                newRes.qty9thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_05', 'PlanQty__c', detailMap);
                newRes.price9thMAY              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_05', 'PlanPrice__c', detailMap);
                newRes.amt9thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_06', 'PlanAmount__c', detailMap);
                newRes.qty9thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_06', 'PlanQty__c', detailMap);
                newRes.price9thJUN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_06', 'PlanPrice__c', detailMap);
                newRes.amt9thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_07', 'PlanAmount__c', detailMap);
                newRes.qty9thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_07', 'PlanQty__c', detailMap);
                newRes.price9thJUL              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_07', 'PlanPrice__c', detailMap);
                newRes.amt9thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_08', 'PlanAmount__c', detailMap);
                newRes.qty9thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_08', 'PlanQty__c', detailMap);
                newRes.price9thAUG              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_08', 'PlanPrice__c', detailMap);
                newRes.amt9thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_09', 'PlanAmount__c', detailMap);
                newRes.qty9thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_09', 'PlanQty__c', detailMap);
                newRes.price9thSEP              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_09', 'PlanPrice__c', detailMap);
                newRes.amt9thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_10', 'PlanAmount__c', detailMap);
                newRes.qty9thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_10', 'PlanQty__c', detailMap);
                newRes.price9thOCT              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_10', 'PlanPrice__c', detailMap);
                newRes.amt9thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_11', 'PlanAmount__c', detailMap);
                newRes.qty9thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_11', 'PlanQty__c', detailMap);
                newRes.price9thNOV              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_11', 'PlanPrice__c', detailMap);
                newRes.amt9thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_12', 'PlanAmount__c', detailMap);
                newRes.qty9thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_12', 'PlanQty__c', detailMap);
                newRes.price9thDEC              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_12', 'PlanPrice__c', detailMap);
    
                /* 10년차 수량물량 정보 */
                newRes.ttlamt10th                = getMapDecimal(itemkey, 'ru_PlanAmt10th__c', itemMap);
                newRes.ttlqty10th                = getMapDecimal(itemkey, 'ru_PlanQty10th__c', itemMap);
                newRes.ttlprice10th              = getMapDecimal(itemkey, 'fm_AvgPrice10th__c', itemMap);
    
                newRes.amt10thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_01', 'PlanAmount__c', detailMap);
                newRes.qty10thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_01', 'PlanQty__c', detailMap);
                newRes.price10thJAN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_01', 'PlanPrice__c', detailMap);
                newRes.amt10thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_02', 'PlanAmount__c', detailMap);
                newRes.qty10thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_02', 'PlanQty__c', detailMap);
                newRes.price10thFEB              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_02', 'PlanPrice__c', detailMap);
                newRes.amt10thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_03', 'PlanAmount__c', detailMap);
                newRes.qty10thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_03', 'PlanQty__c', detailMap);
                newRes.price10thMAR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_03', 'PlanPrice__c', detailMap);
                newRes.amt10thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_04', 'PlanAmount__c', detailMap);
                newRes.qty10thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_04', 'PlanQty__c', detailMap);
                newRes.price10thAPR              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_04', 'PlanPrice__c', detailMap);
                newRes.amt10thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_05', 'PlanAmount__c', detailMap);
                newRes.qty10thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_05', 'PlanQty__c', detailMap);
                newRes.price10thMAY              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_05', 'PlanPrice__c', detailMap);
                newRes.amt10thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_06', 'PlanAmount__c', detailMap);
                newRes.qty10thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_06', 'PlanQty__c', detailMap);
                newRes.price10thJUN              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_06', 'PlanPrice__c', detailMap);
                newRes.amt10thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_07', 'PlanAmount__c', detailMap);
                newRes.qty10thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_07', 'PlanQty__c', detailMap);
                newRes.price10thJUL              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_07', 'PlanPrice__c', detailMap);
                newRes.amt10thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_08', 'PlanAmount__c', detailMap);
                newRes.qty10thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_08', 'PlanQty__c', detailMap);
                newRes.price10thAUG              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_08', 'PlanPrice__c', detailMap);
                newRes.amt10thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_09', 'PlanAmount__c', detailMap);
                newRes.qty10thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_09', 'PlanQty__c', detailMap);
                newRes.price10thSEP              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_09', 'PlanPrice__c', detailMap);
                newRes.amt10thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_10', 'PlanAmount__c', detailMap);
                newRes.qty10thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_10', 'PlanQty__c', detailMap);
                newRes.price10thOCT              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_10', 'PlanPrice__c', detailMap);
                newRes.amt10thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_11', 'PlanAmount__c', detailMap);
                newRes.qty10thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_11', 'PlanQty__c', detailMap);
                newRes.price10thNOV              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_11', 'PlanPrice__c', detailMap);
                newRes.amt10thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_12', 'PlanAmount__c', detailMap);
                newRes.qty10thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_12', 'PlanQty__c', detailMap);
                newRes.price10thDEC              = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_12', 'PlanPrice__c', detailMap);
    
                recordList.add(newRes);
            }
            
        }

        return recordList;
    }

    /**
     * @description init 메소드 : 현재 Project에 매핑되어 있는 SalesPlan의 ID List를 리턴
     *              Set<Id>를 리턴할 수 없어 List<String>으로 작성
     * @param 화면의 record Id
     * @return List<String>
     */
    @AuraEnabled
    public static List<String> getProjectSalesPlanId(Id recordId) {
        List<String> resListString = new List<String>();
    
        String query = 'SELECT';
        query += ' Id, l_Project__c, l_SalesPlan__c';
        query += ' FROM VS_ProjectSalesPlan__c';
        query += ' WHERE l_Project__c = :recordId';
        query += ' ORDER BY CreatedDate ASC';
        System.debug('getProjectSalesPlan Query');
        System.debug(query);
        List<VS_ProjectSalesPlan__c> listPjtSalesPlan = Database.query(query);        

        for(VS_ProjectSalesPlan__c pjtSalesPlan : listPjtSalesPlan){
            resListString.add(pjtSalesPlan.l_SalesPlan__c );
        }

        return resListString;
    }

    /**
     * @description ProjectSalesPlan의 Item 목록을 가져온다.
     * @param 현재 Project에 매핑되어 있는 SalesPlan들
     * @return Map<String,Object>
     */
    @AuraEnabled
    public static Map<String,Object> getSalesPlanItem(List<String> paramListId) {
        Map<String,Object> resMap = new Map<String,Object>();

        Integer pjtStartYear = null;
        Integer pjtEndYear = null;
        Integer pjtTerm = null;

        String query = 'SELECT';
        // 견적제품 기본 정보
        query += ' Id, CurrencyISOCode, SOP__c, EOP__c,';
        query += ' l_SalesPlan__c, l_SalesPlan__r.l_Opportunity__c, l_OpportunityItem__c, l_OpportunityItem__r.Name,';
        query += ' fm_ProjectName__c, fm_OpportunityName__c, fm_OpportunityItemName__c, fm_QuoteName__c, ru_cntDetail__c,';
        query += ' Corporate__c, ProductionType__c, Incoterms__c, DLocation__c, ProfitabilityItemName__c, InitialSalesPrice__c,';
         // 견적제품 수량물량 정보 : 전체/년도별
        query += ' ru_TotalQuantity__c, ru_TotalAmount__c, fm_AveragePrice__c,';
        query += ' ru_PlanAmt1st__c, ru_PlanQty1st__c, fm_AvgPrice1st__c, ru_PlanAmt2nd__c, ru_PlanQty2nd__c, fm_AvgPrice2nd__c, ru_PlanAmt3rd__c, ru_PlanQty3rd__c, fm_AvgPrice3rd__c,';
        query += ' ru_PlanAmt4th__c, ru_PlanQty4th__c, fm_AvgPrice4th__c, ru_PlanAmt5th__c, ru_PlanQty5th__c, fm_AvgPrice5th__c, ru_PlanAmt6th__c, ru_PlanQty6th__c, fm_AvgPrice6th__c,';
        query += ' ru_PlanAmt7th__c, ru_PlanQty7th__c, fm_AvgPrice7th__c, ru_PlanAmt8th__c, ru_PlanQty8th__c, fm_AvgPrice8th__c, ru_PlanAmt9th__c, ru_PlanQty9th__c, fm_AvgPrice9th__c,';
        query += ' ru_PlanAmt10th__c, ru_PlanQty10th__c, fm_AvgPrice10th__c';
        query += ' FROM VS_SalesPlanItem__c';
        query += ' WHERE l_SalesPlan__r.isProjectSalesPlan__c = true';
        query += ' AND l_SalesPlan__c IN :paramListId';
        query += ' ORDER By fm_OpportunityItemName__c, fm_OpportunityName__c ASC';
        System.debug('getSalesPlanItem Query');
        System.debug(query);

        List<VS_SalesPlanItem__c> resList = Database.query(query);

        for(VS_SalesPlanItem__c res : resList){
            if(pjtStartYear == null){
                pjtStartYear = (res.SOP__c).year();
            }else if(pjtStartYear > (res.SOP__c).year()){
                pjtStartYear = (res.SOP__c).year();
            }
            if(pjtEndYear == null){
                pjtEndYear = (res.EOP__c).year();
            }else if(pjtEndYear < (res.EOP__c).year()){
                pjtEndYear = (res.EOP__c).year();
            }
        }
        
        resMap.put('pjtStartYear',pjtStartYear);
        resMap.put('pjtTerm',pjtEndYear-pjtStartYear+1);
        resMap.put('itemListSize',resList.Size());
        resMap.put('itemList',resList);

        return resMap;
    }
    
    /**
     * @description ProjectSalesPlan Item의 상세 목록을 가져온다.
     * @param 현재 Project에 매핑되어 있는 SalesPlan들
     * @return Map<String,Object>
     */
    @AuraEnabled
    public static Map<String,Object> getSalesPlanDetail(List<String> paramListId) {
        Map<String,Object> resMap = new Map<String,Object>();

        String query = 'SELECT';
        query += ' Id,';
        // 견적제품 기본 정보
        query += ' l_SalesPlan__c, l_SalesPlan__r.l_Opportunity__c, l_SalesPlanItem__c, l_SalesPlanItem__r.l_OpportunityItem__c, fm_OpportunityName__c,';
        // 견적제품 년월별 수량물량 정보
        query += ' Year__c, Month__c, PlanQty__c, PlanPrice__c, PlanAmount__c, NoOfYears__c';
        query += ' FROM VS_SalesPlanDetail__c';
        query += ' WHERE l_SalesPlan__r.isProjectSalesPlan__c = true';
        query += ' AND l_SalesPlan__c IN :paramListId';
        query += ' ORDER By fm_OpportunityName__c, l_SalesPlanItem__c, Year__c, Month__c  ASC';
        System.debug('getSalesPlanDetail Query');
        System.debug(query);
        
        List<VS_SalesPlanDetail__c> resList = Database.query(query);
        resMap.put('detailListSize',resList.Size());
        resMap.put('detailList',resList);

        return resMap;
    }

    /**
     * @description Map에 key값으로 SObject를 가져오고 null처리 함. -> util성 Method로 추후 util class에 추가 필요
     * @param Map의 key값, target Map
     * @return SObject, null일경우엔 null 리턴
     */
    private static SObject getMapSObject(String key, Map<String,SObject> targetMap){
        SObject value = targetMap.get(key);
        return value == null ? null : value;
    }

    /**
     * @description Map<String,SObject>에서 SObject의 String field 리턴하고 null 처리 함.  -> util성 Method로 추후 util class에 추가 필요
     * @param Map의 key값, field명, target Map
     * @return String, null일경우엔 null 리턴
     */
    private static String getMapString(String key, String fieldName, Map<String,SObject> targetMap){
        String resValue = '';
        Map<String, Object> mapSObj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize( getMapSObject(key, targetMap) ));

        if(mapSObj != null){
            resValue = String.valueOf( mapSObj.get(fieldName) );
        }
        return resValue == null ? null : resValue;
    }

    /**
     * @description Map<String,SObject>에서 SObject의 Decimal field 리턴하고 null 처리 함.  -> util성 Method로 추후 util class에 추가 필요
     * @param Map의 key값, field명, target Map
     * @return Decimal, null일경우엔 null 리턴
     */
    private static Decimal getMapDecimal(String key, String fieldName, Map<String,SObject> targetMap){
        Decimal resValue = 0;
        Map<String, Object> mapSObj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize( getMapSObject(key, targetMap) ));

        if(mapSObj != null){
            resValue = (Decimal)mapSObj.get(fieldName);
        }
        return resValue == null ? null : resValue;
    }

    /** 화면에 전달할 결과값 warraper class */
    public class InitCls {
        @AuraEnabled public String className = 'RealGridProjectSalesPlanSampleController';
        @AuraEnabled public List<String> pjtSalesPlanIdList;
        @AuraEnabled public Map<String, SchemaUtil.ObjectCls> objectDescribeMap = SchemaUtil.getDescribedObjectMap(new Set<String>{'VS_SalesPlanItem__c','VS_SalesPlanDetail__c'});
    }

    /** 화면에 표시할 결과 wrapper class **/
    public class ResProjectSalesPlan {
        @AuraEnabled public String id;

        /* 견적제품 기본 정보 */
        @AuraEnabled public String quoteProdName;
        @AuraEnabled public String opptyName;
        @AuraEnabled public String coroprate;
        @AuraEnabled public String productionType;
        @AuraEnabled public String incoterms;
        @AuraEnabled public String dLocation;
        @AuraEnabled public String currencyIsoCode;

        /* 견적제품 전체 수량물량 정보 */
        @AuraEnabled public Decimal ttlAmt;
        @AuraEnabled public Decimal ttlQty;
        @AuraEnabled public Decimal ttlPrice;

        /* 1년차 수량물량 정보 */
        @AuraEnabled public Decimal ttlamt1st;
        @AuraEnabled public Decimal ttlqty1st;
        @AuraEnabled public Decimal ttlprice1st;

        @AuraEnabled public Decimal amt1stJAN;
        @AuraEnabled public Decimal qty1stJAN;
        @AuraEnabled public Decimal price1stJAN;
        @AuraEnabled public Decimal amt1stFEB;
        @AuraEnabled public Decimal qty1stFEB;
        @AuraEnabled public Decimal price1stFEB;
        @AuraEnabled public Decimal amt1stMAR;
        @AuraEnabled public Decimal qty1stMAR;
        @AuraEnabled public Decimal price1stMAR;
        @AuraEnabled public Decimal amt1stAPR;
        @AuraEnabled public Decimal qty1stAPR;
        @AuraEnabled public Decimal price1stAPR;
        @AuraEnabled public Decimal amt1stMAY;
        @AuraEnabled public Decimal qty1stMAY;
        @AuraEnabled public Decimal price1stMAY;
        @AuraEnabled public Decimal amt1stJUN;
        @AuraEnabled public Decimal qty1stJUN;
        @AuraEnabled public Decimal price1stJUN;
        @AuraEnabled public Decimal amt1stJUL;
        @AuraEnabled public Decimal qty1stJUL;
        @AuraEnabled public Decimal price1stJUL;
        @AuraEnabled public Decimal amt1stAUG;
        @AuraEnabled public Decimal qty1stAUG;
        @AuraEnabled public Decimal price1stAUG;
        @AuraEnabled public Decimal amt1stSEP;
        @AuraEnabled public Decimal qty1stSEP;
        @AuraEnabled public Decimal price1stSEP;
        @AuraEnabled public Decimal amt1stOCT;
        @AuraEnabled public Decimal qty1stOCT;
        @AuraEnabled public Decimal price1stOCT;
        @AuraEnabled public Decimal amt1stNOV;
        @AuraEnabled public Decimal qty1stNOV;
        @AuraEnabled public Decimal price1stNOV;
        @AuraEnabled public Decimal amt1stDEC;
        @AuraEnabled public Decimal qty1stDEC;
        @AuraEnabled public Decimal price1stDEC;

        /* 2년차 수량물량 정보 */
        @AuraEnabled public Decimal ttlamt2nd;
        @AuraEnabled public Decimal ttlqty2nd;
        @AuraEnabled public Decimal ttlprice2nd;

        @AuraEnabled public Decimal amt2ndJAN;
        @AuraEnabled public Decimal qty2ndJAN;
        @AuraEnabled public Decimal price2ndJAN;
        @AuraEnabled public Decimal amt2ndFEB;
        @AuraEnabled public Decimal qty2ndFEB;
        @AuraEnabled public Decimal price2ndFEB;
        @AuraEnabled public Decimal amt2ndMAR;
        @AuraEnabled public Decimal qty2ndMAR;
        @AuraEnabled public Decimal price2ndMAR;
        @AuraEnabled public Decimal amt2ndAPR;
        @AuraEnabled public Decimal qty2ndAPR;
        @AuraEnabled public Decimal price2ndAPR;
        @AuraEnabled public Decimal amt2ndMAY;
        @AuraEnabled public Decimal qty2ndMAY;
        @AuraEnabled public Decimal price2ndMAY;
        @AuraEnabled public Decimal amt2ndJUN;
        @AuraEnabled public Decimal qty2ndJUN;
        @AuraEnabled public Decimal price2ndJUN;
        @AuraEnabled public Decimal amt2ndJUL;
        @AuraEnabled public Decimal qty2ndJUL;
        @AuraEnabled public Decimal price2ndJUL;
        @AuraEnabled public Decimal amt2ndAUG;
        @AuraEnabled public Decimal qty2ndAUG;
        @AuraEnabled public Decimal price2ndAUG;
        @AuraEnabled public Decimal amt2ndSEP;
        @AuraEnabled public Decimal qty2ndSEP;
        @AuraEnabled public Decimal price2ndSEP;
        @AuraEnabled public Decimal amt2ndOCT;
        @AuraEnabled public Decimal qty2ndOCT;
        @AuraEnabled public Decimal price2ndOCT;
        @AuraEnabled public Decimal amt2ndNOV;
        @AuraEnabled public Decimal qty2ndNOV;
        @AuraEnabled public Decimal price2ndNOV;
        @AuraEnabled public Decimal amt2ndDEC;
        @AuraEnabled public Decimal qty2ndDEC;
        @AuraEnabled public Decimal price2ndDEC;

        /* 3년차 수량물량 정보 */
        @AuraEnabled public Decimal ttlamt3rd;
        @AuraEnabled public Decimal ttlqty3rd;
        @AuraEnabled public Decimal ttlprice3rd;

        @AuraEnabled public Decimal amt3rdJAN;
        @AuraEnabled public Decimal qty3rdJAN;
        @AuraEnabled public Decimal price3rdJAN;
        @AuraEnabled public Decimal amt3rdFEB;
        @AuraEnabled public Decimal qty3rdFEB;
        @AuraEnabled public Decimal price3rdFEB;
        @AuraEnabled public Decimal amt3rdMAR;
        @AuraEnabled public Decimal qty3rdMAR;
        @AuraEnabled public Decimal price3rdMAR;
        @AuraEnabled public Decimal amt3rdAPR;
        @AuraEnabled public Decimal qty3rdAPR;
        @AuraEnabled public Decimal price3rdAPR;
        @AuraEnabled public Decimal amt3rdMAY;
        @AuraEnabled public Decimal qty3rdMAY;
        @AuraEnabled public Decimal price3rdMAY;
        @AuraEnabled public Decimal amt3rdJUN;
        @AuraEnabled public Decimal qty3rdJUN;
        @AuraEnabled public Decimal price3rdJUN;
        @AuraEnabled public Decimal amt3rdJUL;
        @AuraEnabled public Decimal qty3rdJUL;
        @AuraEnabled public Decimal price3rdJUL;
        @AuraEnabled public Decimal amt3rdAUG;
        @AuraEnabled public Decimal qty3rdAUG;
        @AuraEnabled public Decimal price3rdAUG;
        @AuraEnabled public Decimal amt3rdSEP;
        @AuraEnabled public Decimal qty3rdSEP;
        @AuraEnabled public Decimal price3rdSEP;
        @AuraEnabled public Decimal amt3rdOCT;
        @AuraEnabled public Decimal qty3rdOCT;
        @AuraEnabled public Decimal price3rdOCT;
        @AuraEnabled public Decimal amt3rdNOV;
        @AuraEnabled public Decimal qty3rdNOV;
        @AuraEnabled public Decimal price3rdNOV;
        @AuraEnabled public Decimal amt3rdDEC;
        @AuraEnabled public Decimal qty3rdDEC;
        @AuraEnabled public Decimal price3rdDEC;

        /* 4년차 수량물량 정보 */
        @AuraEnabled public Decimal ttlamt4th;
        @AuraEnabled public Decimal ttlqty4th;
        @AuraEnabled public Decimal ttlprice4th;

        @AuraEnabled public Decimal amt4thJAN;
        @AuraEnabled public Decimal qty4thJAN;
        @AuraEnabled public Decimal price4thJAN;
        @AuraEnabled public Decimal amt4thFEB;
        @AuraEnabled public Decimal qty4thFEB;
        @AuraEnabled public Decimal price4thFEB;
        @AuraEnabled public Decimal amt4thMAR;
        @AuraEnabled public Decimal qty4thMAR;
        @AuraEnabled public Decimal price4thMAR;
        @AuraEnabled public Decimal amt4thAPR;
        @AuraEnabled public Decimal qty4thAPR;
        @AuraEnabled public Decimal price4thAPR;
        @AuraEnabled public Decimal amt4thMAY;
        @AuraEnabled public Decimal qty4thMAY;
        @AuraEnabled public Decimal price4thMAY;
        @AuraEnabled public Decimal amt4thJUN;
        @AuraEnabled public Decimal qty4thJUN;
        @AuraEnabled public Decimal price4thJUN;
        @AuraEnabled public Decimal amt4thJUL;
        @AuraEnabled public Decimal qty4thJUL;
        @AuraEnabled public Decimal price4thJUL;
        @AuraEnabled public Decimal amt4thAUG;
        @AuraEnabled public Decimal qty4thAUG;
        @AuraEnabled public Decimal price4thAUG;
        @AuraEnabled public Decimal amt4thSEP;
        @AuraEnabled public Decimal qty4thSEP;
        @AuraEnabled public Decimal price4thSEP;
        @AuraEnabled public Decimal amt4thOCT;
        @AuraEnabled public Decimal qty4thOCT;
        @AuraEnabled public Decimal price4thOCT;
        @AuraEnabled public Decimal amt4thNOV;
        @AuraEnabled public Decimal qty4thNOV;
        @AuraEnabled public Decimal price4thNOV;
        @AuraEnabled public Decimal amt4thDEC;
        @AuraEnabled public Decimal qty4thDEC;
        @AuraEnabled public Decimal price4thDEC;

        /* 5년차 수량물량 정보 */
        @AuraEnabled public Decimal ttlamt5th;
        @AuraEnabled public Decimal ttlqty5th;
        @AuraEnabled public Decimal ttlprice5th;

        @AuraEnabled public Decimal amt5thJAN;
        @AuraEnabled public Decimal qty5thJAN;
        @AuraEnabled public Decimal price5thJAN;
        @AuraEnabled public Decimal amt5thFEB;
        @AuraEnabled public Decimal qty5thFEB;
        @AuraEnabled public Decimal price5thFEB;
        @AuraEnabled public Decimal amt5thMAR;
        @AuraEnabled public Decimal qty5thMAR;
        @AuraEnabled public Decimal price5thMAR;
        @AuraEnabled public Decimal amt5thAPR;
        @AuraEnabled public Decimal qty5thAPR;
        @AuraEnabled public Decimal price5thAPR;
        @AuraEnabled public Decimal amt5thMAY;
        @AuraEnabled public Decimal qty5thMAY;
        @AuraEnabled public Decimal price5thMAY;
        @AuraEnabled public Decimal amt5thJUN;
        @AuraEnabled public Decimal qty5thJUN;
        @AuraEnabled public Decimal price5thJUN;
        @AuraEnabled public Decimal amt5thJUL;
        @AuraEnabled public Decimal qty5thJUL;
        @AuraEnabled public Decimal price5thJUL;
        @AuraEnabled public Decimal amt5thAUG;
        @AuraEnabled public Decimal qty5thAUG;
        @AuraEnabled public Decimal price5thAUG;
        @AuraEnabled public Decimal amt5thSEP;
        @AuraEnabled public Decimal qty5thSEP;
        @AuraEnabled public Decimal price5thSEP;
        @AuraEnabled public Decimal amt5thOCT;
        @AuraEnabled public Decimal qty5thOCT;
        @AuraEnabled public Decimal price5thOCT;
        @AuraEnabled public Decimal amt5thNOV;
        @AuraEnabled public Decimal qty5thNOV;
        @AuraEnabled public Decimal price5thNOV;
        @AuraEnabled public Decimal amt5thDEC;
        @AuraEnabled public Decimal qty5thDEC;
        @AuraEnabled public Decimal price5thDEC;

        /* 6년차 수량물량 정보 */
        @AuraEnabled public Decimal ttlamt6th;
        @AuraEnabled public Decimal ttlqty6th;
        @AuraEnabled public Decimal ttlprice6th;

        @AuraEnabled public Decimal amt6thJAN;
        @AuraEnabled public Decimal qty6thJAN;
        @AuraEnabled public Decimal price6thJAN;
        @AuraEnabled public Decimal amt6thFEB;
        @AuraEnabled public Decimal qty6thFEB;
        @AuraEnabled public Decimal price6thFEB;
        @AuraEnabled public Decimal amt6thMAR;
        @AuraEnabled public Decimal qty6thMAR;
        @AuraEnabled public Decimal price6thMAR;
        @AuraEnabled public Decimal amt6thAPR;
        @AuraEnabled public Decimal qty6thAPR;
        @AuraEnabled public Decimal price6thAPR;
        @AuraEnabled public Decimal amt6thMAY;
        @AuraEnabled public Decimal qty6thMAY;
        @AuraEnabled public Decimal price6thMAY;
        @AuraEnabled public Decimal amt6thJUN;
        @AuraEnabled public Decimal qty6thJUN;
        @AuraEnabled public Decimal price6thJUN;
        @AuraEnabled public Decimal amt6thJUL;
        @AuraEnabled public Decimal qty6thJUL;
        @AuraEnabled public Decimal price6thJUL;
        @AuraEnabled public Decimal amt6thAUG;
        @AuraEnabled public Decimal qty6thAUG;
        @AuraEnabled public Decimal price6thAUG;
        @AuraEnabled public Decimal amt6thSEP;
        @AuraEnabled public Decimal qty6thSEP;
        @AuraEnabled public Decimal price6thSEP;
        @AuraEnabled public Decimal amt6thOCT;
        @AuraEnabled public Decimal qty6thOCT;
        @AuraEnabled public Decimal price6thOCT;
        @AuraEnabled public Decimal amt6thNOV;
        @AuraEnabled public Decimal qty6thNOV;
        @AuraEnabled public Decimal price6thNOV;
        @AuraEnabled public Decimal amt6thDEC;
        @AuraEnabled public Decimal qty6thDEC;
        @AuraEnabled public Decimal price6thDEC;

        /* 7년차 수량물량 정보 */
        @AuraEnabled public Decimal ttlamt7th;
        @AuraEnabled public Decimal ttlqty7th;
        @AuraEnabled public Decimal ttlprice7th;

        @AuraEnabled public Decimal amt7thJAN;
        @AuraEnabled public Decimal qty7thJAN;
        @AuraEnabled public Decimal price7thJAN;
        @AuraEnabled public Decimal amt7thFEB;
        @AuraEnabled public Decimal qty7thFEB;
        @AuraEnabled public Decimal price7thFEB;
        @AuraEnabled public Decimal amt7thMAR;
        @AuraEnabled public Decimal qty7thMAR;
        @AuraEnabled public Decimal price7thMAR;
        @AuraEnabled public Decimal amt7thAPR;
        @AuraEnabled public Decimal qty7thAPR;
        @AuraEnabled public Decimal price7thAPR;
        @AuraEnabled public Decimal amt7thMAY;
        @AuraEnabled public Decimal qty7thMAY;
        @AuraEnabled public Decimal price7thMAY;
        @AuraEnabled public Decimal amt7thJUN;
        @AuraEnabled public Decimal qty7thJUN;
        @AuraEnabled public Decimal price7thJUN;
        @AuraEnabled public Decimal amt7thJUL;
        @AuraEnabled public Decimal qty7thJUL;
        @AuraEnabled public Decimal price7thJUL;
        @AuraEnabled public Decimal amt7thAUG;
        @AuraEnabled public Decimal qty7thAUG;
        @AuraEnabled public Decimal price7thAUG;
        @AuraEnabled public Decimal amt7thSEP;
        @AuraEnabled public Decimal qty7thSEP;
        @AuraEnabled public Decimal price7thSEP;
        @AuraEnabled public Decimal amt7thOCT;
        @AuraEnabled public Decimal qty7thOCT;
        @AuraEnabled public Decimal price7thOCT;
        @AuraEnabled public Decimal amt7thNOV;
        @AuraEnabled public Decimal qty7thNOV;
        @AuraEnabled public Decimal price7thNOV;
        @AuraEnabled public Decimal amt7thDEC;
        @AuraEnabled public Decimal qty7thDEC;
        @AuraEnabled public Decimal price7thDEC;

        /* 8년차 수량물량 정보 */
        @AuraEnabled public Decimal ttlamt8th;
        @AuraEnabled public Decimal ttlqty8th;
        @AuraEnabled public Decimal ttlprice8th;

        @AuraEnabled public Decimal amt8thJAN;
        @AuraEnabled public Decimal qty8thJAN;
        @AuraEnabled public Decimal price8thJAN;
        @AuraEnabled public Decimal amt8thFEB;
        @AuraEnabled public Decimal qty8thFEB;
        @AuraEnabled public Decimal price8thFEB;
        @AuraEnabled public Decimal amt8thMAR;
        @AuraEnabled public Decimal qty8thMAR;
        @AuraEnabled public Decimal price8thMAR;
        @AuraEnabled public Decimal amt8thAPR;
        @AuraEnabled public Decimal qty8thAPR;
        @AuraEnabled public Decimal price8thAPR;
        @AuraEnabled public Decimal amt8thMAY;
        @AuraEnabled public Decimal qty8thMAY;
        @AuraEnabled public Decimal price8thMAY;
        @AuraEnabled public Decimal amt8thJUN;
        @AuraEnabled public Decimal qty8thJUN;
        @AuraEnabled public Decimal price8thJUN;
        @AuraEnabled public Decimal amt8thJUL;
        @AuraEnabled public Decimal qty8thJUL;
        @AuraEnabled public Decimal price8thJUL;
        @AuraEnabled public Decimal amt8thAUG;
        @AuraEnabled public Decimal qty8thAUG;
        @AuraEnabled public Decimal price8thAUG;
        @AuraEnabled public Decimal amt8thSEP;
        @AuraEnabled public Decimal qty8thSEP;
        @AuraEnabled public Decimal price8thSEP;
        @AuraEnabled public Decimal amt8thOCT;
        @AuraEnabled public Decimal qty8thOCT;
        @AuraEnabled public Decimal price8thOCT;
        @AuraEnabled public Decimal amt8thNOV;
        @AuraEnabled public Decimal qty8thNOV;
        @AuraEnabled public Decimal price8thNOV;
        @AuraEnabled public Decimal amt8thDEC;
        @AuraEnabled public Decimal qty8thDEC;
        @AuraEnabled public Decimal price8thDEC;

        /* 9년차 수량물량 정보 */
        @AuraEnabled public Decimal ttlamt9th;
        @AuraEnabled public Decimal ttlqty9th;
        @AuraEnabled public Decimal ttlprice9th;

        @AuraEnabled public Decimal amt9thJAN;
        @AuraEnabled public Decimal qty9thJAN;
        @AuraEnabled public Decimal price9thJAN;
        @AuraEnabled public Decimal amt9thFEB;
        @AuraEnabled public Decimal qty9thFEB;
        @AuraEnabled public Decimal price9thFEB;
        @AuraEnabled public Decimal amt9thMAR;
        @AuraEnabled public Decimal qty9thMAR;
        @AuraEnabled public Decimal price9thMAR;
        @AuraEnabled public Decimal amt9thAPR;
        @AuraEnabled public Decimal qty9thAPR;
        @AuraEnabled public Decimal price9thAPR;
        @AuraEnabled public Decimal amt9thMAY;
        @AuraEnabled public Decimal qty9thMAY;
        @AuraEnabled public Decimal price9thMAY;
        @AuraEnabled public Decimal amt9thJUN;
        @AuraEnabled public Decimal qty9thJUN;
        @AuraEnabled public Decimal price9thJUN;
        @AuraEnabled public Decimal amt9thJUL;
        @AuraEnabled public Decimal qty9thJUL;
        @AuraEnabled public Decimal price9thJUL;
        @AuraEnabled public Decimal amt9thAUG;
        @AuraEnabled public Decimal qty9thAUG;
        @AuraEnabled public Decimal price9thAUG;
        @AuraEnabled public Decimal amt9thSEP;
        @AuraEnabled public Decimal qty9thSEP;
        @AuraEnabled public Decimal price9thSEP;
        @AuraEnabled public Decimal amt9thOCT;
        @AuraEnabled public Decimal qty9thOCT;
        @AuraEnabled public Decimal price9thOCT;
        @AuraEnabled public Decimal amt9thNOV;
        @AuraEnabled public Decimal qty9thNOV;
        @AuraEnabled public Decimal price9thNOV;
        @AuraEnabled public Decimal amt9thDEC;
        @AuraEnabled public Decimal qty9thDEC;
        @AuraEnabled public Decimal price9thDEC;

        /* 10년차 수량물량 정보 */
        @AuraEnabled public Decimal ttlamt10th;
        @AuraEnabled public Decimal ttlqty10th;
        @AuraEnabled public Decimal ttlprice10th;

        @AuraEnabled public Decimal amt10thJAN;
        @AuraEnabled public Decimal qty10thJAN;
        @AuraEnabled public Decimal price10thJAN;
        @AuraEnabled public Decimal amt10thFEB;
        @AuraEnabled public Decimal qty10thFEB;
        @AuraEnabled public Decimal price10thFEB;
        @AuraEnabled public Decimal amt10thMAR;
        @AuraEnabled public Decimal qty10thMAR;
        @AuraEnabled public Decimal price10thMAR;
        @AuraEnabled public Decimal amt10thAPR;
        @AuraEnabled public Decimal qty10thAPR;
        @AuraEnabled public Decimal price10thAPR;
        @AuraEnabled public Decimal amt10thMAY;
        @AuraEnabled public Decimal qty10thMAY;
        @AuraEnabled public Decimal price10thMAY;
        @AuraEnabled public Decimal amt10thJUN;
        @AuraEnabled public Decimal qty10thJUN;
        @AuraEnabled public Decimal price10thJUN;
        @AuraEnabled public Decimal amt10thJUL;
        @AuraEnabled public Decimal qty10thJUL;
        @AuraEnabled public Decimal price10thJUL;
        @AuraEnabled public Decimal amt10thAUG;
        @AuraEnabled public Decimal qty10thAUG;
        @AuraEnabled public Decimal price10thAUG;
        @AuraEnabled public Decimal amt10thSEP;
        @AuraEnabled public Decimal qty10thSEP;
        @AuraEnabled public Decimal price10thSEP;
        @AuraEnabled public Decimal amt10thOCT;
        @AuraEnabled public Decimal qty10thOCT;
        @AuraEnabled public Decimal price10thOCT;
        @AuraEnabled public Decimal amt10thNOV;
        @AuraEnabled public Decimal qty10thNOV;
        @AuraEnabled public Decimal price10thNOV;
        @AuraEnabled public Decimal amt10thDEC;
        @AuraEnabled public Decimal qty10thDEC;
        @AuraEnabled public Decimal price10thDEC;
    }
    
}