/****************************************************************************************
 * File Name    : string
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
 *
 * @param stringToFormat format string
 * @param formattingArguments 매개변수
 * @returns {string}
 * @example StdUtil.format('Hi this is {0}', 'util'); // Hi this is util
 */
const format = (stringToFormat, ...formattingArguments) => {
    if (typeof stringToFormat !== 'string') throw new Error('\'stringToFormat\' must be a String');
    return stringToFormat.replace(/{(\d+)}/gm, (match, index) =>
        (formattingArguments[index] === undefined ? '' : `${formattingArguments[index]}`));
}

/**
 * @description 10 처리
 */
const leftPad = (value) => {
    return value >= 10 ? value : `0${value}`;
}

/*function typing(txt, i=0){
    console.info('%c==================================== string.typing', 'color:red;');
    console.log(txt, i, this.test);
    try{
        const speed = 50;
        if (i < txt.length) {
            this.test = this.test + txt.charAt(i);
            i++;
            setTimeout(typing.bind(this), speed, txt, i);
        }
    }catch (e) {
        console.log(e.stack);
    }
}*/

/**
 * obj.text에 타이핑되어야 할 값을 넣음
 * obj.result에 타이핑되는 내용이 반환됨
 * ex)  @track obj ={};
 *      this.obj = {text:'this is sucks.'};
 *      typing.bind(this)(this.obj);
 *
 *      obj.result 사용
 * @param obj
 * @param i
 */
function typing(obj, i=0){
    console.info('%c==================================== string.typing', 'color:red;');
    if(i === 0) obj.result = '';
    try{
        const speed = 50;
        if (i < obj.text.length) {
            obj.result = obj.result + obj.text.charAt(i);
            i++;
            setTimeout(typing.bind(this), speed, obj, i);
        }
    }catch (e) {
        console.log(e.stack);
    }
}

export {format, leftPad, typing}