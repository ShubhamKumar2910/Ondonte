import { LightningElement, wire, track } from 'lwc';
import { unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import getJobRequisitions from "@salesforce/apex/RecruiterDashboardPannelController.getJobRequisitions";
import { refreshApex } from "@salesforce/apex";
import { updateRecord } from 'lightning/uiRecordApi';
import LAST_REFRESHED_ONFIELD from '@salesforce/schema/Job_Requisition__c.RD_Last_Refreshed_On__c';
import ID_FIELD from '@salesforce/schema/Job_Requisition__c.Id';

const TYPE_TEMPORARY = 'TEMPORARY';

const DATE_FORMAT_OPTIONS = {
    year: 'numeric', month: 'numeric', day: 'numeric',
    hour: 'numeric', minute: 'numeric',
    hour12: true
};
export default class RecruitorDashboardParent extends LightningElement {    
    @wire(CurrentPageReference) pageRef;
    requisitions = [];
    tempRequisitions = [];
    @track requisitionsBadge = "";
    error;
    selectedRequisition;
    accId = "";
    currentFilter = "all_open";
    tempFilterSelected = true;
    perFilterSelected = false;
    tempBtnClass = "slds-button slds-button_brand";
    permntBtnClass = "slds-button slds-button_neutral";
    reqWireResult;
     refreshedJobId = undefined;
    isTemporary = true;
    
    get filterOptions() {
        return [
            { label: "All Open", value: "all_open" },
            { label: "This Week", value: "THIS_WEEK" },
            { label: "This Month", value: "THIS_MONTH" },
            { label: "Today", value: "TODAY" },
            { label: "Tomorrow", value: "TOMORROW" },
            { label: "Next Week", value: "NEXT_WEEK" },
            { label: "Next Month", value: "NEXT_MONTH" },
            { label: "Next 90 Days", value: "NEXT_90_DAYS" },
        ];
    }


    connectedCallback() {  
    }

    onAppCreated(customEvent) {
        debugger;
        console.log('AskingFor-------',customEvent.detail);
        if(customEvent.detail) 
            this.refreshRequisitions(customEvent.detail); //register for job change event
    }


    onShiftCreated(customEvent) {
        debugger;
        if(customEvent.detail) 
            this.refreshRequisitions(customEvent.detail); //register for job change event
    }

    onPlaceCreated(customEvent) {
        debugger;
        if(customEvent.detail) 
            this.refreshRequisitions(customEvent.detail); //register for job change event
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
    
    tempActiveAccordianSectionName = '';
    @wire(getJobRequisitions, {accId: "$accId", filter: "$currentFilter", isTemp: "$tempFilterSelected", isPermnt: "$perFilterSelected"})
    wiredRequisitions(result) {
        this.reqWireResult = result;

        this.requisitions = [];
        this.requisitionsBadge = `Total Requisitions: ${this.requisitions.length}`;
        let sORequisitions = [];
        debugger;
        if(result.data) {
            if(result.data.responseType === TYPE_TEMPORARY && result.data.responseObject && result.data.responseObject.length > 0) {
                this.tempActiveAccordianSectionName = result.data.responseObject[result.data.responseObject.length-1].accordianHeader;
                this.tempRequisitions = [];
                result.data.responseObject.forEach((req, index) => {
                    let respWrapper = { uniqueId: req.uniqueId, responseType: req.responseType, accordianHeader: req.accordianHeader, requisitionShiftList: [] };
                    req.requisitionShiftList.forEach((reqShift) => {
                        let shiftClone = {...reqShift};
                        let sd = new Date(reqShift.Start_DateTime__c);
                        let ed = new Date(reqShift.End_DateTime__c);
                        shiftClone.Start_DateTime__c = new Intl.DateTimeFormat('en-US',DATE_FORMAT_OPTIONS).format( sd );
                        shiftClone.End_DateTime__c = new Intl.DateTimeFormat('en-US',DATE_FORMAT_OPTIONS).format( ed );
                        respWrapper.requisitionShiftList.push(shiftClone);
                    });
                    this.tempRequisitions.push(respWrapper);
                });
            }else {
                if(result.data.responseObject.length > 0) {
                    
                    if(this.refreshedJobId && !result.data.responseObject.find(res=>res.jobReq.Id===this.refreshedJobId)){
                        this.refreshedJobId = undefined;
                    }
    
                    result.data.responseObject.forEach((req, index) => {
                        let reqClone = {... req.jobReq};
                        console.log('JOBREQ-------',reqClone);
                        if(this.refreshedJobId == undefined && index == 0) {
                            console.log(`index ${index} :`,this.selectedRequisition);
                            this.selectedRequisition = reqClone;
                            reqClone.class = 'slds-border_top selectedRequisition';
                        }
                        else if(this.refreshedJobId == reqClone.Id) {
                            this.selectedRequisition = reqClone;
                            reqClone.class = 'slds-border_top selectedRequisition';
                            this.refreshedJobId = undefined;
                        }else {
                            reqClone.class = 'slds-border_top';
                        }
                        reqClone.prefCandidates = req.prefList? req.prefList:[];
                        reqClone.staffType = req.staffTypeList;
                        reqClone.appInterviewEvent = req.appInterviewEvent? req.appInterviewEvent:{};
                        reqClone.isPermanentPlacement = reqClone.Placement_Type__c === "Permanent" ? true : false;
                        reqClone.tempOpenShiftCount = req.tempOpenShiftCount;
                        sORequisitions.push(reqClone);
                    });
                    debugger;
                    console.log(sORequisitions);
                    this.requisitions = sORequisitions;
                }else {
                    this.requisitions = [];
                    this.selectedRequisition = undefined;
                }
                this.isTemporary = this.selectedRequisition && this.selectedRequisition.Placement_Type__c === "Temporary";
                this.notifyChildrens();
                this.requisitionsBadge = `Total Requisitions: ${this.requisitions.length}`;
                this.error = undefined;
            }
        }else if(result.error) {
            console.log(result.error);
            this.error = result.error;
            this.requisitions = [];
        }
    }

    currentStaffType = 'DA';

    get staffType() {
        return [
            { label: 'DA', value: 'DA' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Finished', value: 'finished' },
        ];
    }

    staffTypeChange(event) {
        this.currentStaffType = event.detail.value;
    }

    showMore() {
        //TODO:
    }
    

    refreshRequisitions(jobId) {
        debugger;
        this.updateRefreshJR(jobId);
    }

    updateRefreshJR(jobId) {
        debugger;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = jobId;
        fields[LAST_REFRESHED_ONFIELD.fieldApiName] = new Date().toISOString();
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
            this.refreshedJobId = jobId;
            refreshApex(this.reqWireResult);
        })
        .catch(error => {
           console.log('couldn\'t refresh job'+JSON.stringify(error));
        });
    }
    
    handleFilterChange(event) {
        debugger;
        this.currentFilter = event.target.value;
    }

    hardSortClick() {
        
    }
    handleFilterClick() {
        
    }
    handleSearchClick() {
        
    }

    handleCardChild(event) {
        //event.stopPropagation();
    }
    //TODO:
    columns = [
        { label: 'Label', fieldName: 'name' },
        { label: 'Status', fieldName: 'status'},
        { label: 'Start Time', fieldName: 'startTime'},
        { label: 'End Time', fieldName: 'endTime'},
    ];

    data = [{name:"SHFT-001", status:"open", startTime:"2022-05-09T03:00:00.000Z", endTime:"2022-05-09T03:00:00.000Z"}];

    handleToggleSection() {
        /* const accordion = this.template.querySelector('.example-accordion');
        accordion.activeSectionName = 'C'; */
    }

    accSelectionHandler(event) {
        console.log(event);
        debugger;
        if(event && event.detail != undefined)
            this.accId = event.detail;
    }

    notifyChildrens() {
        debugger;
        //condiotianally
        if(!this.isTemporary) {
            console.log('SelectedRequisition',this.selectedRequisition);
            setTimeout(() => this.template.querySelector('c-r-d-top-panel').setupJob(this.selectedRequisition));
            setTimeout(() => this.template.querySelector('c-r-d-content').setupJob(this.selectedRequisition));
        }else {
            setTimeout(() => this.template.querySelector('c-r-d-content-temporary-top').setupJob(this.selectedRequisition));
        }
    }
    
    handleJobChange(event) {
        debugger;
        let selectedID = event.currentTarget.dataset.id;
        if(selectedID && selectedID === this.selectedRequisition.Id) {
            return;
        }

        let previousSelection = this.template.querySelector('.selectedRequisition');
        if(previousSelection != null) {
            previousSelection.classList.remove('selectedRequisition');
        }
        
        event.currentTarget.classList.add('selectedRequisition');
        this.selectedRequisition = this.requisitions.find(requisition => selectedID === requisition.Id);
        console.log('selectedRequisition - ',this.selectedRequisition);
        this.notifyChildrens();
        //this.template.querySelector('[data-id="contactpopup"]');
        //this.template.querySelector('.yesBtn').classList.add('dynamicCSS');
    }

    handleTempClick(event) {
        debugger;
        
        this.tempFilterSelected = true;
        this.perFilterSelected = false;
        event.currentTarget.classList.remove("slds-button_neutral");
        event.currentTarget.classList.add("slds-button_brand");

        this.template.querySelector('[data-id="permnt-btn"]').classList.add("slds-button_neutral");
        this.template.querySelector('[data-id="permnt-btn"]').classList.remove("slds-button_brand");
        this.isTemporary = true;
        this.notifyChildrens();
    }

    handlePermanentClick(event) {
        debugger;
        this.tempFilterSelected = false;
        this.perFilterSelected = true;
        event.currentTarget.classList.remove("slds-button_neutral");
        event.currentTarget.classList.add("slds-button_brand");

        this.template.querySelector('[data-id="temp-btn"]').classList.add("slds-button_neutral");
        this.template.querySelector('[data-id="temp-btn"]').classList.remove("slds-button_brand");
        this.isTemporary = false;
        this.notifyChildrens();
        
    }

}