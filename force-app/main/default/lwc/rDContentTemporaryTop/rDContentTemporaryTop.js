import { LightningElement, wire, track, api } from 'lwc';
import {fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference,NavigationMixin} from 'lightning/navigation';

import getShiftsByJobReqId from "@salesforce/apex/RecruiterDashboardTemporaryJobController.getShiftsByJobReqId";
import allocateCandidates from "@salesforce/apex/RecruiterDashboardTemporaryJobController.allocateCandidates";

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Shift__c.Status__c';
import ID_FIELD from '@salesforce/schema/Shift__c.Id';


const KEY_ACCEPTED_BY_CANDIDATE = "Accepted By Candidate";
const KEY_CANDIDATE_NOT_AVAILABLE = "Not Available";
const KEY_ALLOCATED = "Allocated";
const KEY_ASSIGNED = "Requested";

export default class RDContentTemporaryTop extends NavigationMixin(LightningElement) {

   @wire(CurrentPageReference) pageRef;

    @api job = {};
    incrementKey = "increment";
    decrementKey = "decrement";
    @track loaded = true;
    createApplication = [];
    currentApplicantsCount = 0;
    hasLoaded = false;
    jobSelected = false;
    showActive = false;
    showEditShiftModal = false;
    totalShiftToday = "";
    currentShiftId;
    currentShiftSelected={};
    isAppliedShiftAllChecked = false;
    allMonthCalendar = [];

    monthlyShiftMsg;
    thisWeekShiftMsg;
    selectedShiftMsg;

    monthlyShiftCount = 0;
    thisWeekShiftCount;
    selectedShiftCount;

    editClientShiftUrl = "";

    actions = [
        { label: 'View', name: 'view' },
        { label: 'Edit', name: 'edit' },
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

    childShiftcolumns = [
        { label: 'Name', fieldName: 'name'},
        { label: 'StartTime', fieldName: 'startDate'},
        { label: 'EndTime', fieldName: 'endDate'},
        {label:'Status',fieldName:'Status__c'}
    ];

    totalWeeks = 4;
    selectedDate;
    weekNumber=0;
    currentWeekDays = [];
    monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

    @track shiftReqWireResult;
    @track shiftList = [];
    @track childShiftList = [];
    @track hasChildShift = false;
    @track smsPopup = false;
    @track smsUrl = "";
    selectedCandidatesToAllocate = [];
    @track shiftSelectedForParticularDate  = [];
    @track registerBlockerActive = false;
    @track numberOfPosRequired = 0;
    @track recordsToDisplay = [];
    @track allocatedShifts = 0;

    selectCandidatesHanlder(event){
        this.selectedCandidatesToAllocate = [];
        event.detail.selectedRows.forEach(con=>{
            if(con.Status__c==='Requested'){
                this.selectedCandidatesToAllocate.push(con.Id);
            }
        })
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

    

    openShift(event){
        let shiftId = event.currentTarget.dataset.id;
        this[NavigationMixin.GenerateUrl]({
            type:'standard__recordPage',
            attributes:{
                recordId:shiftId,
                objectApiName:'Shift__c',
                actionName: 'view'
            }
        }).then(url=>{
            window.open(url, "_blank");
        })
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

    openCanidateDetailPage(event){
        let candidateId = event.currentTarget.dataset.id;
        this[NavigationMixin.GenerateUrl]({
            type:'standard__recordPage',
            attributes:{
                recordId:candidateId,
                objectApiName:'Contact',
                actionName: 'view'
            }
        }).then(url=>{
            window.open(url, "_blank");
        })
    }

    selectAllHandler(){
        this.selectedCandidatesToAllocate = [];
        let tempChildShiftList = [];
        this.isAppliedShiftAllChecked = !this.isAppliedShiftAllChecked;

        this.childShiftList.forEach(con=>{
            if(true/*con.Status__c==='Assigned'*/){
                if(this.isAppliedShiftAllChecked){
                    this.selectedCandidatesToAllocate.push(con.Id)
                }else{
                    this.selectedCandidatesToAllocate = [];
                }
                //this.isAppliedShiftAllChecked?this.selectedCandidatesToAllocate.push(con.Id):this.selectedCandidatesToAllocate.pop(con.Id);
            }
            con.isChecked = this.isAppliedShiftAllChecked?true:false;
            tempChildShiftList.push(con);
        })
        debugger;
        this.childShiftList = tempChildShiftList;
        this.saveRecommendedRecords();
    }

    tableIndexChange(event){
        let id = event.currentTarget.dataset.id;
        let tempChildShiftList = [];
        let totalChecked = 0;
        this.childShiftList.forEach(con=>{
            if(con.Id===id /*&& con.Status__c==='Assigned'*/){
                con.isChecked = !con.isChecked;     
                if(con.isChecked){
                    this.selectedCandidatesToAllocate.push(con.Id)
                }else{
                    this.selectedCandidatesToAllocate = this.selectedCandidatesToAllocate.filter(id=>id!=con.Id);
                }
               // con.isChecked ? this.selectedCandidatesToAllocate.push(con.Id):this.selectedCandidatesToAllocate.pop(con.Id);
            }
            totalChecked+= con.isChecked?1:0;
            tempChildShiftList.push(con);
        })
        debugger;
        this.isAppliedShiftAllChecked = this.childShiftList.length===totalChecked;
        this.childShiftList = tempChildShiftList;
        this.saveRecommendedRecords();
    }

    allocateCandidates(event){
        let selectedShiftId = [];
        let type = event.currentTarget.dataset.id;
        let canNames='';
        let hasError = false;
        let errorMsg;

        debugger;

        if(this.selectedCandidatesToAllocate && this.selectedCandidatesToAllocate.length===0){
            this.showNotification('Empty!','Please select any shift','warning');
            return;
        }

        if(this.selectedCandidatesToAllocate && this.selectedCandidatesToAllocate.length > this.numberOfPosRequired){
            this.showNotification('Failed',`Only ${this.numberOfPosRequired} candidates are required`,'error')
            return;
        }

        this.childShiftList.forEach((shift)=>{
            debugger;
            if(this.selectedCandidatesToAllocate.find(id=>id===shift.Id)){
                if(type===KEY_ACCEPTED_BY_CANDIDATE){
                    if(shift.Status__c!=KEY_ASSIGNED){
                        canNames+=shift.name+" ,";
                        errorMsg = KEY_ASSIGNED;
                        hasError=true;
                    }else{
                        selectedShiftId.push(shift.Id);
                    }
                }else if(type===KEY_ALLOCATED || type==='Submit'){
                    if(shift.Status__c!=KEY_ACCEPTED_BY_CANDIDATE){
                        canNames+=shift.name+" ,";
                        errorMsg = KEY_ACCEPTED_BY_CANDIDATE;
                        hasError=true;
                    }else{
                        selectedShiftId.push(shift.Id);
                    }
                }else if(type===KEY_CANDIDATE_NOT_AVAILABLE){
                    canNames+=shift.name+" ,";
                    errorMsg = type;
                    hasError=true;
                }
            }
        });


        if(hasError){
            canNames = canNames.substring(0, canNames.length - 1);
            this.showNotification(`${canNames}`,`You can only choose ${errorMsg}`,'error');
            return;
        }


        this.loaded = false;

        allocateCandidates({candidateList:selectedShiftId,status:type}).then(result =>{
            console.log("RESULT-----",result);
            let updateChildShiftList = [];

            this.loaded = true;

            debugger;
            this.childShiftList.forEach(shift=>{    
                debugger;
                if(this.selectedCandidatesToAllocate.includes(shift.Id)){
                    if(type==KEY_ALLOCATED){
                        shift.class = 'grayColor';
                        shift.Status__c = type;
                        this.allocatedShifts++;
                    }else if(type==KEY_ACCEPTED_BY_CANDIDATE){
                        shift.Status__c = 'Accepted By Candidate';
                        shift.class = 'grayColor';
                    }else{
                        shift.Submitted__c = true;
                        shift.isSubmitted = true;
                    }
                }
                updateChildShiftList.push(shift);
            })

            this.childShiftList = updateChildShiftList;
            this.saveRecommendedRecords();
            //this.selectedCandidatesToAllocate = [];
            this.isAppliedShiftAllChecked = false;
             let copiedShiftList = [];
            this.shiftList.forEach(item=>{
                debugger;
                item.shifts.forEach(s=>{
                    debugger;
                    if(s.Id===this.currentShiftId){
                        if(s.Shifts__r && s.Shifts__r.records){
                            s.Shifts__r.records = this.childShiftList;
                        }else{
                            s.Shifts__r={records:this.childShiftList}
                        }
                        if(this.numberOfPosRequired===this.allocatedShifts){
                            s.Status__c = "Filled";
                            s.class = 'slds-box cardhover shiftFilled';
                            fireEvent(this.pageRef, 'clearCache', null);
                        }
                    }
                })
                debugger;
                copiedShiftList.push(item);
            })
            this.shiftList = copiedShiftList;
            this.registerLimitBlocker();
            this.showNotification("Success","Candidate Allocated Successfully","success"); 

        }).catch(error=>{
            this.loaded = true;
            this.showNotification("Error",error,"error");
            console.log("Error",error);
        })
    }


    updateUI(shiftId,type){

        let updateChildShiftList = [];
        
        this.loaded = true;
        debugger;
        this.childShiftList.forEach(shift=>{    
            debugger;
            if(shift.Id == shiftId){
                if(type==KEY_ALLOCATED){
                    shift.class = 'grayColor';
                    shift.Status__c = type;
                    this.allocatedShifts++;
                }else if(type==KEY_ACCEPTED_BY_CANDIDATE){
                    shift.Status__c = 'Accepted By Candidate';
                    shift.class = 'grayColor';
                }else if(type==KEY_CANDIDATE_NOT_AVAILABLE){
                    if(shift.Status__c==KEY_ALLOCATED){
                        this.allocatedShifts--;
                    }
                    shift.Status__c = KEY_CANDIDATE_NOT_AVAILABLE;
                    shift.class = 'redColor';
                }else{
                    shift.Submitted__c = true;
                    shift.isSubmitted = true;
                }
            }
            updateChildShiftList.push(shift);
        })

        this.childShiftList = updateChildShiftList;
        this.saveRecommendedRecords();
            
        this.isAppliedShiftAllChecked = false;
        let copiedShiftList = [];
        this.shiftList.forEach(item=>{
            debugger;
            item.shifts.forEach(s=>{
                debugger;
                if(s.Id===this.currentShiftId){
                    if(s.Shifts__r && s.Shifts__r.records){
                        s.Shifts__r.records = this.childShiftList;
                    }else{
                        s.Shifts__r={records:this.childShiftList}
                    }
                    if(this.numberOfPosRequired===this.allocatedShifts){
                        s.Status__c = "Filled";
                        s.class = 'slds-box cardhover shiftFilled';
                        fireEvent(this.pageRef, 'clearCache', null);
                    }else if(s.Status__c=="Filled"){
                        s.Status__c = "Open";
                        s.class = 'slds-box cardhover cardSelected';
                        fireEvent(this.pageRef, 'shiftClicked', this.currentShiftSelected);
                    }
                }
            })
            debugger;
            copiedShiftList.push(item);
        })
        this.shiftList = copiedShiftList;
        this.registerLimitBlocker();
        this.showNotification("Success",`Marked ${type} Successfully`,"success"); 
    }

    getShiftsData(){
        this.monthlyShiftCount = 0;
        this.thisWeekShiftCount = 0;
        this.selectedShiftCount = 0;

        this.shiftList  = [];
        this.shiftReqWireResult={};
        getShiftsByJobReqId({jobId:this.job.Id}).then(result =>{ 
            debugger;
            console.log("RESULT",result);
            this.shiftReqWireResult = JSON.parse(result);
            this.shiftList = Object.entries(this.shiftReqWireResult).map(([date, shifts]) => ({date,shifts}));
            
            let tempDate = new Date();
            let weekDate = new Date();

            weekDate.setDate(tempDate.getDate()+7);

            this.shiftList.forEach(item=>{
                item.shifts.forEach(s=>{
                    console.log('SHIFYYY',s);
                    let sDate = new Date(s.Start_DateTime__c);
                    let eDate = new Date(s.End_DateTime__c); 
                    s.staffType = s.Staff_Type__c?s.Staff_Type__c.split(";"):[];
                    s.sDate = sDate.toLocaleTimeString([],{ hour: '2-digit', minute: "2-digit" });
                    s.eDate = eDate.toLocaleTimeString([],{ hour: '2-digit', minute: "2-digit" });
                    s.selected = false;
                    s.class = 'slds-box cardhover';
                    this.monthlyShiftCount += s.Status__c=="Open"?1:0;
                    if(sDate>tempDate && sDate<=weekDate){
                        this.thisWeekShiftCount++;
                    }
                })
            })
            
            this.monthlyShiftMsg = `Monthly Shift (${this.monthlyShiftCount})`;
            this.thisWeekShiftMsg = `This Week Shift (${this.thisWeekShiftCount})`;
            //localStorage.setItem(this.jobId,JSON.stringify({dateSelected:this.selectedDate,shiftSelected:this.currentShiftSelected}));
            debugger;
            if(localStorage.getItem(this.job.Id)!=null){
                debugger;
                let preShiftLocal = JSON.parse(localStorage.getItem(this.job.Id)).tempshift;
                console.log('LSSLLSLSLS',preShiftLocal);
                this.ondatechoosedhandler(preShiftLocal.dateSelected);
                this.shiftSelectedHandlder(preShiftLocal.shiftSelected.Id);
                localStorage.removeItem(this.job.Id);
            }else{
                this.ondatechoosedhandler(`${tempDate.getDate()}/${tempDate.getMonth()+1}/${tempDate.getFullYear()}`);        
            }
            console.log("SHIFTRECORD---------",this.shiftList);
        }).catch(error=>{
            console.log("SHIFTRECORD---------",error);
        });   
    }

    shiftSelectedHandlder(event){
        debugger;
        let id = event.currentTarget?event.currentTarget.dataset.id:event;

        let copyShiftList = this.shiftList;
        this.hasChildShift = false;
        this.childShiftList = [];
        this.recordsToDisplay = [];
        this.currentShiftId = ""
        this.currentShiftSelected={};
        this.allocatedShifts = 0;
        this.numberOfPosRequired = 0;
        this.registerBlockerActive = false;

        this.shiftList.forEach(item=>{
            //shift map based on
            item.shifts.forEach(s=>{
                //client shifts
                let sDate = new Date(s.Start_DateTime__c);
                let eDate = new Date(s.End_DateTime__c); 
                s.prefCandidates = this.job.prefCandidates;

                s.sDate = sDate.toLocaleTimeString([],{ hour: '2-digit', minute: "2-digit" });
                s.eDate = eDate.toLocaleTimeString([],{ hour: '2-digit', minute: "2-digit" })

                s.selected = false;
                if(s.Id==id){
                    this.currentShiftId = id;
                    this.currentShiftSelected = s;
                    this.numberOfPosRequired = s.No_Of_Required_Candidates__c;
                    if(s.Shifts__r && s.Shifts__r.records){
                        s.Shifts__r.records.forEach(rec=>{
                            console.log("recccccc,",rec);
                            let obj;
                            try{
                                obj = {
                                    Id:rec.Id,
                                    name: rec.Contact__r.FirstName?rec.Contact__r.FirstName:"" + " " + rec.Contact__r.LastName,
                                    contactId:rec.Contact__r.Id,
                                    email:rec.Contact__r.Email,
                                    shiftName:rec.Name,
                                    phone:rec.Contact__r.Phone,
                                    startDate:rec.Start_DateTime__c,
                                    endDate:rec.End_DateTime__c,
                                    sDate:new Date(rec.Start_DateTime__c).toLocaleTimeString([],{ hour: '2-digit', minute: "2-digit" }),
                                    eDate:new Date(rec.End_DateTime__c).toLocaleTimeString([],{ hour: '2-digit', minute: "2-digit" }),
                                    Status__c:rec.Status__c=="Assigned"?"Requested":rec.Status__c,
                                    Type__c:rec.Type__c?rec.Type__c:"Recruiter",
                                    profile:rec.Contact__r.Profile_Picture_URL__c?rec.Contact__r.Profile_Picture_URL__c:"https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png",
                                    isChecked:false,
                                    isSubmitted:rec.Submitted__c? rec.Submitted__c:false
                                }
                                if(obj.Status__c=='Requested'||obj.Status__c=='Available'){
                                    obj.class = 'greenColor';
                                }else if(obj.Status__c==KEY_CANDIDATE_NOT_AVAILABLE){
                                    obj.class = 'redColor';
                                }else{
                                    obj.class = 'grayColor';
                                }
                                if(obj.Status__c==='Allocated'){
                                    this.allocatedShifts++;
                                }
                            }catch(error){
                                obj = rec;
                            }
                            console.log("JJDJJJJJJJ--------",obj);
                            this.childShiftList.push(obj);    
                        })
                        this.hasChildShift = true;
                    }

                    this.saveRecommendedRecords();
                    console.log('REQUIRED CANDIDATE',s);
                    s.class = s.Status__c=='Open'?'slds-box cardhover cardSelected':'slds-box cardhover shiftFilled';
                    console.log('shiftSelectedForParticularDate',this.shiftSelectedForParticularDate);
                    this.currentShiftSelected = s;
                    this.registerLimitBlocker();
                    if(s.Status__c=='Open'){
                        fireEvent(this.pageRef, 'shiftClicked', s);
                    }else{
                        this.registerBlockerActive = true;
                    }
                    // this.childShiftList = s.Shifts__r && s.Shifts__r.records ?s.Shifts__r.records:[];
                }else{
                    s.class = 'slds-box cardhover ';
                }
            })
        })
    }

    handleWeekChange(event){
        debugger;

        let type = event.target? event.target.id.includes("increment")?"increment":"decrement": event;

        this.weekNumber = ((this.weekNumber===0 && type==="decrement") || (this.weekNumber===4 && type==="increment"))? this.weekNumber : type==="increment" ? this.weekNumber + 1 : this.weekNumber - 1;
        debugger;

        let startDateFrom = 1;

        if(this.weekNumber===1){startDateFrom=1;}
        if(this.weekNumber===2){startDateFrom=8;}
        if(this.weekNumber===3){startDateFrom=15;}
        if(this.weekNumber===4){startDateFrom=22;}

        this.currentWeekDays = [];

        for(let i = startDateFrom; i<startDateFrom+7;i++){
            let date = new Date();

            let thatDay = new Date(`${this.monthNames[date.getMonth()]} ${i}, ${date.getFullYear()}`);
            let dayOnThisDay = thatDay.getDay();
            let obj = {"day":this.days[dayOnThisDay].substring(0,3),"date":i,"month":thatDay.getMonth()+1,"selected":i===startDateFrom,fDate:`${thatDay.getDate()}/${thatDay.getMonth()+1}/${thatDay.getFullYear()}`};
            this.currentWeekDays.push(obj);
        }
        console.log("WEEKDAYSLIST",this.currentWeekDays);
    }



    getCalendar(){
        this.allMonthCalendar = [];
        this.weekNumber = 0;

        for(let i = 0; i<32;i++){
            
            let date = new Date();
            date.setDate(date.getDate()+i);

            let thatDate = new Date(`${date.getFullYear()}-${date.getMonth()+1}-${date.getDate()}`);
            let d = thatDate.getDay();
            let obj = {"day":this.days[d].substring(0,3),"date":date.getDate(),"month":thatDate.getMonth()+1,"selected":i===0,fDate:`${thatDate.getDate()}/${thatDate.getMonth()+1}/${thatDate.getFullYear()}`};
            this.allMonthCalendar.push(obj);
        }

    }

    handleWeekChange2(event){
        debugger;
        this.currentWeekDays = [];
        let type = event.target? event.target.id.includes("increment")?"increment":"decrement": event;
        
        this.weekNumber = ((this.weekNumber===1 && type==="decrement") || (this.weekNumber===4 && type==="increment"))? type==="decrement"? 1:4 : type==="increment" ? this.weekNumber + 1 : this.weekNumber - 1;
        this.currentWeekDays = this.allMonthCalendar.slice((this.weekNumber-1)*8,this.weekNumber*8);

        console.log()


    }

    connectedCallback() {
        //registerListener('jobChanged', this.updateCurrentJob, this); //register for job change event
        registerListener('recCanAssignedListener', this.recCanAssignedListener, this); //register for job change event
    }

    recCanAssignedListener(candidatesList){
        debugger;
        if(candidatesList){
            let data = [];

            candidatesList.forEach((d)=>{
                d.Status__c = "Requested";
                d.isChecked = false;
                d.class = 'greenColor';
                data.push(d);
            })

            this.childShiftList = this.childShiftList.concat(data);
            this.saveRecommendedRecords();
            this.hasChildShift = true;

            let copiedShiftList = [];
            this.shiftList.forEach(item=>{
                debugger;
                item.shifts.forEach(s=>{
                    debugger;
                    if(s.Id===this.currentShiftId){
                        if(s.Shifts__r && s.Shifts__r.records){
                            s.Shifts__r.records = this.childShiftList;
                        }else{
                            s.Shifts__r={records:this.childShiftList}
                        }
                    }
                })
                debugger;
                copiedShiftList.push(item);
            })
            this.shiftList = copiedShiftList;
            
        }
    }

    @api
    setupJob(job) {
        
        debugger;
        this.getCalendar();
        this.handleWeekChange2("increment");

        if(job) {

            this.jobSelected = true;
            this.job = job;
            this.editClientShiftUrl = `${window.location.origin}/apex/EditTemporaryJobShifts?id=${this.job.Id}&isrdview=false`;
            console.log("EDUTSHIfTUrL-----",this.editClientShiftUrl);

            console.log("Job------",JSON.stringify(this.job));
            debugger;
            this.createApplication = [];

            this.showActive = job.Status__c === "Open";

            if(job && job.Job_Applications__r){

                job.Job_Applications__r.forEach(application=>{
                    let applicationObj = {
                        "Id":application.Id,
                        "ApplicationName":application.Name,
                        "Application_Stage__c":application.Application_Stage__c,
                        "CreatedDate":application.CreatedDate,
                        "Type__c":application.Type__c,
                        "Name":application.Contact__r.Name,
                        "email":application.Contact__r.Email,
                        "phone":application.Contact__r.Phone
                    }
                    this.createApplication.push(applicationObj);
                })

                this.hasLoaded = true;
                console.log("APPLICATIONS________",this.createApplication);
            }else{
                this.createApplication = [];
                this.hasLoaded = false;
            }

            console.log('JobReceived-------',this.job.prefCandidates);
            console.log("JOBID---------",this.job.Id);
            this.getShiftsData();
            this.currentApplicantsCount = `Applicants(${job && job.Job_Applications__r ? job.Job_Applications__r.length : 0})`;
        }else {
            this.jobSelected = false;
        }
    }

    ondatechoosedhandler(event){
        debugger;
        this.hasChildShift = false;
        this.selectedDate = event.target ? event.target.dataset.id:event
        
        console.log("DATESELECTED",this.selectedDate);
        
        let copyCurrentDateList = [...this.currentWeekDays];

        let currenDateSelected = copyCurrentDateList.findIndex(item=> item.fDate == this.selectedDate);
        let prevselectedIndex = copyCurrentDateList.findIndex(item=>item.selected===true);

        if(prevselectedIndex!=-1){
            copyCurrentDateList[prevselectedIndex].selected = false;
        }
        copyCurrentDateList[currenDateSelected].selected = true;

        this.currentWeekDays = copyCurrentDateList;

        let shiftSelected = this.shiftList.find(item=>item.date===this.selectedDate);
        debugger;
        this.shiftSelectedForParticularDate = shiftSelected?shiftSelected:[];
        this.totalShiftToday = `Shift(${this.shiftSelectedForParticularDate && this.shiftSelectedForParticularDate.shifts ? this.shiftSelectedForParticularDate.shifts.length : 0})`;

        console.log("SHIFCHOOSEDON----",shiftSelected);
        fireEvent(this.pageRef, 'clearCache', this.job.Id);

    }

    searchHandler(event){
        let value = event.target.value.toLowerCase();
        if(value.length===0){
            this.saveRecommendedRecords();
        }else{
            this.recordsToDisplay = this.childShiftList.filter((data) => {
                return data.name.toLowerCase().search(value) !== -1;
            })
        }
    }

    handleRowAction(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        debugger;
        console.log("ActionName",row.Id);
        var url= 'https://sales-production--ondontesb.lightning.force.com/lightning/r/Job_Application__c'+'/'+row.Id+'/'+actionName;
        window.open(url, '_blank');
    }

    // s.Status__c=s.Status__c=="Assigned"?"Requested":s.Status__c;

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    
    showNotification(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    openSendSmSPopup(event){
        debugger;
        const recId = event.currentTarget.dataset.id;

        this.smsUrl = `https://ondonte--dev.lightning.force.com/apex/tdc_tsw__SendSMS?id=${recId}&retURL=${window.location.href}`;
        console.log("SMSURL----------------",this.smsUrl);
        this.smsPopup = true;
    }

    closeSMSPopup(){
        this.smsPopup = false;
    }

    bulkSmsHandler(event){
        
        let smsParticipants = [];
        this.childShiftList.forEach(can=>{
            smsParticipants.push(can.contactId);
        })

        this.smsUrl = `https://ondonte--dev.lightning.force.com/apex/tdc_tsw__SendBulkSMS_SLDS?ids=${smsParticipants}&redirectURL=${window.location.href}`;
        window.open(this.smsUrl, '_blank');
        console.log("SMSURL----------------",this.smsUrl);
    }

    registerLimitBlocker(){
        this.registerBlockerActive = (this.numberOfPosRequired-this.allocatedShifts)<=0;
        //this.registerBlockerActive = (this.numberOfPosRequired - this.allocatedShifts)<=0;
    }

    notifyParent(){
        localStorage.setItem(this.job.Id,JSON.stringify({tempshift:{dateSelected:this.selectedDate,shiftSelected:this.currentShiftSelected}}));
        this.dispatchEvent(new CustomEvent('shiftcreated', {detail : this.job.Id}));
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
        this.pageNo += this.childShiftList.length > ((this.pageNo) * parseInt(this.recordsperpage))?1:0;
        this.preparePaginationList();
    }

    handlePrevious() {
        this.pageNo -= this.pageNo>1?1:0;
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
        let end = this.childShiftList.length > (parseInt(begin) + parseInt(this.recordsperpage))?parseInt(begin) + parseInt(this.recordsperpage):this.childShiftList.length;
        debugger;
        this.recordsToDisplay = this.childShiftList.slice(begin, end);
        console.log('this.begin-' + begin);
        console.log('this.end-' + end);
        console.log('this.recordsToDisplay-' + this.recordsToDisplay);
        this.startRecord = begin + parseInt(1);
        this.endRecord = end > this.totalRecommended ? this.totalRecommended : end;
        this.end = end > this.totalRecommended ? true : false;

        const event = new CustomEvent('pagination', {
            detail: {
                records: this.recordsToDisplay
            }
        });
        this.dispatchEvent(event);

        console.log("POSTSSSSSS",this.childShiftList);
        console.log("Records to display:",this.recordsToDisplay);

        this.isLoading = false;
    }

     saveRecommendedRecords() {
        debugger;
        this.totalRecommended = this.childShiftList.length;
        this.recordsperpage = 5;
        this.pageNo = 1;
        this.totalPages = Math.ceil(this.totalRecommended / this.recordsperpage);
        debugger;
        this.pagelinks = [];
        for (let i = 1; i <= this.totalPages; i++) {
            this.pagelinks.push(i);
        }
        this.preparePaginationList();
        this.isLoading = false;
    }



    updateShiftStatus(shiftId,status) {
        debugger;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = shiftId;
        fields[STATUS_FIELD.fieldApiName] = status;
        const recordInput = { fields };
        updateRecord(recordInput)
        .then((result) => {
            console.log('Updation Result----',result);
            this.updateUI(shiftId,status);
        })
        .catch(error => {
           console.log('couldn\'t updated shift'+JSON.stringify(error));
        });
    }

    handleAction(event){
        let shiftId = event.currentTarget.dataset.id;
        let action = event.currentTarget.dataset.action;
        let status = event.currentTarget.dataset.status;

        if(status==action){
            this.showNotification('Candidate is not available')
            return;
        }else{
            this.updateShiftStatus(shiftId,action);
        }
    }


    openEditShiftModal(){
        window.open(this.editClientShiftUrl, '_blank');
    }

    candidateEditShiftUrl = "";
    openCandidateEditShiftModal(event){
        let shiftId = event.currentTarget.dataset.id;
        this.candidateEditShiftUrl =  `${window.location.origin}/apex/EditCandidateShift?id=${shiftId}&isrdview=false`;
        console.log("CandidateEditShiftURL----",this.candidateEditShiftUrl);
        window.open(this.candidateEditShiftUrl, '_blank');
    }

    

    closeEditShiftModal(){
        this.showEditShiftModal = false;
    }
}