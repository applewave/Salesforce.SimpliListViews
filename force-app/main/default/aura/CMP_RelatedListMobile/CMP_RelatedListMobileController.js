/****************************************************************************************
 * File Name    : CMP_RelatedListMobileController.js
 * Author       : sy.lee
 * Date         : 2024-06-21
 * Description  :
 * Copyright (c) 2023. LG CNS, All Rights Reserved.
 * Modification Log
 * ===============================================================
 * Ver      Date 		Author    			Modification
 * ===============================================================
 1.0		2024-06-21 	sy.lee			    Create

 ****************************************************************************************/
({

    /** 2023-12-05 - sy.lee - Init */
    fnInit: function (component, event, helper) {
        console.info('%c==================================== CMP_RelatedListMobileController.fnInit', 'color:red;');

        // 2024.06.10 - sy.lee - 수정
        // sessionStorage로 넘어오는 항목 중에서 Boolean으로 처리를 해줘야하는 항목이 있음
        component.set('v.recordId', sessionStorage.getItem('recordId'));
        component.set('v.currentObjectApi', sessionStorage.getItem('currentObjectApi'));
        component.set('v.targetObjectApi', sessionStorage.getItem('targetObjectApi'));
        component.set('v.fields', sessionStorage.getItem('fields'));
        component.set('v.condition', sessionStorage.getItem('condition'));
        component.set('v.sortedBy', sessionStorage.getItem('sortedBy'));
        component.set('v.sortedDirection', sessionStorage.getItem('sortedDirection'));
        component.set('v.limitCount', sessionStorage.getItem('limitCount'));
        // 2024.06.10 - sy.lee - 추가 로직이 별도로 필요해서 일단 뺌
        //console.log('sortedByLabel', sessionStorage.getItem('sortedByLabel'));
        //component.set('v.sortedByLabel', sessionStorage.getItem('sortedByLabel'));
        component.set('v.buttonComponentName', sessionStorage.getItem('buttonComponentName'));
        component.set('v.isWithOutSharing', Boolean(sessionStorage.getItem('isWithOutSharing')));
        component.set('v.needAccessCheck', Boolean(sessionStorage.getItem('needAccessCheck')));
        component.set('v.applyApprovalLock', Boolean(sessionStorage.getItem('applyApprovalLock')));
        component.set('v.iconName', sessionStorage.getItem('iconName'));
        console.log('isPhone', sessionStorage.getItem('isPhone'))
        component.set('v.isPhone', Boolean(sessionStorage.getItem('isPhone')));

        // todo - 이거 필요한가? 이벤트 등록
        //helper._registerRecordChangeListener(component);

        // 현재 레코드 아이디
        const recordId = component.get('v.recordId');
        console.log('recordId', recordId);

        // 파라미터
        const params = {
            recordId: recordId,
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
            isPhone:  component.get('v.isPhone'),
        }

        console.log('params', params);
        /**
         * 2024.02.28 - sy.lee
         * - 모바일의 경우, init을 두번하게 된다. 처음에 타이틀과 개수만 나올때 쿼리하는 부분이 있고, 해당 부분을 누르면.. 여기로 온다
         * - 여기선 온갖 데이터를 다 들고 와야하므로 initDesktop을 사용한다
         */
        helper.apex(component, 'initDesktop', {params})
            .then(result => {
                component.set('v.result', result);
                console.log('result', component.get('v.result'));

                // 조회대상
                const targetObjectApi = component.get('v.targetObjectApi');


                // 타이틀
                helper._handleTitle(component, result.relatedObject[targetObjectApi].labelPlural);

                // 컬럼 생성
                //const columnList = helper._createColumn(component, result, true);
                const columnLabelList = helper._getColumnLabelList(component, event, helper);
                console.log('columnLabelList', columnLabelList);
                //console.log('columnList', columnList);

                //helper._createRowAction(component, columnList);

                //component.set('v.columns', columnList);

                //component.set('v.sortedByLabel', sortedByLabel)

                // 데이터 생성
                const recordList = helper._createData(component, result.data.recordList);
                const refinedRecordList = helper._refineData(columnLabelList, recordList);
                console.log('refinedRecordList', refinedRecordList);

                component.set('v.data', refinedRecordList);

                // todo - 선택가능한 레코드 개수
                //const maxRowSelection = component.get('v.maxRowSelection');
                //console.log(maxRowSelection);
                //maxRowSelection && maxRowSelection.set('v.maxRowSelection', maxRowSelection);
                // 레코드 카운트
                //const {length} = recordList;
                //component.set('v.recordCount', (length < result.data.totalRecordCount) ? `(${length}+)` : `(${length})`);

                // 아이템 카운트
                component.set('v.itemCount', $A.get("$Label.c.CMP_CR_Lab_NItems").replace(`{0}`, result.data.totalRecordCount));

                // 쿼리
                //component.set('v.query', result.data.query);

                // 카운트 쿼리
                //component.set('v.countQuery', result.data.countQuery);

                return result;
            })
            .then($A.getCallback(result => {
                console.log('buttonComponentName', component.get('v.buttonComponentName'));
                const buttonComponentName = component.get('v.buttonComponentName');
                if(buttonComponentName === 'undefined'){
                    component.set('v.isLoading', false);
                }else{
                    helper._createButtonComponent(component, buttonComponentName);
                }
            }))
            .catch(err => {
                console.log('CMP_RelatedListMobileAuraController.init Error : ', err.stack);
            });

    },

    fnNavigateToRecord: function (component, event, helper){
        console.info('%c==================================== CMP_RelatedListMobileController.fnNavigateToRecord', 'color:red;');
        event.preventDefault();

        const recordId = event.currentTarget.dataset.recordid;
        console.log(recordId);

        const navService = component.find("navService");
        navService.navigate({
            "type": "standard__recordPage",
            "attributes": {
                recordId,
                "objectApiName": component.get('v.targetObjectApi'),
                "actionName": "view"
            }
        });
    }
});