/****************************************************************************************
 * File Name    : CMP_RelatedListController.js
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
({

    /**
     * Description init
     * @param component
     * @param event
     * @param helper
     */
    fnInit: function (component, event, helper) {

        // 2024.06.21 - sy.lee - sessionStorage Clear
        sessionStorage.clear();

        const relatedListId = component.get('v.relatedListId');
        console.info('%c==================================== CMP_RelatedListController.fnInit ('+ relatedListId + ')', 'color:red;');

        // 현재 레코드 아이디
        const recordId = component.get('v.recordId');
        console.log('recordId', recordId);

        // 모바일 여부
        const isPhone = component.get('v.mobileTest') || $A.get("$Browser.isPhone");
        component.set('v.isPhone', isPhone);

        // 이벤트 등록
        helper._registerRecordChangeListener(component);

        // 레코드 디테일에 변경이 있을때 렌더링이 필요한 경우
        if(component.get('v.applyRefresh')){
            helper._registerDetailChangeListener(component);
        }

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
            isPhone
        }

        console.log('params', params);

        helper.apex(component, 'init', {params})
            .then(result => {
                component.set('v.result', result);
                console.log('result', component.get('v.result'));

                // 조회대상
                const targetObjectApi = component.get('v.targetObjectApi');

                const label = result.relatedObject[targetObjectApi].labelPlural;

                const {data: {recordList, query, countQuery, totalRecordCount} } = result;

                if(isPhone){ // Mobile ========================================
                    // 타이틀
                    helper._handleTitle(component, label);

                    // 레코드 카운트
                    component.set('v.recordCount', `(${totalRecordCount})`);

                }else{ // Desktop =============================================
                    // 타이틀
                    helper._handleTitle(component, label);

                    // 컬럼 생성
                    const columnList = helper._createColumn(component, result, true);

                    // Row Action 생성
                    helper._createRowAction(component, columnList);
                    component.set('v.columns', columnList);

                    // 데이터 생성
                    const refinedRecordList = helper._createData(component, recordList);
                    component.set('v.data', refinedRecordList);

                    // 쿼리
                    component.set('v.query', query);

                    // 카운트 쿼리
                    component.set('v.countQuery', countQuery);

                    // 데이터가 없는 경우 테이블을 그릴 필요가 없음
                    if(refinedRecordList.length === 0) return;

                    // 선택가능한 레코드 개수
                    if(component.get('v.hideCheckboxColumn')){ // checkbox를 감춘 상태라면 의미없으므로
                        const maxRowSelection = component.get('v.maxRowSelection'),
                            table = component.find('table');
                        maxRowSelection && table.set('v.maxRowSelection', maxRowSelection === 'N' ? 1000 : 1);
                    }

                    // 전체 레코드 카운트
                    const {length} = refinedRecordList;
                    component.set('v.recordCount', (length < totalRecordCount) ? `(${length}+)` : `(${length})`);

                    // 아이템 카운트 (라벨 옆에 보이는 부분)
                    component.set('v.itemCount', `${$A.get("$Label.c.CMP_CR_Lab_NItems").replace('{0}', (length < totalRecordCount) ? `${length}+` : `${length}`)}`);
                }

                return result;
            })
            .then($A.getCallback(result => {
                // 버튼 생성
                const buttonComponentName = component.get('v.buttonComponentName');
                if($A.util.isEmpty(buttonComponentName)){
                    component.set('v.isLoading', false);
                }else{
                    helper._createButtonComponent(component, buttonComponentName);
                }
            }))
            .catch(err => {
                console.log('CMP_RelatedList.init Error (' + relatedListId + '): ', err.stack);
            });
    },

    /**
     * View All 처리
     * @param component
     * @param event
     * @param helper
     */
    fnViewAll: function (component, event, helper){
        console.info('%c==================================== CMP_RelatedListController.fnViewAll', 'color:red;');

        event.preventDefault();

        const result = component.get('v.result');
        const {isCommunity} = result; // Community 여부
        const useStandardViewAll = component.get('v.useStandardViewAll'); // 표준 View All 사용 여부

        if(isCommunity){ // Community ===========================
            if(useStandardViewAll){
                //helper.handleCommunityStandardViewAll(component, event, helper);
            }else{
                helper.handleCommunityCustomViewAll(component, event, helper, result);
            }
        }else{ // Internal ===========================
            if(useStandardViewAll){
                helper._handleInternalStandardViewAll(component, event, helper);
            }else{
                helper._handleInternalCustomViewAll(component, event, helper, result);
            }
        }
    },

    /**
     * 모바일에서 사용 - 초기화면 라벨을 누르는 이벤트 처리
     * @param component
     * @param event
     * @param helper
     */
    fnClickRelatedList: function (component, event, helper){
        console.info('%c==================================== CMP_RelatedListController.fnClickRelatedList', 'color:red;');

        // sessionStorage 설정
        const attributes = ['recordId', 'currentObjectApi', 'targetObjectApi', 'fields', 'condition', 'sortedBy', 'sortedDirection', 'limitCount'
            , 'isWithOutSharing', 'needAccessCheck', 'applyApprovalLock', 'sortedByLabel', 'buttonComponentName', 'iconName', 'isPhone'];
        attributes.map(attribute => {
            sessionStorage.setItem(attribute, component.get(`v.${attribute}`));
        });

        const navService = component.find("navService");
        event.preventDefault();
        navService.navigate({
            type: 'standard__component',
            attributes: {
                componentName: 'c__CMP_RelatedListMobile',
            },
        });
    },

    /**
     * Excel Export
     * @param component
     * @param event
     * @param helper
     */
    fnExport: function (component, event, helper){

        const _createBuffer = (s) => {
            const buf = new ArrayBuffer(s.length); //convert s to arrayBuffer
            const view = new Uint8Array(buf);  //create uint8array as viewer
            for (let i=0; i<s.length; i++) view[i] = s.charCodeAt(i) & 0xFF; //convert to octet
            return [buf];
        }

        const params = {
            query: component.get('v.query'),
        }

        helper.apex(component, 'export', params)
            .then(result => {

                console.log(result);

                // Label 맵핑을 위한 맵 생성
                const labelMap = helper._createExcelColumn(component);
                console.log(labelMap);

                // 데이터 정제
                const refineDataList = [];
                result.map(record => {
                    const refineData = {};
                    Object.keys(labelMap).map(api => {
                        if(api.includes('.')){
                            const apiTermList = api.split('.');
                            let value = record;
                            apiTermList.map(apiTerm => {

                                value = value[apiTerm];
                            });
                            // 2024.01.15 - sy.lee - Id인 경우, Name으로 치환
                            console.log(api, value);
                            refineData[labelMap[api]] = value;
                        }else{
                            refineData[labelMap[api]] = record[api];
                        }
                    });
                    refineDataList.push(refineData);
                });

                // step 1. workbook 생성
                const wb = XLSX.utils.book_new();
                // step 2. 시트 만들기
                const ws = XLSX.utils.json_to_sheet(refineDataList);
                // step 3. workbook에 새로만든 워크시트에 이름을 주고 붙인다.
                //XLSX.utils.book_append_sheet(wb, ws, `${this.filterId === 'Recent' ? 'Recently Viewed' : listViewName}`);
                XLSX.utils.book_append_sheet(wb, ws, `aaa`);
                // step 4. 엑셀 파일 만들기
                const wbout = XLSX.write(wb, {bookType: 'xlsx', type: 'binary'});
                // step 5. 엑셀 파일 내보내기
                saveAs(new Blob(_createBuffer(wbout)
                        , {type: "application/octet-stream"})
                    , `${component.get('v.title')} - ${$A.localizationService.formatDate(Date.now(), "yyyyMMdd")}.xlsx`);
            })
    },

    /**
     * LMS 수신
     * @param component
     * @param event
     * @param helper
     */
    fnSubscribeMessage: function(component, event, helper){
        if(event === null) return;

        console.info('%c==================================== RelatedListAuraController.fnSubscribeMessage', 'color:red;');
        console.log(event);

        const recordId = event.getParam("recordId");
        console.log('recordId', recordId);
        const relatedListId = event.getParam("relatedListId");
        console.log('relatedListId', relatedListId);

        // 자신과 동일한 relatedListId가 넘어오거나 all인 경우 처리
        if(relatedListId !== 'all' && (relatedListId !== component.get('v.relatedListId'))) return;

        const action = event.getParam("action");
        console.log('action', action);
        switch (action) {
            case 'refresh' : {
                console.log('refresh - ', relatedListId);
                const action = component.get('c.fnRefresh');
                $A.enqueueAction(action);
            }
        }
    },
});