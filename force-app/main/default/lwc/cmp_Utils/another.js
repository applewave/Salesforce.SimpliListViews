/****************************************************************************************
 * File Name    : another
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
 * Bytes 포맷 변환
 * @param bytes 바이트 사이즈
 * @param decimals 소수점
 * @returns {string}
 */
export const formatBytes = (bytes,decimals = 2) => {
    if(bytes === 0) return '0 Bytes';
    const k = 1024,
        dm = decimals,
        sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
        i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
}