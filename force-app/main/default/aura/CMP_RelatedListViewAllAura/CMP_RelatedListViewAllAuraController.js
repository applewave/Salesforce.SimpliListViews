/****************************************************************************************
 * File Name    : RelatedListViewAllAuraController.js
 * Author       : sy.lee
 * Date         : 2023-11-21
 * Description  :
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * ===============================================================
 * Ver      Date 		Author    			Modification
 * ===============================================================
 1.0		2023-11-21 	sy.lee			    Create

 ****************************************************************************************/
 ({

    /** 2023-11-21 - sy.lee - Init */
    fnInit: function (component, event, helper) {
        console.info('%c==================================== RelatedListViewAllAuraController.fnInit', 'color:red;');

        // 이벤트 등록
        helper._registerRecordChangeListener(component);

        //helper._sample(component);

        component.set(`v.iconName`, sessionStorage.getItem('iconName'));
        component.set(`v.columns`, JSON.parse(sessionStorage.getItem('columns')));
        component.set(`v.hideCheckboxColumn`, sessionStorage.getItem('hideCheckboxColumn'));
        component.set(`v.sortedBy`, sessionStorage.getItem('sortedBy'));
        component.set(`v.sortedDirection`, sessionStorage.getItem('sortedDirection'));
        component.set(`v.maxRowSelection`, sessionStorage.getItem('maxRowSelection'));
        component.set(`v.showRowNumberColumn`, sessionStorage.getItem('showRowNumberColumn'));
        component.set(`v.query`, sessionStorage.getItem('query'));
        component.set(`v.countQuery`, sessionStorage.getItem('countQuery'));
        component.set(`v.columnMap`, sessionStorage.getItem('columnMap'));
        component.set('v.result', JSON.parse(sessionStorage.getItem('result')));
        component.set('v.sortedByMap', JSON.parse(sessionStorage.getItem('sortedByMap')));
        component.set('v.needAccessCheck', sessionStorage.getItem('needAccessCheck'));
        component.set('v.title', sessionStorage.getItem('title'));
        component.set('v.useEditRowAction', sessionStorage.getItem('useEditRowAction'));
        component.set('v.useShowDetailRowAction', sessionStorage.getItem('useShowDetailRowAction'));
        component.set('v.useDeleteRowAction', sessionStorage.getItem('useDeleteRowAction'));
        component.set('v.buttonComponentName', sessionStorage.getItem('buttonComponentName'));
        component.set('v.sortedByLabel', sessionStorage.getItem('sortedByLabel'));
        component.set('v.isInfinityLoading', sessionStorage.getItem('isInfinityLoading'));
        component.set('v.useExport', Boolean(sessionStorage.getItem('useExport')));


        console.log('result', component.get('v.result'));
        console.log('query', component.get('v.query'));
        console.log('sortedBy', component.get('v.sortedBy'));
        console.log('columns', component.get('v.columns'));

        // 파라미터
        /*const params = {
            recordId: component.get('v.recordId'),
            currentObjectApi: component.get('v.currentObjectApi'),
            currentObjectFields: component.get('v.currentObjectFields'),
            targetObjectApi: component.get('v.targetObjectApi'),
            fields: component.get('v.fields'),
            condition: component.get('v.condition'),
            sortedBy: component.get('v.sortedBy'),
            sortedDirection: component.get('v.sortedDirection'),
            limitCount: component.get('v.limitCount'),
            isWithOutSharing: component.get('v.isWithOutSharing'),
            needAccessCheck: component.get('v.needAccessCheck'),
            applyApprovalLock: component.get('v.applyApprovalLock'),
        }*/

        const params = {
            query: component.get('v.query'),
            limitCount: '50',
            isWithOutSharing: false,
            needAccessCheck: false,
            applyApprovalLock: false,
        }
        console.log('params', JSON.parse(JSON.stringify(params)));

        helper.apex(component, 'init', params)
            .then(result => {
                console.log('data', result);

                // 컬럼은 넘겨 받음
                const columns = component.get('v.columns');

                // Row Action 생성
                helper._createRowAction(component, columns);
                console.log('columns', columns);
                component.set('v.columns', columns);

                // 데이터 생성
                const recordList = helper._createData(component, result.data.recordList);

                // 임시로 scroll 테스트 할라고
                /*for(let i=0; i<200; i++){
                    recordList.push(recordList[0]);
                }*/

                component.set('v.totalRecordList', recordList);

                // infinity loading을 사용하는 경우에는 데이터를 잘라서 넣어주고, 아닌 경우에는 전부 넣어준다
                if(component.get('v.isInfinityLoading')){
                    component.set('v.data', recordList.slice(0, 50));
                }else{
                    component.set('v.data', recordList);
                }

                // 레코드 카운트
                const {length} = component.get('v.data');

                // 아이템 카운트
                component.set('v.itemCount', `${$A.get("$Label.c.CMP_CR_Lab_NItems").replace('{0}', length)}`);

                // Sorted By - Label 설정 -> data 만들때 알아서 처리한다
            })
            .then($A.getCallback(result => {
                // 커스텀 버튼 생성
                const buttonComponentName = component.get('v.buttonComponentName');
                if(!buttonComponentName){
                    component.set('v.isLoading', false);
                }else{
                    helper._createButtonComponent(component, buttonComponentName);
                }
            }))
            .catch(err => {
                console.log('RelatedListViewAll.init ERROR : ', err.stack);
            });
    },


    fnLoadmore: function (component, event, helper){
        // infinity loading이 false인 경우는 필요 로직을 수행할 필요 없음
        const isInfinityLoading = component.get('v.isInfinityLoading');
        if(isInfinityLoading === false){
            component.set('v.isLoading', false);
            return;
        }

        console.info('%c==================================== RelatedListViewAllAuraController.fnLoadmore', 'color:red;');
        component.set('v.isLoading', true);
        const table = component.get('v.result').isCommunity ? component.find('communityTable') : component.find('table');
        table.set("v.isLoading", true);

        const currentRowList = component.get('v.data'),
            totalRowList = component.get('v.totalRecordList');

        if(currentRowList.length >= totalRowList.length){
            // 전체보다 크면 infinity loading 제거
            table.set('v.enableInfiniteLoading', false);
        }else{
            // 필요한 개수만큼 concat 처리
            component.set('v.data', currentRowList.concat(totalRowList.slice(currentRowList.length, currentRowList.length + 50)));
            component.set('v.itemCount', `${$A.get("$Label.c.CMP_CR_Lab_NItems").replace('{0}', component.get('v.data').length)}`);
        }
        table.set('v.isLoading', false);

        component.set('v.isLoading', false);
    }

});