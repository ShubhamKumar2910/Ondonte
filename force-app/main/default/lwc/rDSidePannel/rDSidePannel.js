import { LightningElement, wire, track} from "lwc";
import getJobRequisitions from "@salesforce/apex/RecruiterDashboardPannelController.getJobRequisitions";
import { fireEvent,registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import { refreshApex } from "@salesforce/apex";

export default class RDSidePannel extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    requisitions = [];
    requisitionsBadge = "";
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
    @track isTemporary = false;

    get filterOptions() {
        return [
            { label: "All Open", value: "all_open" },
            { label: "This Week", value: "THIS_WEEK" },
            { label: "This Month", value: "THIS_MONTH" },
            { label: "Today", value: "TODAY" },
            { label: "Last Week", value: "LAST_WEEK" },
            { label: "Last Month", value: "LAST_MONTH" },
            { label: "Last 90 Days", value: "LAST_90_DAYS" },
        ];
    }


    connectedCallback() {
        debugger;
        registerListener('jobApplicationCreated', this.refreshRequisitions, this); //register for job change event
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
    
    @wire(getJobRequisitions, {accId: "$accId", filter: "$currentFilter", isTemp: "$tempFilterSelected", isPermnt: "$perFilterSelected"})
    wiredRequisitions(result) {
        this.reqWireResult = result;
        let sORequisitions = [];
        debugger;
        if(result.data) {
            if(result.data.length > 0) {
                result.data.forEach((req, index) => {

                    let reqClone = {... req.jobReq};
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
                    reqClone.isPermanentPlacement = reqClone.Placement_Type__c === "Permanent" ? true : false;
                    sORequisitions.push(reqClone);
                });
                debugger;
                console.log(sORequisitions);
                this.requisitions = sORequisitions;
            }else {
                this.requisitions = [];
                this.selectedRequisition = undefined;
            }
            this.notifySiblings();
            this.requisitionsBadge = `Total Requisitions: ${this.requisitions.length}`;
            this.error = undefined;
        }else if(result.error) {
            console.log(result.error);
            this.error = result.error;
            this.requisitions = [];
        }
    }

    showMore() {
        //TODO:
    }
    

    refreshRequisitions(jobId) {
        debugger;
        this.refreshedJobId = jobId;
        refreshApex(this.reqWireResult);
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

    accSelectionHandler(event) {
        console.log(event);
        debugger;
        if(event && event.detail != undefined)
            this.accId = event.detail;
    }

    notifySiblings() {
        debugger;
        this.isTemporary = this.selectedRequisition && this.selectedRequisition.Placement_Type__c==="Temporary"
        fireEvent(this.pageRef, 'jobChanged', this.selectedRequisition);
    }
    
    handleJobChange(event) {
        debugger;

        let previousSelection = this.template.querySelector('.selectedRequisition');
        if(previousSelection != null) {
            previousSelection.classList.remove('selectedRequisition');
        }
        let selectedID = event.currentTarget.dataset.id;
        event.currentTarget.classList.add('selectedRequisition');
        this.selectedRequisition = this.requisitions.find(requisition => selectedID === requisition.Id);
        console.log('selectedRequisition - ',this.selectedRequisition);
        this.notifySiblings();
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
        
    }

    handlePermanentClick(event) {
        debugger;
        this.tempFilterSelected = false;
        this.perFilterSelected = true;
        event.currentTarget.classList.remove("slds-button_neutral");
        event.currentTarget.classList.add("slds-button_brand");

        this.template.querySelector('[data-id="temp-btn"]').classList.add("slds-button_neutral");
        this.template.querySelector('[data-id="temp-btn"]').classList.remove("slds-button_brand");
        
    }
}