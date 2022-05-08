import { LightningElement, wire,track, api} from 'lwc';
import {CurrentPageReference, NavigationMixin} from 'lightning/navigation';
import submitToClientApex from '@salesforce/apex/RecruiterDashboardContentController.submitToClient';
import createPlacementApex from '@salesforce/apex/RecruiterDashboardContentController.createPlacement';
import sendRequestInterviewFeedback from '@salesforce/apex/RecruiterDashboardContentController.sendRequestInterviewFeedback';
import updateInterviewStatusApex from '@salesforce/apex/RecruiterDashboardContentController.updateInterviewStatus';
import { fireEvent,registerListener, unregisterAllListeners } from 'c/pubsub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Job_Application__c.Application_Stage__c';
import ID_FIELD from '@salesforce/schema/Job_Application__c.Id';

export default class RDTopPanel extends NavigationMixin(LightningElement) {

    @wire(CurrentPageReference) pageRef;
    job = {};
    createApplication = [];
    currentApplicantsCount = 0;
    showPrefferedCandidatesModal = false;
    @track loaded = true;
    hasLoaded = false;
    jobSelected = false;
    showActive = false;
    showInterviewPopup = false;
    @track isAllApplicationSelected = false;
    @track applicationSelected = [];
    @track recordsToDisplay;
    @track smsUrl = "";
    @track smsPopup = false;
    @track No_Of_Positions__c;
    @track reqPosMsg;
    @track openSpot = 0;
    @track openSpotMsg;
    @track numberOfPlaced = 0;
    @track registerBlockerActive = false;
    updateInterviewStatusCheced = "Selected";


    get eventActions() {
        return [
            {label: 'Select Candidate',value:'Selected'},
            {label: 'Reject Candidate',value:'Rejected'}
        ];
    }

    handleEventUpdateStatusInterview(event){
        debugger;
        let value = event.detail.value;
        this.updateInterviewStatusCheced = value;    
    }

    
    actions = [
        { label: 'View', value: 'view' },
        { label: 'Edit', value: 'edit' },
    ];

    columns = [
        { label: 'ApplicationName', fieldName: 'ApplicationName'},
        { label: 'Status', fieldName: 'Application_Stage__c'},
        { label: 'Created Date', fieldName: 'CreatedDate'},
        { label: 'App Source', fieldName: 'Type__c'},
        { label: 'Candidate', fieldName: 'Name'},
        { label: 'Email', fieldName: 'email' },
        { label: 'Phone', fieldName: 'phone' },
        { 
            type: 'action',
            typeAttributes: { rowActions: this.actions },
        },
    ];


    prefCandidatesColumn = [
        { label: 'Name', fieldName: 'Name'},
        { label: 'Status', fieldName: 'Application_Stage__c'},
        { label: 'Created Date', fieldName: 'CreatedDate'},
        { label: 'App Source', fieldName: 'Type__c'},
        { label: 'Candidate', fieldName: 'Name'},
        { label: 'Email', fieldName: 'email' },
        { label: 'Phone', fieldName: 'phone' },
        { 
            type: 'action',
            typeAttributes: { rowActions: this.actions },
        },
    ];

    connectedCallback() {
        //registerListener('jobChanged', this.updateCurrentJob, this); //register for job change event
    }




    @api
    setupJob(job) {
        debugger;
        console.log('--- job selected'+JSON.stringify(job));
        this.job = job;
        if(this.job) {
            this.No_Of_Positions__c = this.job.No_Of_Positions__c;
            this.numberOfPlaced = 0;
            this.reqPosMsg = `Position (${this.job.No_Of_Positions__c})`;
            this.jobSelected = true;
            console.log("Job------",this.job);
            debugger;
            this.createApplication = [];
            this.applicationSelected = [];

            this.showActive = this.job.Status__c === "Open";

            if(this.job && this.job.Job_Applications__r){

                this.job.Job_Applications__r.forEach(application=>{

                    if(application.Application_Stage__c==='Placed'){
                        this.numberOfPlaced++;
                    }

                    let applicationObj = {
                        "Id":application.Id,
                        "ApplicationName":application.Name,
                        "Application_Stage__c":application.Application_Stage__c,
                        "CreatedDate":application.CreatedDate,
                        "Type__c":application.Type__c,
                        "conId":application.Contact__r.Id,
                        "Name":application.Contact__r.Name,
                        "profile":application.Contact__r.Profile?application.Contact__r.Profile:"https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png",
                        "email":application.Contact__r.Email,
                        "phone":application.Contact__r.Phone,
                        "checked":false,
                        "interviewVisible":application.Application_Stage__c==="Submitted To Client",
                        "showUpdateInterview": application.Application_Stage__c==="Interview Scheduled",
                        "Request_Interview_Feedback__c":application.Request_Interview_Feedback__c,
                        showActions:false
                    }

                    if(applicationObj.Application_Stage__c=="Placed" || applicationObj.Application_Stage__c=="Withdrawn by Candidate" || applicationObj.Application_Stage__c=="Rejected by Client" || applicationObj.Application_Stage__c=="Final Candidate Selected"){
                        applicationObj.showWithDraw = false;
                    }else{
                        applicationObj.showWithDraw = true;
                    }
                    this.createApplication.push(applicationObj);
                })

                this.hasLoaded = true;
                console.log("APPLICATIONS________",this.createApplication);
            }else{
                this.createApplication = [];
                this.hasLoaded = false;
            }
            this.openSpot = this.No_Of_Positions__c-this.numberOfPlaced;
            this.openSpotMsg = `Open Spot(${this.No_Of_Positions__c-this.numberOfPlaced})`
            this.currentApplicantsCount = `Applicants(${this.job && this.job.Job_Applications__r ? this.job.Job_Applications__r.length : 0})`;
            this.registerLimitBroker();
            this.setRecordsToDisplay();
        }else {
            this.jobSelected = false;
        }
    }

    openDropDown(event){
        let conId = event.currentTarget.dataset.id;
        this.recordsToDisplay.forEach(app=> app.showActions = app.showActions===false && app.conId===conId);
    }

    closeJobStatus(){
        this.job.Status__c = 'Close';
        this.showActive = false;
    }


    interviewSchedulerAppId;
    openInterviewPopup(event){
        debugger;
        this.interviewSchedulerAppId = event.currentTarget.dataset.appid;
        if(this.interviewSchedulerAppId) {
            this.showInterviewPopup = true;
        }
    }

    handleInterviewUpdateSuccess(event) {
        debugger;
        console.log(event);
        this.showInterviewPopup = false;
        this.closeDropDown();
        this.notifyParent();
    }        

    closeInterviewPopup(){
        this.showInterviewPopup = false;
        this.closeDropDown();
    }

    showPrefModalHandler(){
        this.showPrefferedCandidatesModal = !this.showPrefferedCandidatesModal;
    }

    disconnectedCallback() {
        //unregisterAllListeners(this);
    }

    editJobRequistion(){
        this[NavigationMixin.Navigate]({
            type:'standard__objectPage',
            attributes:{
                recordId:this.job.Id,
                objectApiName:'Job_Requisition__c',
                actionName: 'edit'
            }
        })
    }

    showUpdateInterview = false;
    @track updateInterviewEventId;

    openShowUpdateInterview(event){
        debugger;
        let appId = event.currentTarget.dataset.appid;
        if(this.job.appInterviewEvent && this.job.appInterviewEvent[appId]){
            this.updateInterviewEventId = this.job.appInterviewEvent[appId].Id;
            this.showUpdateInterview = true;
        }else{
            this.showNotification('Empty!',"Couldn't find interview ",'warning');
        }
    }

    updateInterviewStatus(){
        this.loaded = false;
        console.log('eventId',this.updateInterviewEventId,'insterviewStatus',this.updateInterviewStatusCheced);
        updateInterviewStatusApex({'eventId':this.updateInterviewEventId,'insterviewStatus':this.updateInterviewStatusCheced}).then(result=>{
            debugger;
            if(result=='Success'){
                console.log("RESULT",result);
                this.closeUpdateInterview();
                this.notifyParent();
                this.closeDropDown();
            }
            this.loaded = true;
        })
    }

    closeUpdateInterview(){
        this.showUpdateInterview = false;
    }

    openJobDetailPage(){
        this[NavigationMixin.GenerateUrl]({
            type:'standard__recordPage',
            attributes:{
                recordId:this.job.Id,
                objectApiName:'Job_Requisition__c',
                actionName: 'view'
            }
        }).then(url=>{
            window.open(url, "_blank");
        })
    }

    applicationNavigation(event){
        console.log("recordsToDisplay",this.recordsToDisplay);
        let appId = event.currentTarget.dataset.id;

        this[NavigationMixin.GenerateUrl]({
            type:'standard__recordPage',
            attributes:{
                recordId:appId,
                objectApiName:'Job_Application__c',
                actionName: 'view'
            }
        }).then(url=>{
            window.open(url, "_blank");
        })
    }

    selectAllApplication(){
        this.applicationSelected = [];

        let tempRecommends = [];
        this.isAllApplicationSelected = !this.isAllApplicationSelected;

        this.createApplication.forEach(con=>{
            if(this.isAllApplicationSelected){
                this.applicationSelected.push(con)
            }else{
                this.applicationSelected = [];
            }
            //this.isAllApplicationSelected?this.applicationSelected.push(con):this.applicationSelected.pop(con);
            con.checked = this.isAllApplicationSelected;
            tempRecommends.push(con);
        })
        debugger;
        this.createApplication = tempRecommends;
    }

    applicationTableRowListener(event){
        let candidateId = event.currentTarget.dataset.id;

        let tempRecommends = [];
        let totalChecked = 0;

        this.createApplication.forEach(con=>{
            if(con.Id===candidateId){
                con.checked = !con.checked;
                if(con.checked){
                    this.applicationSelected.push(con)
                }else{
                    this.applicationSelected = this.applicationSelected.filter(rec=>rec.Id!=con.Id);
                }
                //con.checked ? this.applicationSelected.push(con):this.applicationSelected.pop(con);
            }
            totalChecked+= con.checked?1:0;
            tempRecommends.push(con);
        })
        debugger;
        this.isAllApplicationSelected = this.createApplication.length===totalChecked;
        this.createApplication = tempRecommends;

        console.log("SelectedContactFromTable",this.applicationSelected);
    }

    setRecordsToDisplay() {
        debugger;
        this.totalRecords = this.createApplication.length;
        this.recordsperpage = 5;
        this.pageNo = 1;
        this.totalPages = Math.ceil(this.totalRecords / this.recordsperpage);
        debugger;
        this.pagelinks = [];
        for (let i = 1; i <= this.totalPages; i++) {
            this.pagelinks.push(i);
        }
        this.preparePaginationList();
        this.isLoading = false;
    }


    handleClick(event) {
        let label = event.target.label;
        if (label === "First") {
            this.handleFirst();
        } else if (label === "Previous") { 
            this.handlePrevious();
        } else if (label === "Next") {
            this.handleNext();
        } else if (label === "Last") {
            this.handleLast();
        }
    }

    handleNext() {
        debugger;
        this.pageNo += 1;
        this.preparePaginationList();
    }

    handlePrevious() {
        this.pageNo -= 1;
        this.preparePaginationList();
    }

    handleFirst() {
        this.pageNo = 1;
        this.preparePaginationList();
    }

    handleLast() {
        this.pageNo = this.totalPages;
        this.preparePaginationList();
    }

    handlePage(button) {
        debugger;
        this.pageNo = button.target.label;
        this.preparePaginationList();
    }

    preparePaginationList() {
        console.log('this.pageNo-' + this.pageNo);
        let begin = (this.pageNo - 1) * parseInt(this.recordsperpage);
        let end = parseInt(begin) + parseInt(this.recordsperpage);
        debugger;
        this.recordsToDisplay = this.createApplication.slice(begin, end);
        console.log('this.begin-' + begin);
        console.log('this.end-' + end);
        console.log('this.recordsToDisplay-' + this.recordsToDisplay);
        this.startRecord = begin + parseInt(1);
        this.endRecord = end > this.totalRecords ? this.totalRecords : end;
        this.end = end > this.totalRecords ? true : false;

        const event = new CustomEvent('pagination', {
            detail: {
                records: this.recordsToDisplay
            }
        });
        this.dispatchEvent(event);

        // window.clearTimeout(this.delayTimeout);
        // this.delayTimeout = setTimeout(() => {
        //     this.disableEnableActions();
        // }, DELAY);
        this.isLoading = false;
    }

     searchHandler(event){
        let value = event.target.value.toLowerCase();
        if(value.length===0){
            this.setRecordsToDisplay();
        }else{
            this.recordsToDisplay = this.createApplication.filter((data) => {
                return data.Name.toLowerCase().search(value) !== -1;
            })
        }
    }

    openSendSmSPopup(event){
        debugger;
        const recId = event.currentTarget.dataset.id;

        this.smsUrl = `https://ondonte--dev.lightning.force.com/apex/tdc_tsw__SendSMS?id=${recId}&retURL=${window.location.href}`;
        console.log("URL------------------",this.smsUrl)
        this.smsPopup = true;
    }

    closeSMSPopup(){
        this.smsPopup = false;
        this.closeDropDown();
    }

    closeDropDown(){
        this.recordsToDisplay.forEach(app=> app.showActions = false);
    }

    bulkSmsHandler(event){
        console.log("selectedContactsFromTable",this.applicationSelected);
        let smsParticipants = [];
        this.applicationSelected.forEach(can=>{
            smsParticipants.push(can.conId);
        })
        if(smsParticipants.length > 0){
            this.smsUrl = `https://ondonte--dev.lightning.force.com/apex/tdc_tsw__SendBulkSMS_SLDS?ids=${smsParticipants}&redirectURL=${window.location.href}`;
            window.open(this.smsUrl, '_blank');
            console.log("SMSURL----------------",this.smsUrl);
        }else{
            this.showNotification('Failed',"Please select Candidate","warning");
            //alert('Please select any candidate');
        }
    }

    showValidationsError(canNames, type){
        canNames = canNames.substr(0, canNames.length - 1);
        let errorMsg = '';
        debugger;
        if(type == 'request'){
            errorMsg = canNames + "- You can only submit " +'"Interview Scheduled"';
        }else if(type=='submit'){
            errorMsg = canNames + "- You can only submit " +'"Selected by Recruiter"';
        }else if(type=='selectByRecruiter'){
            errorMsg = canNames + "- You can only submit " +'"Accepted By Candidate"';
        }
        else{
            errorMsg = canNames + "- You can only submit " +'"Selected by Client"';
        }
        this.showNotification("Failed",errorMsg,"warning");
    }

    showNotification(title,message,variant){

        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    submitToClient(){
        const status = "Selected By Recruiter";
        let canNames='';
        let selectedAppId = [];
        let hasError = false;
        this.loaded = false;

        this.applicationSelected.forEach(app=>{
            console.log('APPPNAME',app);
            if(app.Application_Stage__c!=status){
                canNames+=app.Name+" ,";
                hasError = true;
            }else if(!hasError && app.Application_Stage__c===status){
                selectedAppId.push(app.Id)
            }  
        });

        console.log("APPPNAME----",canNames);

        if(hasError){
            this.loaded = true;
            this.showValidationsError(canNames,'submit');
            return;
        }
        
        if(this.applicationSelected && this.applicationSelected.length>0){
            console.log(this.applicationSelected);
            this.loaded = false;
            submitToClientApex({'applications':selectedAppId,'status':'Submitted To Client'}).then(result=>{
                console.log('RESULT',result);
                if(result==='Success'){
                    this.loaded = true;

                    let tempApps = [];
                    this.createApplication.forEach(app=>{
                        app.checked = false;
                        if(this.applicationSelected.find(rec=>rec.Id===app.Id)){
                            app.Application_Stage__c = 'Submitted To Client';
                        }
                        tempApps.push(app);
                    })

                    this.applicationSelected = [];
                    this.createApplication = tempApps;
                    this.notifyParent();

                    this.isAllApplicationSelected = false;
                    this.showNotification('Success',"Submitted to client successfully","success");
                    //alert('Submitted to client Successfully');
                }else{
                    this.loaded = true;
                    this.showNotification('Error',result,"error");
                    alert('Error',result);
                }
            }).catch(error=>console.log('Error',error))
        }else{
            this.loaded = true;
            this.showNotification('Failed',"Please select Application",'warning')
            //alert('Please select Application');
        }
    }

    requestInterview(){
        const status = "Interview Scheduled";
        let canNames='';
        let selectedAppId = [];
        let hasError = false;
        this.loaded = false;

        this.applicationSelected.forEach(app=>{
            console.log('APPPNAME',app);
            if(app.Application_Stage__c!=status){
                canNames+=app.Name+" ,";
                hasError = true;
            }else if(!hasError && app.Application_Stage__c===status && !app.Request_Interview_Feedback__c){
                selectedAppId.push(app.Id)
            }  
        });

        console.log("APPPNAME----",canNames);

        if(hasError){
            this.loaded = true;
            this.showValidationsError(canNames,'request');
            return;
        } 
        
        if(this.applicationSelected && this.applicationSelected.length>0){
            console.log(this.applicationSelected);
            this.loaded = false;
            sendRequestInterviewFeedback({'applications':selectedAppId}).then(result=>{
                console.log('RESULT',result);
                if(result==='Success'){
                    this.loaded = true;

                    let tempApps = [];
                    this.createApplication.forEach(app=>{
                        app.checked = false;
                        if(this.applicationSelected.find(rec=>rec.Id===app.Id)){
                            app.Request_Interview_Feedback__c = true;
                        }
                        tempApps.push(app);
                    })

                    this.applicationSelected = [];
                    this.isAllApplicationSelected = false;
                    this.createApplication = tempApps;
                    this.notifyParent();

                    this.showNotification('Success',"Request Interview feedback sent successfully","success");
                    //alert('Submitted to client Successfully');
                }else{
                    this.loaded = true;
                    this.showNotification('Error',result,"error");
                    alert('Error',result);
                }
            }).catch(error=>console.log('Error'))
        }else{
            this.loaded = true;
            this.showNotification('Failed',"Please select Application",'warning')
            //alert('Please select Application');
        }
    }

    
    selectedByRecruiter(){
        debugger;
        const status = "Accepted By Candidate";
        let canNames='';
        let selectedAppId = [];
        let hasError = false;
        this.loaded = false;

        this.applicationSelected.forEach(app=>{
            console.log('APPPNAME',app);
            if(app.Application_Stage__c!=status){
                canNames+=app.Name+" ,";
                hasError = true;
            }else if(!hasError && app.Application_Stage__c===status && !app.Request_Interview_Feedback__c){
                selectedAppId.push(app.Id)
            }  
        });

        console.log("APPPNAME----",canNames);

        if(hasError){
            this.loaded = true;
            this.showValidationsError(canNames,'selectByRecruiter');
            return;
        } 
        
        if(this.applicationSelected && this.applicationSelected.length>0){
            console.log(this.applicationSelected);
            this.loaded = false;
            submitToClientApex({'applications':selectedAppId,'status':'Selected By Recruiter'}).then(result=>{
                console.log('RESULT',result);
                if(result==='Success'){
                    this.loaded = true;

                    let tempApps = [];
                    this.createApplication.forEach(app=>{
                        app.checked = false;
                        if(this.applicationSelected.find(rec=>rec.Id===app.Id)){
                            app.Application_Stage__c = 'Selected By Recruiter';
                        }
                        tempApps.push(app);
                    })

                    this.applicationSelected = [];
                    this.createApplication = tempApps;
                    this.notifyParent();

                    this.isAllApplicationSelected = false;
                    this.showNotification('Success',"Selected By Recruiter Success","success");
                    //alert('Submitted to client Successfully');
                }else{
                    this.loaded = true;
                    this.showNotification('Error',result,"error");
                    alert('Error',result);
                }
            }).catch(error=>console.log('Error',error))
        }else{
            this.loaded = true;
            this.showNotification('Failed',"Please select Application",'warning')
            //alert('Please select Application');
        }
    }

    createPlacement(){

        const status = "Selected by Client";
        let canNames='';
        let selectedAppId = [];
        let hasError = false;
        this.loaded = false;

        this.applicationSelected.forEach(app=>{
            console.log('APPPNAME',app);
            if(app.Application_Stage__c!=status){
                canNames+=app.Name+" ,";
                hasError = true;
            }else if(!hasError && app.Application_Stage__c===status){
                selectedAppId.push(app.Id)
            }  
        });

        if(hasError){
            this.loaded = true;
            this.showValidationsError(canNames,'placed');
            return;
        } 

        debugger;
        if(this.applicationSelected && this.applicationSelected.length>0){
            console.log(this.applicationSelected);
            this.loaded = false;
            createPlacementApex({'applications':selectedAppId}).then(result=>{
                console.log('RESULT',result);
                if(result==='Success'){
                    this.loaded = true;
                    let tempApps = [];
                    this.createApplication.forEach(app=>{
                        app.checked = false;
                        if(this.applicationSelected.find(rec=>rec.Id===app.Id)){
                            this.numberOfPlaced++;
                            app.Application_Stage__c = 'Placed';
                        }
                        tempApps.push(app);
                    })
                    this.isAllApplicationSelected = false;
                    this.notifyChildToSaveSearch();
                    this.applicationSelected = [];
                    this.createApplication = tempApps;
                    this.openSpot = this.No_Of_Positions__c - this.numberOfPlaced;
                    this.openSpotMsg = `Open Spot(${this.openSpot})`
                    this.isAllApplicationSelected = false;
                    this.registerLimitBlocker();
                    
                    this.showNotification('Success',"Placement created Successfully.","success");
                    //alert('Placement created Successfully.');
                }else{
                    this.loaded = true;
                    this.showNotification('Error',result,"error");
                    //alert('Error',result);
                }
            }).catch(error=>console.log('Error'))
        }else{
            this.loaded = true;
            this.showNotification('Failed',"Please select Application","warning");
            //alert('Please select Application');
        }
    }

    openCanidateDetailPage(event){
        let conId = event.currentTarget.dataset.id;

        this[NavigationMixin.GenerateUrl]({
            type:'standard__recordPage',
            attributes:{
                recordId:conId,
                objectApiName:'Contact',
                actionName: 'view'
            }
        }).then(url=>{
            window.open(url, "_blank");
        })
    }

    registerLimitBroker(){
        if(this.openSpot==0){
            this.closeJobStatus();
            this.notifyChildToCloseJobApplication();
        }
        this.registerBlockerActive = this.openSpot<=0;
    }
    registerLimitBlocker(){
        if(this.openSpot!=0){
            this.notifyParent();
        }else{
            this.closeJobStatus();
            this.notifyChildToCloseJobApplication();
        }
        this.registerBlockerActive = this.openSpot<=0;
    }

    notifyParent(){
        this.dispatchEvent(new CustomEvent('placecreated', {detail : this.job.Id}));
    }

    notifyChildToSaveSearch(){
        fireEvent(this.pageRef, 'saveSearch',this.job.Id);
    }

    notifyChildToCloseJobApplication(){
        fireEvent(this.pageRef, 'jobClose',this.job.Id);
    }

    handleAction(event){
        let appId = event.currentTarget.dataset.id;
        let action = event.currentTarget.dataset.action;
        let status = event.currentTarget.dataset.status;

        if(status==action){
            this.showNotification('Candidate has Already Rejected');
            return;
        }else{
            this.updateAppStatus(appId,action);
        }
    }

    updateAppStatus(appId,status) {
        debugger;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = appId;
        fields[STATUS_FIELD.fieldApiName] = status;
        const recordInput = { fields };
        updateRecord(recordInput)
        .then((result) => {
            console.log('Updation Result----',result);
            this.notifyParent();
            //this.updateUI(shiftId,status);
        })
        .catch(error => {
           console.log('couldn\'t updated shift'+JSON.stringify(error));
        });
    }

    
}