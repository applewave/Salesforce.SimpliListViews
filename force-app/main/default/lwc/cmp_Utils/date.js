/****************************************************************************************
 * File Name    : date
 * Author       : sy.lee
 * Date         : 2024-06-24
 * Description  :
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * ===============================================================
 * Ver      Date 		Author    			Modification
 * ===============================================================
 1.0		2024-06-24 	sy.lee			    Create

 ****************************************************************************************/
/**
 * @description add days to date
 * @param date
 * @param days
 * @returns {Date}
 */
const addDays = (date, days) => {
    const dateCopy = new Date(date);
    dateCopy.setDate(date.getDate() + days);
    return dateCopy;
}

/**
 * @description date to string (YYYY-MM-DD)
 * @param date
 * @returns {string}
 */
const toStr = (date) => {
    const isoString = date.toISOString();
    return isoString.substring(0, isoString.indexOf('T'));
}

/**
 * @description return month
 * @param date
 * @returns {*}
 */
const getMonth = (date) => {
    return date.getMonth() + 1;
}

/**
 * @description return year
 * @param date
 * @returns {number}
 */
const getYear = (date) => {
    return date.getFullYear();
}

/**
 * @description return date
 * @param date
 * @returns {*}
 */
const getDate = (date) => {
    return date.getDate();
}

/**
 * @description return hour
 * @param date
 * @returns {*}
 */
const getHour = (date) => {
    return date.getHour();
}

/**
 * @description return minute
 * @param date
 * @returns {number}
 */
const getMinute = (date) => {
    return date.getMinutes();
}

export {addDays, toStr, getYear, getMonth, getDate, getHour, getMinute}