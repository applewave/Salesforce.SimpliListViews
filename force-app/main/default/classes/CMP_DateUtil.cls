/**************************************************************************************** 
 * File Name    : CMP_DateUtil
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
global without sharing class CMP_DateUtil {

    /** Whether Test or not */
    private final static Boolean IS_TEST = Test.isRunningTest();

    /** 기본 포맷 */
    private final static String DEFAULT_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ';

    /**
     * @description Org의 Timezone에 맞는 현재 시간
     */
    global static final Datetime COMPANY_NOW {
        get{
            if(COMPANY_NOW == null){
                String strCompanyNow = Datetime.now().format('yyyy-MM-dd HH:mm:ss', CMP_OrgUtil.ORG_INFO.TimeZoneSidKey);
                COMPANY_NOW = Datetime.valueOf(strCompanyNow);
            }
            return COMPANY_NOW;
        }
        set;
    }

    /**
     * @description Org의 Timezone에 맞는 현재 월
     */
    global static final Integer COMPANY_MONTH {
        get{
            if(COMPANY_MONTH == null){
                COMPANY_MONTH = COMPANY_NOW.month();
            }
            return COMPANY_MONTH;
        }
        set;
    }

    /**
     * @description Org의 Timezone에 맞는 현재 연도
     */
    global static final Integer COMPANY_YEAR {
        get{
            if(COMPANY_YEAR == null){
                COMPANY_YEAR = COMPANY_NOW.year();
            }
            return COMPANY_YEAR;
        }
        set;
    }

    /**
     * @description GMT 시간으로 반환
     * @param dt Datetime
     *
     * @return String
     */
    public static String getGmt(Datetime dt){
        return dt?.formatGmt(DEFAULT_FORMAT);
    }

    /**
     * @description MT 시간으로 반환 - 지정된 포맷
     * @param dt Datetime
     * @param format Format
     *
     * @return String
     */
    global static String getGmt(Datetime dt, String format){
        return String.isBlank(format) ? getGmt(dt) : dt?.formatGmt(format);
    }

    /**
     * @description User의 Timezone에 맞는 현재 시간
     * @param dt Datetime
     * @param usr User
     *
     * @return String
     */
    public static String getLocalDateTime(Datetime dt, User usr){
        return dt?.format(DEFAULT_FORMAT, IS_TEST ? 'Asia/Seoul' : usr?.TimeZoneSidKey);
    }

    /**
     * @description User의 Timezone에 맞는 현재 시간 - 지정된 포맷
     * @param dt Datetime
     * @param usr User
     * @param format Format
     *
     * @return String
     */
    global static String getLocalDateTime(Datetime dt, User usr, String format){
        return String.isBlank(format) ? getLocalDateTime(dt, usr) : (dt?.format(format, IS_TEST ? 'Asia/Seoul' : usr?.TimeZoneSidKey));
    }

}