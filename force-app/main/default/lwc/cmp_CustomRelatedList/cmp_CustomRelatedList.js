import { LightningElement, wire, api } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { getRelatedListInfo, getRelatedListRecords } from "lightning/uiRelatedListApi";
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import { refreshGraphQL } from "lightning/uiGraphQLApi";

import QuickSavingModal from 'c/cmp_ProjectQuickSavingModal';

export default class cmp_CustomRelatedList extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    notes;
    wiredNotesResult;
    relatedListColumns; // API response columns
    dataTable;
    dataTableColumns; // Datatable columns
    dataTableColumnsMap;
    relatedListFields;
    lookupField;

    pageToken;
    currentPageToken;
    nextPageToken;

    @api iconName;
    @api pRelatedListTitle;
    relatedListTitle;
    @api pNotesRelatedList;
    notesRelatedList;
    @api pNoteObjectApiName;
    noteObjectApiName;
    @api pNotesFields;
    notesFields;
    @api pDefaultSortedBy;
    sortedBy;
    @api pDefaultSortDirection;
    sortDirection;
    @api pFilterText = '{ CreatedBy: { Name: { ne: "System Batch Job" } } }';
    filterText;
    @api pPageSize;
    pageSize;
    @api showNewButton;

    showLoading1 = true;
    showLoading2 = false;
    wrapText = false;
    styleAdded = false;
    forceRefresh = false;
    showClipWrapButton = false;
    unsupportedListview = false;

    maxCellheight = 150; // in (px)
    maxTableHeight = 60; // in (vh)
    cellScrollbarWidth = 9; // in (px)

    connectedCallback() {
        this.relatedListTitle = this.pRelatedListTitle;
        this.notesRelatedList = this.pNotesRelatedList;
        this.parentObjectApiName = this.pParentObjectApiName;
        this.noteObjectApiName = this.pNoteObjectApiName; 
        this.notesFields = this.pNotesFields.split(",").map((x) => this.pNoteObjectApiName + '.' + x.trim()); 
        this.sortedBy = this.pDefaultSortedBy; 
        this.sortDirection = this.pDefaultSortDirection; 
        this.filterText = this.pFilterText;
        this.pageSize = this.pPageSize;
    }

    renderedCallback() {
        if (!this.styleAdded) this.loadStyle();
    }

    loadStyle() {
        let e = this.template.querySelector(".related-list-style-div");
        if (e) {
            let x = "<style>";
            // Scrollable cell styles
            x += ".related-list-body tbody td span {  max-height: " + this.maxCellheight + "px !important;  overflow-y: auto !important;  white-space: normal !important;  word-wrap: break-word !important;}";
            // Scrollable table styles
            x += ".related-list-body div.slds-scrollable_y { max-height: "+ this.maxTableHeight +"vh !important; }";
            // Scroll bar styles (only for cell scroll)
            x += ".related-list-body tbody td span::-webkit-scrollbar { width: " + this.cellScrollbarWidth + "px; height: " + this.cellScrollbarWidth + "px; }.related-list-body tbody td span::-webkit-scrollbar-track {border: 1px solid rgb(196, 196, 196);border-radius: 10px;}.related-list-body tbody td span::-webkit-scrollbar-thumb {background: #949494;border-radius: 10px;}";
            // For accurate calculation of row numbers
            x += ".related-list-body table > tbody > tr.slds-hint-parent { counter-increment: row-number1; } .related-list-body .slds-table .slds-row-number:after { content: counter(row-number1); }";
            // To disable row hover
            x += ".related-list-body tr:hover > * { background-color: #fff !important; }";
            x += "</style>";
            e.innerHTML = x;
            this.styleAdded = true;
        }
        // this.template.querySelector(".related-list-body tbody").classList.add("c-custom-counter");
    }

    @wire(getRecord, { recordId: "$recordId", fields: ["Case.RecordTypeId"] })
    caseRecord;

    get recordTypeId() {
        return getFieldValue(this.caseRecord.data, "Case.RecordTypeId");
    }

    get showLoading() {
        return this.showLoading1 || this.showLoading2;
    }

    @wire(getRelatedListInfo, {
        parentObjectApiName: "$objectApiName",
        relatedListId: "$notesRelatedList",
        optionalFields: "$notesFields",
        restrictColumnsToLayout: false
    })
    wiredListInfo({ error, data }) {
        if (data) {
            this.relatedListColumns = data.displayColumns;
            this.lookupField = data.fieldApiName;
            console.log(JSON.stringify(data, null, 2));
            // to sort the columns based on the order of fields in the pNotesFields (when restrictColumnsToLayout is false, the order of fields in the relatedListColumns is not guaranteed to be the same as the order of fields in the pNotesFields. Hence the sorting is necessary)
            let columnMap = {};
            this.relatedListColumns.forEach((col) => {
                columnMap[col.fieldApiName] = col;
            });
            let columns = [];
            let listOfFields = this.pNotesFields.split(",").map((field) => field.trim());
            listOfFields.forEach((field) => {
                if (columnMap[field]) columns.push(columnMap[field]);
            });

            // preparing the columns for the datatable
            this.dataTableColumns = columns.map((col) => this.prepareDatatableColumn(col));
            this.dataTableColumnsMap = {};
            this.dataTableColumns.forEach((col) => {
                this.dataTableColumnsMap[col.fieldName] = col;
            });
            this.fieldApiNames = this.relatedListColumns.map((col) => col.fieldApiName);
            this.relatedListFields = this.fieldApiNames.map((col) => this.noteObjectApiName + "." + col);
        } else if (error) {
            console.error(JSON.stringify(error, null, 2));
            this.showLoading1 = false;
            this.unsupportedListview = true;
        }
    }

    prepareDatatableColumn(col) {
        let x = {
            label: col.label,
            fieldName: col.fieldApiName,
            sortable: col.sortable,
            type: col.dataType
        };

        if (col.dataType === "textarea") {
            x.type = "richText";
            x.wrapText = false;
        } else if (col.dataType === "boolean") {
            x.initialWidth = 80;
        } else if (this.isUrlCol(col)) {
            x.type = "url";
            x.typeAttributes = {
                label: { fieldName: x.fieldName }
            };
            x.fieldName = col.lookupId + "_URL";
        }
        return x;
    }

    isUrlCol(col) {
        return col.dataType === "string" && col.lookupId !== null;
    }

    isNameCol(col) {
        return col.dataType === "string" && col.lookupId === "Id";
    }

    isPicklistCol(col) {
        return col.dataType === "picklist";
    }

    handleSort(event) {
        this.showLoading1 = true;
        this.moveScrollbarToTop();
        this.forceRefresh = true;
        this.sortedBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.pageToken = null;
    }

    get sortBy() {
        let x = this.noteObjectApiName + ".";
        let z = this.dataTableColumnsMap ? this.dataTableColumnsMap[this.sortedBy] : null;
        x = z && z.type === "url" ? x + z.typeAttributes.label.fieldName : x + this.sortedBy;
        let y = this.sortDirection === "asc" ? x : "-" + x;
        return [y];
    }

    get sortedByFieldLabel() {
        let z = this.dataTableColumnsMap ? this.dataTableColumnsMap[this.sortedBy] : null;
        return z ? z.label : "";
    }

    prepareNote(record) {
        let note = {};
        function getLookupObjectName(column) {
            return column.fieldApiName.split(".")[0];
        }
        try {
            this.relatedListColumns.forEach(
                function (col) {
                    let field = col.fieldApiName;
                    if (this.isUrlCol(col)) {
                        note[field] = field in record.fields ? record.fields[field].value : record.fields[getLookupObjectName(col)].displayValue;
                        note[col.lookupId + "_URL"] = "/" + record.fields[getLookupObjectName(col)].value.id;
                    } else {
                        let v = record.fields[field].displayValue ? record.fields[field].displayValue : record.fields[field].value;
                        note[field] = v;
                    }
                }.bind(this)
            );
        } catch (error) {
            console.error(error);
        }
        
        note.Id = record.id;
        note.Id_URL = "/" + record.id;
        return note;
    }

    @wire(getRelatedListRecords, {
        parentRecordId: "$recordId",
        relatedListId: "$notesRelatedList",
        fields: "$relatedListFields",
        sortBy: "$sortBy",
        pageSize: "$pageSize", // max pageSize = 249; default = 50
        pageToken: "$pageToken",
        where: "$filterText"
    })
    wiredNotes(result) {
        if (!this.relatedListFields) {
            return;
        }
        this.wiredNotesResult = result;
        const { error, data } = result;
        if (data) {
            let x = [];
            data.records.forEach((record) => {
                x.push(this.prepareNote(record));
            });
            if (this.currentPageToken && this.currentPageToken === data.previousPageToken) {
                let z = JSON.parse(JSON.stringify(this.notes));
                Array.prototype.push.apply(z, x);
                this.notes = z;
            } else {
                this.notes = x;
            }
            this.currentPageToken = data.currentPageToken;
            this.nextPageToken = data.nextPageToken;
            if (this.forceRefresh) this.refreshData();
            if (this.dataTable) this.dataTable.isLoading = false;
            this.showLoading1 = false;
        } else if (error) {
            console.error(JSON.stringify(error));
            this.notes = [];
            this.showLoading1 = false;
        }
    }

    get recordCount() {
        return this.notes ? this.notes.length : 0;
    }

    get hasNotes() {
        return this.recordCount !== 0;
    }

    get showEmptyMessage() {
        return !this.showLoading && !this.hasNotes;
    }

    get showListMeta() {
        return this.recordCount > 1;
    }

    get recordCountMeta() {
        return this.nextPageToken ? this.recordCount + "+" : this.recordCount;
    }

    get relatedListTitleWithCount() {
        return this.relatedListTitle + " (" + this.recordCountMeta + ")";
    }

    handleClipWrap() {
        if (this.dataTableColumns) {
            let x = JSON.parse(JSON.stringify(this.dataTableColumns));
            this.wrapText = !this.wrapText;
            x.forEach((col) => {
                col.wrapText = this.wrapText;
            });
            this.dataTableColumns = x;
        }
    }

    handleRefreshList() {
        this.moveScrollbarToTop();
        this.showLoading2 = true;
        if (this.pageToken) {
            this.pageToken = null;
            this.currentPageToken = null;
            this.forceRefresh = true;
        } else {
            this.refreshData(this.wiredNotesResult);
        }
    }

    moveScrollbarToTop() {
        try {
            this.template.querySelector("c-custom-datatable").customScrollToTop();
        } catch (error) {
            console.error(error);
        }
    }

    async refreshData() {
        this.showLoading2 = true;
        this.forceRefresh = false;
        await refreshGraphQL(this.wiredNotesResult);
        this.showLoading2 = false;
    }

    handleLoadMore(event) {
        event.preventDefault();
        if (this.nextPageToken) {
            this.dataTable = event.target;
            event.target.isLoading = true;
            this.loadMoreData();
            // event.target.isLoading = false;
        } else {
            event.target.enableInfiniteLoading = false;
        }
    }

    loadMoreData() {
        // comment the below line when infinite loading is enabled
        // this.showLoading1 = true;

        this.pageToken = this.nextPageToken;
    }

    async handleShowSavingModal() {
        const isSuccess = await QuickSavingModal.open({
            size: 'large',
            msg: 'Quick Saving Modal',
        });

        if (isSuccess) {
            console.log('popup show', isSuccess);
        }
    }

    // navigateToNewRecordPage() {
    //     let x = {};
    //     x[this.lookupField] = this.recordId;
    //     const defaultValues = encodeDefaultFieldValues(x);
    //     try {
    //         this[NavigationMixin.Navigate]({
    //             type: "standard__objectPage",
    //             attributes: {
    //                 objectApiName: this.noteObjectApiName,
    //                 actionName: "new"
    //             },
    //             state: {
    //                 nooverride: "1",
    //                 navigationLocation: "RELATED_LIST",
    //                 defaultFieldValues: defaultValues
    //             }
    //         });
    //     } catch (error) {
    //         console.error(error);
    //     }
    // }
}