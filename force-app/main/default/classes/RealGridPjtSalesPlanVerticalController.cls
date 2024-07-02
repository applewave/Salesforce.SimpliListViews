/**************************************************************************************** 
 * File Name    : RealGridPjtSalesPlanVerticalController
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
public with sharing class RealGridPjtSalesPlanVerticalController {

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
    
                ResProjectSalesPlan newResPrice     = new ResProjectSalesPlan();        
                ResProjectSalesPlan newResQty       = new ResProjectSalesPlan();       
                ResProjectSalesPlan newResAMT       = new ResProjectSalesPlan();       
                
                /* 견적제품 기본 정보 */
                newResPrice.quoteProdName           = getMapString(itemKey, 'fm_OpportunityItemName__c', itemMap);
                newResPrice.opptyName               = getMapString(itemKey, 'fm_OpportunityName__c', itemMap);
                newResPrice.coroprate               = getMapString(itemKey, 'Corporate__c', itemMap);
                newResPrice.productionType          = getMapString(itemKey, 'ProductionType__c', itemMap);
                newResPrice.incoterms               = getMapString(itemKey, 'Incoterms__c', itemMap);
                newResPrice.dLocation               = getMapString(itemKey, 'DLocation__c', itemMap);
                newResPrice.currencyIsoCode         = getMapString(itemKey, 'CurrencyIsoCode', itemMap);

                newResQty.quoteProdName             = newResPrice.quoteProdName;
                newResQty.opptyName                 = newResPrice.opptyName;
                newResQty.coroprate                 = newResPrice.coroprate;
                newResQty.productionType            = newResPrice.productionType;
                newResQty.incoterms                 = newResPrice.incoterms;
                newResQty.dLocation                 = newResPrice.dLocation;
                newResQty.currencyIsoCode           = newResPrice.currencyIsoCode;

                newResAMT.quoteProdName             = newResPrice.quoteProdName;
                newResAMT.opptyName                 = newResPrice.opptyName;
                newResAMT.coroprate                 = newResPrice.coroprate;
                newResAMT.productionType            = newResPrice.productionType;
                newResAMT.incoterms                 = newResPrice.incoterms;
                newResAMT.dLocation                 = newResPrice.dLocation;
                newResAMT.currencyIsoCode           = newResPrice.currencyIsoCode;
    
                /* 견적제품 전체 수량물량 정보 */
                newResPrice.div                     = 'Price';
                newResPrice.ttl                     = getMapDecimal(itemKey, 'fm_AveragePrice__c', itemMap);
                newResQty.div                       = 'Qty';
                newResQty.ttl                       = getMapDecimal(itemKey, 'ru_TotalQuantity__c', itemMap);
                newResAMT.div                       = 'Amt';
                newResAMT.ttl                       = getMapDecimal(itemKey, 'ru_TotalAmount__c', itemMap);
    
                /* 1년차 수량물량 정보 */
                newResPrice.ttl1st                  = getMapDecimal(itemkey, 'fm_AvgPrice1st__c', itemMap);
                newResQty.ttl1st                    = getMapDecimal(itemkey, 'ru_PlanQty1st__c', itemMap);
                newResAMT.ttl1st                    = getMapDecimal(itemkey, 'ru_PlanAmt1st__c', itemMap);
                
                newResPrice.no1stJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_01', 'PlanPrice__c', detailMap);
                newResQty.no1stJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_01', 'PlanQty__c', detailMap);
                newResAMT.no1stJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_01', 'PlanAmount__c', detailMap);
                newResPrice.no1stFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_02', 'PlanPrice__c', detailMap);
                newResQty.no1stFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_02', 'PlanQty__c', detailMap);
                newResAMT.no1stFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_02', 'PlanAmount__c', detailMap);
                newResPrice.no1stMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_03', 'PlanPrice__c', detailMap);
                newResQty.no1stMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_03', 'PlanQty__c', detailMap);
                newResAMT.no1stMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_03', 'PlanAmount__c', detailMap);
                newResPrice.no1stAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_04', 'PlanPrice__c', detailMap);
                newResQty.no1stAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_04', 'PlanQty__c', detailMap);
                newResAMT.no1stAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_04', 'PlanAmount__c', detailMap);
                newResPrice.no1stMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_05', 'PlanPrice__c', detailMap);
                newResQty.no1stMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_05', 'PlanQty__c', detailMap);
                newResAMT.no1stMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_05', 'PlanAmount__c', detailMap);
                newResPrice.no1stJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_06', 'PlanPrice__c', detailMap);
                newResQty.no1stJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_06', 'PlanQty__c', detailMap);
                newResAMT.no1stJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_06', 'PlanAmount__c', detailMap);
                newResPrice.no1stJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_07', 'PlanPrice__c', detailMap);
                newResQty.no1stJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_07', 'PlanQty__c', detailMap);
                newResAMT.no1stJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_07', 'PlanAmount__c', detailMap);
                newResPrice.no1stAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_08', 'PlanPrice__c', detailMap);
                newResQty.no1stAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_08', 'PlanQty__c', detailMap);
                newResAMT.no1stAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_08', 'PlanAmount__c', detailMap);
                newResPrice.no1stSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_09', 'PlanPrice__c', detailMap);
                newResQty.no1stSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_09', 'PlanQty__c', detailMap);
                newResAMT.no1stSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_09', 'PlanAmount__c', detailMap);
                newResPrice.no1stOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_10', 'PlanPrice__c', detailMap);
                newResQty.no1stOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_10', 'PlanQty__c', detailMap);
                newResAMT.no1stOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_10', 'PlanAmount__c', detailMap);
                newResPrice.no1stNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_11', 'PlanPrice__c', detailMap);
                newResQty.no1stNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_11', 'PlanQty__c', detailMap);
                newResAMT.no1stNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_11', 'PlanAmount__c', detailMap);
                newResPrice.no1stDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_12', 'PlanPrice__c', detailMap);
                newResQty.no1stDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_12', 'PlanQty__c', detailMap);
                newResAMT.no1stDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_12', 'PlanAmount__c', detailMap);

                /* 2년차 수량물량 정보 */
                newResPrice.ttl2nd                  = getMapDecimal(itemkey, 'fm_AvgPrice2nd__c', itemMap);
                newResQty.ttl2nd                    = getMapDecimal(itemkey, 'ru_PlanQty2nd__c', itemMap);
                newResAMT.ttl2nd                    = getMapDecimal(itemkey, 'ru_PlanAmt2nd__c', itemMap);

                newResPrice.no2ndJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_01', 'PlanPrice__c', detailMap);
                newResQty.no2ndJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_01', 'PlanQty__c', detailMap);
                newResAMT.no2ndJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_01', 'PlanAmount__c', detailMap);
                newResPrice.no2ndFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_02', 'PlanPrice__c', detailMap);
                newResQty.no2ndFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_02', 'PlanQty__c', detailMap);
                newResAMT.no2ndFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_02', 'PlanAmount__c', detailMap);
                newResPrice.no2ndMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_03', 'PlanPrice__c', detailMap);
                newResQty.no2ndMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_03', 'PlanQty__c', detailMap);
                newResAMT.no2ndMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_03', 'PlanAmount__c', detailMap);
                newResPrice.no2ndAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_04', 'PlanPrice__c', detailMap);
                newResQty.no2ndAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_04', 'PlanQty__c', detailMap);
                newResAMT.no2ndAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_04', 'PlanAmount__c', detailMap);
                newResPrice.no2ndMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_05', 'PlanPrice__c', detailMap);
                newResQty.no2ndMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_05', 'PlanQty__c', detailMap);
                newResAMT.no2ndMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_05', 'PlanAmount__c', detailMap);
                newResPrice.no2ndJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_06', 'PlanPrice__c', detailMap);
                newResQty.no2ndJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_06', 'PlanQty__c', detailMap);
                newResAMT.no2ndJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_06', 'PlanAmount__c', detailMap);
                newResPrice.no2ndJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_07', 'PlanPrice__c', detailMap);
                newResQty.no2ndJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_07', 'PlanQty__c', detailMap);
                newResAMT.no2ndJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_07', 'PlanAmount__c', detailMap);
                newResPrice.no2ndAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_08', 'PlanPrice__c', detailMap);
                newResQty.no2ndAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_08', 'PlanQty__c', detailMap);
                newResAMT.no2ndAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_08', 'PlanAmount__c', detailMap);
                newResPrice.no2ndSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_09', 'PlanPrice__c', detailMap);
                newResQty.no2ndSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_09', 'PlanQty__c', detailMap);
                newResAMT.no2ndSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_09', 'PlanAmount__c', detailMap);
                newResPrice.no2ndOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_10', 'PlanPrice__c', detailMap);
                newResQty.no2ndOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_10', 'PlanQty__c', detailMap);
                newResAMT.no2ndOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_10', 'PlanAmount__c', detailMap);
                newResPrice.no2ndNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_11', 'PlanPrice__c', detailMap);
                newResQty.no2ndNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_11', 'PlanQty__c', detailMap);
                newResAMT.no2ndNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_11', 'PlanAmount__c', detailMap);
                newResPrice.no2ndDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_12', 'PlanPrice__c', detailMap);
                newResQty.no2ndDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_12', 'PlanQty__c', detailMap);
                newResAMT.no2ndDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+1)+'_12', 'PlanAmount__c', detailMap);

                /* 3년차 수량물량 정보 */
                newResPrice.ttl3rd                  = getMapDecimal(itemkey, 'fm_AvgPrice3rd__c', itemMap);
                newResQty.ttl3rd                    = getMapDecimal(itemkey, 'ru_PlanQty3rd__c', itemMap);
                newResAMT.ttl3rd                    = getMapDecimal(itemkey, 'ru_PlanAmt3rd__c', itemMap);

                newResPrice.no3rdJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_01', 'PlanPrice__c', detailMap);
                newResQty.no3rdJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_01', 'PlanQty__c', detailMap);
                newResAMT.no3rdJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_01', 'PlanAmount__c', detailMap);
                newResPrice.no3rdFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_02', 'PlanPrice__c', detailMap);
                newResQty.no3rdFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_02', 'PlanQty__c', detailMap);
                newResAMT.no3rdFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_02', 'PlanAmount__c', detailMap);
                newResPrice.no3rdMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_03', 'PlanPrice__c', detailMap);
                newResQty.no3rdMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_03', 'PlanQty__c', detailMap);
                newResAMT.no3rdMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_03', 'PlanAmount__c', detailMap);
                newResPrice.no3rdAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_04', 'PlanPrice__c', detailMap);
                newResQty.no3rdAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_04', 'PlanQty__c', detailMap);
                newResAMT.no3rdAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_04', 'PlanAmount__c', detailMap);
                newResPrice.no3rdMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_05', 'PlanPrice__c', detailMap);
                newResQty.no3rdMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_05', 'PlanQty__c', detailMap);
                newResAMT.no3rdMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_05', 'PlanAmount__c', detailMap);
                newResPrice.no3rdJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_06', 'PlanPrice__c', detailMap);
                newResQty.no3rdJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_06', 'PlanQty__c', detailMap);
                newResAMT.no3rdJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_06', 'PlanAmount__c', detailMap);
                newResPrice.no3rdJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_07', 'PlanPrice__c', detailMap);
                newResQty.no3rdJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_07', 'PlanQty__c', detailMap);
                newResAMT.no3rdJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_07', 'PlanAmount__c', detailMap);
                newResPrice.no3rdAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_08', 'PlanPrice__c', detailMap);
                newResQty.no3rdAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_08', 'PlanQty__c', detailMap);
                newResAMT.no3rdAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_08', 'PlanAmount__c', detailMap);
                newResPrice.no3rdSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_09', 'PlanPrice__c', detailMap);
                newResQty.no3rdSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_09', 'PlanQty__c', detailMap);
                newResAMT.no3rdSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_09', 'PlanAmount__c', detailMap);
                newResPrice.no3rdOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_10', 'PlanPrice__c', detailMap);
                newResQty.no3rdOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_10', 'PlanQty__c', detailMap);
                newResAMT.no3rdOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_10', 'PlanAmount__c', detailMap);
                newResPrice.no3rdNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_11', 'PlanPrice__c', detailMap);
                newResQty.no3rdNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_11', 'PlanQty__c', detailMap);
                newResAMT.no3rdNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_11', 'PlanAmount__c', detailMap);
                newResPrice.no3rdDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_12', 'PlanPrice__c', detailMap);
                newResQty.no3rdDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_12', 'PlanQty__c', detailMap);
                newResAMT.no3rdDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+2)+'_12', 'PlanAmount__c', detailMap);

                /* 4년차 수량물량 정보 */
                newResPrice.ttl4th                  = getMapDecimal(itemkey, 'fm_AvgPrice4th__c', itemMap);
                newResQty.ttl4th                    = getMapDecimal(itemkey, 'ru_PlanQty4th__c', itemMap);
                newResAMT.ttl4th                    = getMapDecimal(itemkey, 'ru_PlanAmt4th__c', itemMap);

                newResPrice.no4thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_01', 'PlanPrice__c', detailMap);
                newResQty.no4thJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_01', 'PlanQty__c', detailMap);
                newResAMT.no4thJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_01', 'PlanAmount__c', detailMap);
                newResPrice.no4thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_02', 'PlanPrice__c', detailMap);
                newResQty.no4thFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_02', 'PlanQty__c', detailMap);
                newResAMT.no4thFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_02', 'PlanAmount__c', detailMap);
                newResPrice.no4thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_03', 'PlanPrice__c', detailMap);
                newResQty.no4thMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_03', 'PlanQty__c', detailMap);
                newResAMT.no4thMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_03', 'PlanAmount__c', detailMap);
                newResPrice.no4thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_04', 'PlanPrice__c', detailMap);
                newResQty.no4thAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_04', 'PlanQty__c', detailMap);
                newResAMT.no4thAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_04', 'PlanAmount__c', detailMap);
                newResPrice.no4thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_05', 'PlanPrice__c', detailMap);
                newResQty.no4thMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_05', 'PlanQty__c', detailMap);
                newResAMT.no4thMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_05', 'PlanAmount__c', detailMap);
                newResPrice.no4thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_06', 'PlanPrice__c', detailMap);
                newResQty.no4thJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_06', 'PlanQty__c', detailMap);
                newResAMT.no4thJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_06', 'PlanAmount__c', detailMap);
                newResPrice.no4thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_07', 'PlanPrice__c', detailMap);
                newResQty.no4thJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_07', 'PlanQty__c', detailMap);
                newResAMT.no4thJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_07', 'PlanAmount__c', detailMap);
                newResPrice.no4thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_08', 'PlanPrice__c', detailMap);
                newResQty.no4thAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_08', 'PlanQty__c', detailMap);
                newResAMT.no4thAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_08', 'PlanAmount__c', detailMap);
                newResPrice.no4thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_09', 'PlanPrice__c', detailMap);
                newResQty.no4thSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_09', 'PlanQty__c', detailMap);
                newResAMT.no4thSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_09', 'PlanAmount__c', detailMap);
                newResPrice.no4thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_10', 'PlanPrice__c', detailMap);
                newResQty.no4thOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_10', 'PlanQty__c', detailMap);
                newResAMT.no4thOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_10', 'PlanAmount__c', detailMap);
                newResPrice.no4thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_11', 'PlanPrice__c', detailMap);
                newResQty.no4thNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_11', 'PlanQty__c', detailMap);
                newResAMT.no4thNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_11', 'PlanAmount__c', detailMap);
                newResPrice.no4thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_12', 'PlanPrice__c', detailMap);
                newResQty.no4thDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_12', 'PlanQty__c', detailMap);
                newResAMT.no4thDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+3)+'_12', 'PlanAmount__c', detailMap);

                /* 5년차 수량물량 정보 */
                newResPrice.ttl5th                  = getMapDecimal(itemkey, 'fm_AvgPrice5th__c', itemMap);
                newResQty.ttl5th                    = getMapDecimal(itemkey, 'ru_PlanQty5th__c', itemMap);
                newResAMT.ttl5th                    = getMapDecimal(itemkey, 'ru_PlanAmt5th__c', itemMap);

                newResPrice.no5thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_01', 'PlanPrice__c', detailMap);
                newResQty.no5thJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_01', 'PlanQty__c', detailMap);
                newResAMT.no5thJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_01', 'PlanAmount__c', detailMap);
                newResPrice.no5thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_02', 'PlanPrice__c', detailMap);
                newResQty.no5thFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_02', 'PlanQty__c', detailMap);
                newResAMT.no5thFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_02', 'PlanAmount__c', detailMap);
                newResPrice.no5thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_03', 'PlanPrice__c', detailMap);
                newResQty.no5thMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_03', 'PlanQty__c', detailMap);
                newResAMT.no5thMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_03', 'PlanAmount__c', detailMap);
                newResPrice.no5thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_04', 'PlanPrice__c', detailMap);
                newResQty.no5thAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_04', 'PlanQty__c', detailMap);
                newResAMT.no5thAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_04', 'PlanAmount__c', detailMap);
                newResPrice.no5thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_05', 'PlanPrice__c', detailMap);
                newResQty.no5thMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_05', 'PlanQty__c', detailMap);
                newResAMT.no5thMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_05', 'PlanAmount__c', detailMap);
                newResPrice.no5thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_06', 'PlanPrice__c', detailMap);
                newResQty.no5thJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_06', 'PlanQty__c', detailMap);
                newResAMT.no5thJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_06', 'PlanAmount__c', detailMap);
                newResPrice.no5thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_07', 'PlanPrice__c', detailMap);
                newResQty.no5thJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_07', 'PlanQty__c', detailMap);
                newResAMT.no5thJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_07', 'PlanAmount__c', detailMap);
                newResPrice.no5thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_08', 'PlanPrice__c', detailMap);
                newResQty.no5thAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_08', 'PlanQty__c', detailMap);
                newResAMT.no5thAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_08', 'PlanAmount__c', detailMap);
                newResPrice.no5thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_09', 'PlanPrice__c', detailMap);
                newResQty.no5thSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_09', 'PlanQty__c', detailMap);
                newResAMT.no5thSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_09', 'PlanAmount__c', detailMap);
                newResPrice.no5thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_10', 'PlanPrice__c', detailMap);
                newResQty.no5thOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_10', 'PlanQty__c', detailMap);
                newResAMT.no5thOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_10', 'PlanAmount__c', detailMap);
                newResPrice.no5thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_11', 'PlanPrice__c', detailMap);
                newResQty.no5thNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_11', 'PlanQty__c', detailMap);
                newResAMT.no5thNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_11', 'PlanAmount__c', detailMap);
                newResPrice.no5thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_12', 'PlanPrice__c', detailMap);
                newResQty.no5thDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_12', 'PlanQty__c', detailMap);
                newResAMT.no5thDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+4)+'_12', 'PlanAmount__c', detailMap);    

                /* 6년차 수량물량 정보 */
                newResPrice.ttl6th                  = getMapDecimal(itemkey, 'fm_AvgPrice6th__c', itemMap);
                newResQty.ttl6th                    = getMapDecimal(itemkey, 'ru_PlanQty6th__c', itemMap);
                newResAMT.ttl6th                    = getMapDecimal(itemkey, 'ru_PlanAmt6th__c', itemMap);

                newResPrice.no6thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_01', 'PlanPrice__c', detailMap);
                newResQty.no6thJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_01', 'PlanQty__c', detailMap);
                newResAMT.no6thJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_01', 'PlanAmount__c', detailMap);
                newResPrice.no6thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_02', 'PlanPrice__c', detailMap);
                newResQty.no6thFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_02', 'PlanQty__c', detailMap);
                newResAMT.no6thFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_02', 'PlanAmount__c', detailMap);
                newResPrice.no6thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_03', 'PlanPrice__c', detailMap);
                newResQty.no6thMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_03', 'PlanQty__c', detailMap);
                newResAMT.no6thMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_03', 'PlanAmount__c', detailMap);
                newResPrice.no6thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_04', 'PlanPrice__c', detailMap);
                newResQty.no6thAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_04', 'PlanQty__c', detailMap);
                newResAMT.no6thAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_04', 'PlanAmount__c', detailMap);
                newResPrice.no6thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_05', 'PlanPrice__c', detailMap);
                newResQty.no6thMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_05', 'PlanQty__c', detailMap);
                newResAMT.no6thMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_05', 'PlanAmount__c', detailMap);
                newResPrice.no6thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_06', 'PlanPrice__c', detailMap);
                newResQty.no6thJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_06', 'PlanQty__c', detailMap);
                newResAMT.no6thJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_06', 'PlanAmount__c', detailMap);
                newResPrice.no6thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_07', 'PlanPrice__c', detailMap);
                newResQty.no6thJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_07', 'PlanQty__c', detailMap);
                newResAMT.no6thJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_07', 'PlanAmount__c', detailMap);
                newResPrice.no6thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_08', 'PlanPrice__c', detailMap);
                newResQty.no6thAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_08', 'PlanQty__c', detailMap);
                newResAMT.no6thAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_08', 'PlanAmount__c', detailMap);
                newResPrice.no6thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_09', 'PlanPrice__c', detailMap);
                newResQty.no6thSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_09', 'PlanQty__c', detailMap);
                newResAMT.no6thSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_09', 'PlanAmount__c', detailMap);
                newResPrice.no6thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_10', 'PlanPrice__c', detailMap);
                newResQty.no6thOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_10', 'PlanQty__c', detailMap);
                newResAMT.no6thOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_10', 'PlanAmount__c', detailMap);
                newResPrice.no6thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_11', 'PlanPrice__c', detailMap);
                newResQty.no6thNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_11', 'PlanQty__c', detailMap);
                newResAMT.no6thNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_11', 'PlanAmount__c', detailMap);
                newResPrice.no6thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_12', 'PlanPrice__c', detailMap);
                newResQty.no6thDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_12', 'PlanQty__c', detailMap);
                newResAMT.no6thDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+5)+'_12', 'PlanAmount__c', detailMap);

                /* 7년차 수량물량 정보 */
                newResPrice.ttl7th                  = getMapDecimal(itemkey, 'fm_AvgPrice7th__c', itemMap);
                newResQty.ttl7th                    = getMapDecimal(itemkey, 'ru_PlanQty7th__c', itemMap);
                newResAMT.ttl7th                    = getMapDecimal(itemkey, 'ru_PlanAmt7th__c', itemMap);

                newResPrice.no7thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_01', 'PlanPrice__c', detailMap);
                newResQty.no7thJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_01', 'PlanQty__c', detailMap);
                newResAMT.no7thJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_01', 'PlanAmount__c', detailMap);
                newResPrice.no7thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_02', 'PlanPrice__c', detailMap);
                newResQty.no7thFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_02', 'PlanQty__c', detailMap);
                newResAMT.no7thFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_02', 'PlanAmount__c', detailMap);
                newResPrice.no7thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_03', 'PlanPrice__c', detailMap);
                newResQty.no7thMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_03', 'PlanQty__c', detailMap);
                newResAMT.no7thMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_03', 'PlanAmount__c', detailMap);
                newResPrice.no7thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_04', 'PlanPrice__c', detailMap);
                newResQty.no7thAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_04', 'PlanQty__c', detailMap);
                newResAMT.no7thAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_04', 'PlanAmount__c', detailMap);
                newResPrice.no7thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_05', 'PlanPrice__c', detailMap);
                newResQty.no7thMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_05', 'PlanQty__c', detailMap);
                newResAMT.no7thMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_05', 'PlanAmount__c', detailMap);
                newResPrice.no7thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_06', 'PlanPrice__c', detailMap);
                newResQty.no7thJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_06', 'PlanQty__c', detailMap);
                newResAMT.no7thJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_06', 'PlanAmount__c', detailMap);
                newResPrice.no7thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_07', 'PlanPrice__c', detailMap);
                newResQty.no7thJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_07', 'PlanQty__c', detailMap);
                newResAMT.no7thJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_07', 'PlanAmount__c', detailMap);
                newResPrice.no7thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_08', 'PlanPrice__c', detailMap);
                newResQty.no7thAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_08', 'PlanQty__c', detailMap);
                newResAMT.no7thAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_08', 'PlanAmount__c', detailMap);
                newResPrice.no7thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_09', 'PlanPrice__c', detailMap);
                newResQty.no7thSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_09', 'PlanQty__c', detailMap);
                newResAMT.no7thSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_09', 'PlanAmount__c', detailMap);
                newResPrice.no7thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_10', 'PlanPrice__c', detailMap);
                newResQty.no7thOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_10', 'PlanQty__c', detailMap);
                newResAMT.no7thOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_10', 'PlanAmount__c', detailMap);
                newResPrice.no7thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_11', 'PlanPrice__c', detailMap);
                newResQty.no7thNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_11', 'PlanQty__c', detailMap);
                newResAMT.no7thNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_11', 'PlanAmount__c', detailMap);
                newResPrice.no7thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_12', 'PlanPrice__c', detailMap);
                newResQty.no7thDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_12', 'PlanQty__c', detailMap);
                newResAMT.no7thDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear)+'_12', 'PlanAmount__c', detailMap);

                /* 8년차 수량물량 정보 */
                newResPrice.ttl8th                  = getMapDecimal(itemkey, 'fm_AvgPrice8th__c', itemMap);
                newResQty.ttl8th                    = getMapDecimal(itemkey, 'ru_PlanQty8th__c', itemMap);
                newResAMT.ttl8th                    = getMapDecimal(itemkey, 'ru_PlanAmt8th__c', itemMap);

                newResPrice.no8thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_01', 'PlanPrice__c', detailMap);
                newResQty.no8thJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_01', 'PlanQty__c', detailMap);
                newResAMT.no8thJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_01', 'PlanAmount__c', detailMap);
                newResPrice.no8thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_02', 'PlanPrice__c', detailMap);
                newResQty.no8thFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_02', 'PlanQty__c', detailMap);
                newResAMT.no8thFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_02', 'PlanAmount__c', detailMap);
                newResPrice.no8thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_03', 'PlanPrice__c', detailMap);
                newResQty.no8thMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_03', 'PlanQty__c', detailMap);
                newResAMT.no8thMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_03', 'PlanAmount__c', detailMap);
                newResPrice.no8thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_04', 'PlanPrice__c', detailMap);
                newResQty.no8thAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_04', 'PlanQty__c', detailMap);
                newResAMT.no8thAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_04', 'PlanAmount__c', detailMap);
                newResPrice.no8thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_05', 'PlanPrice__c', detailMap);
                newResQty.no8thMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_05', 'PlanQty__c', detailMap);
                newResAMT.no8thMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_05', 'PlanAmount__c', detailMap);
                newResPrice.no8thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_06', 'PlanPrice__c', detailMap);
                newResQty.no8thJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_06', 'PlanQty__c', detailMap);
                newResAMT.no8thJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_06', 'PlanAmount__c', detailMap);
                newResPrice.no8thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_07', 'PlanPrice__c', detailMap);
                newResQty.no8thJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_07', 'PlanQty__c', detailMap);
                newResAMT.no8thJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_07', 'PlanAmount__c', detailMap);
                newResPrice.no8thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_08', 'PlanPrice__c', detailMap);
                newResQty.no8thAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_08', 'PlanQty__c', detailMap);
                newResAMT.no8thAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_08', 'PlanAmount__c', detailMap);
                newResPrice.no8thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_09', 'PlanPrice__c', detailMap);
                newResQty.no8thSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_09', 'PlanQty__c', detailMap);
                newResAMT.no8thSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_09', 'PlanAmount__c', detailMap);
                newResPrice.no8thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_10', 'PlanPrice__c', detailMap);
                newResQty.no8thOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_10', 'PlanQty__c', detailMap);
                newResAMT.no8thOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_10', 'PlanAmount__c', detailMap);
                newResPrice.no8thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_11', 'PlanPrice__c', detailMap);
                newResQty.no8thNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_11', 'PlanQty__c', detailMap);
                newResAMT.no8thNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_11', 'PlanAmount__c', detailMap);
                newResPrice.no8thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_12', 'PlanPrice__c', detailMap);
                newResQty.no8thDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_12', 'PlanQty__c', detailMap);
                newResAMT.no8thDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+7)+'_12', 'PlanAmount__c', detailMap);

                /* 9년차 수량물량 정보 */
                newResPrice.ttl9th                  = getMapDecimal(itemkey, 'fm_AvgPrice9th__c', itemMap);
                newResQty.ttl9th                    = getMapDecimal(itemkey, 'ru_PlanQty9th__c', itemMap);
                newResAMT.ttl9th                    = getMapDecimal(itemkey, 'ru_PlanAmt9th__c', itemMap);

                newResPrice.no9thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_01', 'PlanPrice__c', detailMap);
                newResQty.no9thJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_01', 'PlanQty__c', detailMap);
                newResAMT.no9thJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_01', 'PlanAmount__c', detailMap);
                newResPrice.no9thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_02', 'PlanPrice__c', detailMap);
                newResQty.no9thFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_02', 'PlanQty__c', detailMap);
                newResAMT.no9thFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_02', 'PlanAmount__c', detailMap);
                newResPrice.no9thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_03', 'PlanPrice__c', detailMap);
                newResQty.no9thMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_03', 'PlanQty__c', detailMap);
                newResAMT.no9thMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_03', 'PlanAmount__c', detailMap);
                newResPrice.no9thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_04', 'PlanPrice__c', detailMap);
                newResQty.no9thAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_04', 'PlanQty__c', detailMap);
                newResAMT.no9thAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_04', 'PlanAmount__c', detailMap);
                newResPrice.no9thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_05', 'PlanPrice__c', detailMap);
                newResQty.no9thMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_05', 'PlanQty__c', detailMap);
                newResAMT.no9thMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_05', 'PlanAmount__c', detailMap);
                newResPrice.no9thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_06', 'PlanPrice__c', detailMap);
                newResQty.no9thJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_06', 'PlanQty__c', detailMap);
                newResAMT.no9thJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_06', 'PlanAmount__c', detailMap);
                newResPrice.no9thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_07', 'PlanPrice__c', detailMap);
                newResQty.no9thJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_07', 'PlanQty__c', detailMap);
                newResAMT.no9thJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_07', 'PlanAmount__c', detailMap);
                newResPrice.no9thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_08', 'PlanPrice__c', detailMap);
                newResQty.no9thAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_08', 'PlanQty__c', detailMap);
                newResAMT.no9thAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_08', 'PlanAmount__c', detailMap);
                newResPrice.no9thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_09', 'PlanPrice__c', detailMap);
                newResQty.no9thSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_09', 'PlanQty__c', detailMap);
                newResAMT.no9thSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_09', 'PlanAmount__c', detailMap);
                newResPrice.no9thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_10', 'PlanPrice__c', detailMap);
                newResQty.no9thOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_10', 'PlanQty__c', detailMap);
                newResAMT.no9thOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_10', 'PlanAmount__c', detailMap);
                newResPrice.no9thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_11', 'PlanPrice__c', detailMap);
                newResQty.no9thNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_11', 'PlanQty__c', detailMap);
                newResAMT.no9thNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_11', 'PlanAmount__c', detailMap);
                newResPrice.no9thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_12', 'PlanPrice__c', detailMap);
                newResQty.no9thDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_12', 'PlanQty__c', detailMap);
                newResAMT.no9thDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+8)+'_12', 'PlanAmount__c', detailMap);

                /* 10년차 수량물량 정보 */
                newResPrice.ttl10th                  = getMapDecimal(itemkey, 'fm_AvgPrice10th__c', itemMap);
                newResQty.ttl10th                    = getMapDecimal(itemkey, 'ru_PlanQty10th__c', itemMap);
                newResAMT.ttl10th                    = getMapDecimal(itemkey, 'ru_PlanAmt10th__c', itemMap);

                newResPrice.no10thJAN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_01', 'PlanPrice__c', detailMap);
                newResQty.no10thJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_01', 'PlanQty__c', detailMap);
                newResAMT.no10thJAN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_01', 'PlanAmount__c', detailMap);
                newResPrice.no10thFEB                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_02', 'PlanPrice__c', detailMap);
                newResQty.no10thFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_02', 'PlanQty__c', detailMap);
                newResAMT.no10thFEB                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_02', 'PlanAmount__c', detailMap);
                newResPrice.no10thMAR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_03', 'PlanPrice__c', detailMap);
                newResQty.no10thMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_03', 'PlanQty__c', detailMap);
                newResAMT.no10thMAR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_03', 'PlanAmount__c', detailMap);
                newResPrice.no10thAPR                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_04', 'PlanPrice__c', detailMap);
                newResQty.no10thAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_04', 'PlanQty__c', detailMap);
                newResAMT.no10thAPR                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_04', 'PlanAmount__c', detailMap);
                newResPrice.no10thMAY                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_05', 'PlanPrice__c', detailMap);
                newResQty.no10thMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_05', 'PlanQty__c', detailMap);
                newResAMT.no10thMAY                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_05', 'PlanAmount__c', detailMap);
                newResPrice.no10thJUN                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_06', 'PlanPrice__c', detailMap);
                newResQty.no10thJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_06', 'PlanQty__c', detailMap);
                newResAMT.no10thJUN                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_06', 'PlanAmount__c', detailMap);
                newResPrice.no10thJUL                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_07', 'PlanPrice__c', detailMap);
                newResQty.no10thJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_07', 'PlanQty__c', detailMap);
                newResAMT.no10thJUL                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_07', 'PlanAmount__c', detailMap);
                newResPrice.no10thAUG                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_08', 'PlanPrice__c', detailMap);
                newResQty.no10thAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_08', 'PlanQty__c', detailMap);
                newResAMT.no10thAUG                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_08', 'PlanAmount__c', detailMap);
                newResPrice.no10thSEP                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_09', 'PlanPrice__c', detailMap);
                newResQty.no10thSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_09', 'PlanQty__c', detailMap);
                newResAMT.no10thSEP                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_09', 'PlanAmount__c', detailMap);
                newResPrice.no10thOCT                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_10', 'PlanPrice__c', detailMap);
                newResQty.no10thOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_10', 'PlanQty__c', detailMap);
                newResAMT.no10thOCT                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_10', 'PlanAmount__c', detailMap);
                newResPrice.no10thNOV                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_11', 'PlanPrice__c', detailMap);
                newResQty.no10thNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_11', 'PlanQty__c', detailMap);
                newResAMT.no10thNOV                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_11', 'PlanAmount__c', detailMap);
                newResPrice.no10thDEC                = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_12', 'PlanPrice__c', detailMap);
                newResQty.no10thDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_12', 'PlanQty__c', detailMap);
                newResAMT.no10thDEC                  = getMapDecimal(itemkey+'_'+String.valueOf(startYear+9)+'_12', 'PlanAmount__c', detailMap);

                recordList.add(newResPrice);
                recordList.add(newResQty);
                recordList.add(newResAMT);
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
        @AuraEnabled public String div;
        @AuraEnabled public Decimal ttl;

        /* 1년차 수량물량 정보 */
        @AuraEnabled public Decimal ttl1st;

        @AuraEnabled public Decimal no1stJAN;
        @AuraEnabled public Decimal no1stFEB;
        @AuraEnabled public Decimal no1stMAR;
        @AuraEnabled public Decimal no1stAPR;
        @AuraEnabled public Decimal no1stMAY;
        @AuraEnabled public Decimal no1stJUN;
        @AuraEnabled public Decimal no1stJUL;
        @AuraEnabled public Decimal no1stAUG;
        @AuraEnabled public Decimal no1stSEP;
        @AuraEnabled public Decimal no1stOCT;
        @AuraEnabled public Decimal no1stNOV;
        @AuraEnabled public Decimal no1stDEC;

        /* 2년차 수량물량 정보 */
        @AuraEnabled public Decimal ttl2nd;

        @AuraEnabled public Decimal no2ndJAN;
        @AuraEnabled public Decimal no2ndFEB;
        @AuraEnabled public Decimal no2ndMAR;
        @AuraEnabled public Decimal no2ndAPR;
        @AuraEnabled public Decimal no2ndMAY;
        @AuraEnabled public Decimal no2ndJUN;
        @AuraEnabled public Decimal no2ndJUL;
        @AuraEnabled public Decimal no2ndAUG;
        @AuraEnabled public Decimal no2ndSEP;
        @AuraEnabled public Decimal no2ndOCT;
        @AuraEnabled public Decimal no2ndNOV;
        @AuraEnabled public Decimal no2ndDEC;

        /* 3년차 수량물량 정보 */
        @AuraEnabled public Decimal ttl3rd;

        @AuraEnabled public Decimal no3rdJAN;
        @AuraEnabled public Decimal no3rdFEB;
        @AuraEnabled public Decimal no3rdMAR;
        @AuraEnabled public Decimal no3rdAPR;
        @AuraEnabled public Decimal no3rdMAY;
        @AuraEnabled public Decimal no3rdJUN;
        @AuraEnabled public Decimal no3rdJUL;
        @AuraEnabled public Decimal no3rdAUG;
        @AuraEnabled public Decimal no3rdSEP;
        @AuraEnabled public Decimal no3rdOCT;
        @AuraEnabled public Decimal no3rdNOV;
        @AuraEnabled public Decimal no3rdDEC;

        /* 4년차 수량물량 정보 */
        @AuraEnabled public Decimal ttl4th;

        @AuraEnabled public Decimal no4thJAN;
        @AuraEnabled public Decimal no4thFEB;
        @AuraEnabled public Decimal no4thMAR;
        @AuraEnabled public Decimal no4thAPR;
        @AuraEnabled public Decimal no4thMAY;
        @AuraEnabled public Decimal no4thJUN;
        @AuraEnabled public Decimal no4thJUL;
        @AuraEnabled public Decimal no4thAUG;
        @AuraEnabled public Decimal no4thSEP;
        @AuraEnabled public Decimal no4thOCT;
        @AuraEnabled public Decimal no4thNOV;
        @AuraEnabled public Decimal no4thDEC;

        /* 5년차 수량물량 정보 */
        @AuraEnabled public Decimal ttl5th;

        @AuraEnabled public Decimal no5thJAN;
        @AuraEnabled public Decimal no5thFEB;
        @AuraEnabled public Decimal no5thMAR;
        @AuraEnabled public Decimal no5thAPR;
        @AuraEnabled public Decimal no5thMAY;
        @AuraEnabled public Decimal no5thJUN;
        @AuraEnabled public Decimal no5thJUL;
        @AuraEnabled public Decimal no5thAUG;
        @AuraEnabled public Decimal no5thSEP;
        @AuraEnabled public Decimal no5thOCT;
        @AuraEnabled public Decimal no5thNOV;
        @AuraEnabled public Decimal no5thDEC;

        /* 6년차 수량물량 정보 */
        @AuraEnabled public Decimal ttl6th;

        @AuraEnabled public Decimal no6thJAN;
        @AuraEnabled public Decimal no6thFEB;
        @AuraEnabled public Decimal no6thMAR;
        @AuraEnabled public Decimal no6thAPR;
        @AuraEnabled public Decimal no6thMAY;
        @AuraEnabled public Decimal no6thJUN;
        @AuraEnabled public Decimal no6thJUL;
        @AuraEnabled public Decimal no6thAUG;
        @AuraEnabled public Decimal no6thSEP;
        @AuraEnabled public Decimal no6thOCT;
        @AuraEnabled public Decimal no6thNOV;
        @AuraEnabled public Decimal no6thDEC;

        /* 7년차 수량물량 정보 */
        @AuraEnabled public Decimal ttl7th;

        @AuraEnabled public Decimal no7thJAN;
        @AuraEnabled public Decimal no7thFEB;
        @AuraEnabled public Decimal no7thMAR;
        @AuraEnabled public Decimal no7thAPR;
        @AuraEnabled public Decimal no7thMAY;
        @AuraEnabled public Decimal no7thJUN;
        @AuraEnabled public Decimal no7thJUL;
        @AuraEnabled public Decimal no7thAUG;
        @AuraEnabled public Decimal no7thSEP;
        @AuraEnabled public Decimal no7thOCT;
        @AuraEnabled public Decimal no7thNOV;
        @AuraEnabled public Decimal no7thDEC;

        /* 8년차 수량물량 정보 */
        @AuraEnabled public Decimal ttl8th;

        @AuraEnabled public Decimal no8thJAN;
        @AuraEnabled public Decimal no8thFEB;
        @AuraEnabled public Decimal no8thMAR;
        @AuraEnabled public Decimal no8thAPR;
        @AuraEnabled public Decimal no8thMAY;
        @AuraEnabled public Decimal no8thJUN;
        @AuraEnabled public Decimal no8thJUL;
        @AuraEnabled public Decimal no8thAUG;
        @AuraEnabled public Decimal no8thSEP;
        @AuraEnabled public Decimal no8thOCT;
        @AuraEnabled public Decimal no8thNOV;
        @AuraEnabled public Decimal no8thDEC;

        /* 9년차 수량물량 정보 */
        @AuraEnabled public Decimal ttl9th;

        @AuraEnabled public Decimal no9thJAN;
        @AuraEnabled public Decimal no9thFEB;
        @AuraEnabled public Decimal no9thMAR;
        @AuraEnabled public Decimal no9thAPR;
        @AuraEnabled public Decimal no9thMAY;
        @AuraEnabled public Decimal no9thJUN;
        @AuraEnabled public Decimal no9thJUL;
        @AuraEnabled public Decimal no9thAUG;
        @AuraEnabled public Decimal no9thSEP;
        @AuraEnabled public Decimal no9thOCT;
        @AuraEnabled public Decimal no9thNOV;
        @AuraEnabled public Decimal no9thDEC;

        /* 10년차 수량물량 정보 */
        @AuraEnabled public Decimal ttl10th;

        @AuraEnabled public Decimal no10thJAN;
        @AuraEnabled public Decimal no10thFEB;
        @AuraEnabled public Decimal no10thMAR;
        @AuraEnabled public Decimal no10thAPR;
        @AuraEnabled public Decimal no10thMAY;
        @AuraEnabled public Decimal no10thJUN;
        @AuraEnabled public Decimal no10thJUL;
        @AuraEnabled public Decimal no10thAUG;
        @AuraEnabled public Decimal no10thSEP;
        @AuraEnabled public Decimal no10thOCT;
        @AuraEnabled public Decimal no10thNOV;
        @AuraEnabled public Decimal no10thDEC;
    }
    
}