import { LightningElement, track, wire, api } from 'lwc';
import getPicklistValues from '@salesforce/apex/Utility.getPicklistValues';
import filterSearchHandler from '@salesforce/apex/RecruiterDashboardContentController.filterSearchHandler';
import gpValues from '@salesforce/apex/RecruiterDashboardContentController.getPicklistValues';
import createJOBApplication from '@salesforce/apex/RecruiterDashboardContentController.createJOBApplication';
import getRecommendedCandidates from '@salesforce/apex/RecruiterDashboardContentController.getRecommendedCandidates';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { fireEvent,registerListener, unregisterAllListeners } from 'c/pubsub';


const DELAY = 300;
const actions = [
    { label: 'Show details', name: 'show_details' },
    { label: 'Delete', name: 'delete' },
];

const columns = [
    { label: 'Candidate', fieldName: 'Name'},
    { label: 'Score', fieldName: 'score' },
    { label: 'Email', fieldName: 'email' },
    { label: 'Phone', fieldName: 'phone' },
    { label: 'Status', fieldName: 'status' },
    { label: 'Desired Pay', fieldName: 'desired_pay' },
    { label: 'City', fieldName: 'city' },
    { label: 'State', fieldName: 'State' },
];


export default class RecruiterDashboared_Test extends NavigationMixin(LightningElement) {

    @wire(CurrentPageReference) pageRef;

    @api selectedContacts = []
    @track recordsToDisplay = [];
    @track recordsToDisplay;
    @track isViewOnMapModelOpen = false;
    @track lat;
    @track lang;
    @track jobName = "Salesforce Developer"
    @track loaded = true;
    @track showButton = false;
    @track smsPopup = false;
    @track smsUrl = "";
    @track showPrefCandidates = false;
    @track showPrefSelected = false;
    @track prefSelectedList = [];
    @track isPrefAllSelected = false;

    @track isViewOnSearchModelOpen = false;
    @api openSearchAccordian = false;
    allRecommendedSelected = false;
    isAllSearchSelected = false;


    selectedSearchExperience = null;
    filteredSearchConListLength = 0;

    skillsPicklistValue = [];
    _selectedSkills = [];
    selectedMapConList = [];
    selectedSearcConList = [];
    filteredSearchConList = [];
    preSelectedContacts = [];
    @track selectedContactsFromTable = [];

    
    jobSelected = false;
    showDropDownIcon = false;
    showBottomTable = false;
    showAddCandidateButtonInSearch = false;
    address;
    jobId = '';
    job;

    recommendedCandidates = [];
    prefferedCandidates = [];

    columns = columns;
    record = {};
    pagelinks = [];
    showDoNotHireCandidates = false;

    baseOrgUrl = 'https://ondonte--dev.lightning.force.com/sfc/servlet.shepherd/version/download/';

    prefTableColumns = [
        { label: 'Name', fieldName: 'Name'},
        { label: 'Phone', fieldName: 'phone' },
        { label: 'Email', fieldName: 'email' },
        { label: 'Phone', fieldName: 'phone' },
        { label: 'Status', fieldName: 'status' },
        { label: 'Desired Pay', fieldName: 'desired_pay' },
        { label: 'City', fieldName: 'city' },
        { label: 'State', fieldName: 'State' },
        // {
        //     type: 'action',
        //     typeAttributes: { rowActions: actions },
        // },
    ];

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

    removeCache(){
        this.selectedContacts = [];
        this.recordsToDisplay = [];
        this.recommendedCandidates = [];
        this.prefferedCandidates = [];
        this.showPrefCandidates = false;
        this.showDoNotHireCandidates = false;
    }

    handleCityChange(e){
        this.address = e.target.value;   
    }

    handleChange(e) {
        this._selectedSkills = e.detail.value;
    }

    showPrefModalHandler(event){
        debugger;

        if(this.job.prefCandidates && this.job.prefCandidates.length > 0){
            this.showPrefCandidates = true;
        }else{
            this.showPrefCandidates = false;
            this.showNotification("Empty","Preffered Candidates Not found","warning");
        }
    }

    closePrefHandler(){
        this.showPrefCandidates = false;
    }

    showDoNotHireHandler(event){
        this.showPrefCandidates = false;
        this.changePrefDataTable();
    }

    changePrefDataTable(){
        this.prefferedCandidates = [];
        debugger;
        if(this.job.prefCandidates && this.job.prefCandidates.length > 0){
            this.job.prefCandidates.forEach(item=>{
                debugger;
                console.log(item);
                if(item.RecordType.Name==="Preferred" && this.showPrefCandidates){
                    let obj = {id:item.Candidate__r.Id,Name:item.Candidate__r.Name,phone:item.Candidate__r.phone,email:item.Candidate__r.email,status:item.Client_Notes__c};
                    this.prefferedCandidates.push(obj);
                }else if(item.RecordType.Name!="Preferred" && this.showDoNotHireCandidates){
                    let obj = {id:item.Candidate__r.Id,Name:item.Candidate__r.Name,phone:item.Candidate__r.phone,email:item.Candidate__r.email,status:item.Client_Notes__c};
                    this.prefferedCandidates.push(obj);
                }
            })
            this.showPrefCandidates = true;
        }else{
            this.showPrefCandidates = false;
        }
    }


    showMsg(msg){
        alert(msg);
    }



    searchHandler(event){
        let value = event.target.value.toLowerCase();
        if(value.length===0){
            this.setRecordsToDisplay();
        }else{
            this.recordsToDisplay = this.recommendedCandidates.filter((data) => {
                return data.Name.toLowerCase().search(value) !== -1;
            })
        }
    }
    
    
    showNotification(title,message,variant){

        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }


    getRecommendedCandidates(){
        debugger;
        this.removeCache();

        getRecommendedCandidates({'jobIdString':this.jobId,'preSelectedCandidates':this.preSelectedContacts})
        .then(result=>{
            console.log("GetCandidates",result);

            if(result && result.length > 0) {

                let objList = [];
                result.forEach(candidate=>{
                    let obj = {...candidate};
                    debugger;
                    obj.profileId = candidate.profileId?candidate.profileId:"https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png";
                    obj.isChecked = false;
                    objList.push(obj)
                })
                console.log("RecommendedList",objList);

                this.recommendedCandidates = objList;
                this.setRecordsToDisplay();
            }
        })
        .catch(error=>{
            console.log("Error",error);
        })
    }

    searchTableRowListener(event){
        let candidateId = event.currentTarget.dataset.id;

        let tempRecommends = [];
        let totalChecked = 0;
        this.recommendedCandidates.forEach(con=>{
            if(con.id===candidateId){
                con.isChecked = !con.isChecked;
                if(con.isChecked){
                    this.selectedContactsFromTable.push(con)
                }else{
                    this.selectedContactsFromTable = this.selectedContactsFromTable.filter(rec=>rec.id!=con.id);
                }
                //con.isChecked ? this.selectedContactsFromTable.push(con):this.selectedContactsFromTable.pop(con);
            }
            totalChecked+= con.isChecked?1:0;
            tempRecommends.push(con);
        })
        debugger;
        this.allRecommendedSelected = this.recommendedCandidates.length===totalChecked;
        this.recommendedCandidates = tempRecommends;

        console.log("SelectedContactFromTable",this.selectedContactsFromTable);
    }

    prefTableRowListener(event){
        let candidateId = event.currentTarget.dataset.id;

        let tempPrefList = [];
        let totalChecked = 0;
        this.job.prefCandidates.forEach(con=>{
            if(con.id===candidateId){
                con.isChecked = !con.isChecked;
                if(con.isChecked){
                    this.prefSelectedList.push(con)
                }else{
                    this.prefSelectedList = this.prefSelectedList.filter(rec=>rec.id!=con.id);
                }
            }
            totalChecked+= con.isChecked?1:0;
            tempPrefList.push(con);
        })
        debugger;
        this.isPrefAllSelected = this.job.prefCandidates.length===totalChecked;
        this.job.prefCandidates = tempPrefList;
        this.showPrefSelected = totalChecked>0;

        console.log("SelectedContactFromTable",this.job.prefCandidates);
    }

    prefTableAllSelectedListener(event){
        debugger;
        let tempPrefList = [];
        this.isPrefAllSelected = !this.isPrefAllSelected;

        this.job.prefCandidates.forEach(con=>{
            if(this.isPrefAllSelected){
                this.prefSelectedList.push(con)
            }else{
                this.prefSelectedList = this.prefSelectedList.filter(rec=>rec.Id!=con.Id);
            }
            //this.isPrefAllSelected?this.prefSelectedList.push(con):this.prefSelectedList.pop(con);
            con.isChecked = this.isPrefAllSelected;
            tempPrefList.push(con);
        })
        debugger;
        this.job.prefCandidates = tempPrefList;
        this.showPrefSelected = this.isPrefAllSelected;
    }

    searchTableRowSelectedListener(event){
        let candidateId = event.currentTarget.dataset.id;

        let tempSearchedContacts = [];
        let totalChecked = 0;
        this.selectedContacts.forEach(con=>{
            if(con.id===candidateId){
                con.checked = !con.checked;
                if(con.checked){
                    this.selectedContactsFromTable.push(con)
                }else{
                    this.selectedContactsFromTable = this.selectedContactsFromTable.filter(rec=>rec.id!=con.id);
                }
                //con.checked ? this.selectedContactsFromTable.push(con):this.selectedContactsFromTable.pop(con);
            }
            totalChecked+= con.checked?1:0;
            tempSearchedContacts.push(con);
        })
        debugger;
        this.isAllSearchSelected = this.selectedContacts.length===totalChecked;
        this.selectedContacts = tempSearchedContacts;

        console.log("SelectedContactFromTable",this.selectedContactsFromTable);
    }

    recommendedSelectAllHandler(){
        debugger;
        this.selectedContactsFromTable = [];
        let tempRecommends = [];
        this.allRecommendedSelected = !this.allRecommendedSelected;

        this.recommendedCandidates.forEach(con=>{
            if(this.allRecommendedSelected){
                this.selectedContactsFromTable.push(con)
            }else{
                this.selectedContactsFromTable = [];
            }
            //this.allRecommendedSelected?this.selectedContactsFromTable.push(con):this.selectedContactsFromTable.pop(con);
            con.isChecked = this.allRecommendedSelected;
            tempRecommends.push(con);
        })
        debugger;
        this.recommendedCandidates = tempRecommends;
    }

    onchange(){
        debugger;
        alert("JJDSJDJSJDJS");
    }

    searchedSelectAllHandler(){
        this.selectedContactsFromTable = [];
        let tempSearchedContacts = [];

        this.isAllSearchSelected = !this.isAllSearchSelected;

        this.selectedContacts.forEach(con=>{
            if(this.isAllSearchSelected){
                this.selectedContactsFromTable.push(con)
            }else{
                this.selectedContactsFromTable = [];
            }
            //this.isAllSearchSelected?this.selectedContactsFromTable.push(con):this.selectedContactsFromTable.pop(con);
            con.checked = this.isAllSearchSelected;
            tempSearchedContacts.push(con);
        })
        debugger;
        this.selectedContacts = tempSearchedContacts;
    }

    // @wire(getRecommendedCandidates, {jobId: "$jobId",preSelectedCandidates:this.preSelectedContacts})
    // wiredRecommendedCandidates({error,recommendedCandidates}){
    //     console.log("RecommendedList",recommendedCandidates);
    //     if(recommendedCandidates && recommendedCandidates.length > 0) {
    //         this.recommendedCandidates = recommendedCandidates;
    //         this.setRecordsToDisplay();
    //     }
    // }


    
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


    dropDownClicked(){
        this.showDropDownIcon = !this.showDropDownIcon;
    }

    handleSearchAccordion(){
        this.openSearchAccordian = !this.openSearchAccordian;
    }

    selectedSearchExperienceHanlder(event){
        debugger;
        this.selectedSearchExperience = event.detail.value;
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

    connectedCallback() {
        debugger;
        registerListener('saveSearch', this.saveSearch, this);
        registerListener('jobClose', this.closeJob, this);
        //register for job change event
        //registerListener('accountSelected', this.searchAccountSelected, this); //register for job change event

        this.isLoading = true;
    }

    registerBlockerActive = false;

    closeJob(){
        this.recommendedCandidates = [];
        this.recordsToDisplay = [];
        this.registerBlockerActive = true;
    }

    clearCache(){
        this.selectedMapConList = [];
        this.preSelectedContacts = [];
        this.duplicacyMsg = '';
        this.hasDuplicacy = false;
        this.prefSelectedList = [];
        this.isPrefAllSelected = false;
        this.showBottomTable = false;
        this.registerBlockerActive = false;
    }
    @api
    setupJob(jobRequisition) {
        this.removeCache();
        console.log("jobRequisition&&&&&&&&&&",JSON.stringify(jobRequisition));

        if(jobRequisition){
            this.jobSelected = true;

            if(jobRequisition.Client__r){
                this.lat = jobRequisition.Client__r.BillingLatitude;
                this.lang = jobRequisition.Client__r.BillingLongitude;

                console.log('Latitude',this.lat);
                console.log('Longitude',this.lang);
            }
            if(jobRequisition.prefCandidates){
                let objList = [];
                jobRequisition.prefCandidates.forEach(candidate=>{
                    let obj = {
                        id:candidate.Id,
                        profileId :candidate.profileId?candidate.profileId:"https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png",
                        Name:candidate.Name,
                        email:candidate.Email,
                        phone:candidate.Phone,
                        isChecked : false
                    };
                    debugger;
                    objList.push(obj)
                })
                jobRequisition.prefCandidates = objList;
            }

            this.job  = jobRequisition;
            this.jobId = this.job.Id;

            this.clearCache();

            this.job && this.job.Job_Applications__r &&
                this.job.Job_Applications__r.forEach(application=>
                {application.Contact__r && this.preSelectedContacts.push(application.Contact__r.Id)})
        
            this.getRecommendedCandidates();

            if(localStorage.getItem(this.jobId)!=null) {
                let localList = JSON.parse(localStorage.getItem(this.jobId)).permanentSearched;
                if(localList && localList.length > 0) {
                    this.selectedContacts = localList;
                    this.showBottomTable = true;
                    localStorage.removeItem(this.jobId);
                }
            }else{
                this.showBottomTable = false;
            }

            console.log("RECIEVED--------",this.preSelectedContacts);
            console.log('PREFCANDIDATES',this.job.prefCandidates);
        }else{
            this.recommendedCandidates = []
            this.jobSelected = false;
        }
    }

   

    
    saveSearch(){
        localStorage.setItem(this.jobId,JSON.stringify({permanentSearched:this.selectedContacts}));
    }
    createJobApplicationHandler(){
        debugger;
        let candidatesMap= new Map();
        let candidates = {};

        this.selectedContactsFromTable.forEach(con=>{
            if(!this.preSelectedContacts.find(pre=> pre==con.id)){
                candidatesMap.set(con.id,con);
                candidates[con.id] = con;
            }
        })

        if(candidatesMap.size>0){
            if(this.selectedContactsFromTable && this.selectedContactsFromTable.length>0){
                this.loaded = false;
                createJOBApplication({'conWrapperObj':candidates,'jobId':this.job.Id,'jobTitle':this.job.Name}).then(result=>{
                    if(result=='Success'){
                        debugger;
                        this.selectedContacts = this.selectedContacts.filter(c=>!candidatesMap.has(c.id))
                        console.log('After Update',this.selectedContacts);
                        
                        this.selectedContactsFromTable = []; //TODO: empty table and from next time these candidates shouldnt be fetched in any of recommended and searched candidates table, and successfull created applicats will display under applicant table
                        this.showNotification("Success","Job Application created Successfully","success");
                        localStorage.setItem(this.jobId,JSON.stringify({permanentSearched:this.selectedContacts}));

                        this.notifyParent();
                        this.prefferedCandidates = []
                        if(this.selectedContacts.length===0){
                            this.showBottomTable = false;
                        }
                    }
                    this.showPrefCandidates = false;
                    this.showDoNotHireCandidates = false;
                    this.loaded = true;
                }).catch(error=>{
                    console.log('Error to create createjobApplication',error);
                })
            }else{
                this.showNotification("Error","Please select at least one candidate","error");
            }
        }else{
            this.loaded = true;
            this.showNotification("Error","Candidate not available","error");
        }
    }

    notifyParent() {
        //TOTO: notify parent;
        //fireEvent(this.pageRef, 'jobApplicationCreated',this.job.Id);
        this.dispatchEvent(new CustomEvent('appcreated', {detail : this.job.Id}));
    }

    duplicacyMsg = '';
    hasDuplicacy = false;

    handleAddCandidate(event){

        let dupName='';
        this.duplicacyMsg = '';
        this.hasDuplicacy = false;
        let candidateSourceList = [];
        let type = event.currentTarget.dataset.id;

        debugger;

        if(type==="map"){
            this.selectedMapConList.forEach(rec=>{
                if(this.recommendedCandidates.find(can=>can.id===rec.id) || this.selectedContacts.find(can=>can.id===rec.id)){
                    dupName+=rec.Name+" ,"
                    this.hasDuplicacy = true;
                }else{
                    rec.profileId  = rec.profileId?rec.profileId:"https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png",
                    candidateSourceList.push(rec);
                }
            });
        }else if(type==="pref"){
            this.prefSelectedList.forEach(rec=>{
                if(this.recommendedCandidates.find(can=>can.id===rec.id) || this.selectedContacts.find(can=>can.id===rec.id)){
                    dupName+=rec.Name+" ,"
                    this.hasDuplicacy = true;
                }else{
                    candidateSourceList.push(rec);
                }
            });
        }else{
            console.log("SelectedSearchMain",this.selectedSearcConList);
            this.selectedSearcConList.forEach(rec=>{
                if(this.recommendedCandidates.find(can=>can.id===rec.id) || this.selectedContacts.find(can=>can.id===rec.id)){
                    dupName+=rec.Name+" ,"
                    this.hasDuplicacy = true;
                }else{
                    let obj = {...rec};
                    obj.profileId  = rec.profileId?rec.profileId:"https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png",
                    candidateSourceList.push(obj);
                }
            });
        }

        if(this.hasDuplicacy){
            dupName = dupName.substring(0, dupName.length - 1);
            this.duplicacyMsg+=`Candidate: ${dupName} are already part of existing search!`;
            console.log("DuplicacyMSGGGG---",this.duplicacyMsg);
            return;
        }
        this.closeModal();
        this.closeSearchModal();
        this.closePrefModal();

        if(candidateSourceList.length > 0){
            this.selectedContacts.push(...candidateSourceList);
            console.log("Selected Contacts",this.selectedContacts);
            this.showNotification("Success",`${candidateSourceList.length} Candidate Added to search`,"success");  
        }

        this.showBottomTable = this.selectedContacts.length>0;
    }

    @track crownSelected = [];
    crownSelectedListener(event){
        this.crownSelected = event.detail.value;
    }

    handleSearchFilterCandidates(){
        debugger;
        let xRaySoftOpt = this.template.querySelector('.xRaySoftOpt').value;
        let pmsValue = this.template.querySelector('.pms_combobox').value;
        let xray_combobox = this.template.querySelector('.xray_combobox').value;


        this.filteredSearchConList = [];
        let elements =  this.template.querySelectorAll('.searchCustomCheckbox');
        let subQuery = '';

        for(let i=0;i<elements.length;i++){
            console.log('Element Ids----',elements[i].name);
            if(elements[i].checked){
                subQuery += elements[i].name +' = true And '
            }
        }

        if(this.crownSelected.length>0){
            let str = '';
            this.crownSelected.forEach(c=>{
                str+="\'"+c+"\',";
            })
            subQuery+= 'Types_of_Crowns__c In ('+str.slice(0,-1)+') And '
        }

        if(pmsValue!=undefined) subQuery+='PMS_Knowledge__c = \''+pmsValue+"\' AND ";
        if(xRaySoftOpt!=undefined) subQuery+='Image_X_ray_Software__c = \''+xRaySoftOpt+"\' AND ";
        if(xray_combobox!=undefined) subQuery+='X_ray_Proficiency__c = \''+xray_combobox+"\' AND ";

        let qu = this.template.querySelector('c-partial-search-comp').exposeCheckboxes();
        subQuery+=qu;
        subQuery = subQuery.slice(0,-4);

        this.showAddCandidateButtonInSearch = false;
        filterSearchHandler({'lat':this.lat,'lang':this.lang,'city':this.address,'experience':this.selectedSearchExperience,'skills':this._selectedSkills,'preSelectedCandidates':this.getDisplayedCandidates,'subQuery':subQuery}).then(result=>{
            console.log("SearchFilter---",result);
            if(result && result.length > 0) {
                this.filteredSearchConList = result;
                this.filteredSearchConListLength = result.length;
            }else{
                this.showNotification("Empty!","Candidates not found","warning");
            }
        }).catch(error=>{
            console.log("Error----",error)
        })
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

    setRecordsToDisplay() {
        debugger;
        this.totalRecords = 20;
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

    openModal() { 
        this.isViewOnMapModelOpen = true;
    }
    closeModal() {
        this.showButton = false;
        this.isViewOnMapModelOpen = false;
    }


    get getDisplayedCandidates(){
        let avaliableCandidates = [...this.preSelectedContacts];

        this.selectedContacts && this.selectedContacts.forEach(con=> avaliableCandidates.push(con.id));
        this.recommendedCandidates && this.recommendedCandidates.forEach(con=> avaliableCandidates.push(con.id));        
        
        return avaliableCandidates;
    }

    openSearchModal() {
        this.loaded = false;
        this.fetchPicklist();
    }

    @track pmsKnowOpt = [];
    @track xRaySoftOpt = [];
    @track crownsType = [];
    @track xRayPicklistOpt = [];

    fetchPicklist(){
        debugger;

        let fields  = ['Computer_Skills__c','X_ray_Proficiency__c','PMS_Knowledge__c','Image_X_ray_Software__c','Types_of_Crowns__c'];
        gpValues({objName:'Job_Requisition__c',fields:fields}).then(results=>{
            debugger;
            if(results){
                results.forEach(data=>{
                    if(data.fieldName=='Computer_Skills__c'){
                        data.pickValues.forEach(val=>this.skillsPicklistValue.push({label:val,value:val}));
                    }
                    if(data.fieldName=='X_ray_Proficiency__c'){
                        data.pickValues.forEach(val=>this.xRayPicklistOpt.push({label:val,value:val}));
                    }
                    if(data.fieldName=='PMS_Knowledge__c'){
                        data.pickValues.forEach(val=>this.pmsKnowOpt.push({label:val,value:val}));
                    }
                    if(data.fieldName=='Image_X_ray_Software__c'){
                        data.pickValues.forEach(val=>this.xRaySoftOpt.push({label:val,value:val}));
                    }
                    if(data.fieldName=='Types_of_Crowns__c'){
                        data.pickValues.forEach(val=>this.crownsType.push({label:val,value:val}));
                    }
                })
            }
            this.isViewOnSearchModelOpen = true;
            this.loaded = true;
        }).catch(error=>{
            console.log('Error',error);
        })
    }


    closeSearchModal() {
        this.isViewOnSearchModelOpen = false;
        this.showAddCandidateButtonInSearch = false;
        this.filteredSearchConList = [];
        this.filteredSearchConListLength = 0;
    }

    closePrefModal(){
        this.showDoNotHireCandidates = false;
        this.showPrefCandidates = false;
    }

    handleSkillCheckboxHandler(event){
        console.log("Event-----------",event);
        let id = event.detail.value;
        let selectedSkillsIndex = this.skillsPicklistValue.findIndex(skill=>skill===id)
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

    selectedTableRowHanlder(event){
        debugger;
        this.selectedContactsFromTable = [];
        this.selectedContactsFromTable = event.detail.selectedRows;
        // event.detail.selectedRows.forEach(con=>{
            
        //     let index = this.selectedContactsFromTable.indexOf(con);
        //     if(index==-1){
        //         this.selectedContactsFromTable.push(con);
        //     }else{
        //         this.selectedContactsFromTable.pop(con);
        //     }
        // })

        console.log("selectedContactsFromtable",this.selectedContactsFromTable);
        // this.selectedContactsFromTable = event.detail.selectedRows;
        // console.log("SelectedCandidate",this.selectedContactsFromTable);
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
        this.endRecord = end > this.totalRecords ? this.totalRecords : end;
        this.end = end > this.totalRecords ? true : false;

        const event = new CustomEvent('pagination', {
            detail: {
                records: this.recordsToDisplay
            }
        });
        this.dispatchEvent(event);

        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.disableEnableActions();
        }, DELAY);
        this.isLoading = false;
    }

    disableEnableActions() {
        let buttons = this.template.querySelectorAll("lightning-button");

        buttons.forEach(bun => {
            if (bun.label === this.pageNo) {
                bun.disabled = true;
            } else {
                bun.disabled = false;
            }

            if (bun.label === "First") {
                bun.disabled = this.pageNo === 1 ? true : false;
            } else if (bun.label === "Previous") {
                bun.disabled = this.pageNo === 1 ? true : false;
            } else if (bun.label === "Next") {
                bun.disabled = this.pageNo === this.totalPages ? true : false;
            } else if (bun.label === "Last") {
                bun.disabled = this.pageNo === this.totalPages ? true : false;
            }
        });
    }

    mapSelectionHandler(event) {
        this.selectedMapConList = event.detail;
        debugger;
        this.showButton = this.selectedMapConList.length>0;
    }

    openSendSmSPopup(event){
        debugger;
        const recId = event.currentTarget.dataset.id;

        this.smsUrl = `https://ondonte--dev.lightning.force.com/apex/tdc_tsw__SendSMS?id=${recId}&retURL=${window.location.href}`;
        console.log("URL------------------",this.smsUrl)
        this.smsPopup = true;
    }

    sendSMSPopupNewTab(event){
        debugger;
        const recId = event.currentTarget.dataset.id;

        this.smsUrl = `https://ondonte--dev.lightning.force.com/apex/tdc_tsw__SendSMS?id=${recId}&retURL=${window.location.href}`;
        window.open(this.smsUrl, '_blank');
    }

    closeSMSPopup(){
        this.smsPopup = false;
    }

    bulkSmsHandler(event){
        console.log("selectedContactsFromTable",this.selectedContactsFromTable);
        let smsParticipants = [];
        this.selectedContactsFromTable.forEach(can=>{
            smsParticipants.push(can.id);
        })

        if(smsParticipants.length > 0){
            this.smsUrl = `https://ondonte--dev.lightning.force.com/apex/tdc_tsw__SendBulkSMS_SLDS?ids=${smsParticipants}&redirectURL=${window.location.href}`;
            window.open(this.smsUrl, '_blank');
        }else{
            this.showNotification("Error","Please select at least one candidate","error");
        }
        console.log("SMSURL----------------",this.smsUrl);
    }
}