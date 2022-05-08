import { LightningElement, wire, track,api } from 'lwc';
import { fireEvent,registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference,NavigationMixin} from 'lightning/navigation';
import getRecommendedCandidate from "@salesforce/apex/RecruiterDashboardTemporaryJobController.getRecommendedCandidate";
import filterSearchHandler from "@salesforce/apex/RecruiterDashboardTemporaryJobController.filterSearchHandler";
import assignedCandidates from "@salesforce/apex/RecruiterDashboardTemporaryJobController.assignedCandidates";
import getPicklistValues from '@salesforce/apex/Utility.getPicklistValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import moment from '@salesforce/resourceUrl/moment';
import { updateRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Shift__c.Status__c';
import ID_FIELD from '@salesforce/schema/Shift__c.Id';




export default class RDContentTemporaryBottom  extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference) pageRef;
    numberOfRecords = 1;
    @track loaded = true;
    @track shiftClicked = {};
    address;
    clientShifId = "";
    filteredSearchConListLength = 0;
    @track recommendedCandidates = [];
    @track recordsToDisplay = [];
    @track appliedShfits = [];
    @track prefSelectedList = [];
    _selectedSkills = [];
    selectedMapConList = [];
    selectedContacts = [];
    selectedSearcConList = [];
    skillsPicklistValue = [];
    @track candidatesApplied = [];
    selectedRecords = [];

    @track smsPopup = false;
    @track showButton = false;
    @track hasChildShift = false;
    @track showBottomTable = false;
    @track showPrefSelected = false;
    @track isPrefAllSelected = false;
    @track showPrefCandidates = false;
    @track isViewOnMapModelOpen = false;
    @track searchAllShiftSelected = false;
    @track isViewOnSearchModelOpen = false;
    @track isAppliedShiftAllChecked = false;


    @track selectedShiftName;
    @track selectedShiftLat;
    @track selectedShiftLang;
    @track selectedShiftStartDate;
    @track selectedShiftEndDate;
   
    @track smsUrl = "";
    
    prefCandidates = [];
    prefCandidatesIds = [];
    job;
    jobId;

    @api openSearchAccordian = false;

   
    selectedSearchExperience = null;
    showAddCandidateButtonInSearch = false;
    filteredSearchConList = [];
    appliedShiftList = [];
    setOfContactsOnDash = new Set();


 get experienceList() {
        return [
            { label: '0', value: '0' },
            { label: '< 1 Year', value: '< 1 Year' },
            { label: '1 - 3 Years', value: '1 - 3 Years' },
            { label: '4 - 6 Years', value: '4 - 6 Years' },
            { label: '7 - 9 Years', value: '7 - 9 Years' },
            { label: '> 10 Years', value: '> 10 Years' },
           
        ];
    }

    

    clearCache(jobId){
        this.shiftClicked = {};
        this.hasChildShift = false;
        this.showBottomTable = false;
        this.recommendedCandidates = [];
        this.selectedContacts = [];
        this.selectedShiftName = '';
        this.selectedShiftLat = '';
        this.selectedShiftLang = '';
        this.selectedShiftStartDate = '';
        this.selectedShiftEndDate = '';
        this.setOfContactsOnDash.clear();
        this.prefCandidates = [];
        this.prefSelectedList = [];
        if(jobId){
            this.jobId = jobId;
        }
    }

    selectedRecordsHandler(event){

        this.selectedRecords = [];
        event.detail.selectedRows.forEach(con=>{
            debugger;
            if(con.Status__c==='Available'){
                this.selectedRecords.push(con.Id);
            }
        })
    }

    tableIndexChange(event){
        debugger;
        let id = event.currentTarget.dataset.id;
        let tempRecommends = [];
        let totalChecked = 0;
        this.recommendedCandidates.forEach(con=>{
            if(con.Id===id && (con.Status__c==='Available'||con.Status__c==='Not Available')){
                con.isChecked = !con.isChecked;
                if(con.isChecked){
                    this.selectedRecords.push(con.Id)
                }else{
                    this.selectedRecords = this.selectedRecords.filter(id=>id!=con.Id);
                }
            }
            totalChecked+= con.isChecked?1:0;
            tempRecommends.push(con);
        })
        debugger;
        this.isAppliedShiftAllChecked = this.recommendedCandidates.length===totalChecked;
        this.recommendedCandidates = tempRecommends;
    }

    selectAllHandler(){
        this.selectedRecords = [];
        let tempRecommends = [];
        this.isAppliedShiftAllChecked = !this.isAppliedShiftAllChecked;

        this.recommendedCandidates.forEach(con=>{
            if(con.Status__c==='Available'){
                if(this.isAppliedShiftAllChecked){
                    this.selectedRecords.push(con.Id)
                }else{
                    this.selectedRecords = this.selectedRecords.filter(id=>id!=con.Id);
                }
              //  this.isAppliedShiftAllChecked?this.selectedRecords.push(con.Id):this.selectedRecords.pop(con.Id);
            }
            con.isChecked = this.isAppliedShiftAllChecked?true:false;
            tempRecommends.push(con);
        })
        debugger;
        this.recommendedCandidates = tempRecommends;
    }

    searchSelectAllHandler(){
        this.selectedRecords = [];
        let tempRecommends = [];
        this.searchAllShiftSelected = !this.searchAllShiftSelected;

        this.recommendedCandidates.forEach(con=>{
            if(con.Status__c==='Available'){
                if(isAppliedShiftAllChecked){
                    this.selectedRecords.push(con.Id)
                }else{
                    this.selectedRecords = this.selectedRecords.filter(id=>id!=con.Id);
                }
                //this.isAppliedShiftAllChecked?this.selectedRecords.push(con.Id):this.selectedRecords.pop(con.Id);
            }
            con.isChecked = this.isAppliedShiftAllChecked?true:false;
            tempRecommends.push(con);
        })
        debugger;
        this.recommendedCandidates = tempRecommends;
    }

    searchHandler(event){
        let value = event.target.value.toLowerCase();
        if(value.length===0){
            this.saveRecommendedRecords();
        }else{
            this.recordsToDisplay = this.recommendedCandidates.filter((data) => {
                return data.name.toLowerCase().search(value) !== -1;
            })
        }
    }
    

    assignCandidate(){
        let hasError = false;
        let errorMsg = "";

        if(this.selectedRecords.length===0){
            this.showNotification("Error","Select candidates to proceed","error");
        }else{
            console.log("IdList",this.selectedRecords);
            debugger;
            let selectedCandidates = [];
            this.recommendedCandidates.forEach(can=>{
                if(this.selectedRecords.includes(can.Id) && selectedCandidates.findIndex(selectedCan=>selectedCan.Id===can.Id)===-1){
                    if(can.Status__c=='Not Available'){
                        hasError = true;
                        errorMsg+=can.name;
                    }else if(!hasError){
                        can.Status__c='Assigned';
                        selectedCandidates.push(can);
                    }
                }
            });

            this.selectedContacts.forEach(can=>{
                debugger;
                if(this.selectedRecords.includes(can.Id) && selectedCandidates.findIndex(selectedCan=>selectedCan.Id===can.Id)===-1){
                    if(can.Status__c=='Not Available'){
                        hasError = true;
                        errorMsg+=can.name;
                    }else if(!hasError){
                        can.Status__c='Assigned';
                        selectedCandidates.push(can);
                    }
                }
            });
            if(hasError){
                this.showNotification(`${errorMsg}`,`Only Available Candidates are allowed`,'error');
                return;
            }

            this.loaded = false;
            assignedCandidates({clientShifId:this.clientShifId,candidateShiftListId:this.selectedRecords}).then(result =>{
                debugger;
                if(result=="Success"){
                    fireEvent(this.pageRef, 'recCanAssignedListener', selectedCandidates);
                    this.recommendedCandidates = this.recommendedCandidates.filter(can=>!this.selectedRecords.includes(can.Id));
                    this.selectedContacts = this.selectedContacts.filter(can=>!this.selectedRecords.includes(can.Id));
                    this.showBottomTable = this.selectedContacts.length>0;
                    this.selectedRecords = [];
                    this.showNotification("Success","Candidate Assigned Successfully","success");  

                    this.hasChildShift = this.recommendedCandidates.length>0?true:false;  
                    this.saveRecommendedRecords();
                }
                this.loaded = true;
            }).catch(error =>{
                this.loaded = true;
                console.log("Error----",error);
                this.showNotification("Error",error,"error");
            })
        }
    }


    connectedCallback() {
        debugger;
        registerListener('shiftClicked', this.shiftChangeListener, this); //register for job change event
        registerListener('clearCache', this.clearCache, this); //register for job change event
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    createShiftsWrapper(rec){
        let obj = {
            Id: rec.id,
            name:rec.conName,
            shiftName:rec.name, 
            contactId:rec.conId,
            email:rec.conEmail,
            phone:rec.conPhone,
            startDate: rec.sDate,
            endDate: rec.eDate,
            sDate: new Date(rec.sDate).toLocaleTimeString([],{ hour: '2-digit', minute: "2-digit" }),
            eDate:new Date(rec.eDate).toLocaleTimeString([],{ hour: '2-digit', minute: "2-digit" }),
            Status__c: rec.status,
            Type__c:rec.type?rec.type:"Recruiter",
            shiftScore:rec.matchPercentage?rec.matchPercentage:0,
            profile:rec.profile?rec.profile:"https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png",
            isChecked:false
        }
        console.log("skdsdkjsdks",obj);
        return obj;
    }

    formatDate(dateTime){
        let date = new Date(dateTime);
        return date.getDate() + '-' + date.getMonth()+1 + '-' + date.getFullYear() + ' '+date.getHours() + ':' + date.getMinutes();
    }

    shiftChangeListener(data){
        this.clearCache(null);
        this.setMapBaseData(data);
        this.shiftClicked = data;
        debugger;
        console.log("JSJJSJSJS",data);
        this.hasChildShift = false;
        if(data.Start_DateTime__c && data.End_DateTime__c){
            this.clientShifId = data.Id;

            console.log('PrefCandidatesId',this.prefCandidatesIds);
            getRecommendedCandidate({"startDateString":Date.parse(data.Start_DateTime__c),"endDateString":Date.parse(data.End_DateTime__c),'prefCandidates':this.prefCandidatesIds}).then(result =>{
                console.log("Result=>",result.pref_can);
                console.log("Result=>",result.rec_can);

                if(result && result.rec_can && result.rec_can.length > 0){
                    let recList = [];
                    result.rec_can.forEach(rec=>{  
                        if(recList.find(can=>can.contactId==rec.conId)){
                            let index = recList.findIndex(can=>can.contactId==rec.conId);
                            let obj = recList[index];

                            console.log(obj)
                            if(obj.shiftScore < rec.matchPercentage){
                                recList[index] = this.createShiftsWrapper(rec);                   
                            }
                        }else{
                            recList.push(this.createShiftsWrapper(rec));                   
                        }
                    })
                    this.recommendedCandidates = recList;
                    this.hasChildShift = true;
                }else{
                    this.recommendedCandidates = [];
                    this.hasChildShift = false;
                }
                this.updatePrefRec(result.pref_can);
                this.saveRecommendedRecords();
                console.log("Recommended Candidates",result);
            }).catch(err =>{
                this.hasChildShift = false;
                this.recommendedCandidates = [];
                console.log("Error to get recommended candidates",err);
            });
        }
        console.log("DATA------------------",data);
    }

    showNotification(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    openModal() { 
        if(this.shiftClicked.Id){
            if(this.selectedShiftLat && this.selectedShiftLang){
                this.cleanJunk();
                this.isViewOnMapModelOpen = true
            }else{
                this.showNotification("Empty","Location not found","warning");
            }
        }else{
            this.showNotification("Empty","Shifts not found","warning");
            //alert('Shifts not found!');    
        }
    }

    cleanJunk(){
        this.duplicacyMsg = '';
        this.hasDuplicacy = false;
    }

    closeModal() {
        this.showButton = false;
        this.isViewOnMapModelOpen = false;
        this.showPrefCandidates = false;
    }

    showPrefModalHandler(event){
        debugger;
        this.cleanJunk();
        if(this.prefCandidates && this.prefCandidates.length>0){
            this.showDoNotHireCandidates = false;
            this.showPrefCandidates = !this.showPrefCandidates;
        }else{
            this.showNotification('Empty',"Pref candidates are not available","warning");
            //alert('Pref candidates are not available');
        }
    }


    mapSelectionHandler(event) {
        console.log('Event:-',event);
        this.selectedMapConList = event.detail;
        debugger;
        this.showButton = this.selectedMapConList.length>0;
        console.log('Selected map conList:',this.selectedMapConList);
    }

    get getDisplayedCandidates(){
        return ['323232323'];
    }

    setMapBaseData(data){
        this.selectedShiftName = data.Name ? data.Name : null;
        this.selectedShiftLat = data.Job_Requisition__r && data.Job_Requisition__r.GeoLocation__c ? data.Job_Requisition__r.GeoLocation__c.latitude : null; 
        this.selectedShiftLang = data.Job_Requisition__r && data.Job_Requisition__r.GeoLocation__c ? data.Job_Requisition__r.GeoLocation__c.longitude : null; 
        this.selectedShiftStartDate = data.Start_DateTime__c ? data.Start_DateTime__c : null;
        this.selectedShiftEndDate = data.End_DateTime__c ? data.End_DateTime__c : null;
        this.candidatesApplied = data.Shifts__r ? data.Shifts__r.records : [];

        if(data.prefCandidates){
            let objList = [];
            let objIds = [];
            data.prefCandidates.forEach(candidate=>{
                let obj = {...candidate};
                debugger;
                obj.profileId = candidate.profileId?candidate.profileId:"https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png";
                obj.isChecked = false;
                obj.isDisabled = true;
                objList.push(obj)
                objIds.push(obj.Id);
            })
            this.prefCandidates = objList;
            this.prefCandidatesIds = objIds;
        }
        
        console.log('CandidatesApplied',this.candidatesApplied);
        console.log('PrefCandidates',this.prefCandidates[0]);
    }


    handleSearchAccordion(){
        this.openSearchAccordian = !this.openSearchAccordian;
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

    createAlreadyChoosedCan(){
        let canSet = new Set();

    }

    duplicacyMsg;
    hasDuplicacy = false;
    

    handleAddCandidate(event){
        debugger;
        this.duplicacyMsg = '';
        this.hasDuplicacy = false;

        let repCanCounter = 0;
        let candidateSourceList = [];
        let optionChoosed = event.currentTarget.dataset.id;

        if(optionChoosed==='map'){

            let dupName='';
            this.selectedMapConList.forEach(rec=>{
                if(this.recommendedCandidates.find(can=>can.contactId===rec.id) || this.selectedContacts.find(can=>can.contactId===rec.id)){
                    dupName+=rec.Name+" ,"
                    this.hasDuplicacy = true;
                }
            })

            if(!this.hasDuplicacy){
                let totalSelectedSize = this.selectedMapConList.length;
                this.selectedMapConList = this.selectedMapConList.filter(rec=>{!this.recommendedCandidates.find(can=>can.contactId===rec.id) && !this.selectedContacts.find(can=>can.contactId===rec.id)})
                repCanCounter = totalSelectedSize - this.selectedMapConList.length;
                candidateSourceList = [...this.selectedMapConList];
                this.selectedMapConList = [];
            }else{
                dupName = dupName.substring(0, dupName.length - 1);
                this.duplicacyMsg+=`Candidate: ${dupName} are already part of existing search!`;
                console.log("DuplicacyMSGGGG---",this.duplicacyMsg);
                return;
            }
        }else if(optionChoosed==='pref'){

            console.log('PREFFFFF',this.prefSelectedList);
            console.log('RECOMMMM',this.recommendedCandidates);
            // let totalSelectedSize = this.prefSelectedList.length;
            // this.prefSelectedList = this.prefSelectedList.filter(rec=>{!this.recommendedCandidates.find(can=>can.contactId===rec.contactId) && !this.selectedContacts.find(can=>can.contactId===rec.contactId)})
            // repCanCounter = totalSelectedSize - this.prefSelectedList.length;
            // candidateSourceList = [...this.prefSelectedList];
            // this.prefSelectedList = [];

            let dupName='';
            this.prefSelectedList.forEach(rec=>{
                if(this.recommendedCandidates.find(can=>can.contactId===rec.contactId) || this.selectedContacts.find(can=>can.contactId===rec.contactId)){
                    dupName+=rec.name+" ,"
                    this.hasDuplicacy = true;
                }
            })

            if(!this.hasDuplicacy){
                let totalSelectedSize = this.prefSelectedList.length;
                this.prefSelectedList = this.prefSelectedList.filter(rec=>{!this.recommendedCandidates.find(can=>can.contactId===rec.contactId) && !this.selectedContacts.find(can=>can.contactId===rec.contactId)})
                repCanCounter = totalSelectedSize - this.prefSelectedList.length;
                candidateSourceList = [...this.prefSelectedList];
                this.prefSelectedList = [];
            }else{
                dupName = dupName.substring(0, dupName.length - 1);
                this.duplicacyMsg+=`Candidate: ${dupName} are already part of existing search!`;
                console.log("DuplicacyMSGGGG---",this.duplicacyMsg);
                return;
            }
        }else{
            console.log("DDKJDSDKJS",this.selectedSearcConList);
            let dupName='';
            this.selectedSearcConList.forEach(rec=>{
                if(this.recommendedCandidates.find(can=>can.contactId===rec.id) || this.selectedContacts.find(can=>can.contactId===rec.id)){
                    dupName+=rec.Name+" ,"
                    this.hasDuplicacy = true;
                }
            })

            if(!this.hasDuplicacy){
                let totalSelectedSize = this.selectedSearcConList.length;
                this.selectedSearcConList = this.selectedSearcConList.filter(rec=>{!this.recommendedCandidates.find(can=>can.contactId===rec.id) && !this.selectedContacts.find(can=>can.contactId===rec.id)})
                repCanCounter = totalSelectedSize - this.selectedSearcConList.length;
                candidateSourceList = [...this.selectedSearcConList];
                this.selectedSearcConList = [];
            }else{
                dupName = dupName.substring(0, dupName.length - 1);
                this.duplicacyMsg+=`Candidate: ${dupName} are already part of existing search!`;
                console.log("DuplicacyMSGGGG---",this.duplicacyMsg);
                return;
            }
        }

        if(candidateSourceList.length > 0){
            if(optionChoosed==='pref'){
                this.selectedContacts.concat(candidateSourceList);
            }else{
                let recList = [];
                candidateSourceList.forEach(rec=>{
                    let obj = {
                        Id: rec.shiftId?rec.shiftId:rec.Id,
                        contactId:rec.id?rec.id:rec.contactId,
                        shiftName:rec.shiftName?rec.shiftName:"",
                        email:rec.email,
                        phone:rec.phone,
                        name:rec.Name?rec.Name:rec.name,
                        startDate: rec.startDate,
                        endDate: rec.endDate,
                        sDate:new Date(rec.startDate),
                        eDate:new Date(rec.endDate),
                        Type__c:rec.type?rec.type:"Recruiter",
                        Status__c: rec.candidateStatus?rec.candidateStatus:rec.Status__c,
                        profile:rec.profile?rec.profile:rec.profileId?rec.profileId:"https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png",
                        isChecked:false
                    }
                    recList.push(obj);
                })
                this.selectedContacts.concat(recList);
            }
        }

        this.showNotification("Success",repCanCounter>0? `${repCanCounter} Candidates were Already Added`:`Candidates Added Successfully`,"success");  
        this.showBottomTable = this.selectedContacts.length>0;
        if(!this.hasDuplicacy) this.closeModal();
        this.closeSearchModal();
    }

    searchTableRowListener(event){
        let candidateId = event.currentTarget.dataset.id;
        let tempRecommends = [];
        let totalChecked = 0;
        this.selectedContacts.forEach(con=>{
            if(con.Id===candidateId && con.Status__c==='Active'){
                con.isChecked = !con.isChecked;
                if(con.isChecked){
                    this.selectedRecords.push(con.Id)
                }else{
                    this.selectedRecords = this.selectedRecords.filter(id=>id!=con.Id);
                }
                //con.isChecked ? this.selectedRecords.push(con.Id):this.selectedRecords.pop(con.Id);
            }
            totalChecked+= con.isChecked?1:0;
            tempRecommends.push(con);
        })
        debugger;
        this.searchAllShiftSelected = this.selectedContacts.length===totalChecked;
        this.selectedContacts = tempRecommends;
    }

    searchSelectAllHandler(){
        this.selectedRecords = [];
        let tempRecommends = [];
        this.searchAllShiftSelected = !this.searchAllShiftSelected;

        this.selectedContacts.forEach(con=>{
            if(con.Status__c==='Available'){
                if(this.searchAllShiftSelected){
                    this.selectedRecords.push(con.Id)
                }else{
                    this.selectedRecords = this.selectedRecords.filter(id=>id!=con.Id);
                }
                //this.searchAllShiftSelected?this.selectedRecords.push(con.Id):this.selectedRecords.pop(con.Id);
            }
            con.isChecked = this.searchAllShiftSelected?true:false;
            tempRecommends.push(con);
        })
        debugger;
        this.selectedContacts = tempRecommends;
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
        this.recordsToDisplay = this.recommendedCandidates.slice(begin, end);
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

        console.log("POSTSSSSSS",this.recommendedCandidates);
        console.log("Records to display:",this.recordsToDisplay);

        this.isLoading = false;
    }

    saveRecommendedRecords() {
        debugger;
        this.totalRecommended = this.recommendedCandidates.length;
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



    handleSearchFilterCandidates(){
        debugger;
        this.showAddCandidateButtonInSearch = false;
        filterSearchHandler({'startDateString':this.shiftClicked.Start_DateTime__c,'endDateString':this.shiftClicked.End_DateTime__c,'city':this.address,'experience':this.selectedSearchExperience,'skills':this._selectedSkills}).then(result=>{
            console.log("SearchFilter---",JSON.parse(result));

            let shiftList = JSON.parse(result);

            if(result && shiftList.length > 0) {
                this.filteredSearchConList = shiftList;
                this.filteredSearchConListLength = shiftList.length;
                // this.showAddCandidateButtonInSearch = true;
            }else{
                this.showNotification("Empty","Candidates not found","warning");
            }
        }).catch(error=>{
            this.filteredSearchConListLength = 0;
            console.log("Error----",error)
        })
    }
    
    handleCityChange(e){
        this.address = e.target.value;   
    }

    handleChange(e) {
        this._selectedSkills = e.detail.value;
    }

    selectedSearchExperienceHanlder(event){
        debugger;
        this.selectedSearchExperience = event.detail.value;
    }

    closeSearchModal() {
        this.isViewOnSearchModelOpen = false;
        this.showAddCandidateButtonInSearch = false;
        this.filteredSearchConList = [];
        this.filteredSearchConListLength = 0;
    }

    openSearchModal() {
        debugger;
        this.cleanJunk();
        if(this.shiftClicked.Id){
            this.loaded = false;
            getPicklistValues({'ObjectApi_name':'Contact','Field_name':'Computer_Skills__c'}).then(result=>{
                console.log(result);
                if(result){
                    result.forEach(res=>{
                        this.skillsPicklistValue.push({label:res,value:res})
                    })
                }
                
                this.isViewOnSearchModelOpen = true;
                this.loaded = true;
            }).catch(error=>{
                this.loaded = true;
                alert('Error :- ',error);
            });
        }else{
            this.loaded = true;
            this.showNotification("Empty","Shifts not found","warning");
            //alert('Shifts not found!');
        }
    }

    handleCheckBox(event){
        let id = event.target.name;
        let conSelected = this.filteredSearchConList.find(con=>con.id===id);
        debugger;

        if(!this.selectedSearcConList.includes(conSelected)){
            this.selectedSearcConList.push(conSelected)
        }else{
            this.selectedSearcConList = this.selectedSearcConList.filter(con=> con.id!=id)  
        }

        this.showAddCandidateButtonInSearch = this.selectedSearcConList.length>0
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
        if(this.selectedRecords && this.selectedRecords.length>0){
            let selectedCandidates = [];

            this.recommendedCandidates.forEach(can=>{
                if(this.selectedRecords.includes(can.Id) && selectedCandidates.findIndex(selectedCan=>selectedCan.Id===can.Id)===-1){
                    //can.Status__c='Assigned';
                    selectedCandidates.push(can.contactId);
                }
            });

            this.selectedContacts.forEach(can=>{
                debugger;
                if(this.selectedRecords.includes(can.Id) && selectedCandidates.findIndex(selectedCan=>selectedCan.Id===can.Id)===-1){
                    //can.Status__c='Assigned';
                    selectedCandidates.push(can.contactId);
                }
            });

            if(selectedCandidates.length>0){
                this.smsUrl = `https://ondonte--dev.lightning.force.com/apex/tdc_tsw__SendBulkSMS_SLDS?ids=${selectedCandidates}&redirectURL=${window.location.href}`;
                window.open(this.smsUrl, '_blank');
            }else{
                this.showNotification("Error","Select candidates to proceed","error");
            }
        }else{
            this.showNotification("Empty","Please select candidates to proceed","warning");
            //alert('Please select candidates to proceed');
        }
    }

    updatePrefRec(prefList){
        console.log('PrefList',prefList);
        if(this.prefCandidates){
            console.log('PREFCANDIDATES',this.prefCandidates);

            let tempPrefList = [];

            this.prefCandidates.forEach(can=>{
                console.log("PrefCandidateShifts",can);
                let obj = {...can};
                debugger;
                if(prefList.find(p => p.Contact__r.Id===can.Id)){
                    obj = prefList.find(p => p.Contact__r.Id===can.Id);
                    console.log("Pref",obj);
                    obj.isDisabled = false;

            //          Id: rec.id,
            // name:rec.conName,
            // contactId:rec.conId,
            // email:rec.conEmail,
            // phone:rec.conPhone,
            // startDate: rec.sDate,
            // endDate: rec.eDate,
            // sDate: new Date(rec.sDate).toLocaleTimeString([],{ hour: '2-digit', minute: "2-digit" }),
            // eDate:new Date(rec.eDate).toLocaleTimeString([],{ hour: '2-digit', minute: "2-digit" }),
            // Status__c: rec.status,
            // shiftScore:rec.matchPercentage?rec.matchPercentage:0,
            // profile:rec.profile?this.baseOrgUrl+rec.profile:"https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png",
            // isChecked:false

                    let wrapperObj = {
                        Id:obj.Id,
                        contactId:obj.Contact__r.Id,
                        name:obj.Contact__r.Name,
                        shiftName:obj.shiftName,
                        email:obj.Contact__r.Email,
                        phone:obj.Contact__r.Phone,
                        startDate:obj.Start_DateTime__c,
                        endDate:obj.End_DateTime__c,
                        isChecked:false,
                        sDate:new Date(obj.Start_DateTime__c).toLocaleTimeString([],{ hour: '2-digit', minute: "2-digit" }),
                        eDate:new Date(obj.End_DateTime__c).toLocaleTimeString([],{ hour: '2-digit', minute: "2-digit" }),
                        Status__c:obj.Status__c,
                        Type__c:obj.Type__c?obj.Type__c:'Recruiter',
                        shiftScore:40,
                        profile:obj.Contact__r.Profile_Picture_URL?obj.Contact__r.Profile_Picture_URL:"https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png",
                        isDisabled:false,
                    };
                    // wrapperObj.isDisabled = false;

                    tempPrefList.push(wrapperObj);
                }else{
                    let wrapperObj = {
                        Id: null,
                        name:obj.Name,
                        contactId:obj.Id,
                        email:obj.Email,
                        phone:obj.Phone,
                        startDate: null,
                        endDate: null,
                        sDate:null,
                        eDate:null,
                        Status__c: null,
                        profile:obj.profileId,
                        isChecked:false,
                        isDisabled:true
                    }
                    tempPrefList.push(wrapperObj)
                }
            });
            this.prefCandidates = tempPrefList;
            console.log("PrefCandidateShifts",this.prefCandidates);
        }
    }
  
    prefTableRowListener(event){
        let candidateId = event.currentTarget.dataset.id;

        let tempPrefList = [];
        let totalChecked = 0;
        this.prefCandidates.forEach(con=>{
            if(con.contactId===candidateId){
                con.isChecked = !con.isChecked;
                if(con.isChecked){
                    this.prefSelectedList.push(con)
                }else{
                    this.prefSelectedList = this.prefSelectedList.filter(p=>p.contactId!=con.contactId);
                }
            }
            totalChecked+= con.isChecked?1:0;
            tempPrefList.push(con);
        })
        debugger;
        this.isPrefAllSelected = this.prefCandidates.length===totalChecked;
        this.prefCandidates = tempPrefList;
        this.showPrefSelected = totalChecked>0;

        console.log("SelectedContactFromTable",this.prefCandidates);
    }

    prefClicked(event){
        debugger;
        let candidateId = event.currentTarget.dataset.id;
        if(this.prefCandidates.find(con=>con.contactId===candidateId).isDisabled){
            this.showNotification("Empty","Shift is not available for this candidate","warning");
            //alert('Shift is not available for this candidate')
        }
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
            this.recommendedCandidates.forEach(can=>{if(can.Id==shiftId) {can.Status__c='Not Available';can.isChecked=false}})
            this.showNotification('success','Candidate Marked As Not Available','success')
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

    recurringModalOpen = false;
    openRecurringModal(){
        this.recurringModalOpen = true;
    }

    closeRecurringModal(){
        this.recurringModalOpen = false;
    }

    candidateEditShiftUrl = "";
    openCandidateEditShiftModal(event){
        let shiftId = event.currentTarget.dataset.id;
        this.candidateEditShiftUrl =  `${window.location.origin}/apex/EditCandidateShift?id=${shiftId}&isrdview=false`;
        console.log("CandidateEditShiftURL----",this.candidateEditShiftUrl);
        window.open(this.candidateEditShiftUrl, '_blank');
    }
}