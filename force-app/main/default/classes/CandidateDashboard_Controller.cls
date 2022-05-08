public without sharing class CandidateDashboard_Controller {
    
    public string tabValues                 {get;set;}
    static String code;
    public Boolean isSignUp                 {get;set;}
    public Boolean isLogin                  {get;set;}
    public Boolean isCustomer               {get;set;}
    public Boolean isCandidate              {get;set;}
    public boolean isMentorExist            {get;set;}
    public string  name                     {get;set;}
    public string  FbId                     {get;set;}
    public string  gId                      {get;set;}
    public string  gFname                   {get;set;}
    public string hasCodeUpdate             {get;set;}
    public string Error                     {get;set;}
    public static final String SITE  =      'Login';
    public string currentUserId             {get;set;}
    public string hasCode                   {get;set;}
    public string currentdonorId            {get;set;}
    public Boolean SignupCandidate          {get;set;}
    public Boolean SignupCustomer           {get;set;}
    public string isFBcustomerSignup        {get;set;}
    public string isFBcandidateSignup       {get;set;}
    public string selfAssesmentQuestions    {get;set;}
    public string jobFuncList               {get;set;}
    public string asignmentStatusList       {get;set;}
    public string jobShiftTimings           {get;set;}
    public string jobShiftAvailiblity       {get;set;}
    public string industryType              {get;set;}
    public String candidateSiteURL          {get;set;}
    public String candidateHashcode         {get;set;}
    public static String candidateId        {get;set;}
    public static String workingDaysValues  {get;set;}
    public static String getAllEvents       {get;set;}
    public String blobData                  {get;set;}
    public String temShiftStaffType         {get;set;}
    public String temShiftSpecialSkills     {get;set;}
    public string  candidateName            {get;set;}
    public string  ProfilePictureId         {get;set;}
    public static string  canId         {get;set;}
    
   /* public String blobData {
        get {
            try{
                list<CandidateDashboard_Helper.UserDocumentWrapper> userDocList = getContactUserDoc(getContactId(Apexpages.currentPage().getParameters().get('hc')));
                return EncodingUtil.Base64Encode(userDocList[0].blobFile);
            }catch(Exception e){
                return '';
            }
            
        }
    }  */

    public CandidateDashboard_Controller (){
        candidateSiteURL = Constants.CANDIDATE_SITE ;
        
        candidateHashcode = Apexpages.currentPage().getParameters().get('hc'); 
        system.debug('candidateHashcode---'+candidateHashcode);
        if(!string.isBlank(candidateHashcode)){
            candidateId = getContactId(candidateHashcode);
            contact candidateRecord = [SELECT Id, Name, LastName, Profile_Picture_URL__c,  Profile_Pic_Attachment_Id__c FROM Contact WHERE Id =:candidateId AND Recordtype.Name = :RequiterDashboardConstants.CANDIDATE_RECORD_TYPE];
            candidateName = candidateRecord.LastName;
            ProfilePictureId = candidateRecord.Profile_Pic_Attachment_Id__c;
            canId = candidateRecord.Id;
        }
        list<Customer_Dashboard_Tabs__c> cdTabs = [select name,Tab_Label__c,id,Apex_class_Name__c,Display_Order__c from Customer_Dashboard_Tabs__c ORDER BY Display_Order__c];
        workingDaysValues = JSON.serialize(Utility.getPicklistValues('Contact','Preferred_Working_Days__c'));
        temShiftStaffType = JSON.serialize(Utility.getPicklistValues('Shift__c','Staff_Type__c'));
        temShiftSpecialSkills = JSON.serialize(Utility.getPicklistValues('Shift__c','Special_Skills__c'));

        tabValues = JSON.serialize(cdTabs);
       // getAllEvents = JSON.serialize(getTempJobs(candidateId));
        if(getResumeuserDoc(candidateId) != null)
            blobData = EncodingUtil.Base64Encode(getResumeuserDoc(candidateId)); 
    }

    @RemoteAction
    public static Contact loginUser(string userName, string password){
       return CandidateDashboard_Helper.loginUser(userName, password);
    } 

    public PageReference authenticateUser(){
        system.debug('authenticateUser');
        return CandidateDashboard_Helper.authenticateUser(Apexpages.currentPage().getParameters().get('id'));
    }

    @RemoteAction
    public static CandidateDashboard_Helper.ContactUserDocumentWrapper getUserDetails(string candidateHashcode) {
        return CandidateDashboard_Helper.getUserDetails(candidateHashcode);
    }

    @RemoteAction
    public static list<Job_Requisition__c> getAllJobs(string candidateId) {
        return CandidateDashboard_Helper.getAllJobs(candidateId);
    }

    @RemoteAction
    public static list<Job_Application__c> getMyJobs(string candidateId) {
        return CandidateDashboard_Helper.getMyJobs(candidateId);
    }
   @RemoteAction
    public static list<CandidateDashboard_Helper.UserDocumentWrapper> getAllUserDoc(string applictnId) {
        return CandidateDashboard_Helper.getAllUserDoc(applictnId);
    } 

    @RemoteAction
    public static void updateUserDetails(contact candidateDetails) {
        CandidateDashboard_Helper.updateUserDetails(candidateDetails);
    }

    @RemoteAction
    public static void backgroundcheckConcent(string candidateId) {
        CandidateDashboard_Helper.backgroundcheckConcent(candidateId);
    }

    @RemoteAction
    public static list<Job_Requisition__c> getFilteredJobs(string cnadidateId,string filterJobCity,string placementType,string filterJobName,string filterJobsDate,string filterJobeDate) {
        return CandidateDashboard_Helper.getFilteredJobs(cnadidateId,filterJobCity, placementType, filterJobName, filterJobsDate, filterJobeDate);
    }

    public contact getContactDetails(String hashCode){
        try{
            System.debug('--- hash '+hashCode);
            list<Contact> conList  = [Select id,FirstName,LastName from Contact where login_hash_code__c = :hashCode];
            if(conList.size() > 0){
                return conList[0];
            }
            return null;
        }catch(Exception e){
            return null;
        }
    }



    @RemoteAction
    public static String doUploadAttachment(string type, String attachmentBody, String attachmentName,string conId, String attachmentId, string attId) {
        return CandidateDashboard_Helper.doUploadAttachment(type,attachmentBody, attachmentName,conId, attachmentId, attId);
    }

    @RemoteAction
    public static list<Work_Experience__c> getAllWorkExperience(string conId){
        return CandidateDashboard_Helper.getAllWorkExperience(conId);
    }

    @RemoteAction
    public static Work_Experience__c addWorkExperience(Work_Experience__c wExperience,string startdate, string endDate){
        return CandidateDashboard_Helper.addWorkExperience(wExperience, startdate,  endDate);
    }

    public static string getContactId(string hashcode){
        system.debug('conHashCode---'+hashcode);
        List<contact> currentUser = [select name,id from contact where login_hash_code__c =:hashcode];
        system.debug('currentUser--'+currentUser);
        if(currentUser.size() > 0 ){
            return currentUser[0].Id;
        }else{
            return null;
        }
    }

    @RemoteAction
    public static SovernResponeWrapper resumeParser(string attId, string conId) {
        ContentVersion contentVer =  [SELECT VersionData from ContentVersion where id = :attId];
        SovernAPIHandler sovernHandler = SovernAPIHandler.getInstance();
        string  response = sovernHandler.parseResumeAndGetResult(contentVer.VersionData);
        system.debug('response-----'+response);
        Resume_Parser_Response__c resParser = New Resume_Parser_Response__c(Contact__c=conId,Response__c=response);
        insert resParser;
        
        return SovernResponeWrapper.parse(response);
    }

    @RemoteAction
    public static string applyForJob(string jobId, string candidateId) {
        return CandidateDashboard_Helper.applyForJob(jobId, candidateId);
    }

    @RemoteAction
    public static string updateAvailabllity(string candidateId, list<string> availableDays, integer strtMin,integer strtHour, integer endMin,integer endHour) {
        return CandidateDashboard_Helper.updateAvailabllity(candidateId, availableDays,strtMin, strtHour, endMin, endHour);
    }

    @RemoteAction
    public static string withdrawApplication(string appId) {
        return CandidateDashboard_Helper.withdrawApplication(appId);
    }

    @RemoteAction
    public static void saveResumeResponse(list<education__c> eduDetails, list<Work_Experience__c> wrkExpDetails) {
        CandidateDashboard_Helper.saveResumeResponse(eduDetails, wrkExpDetails);
    }

    @RemoteAction
    public static list<event> getAllEvents(string cnadidateId) {
        return CandidateDashboard_Helper.getAllEvents(cnadidateId);
    }

    @RemoteAction
    public static list<County__c> getAllCounties() {
        return CandidateDashboard_Helper.getAllCounties();
    }
    
    @RemoteAction
    public static list<City__c> getAllCityInCounty(string countyId,List<string> selectedCity) {
        return CandidateDashboard_Helper.getAllCityInCounty(countyId,selectedCity);
    }


    @RemoteAction
    public static string addNewPreferedWorkLocation(string countyId,list<string> cityIdList, string conId) {
        return CandidateDashboard_Helper.addNewPreferedWorkLocation(countyId,cityIdList,conId);
    }

    @RemoteAction
    public static List<Preferred_Work_Location__c> getPreferredWorkingLocation(string conId) {
        return CandidateDashboard_Helper.getPreferredWorkingLocation(conId);
    }

    @RemoteAction
    public static void delteWorkLocation(Preferred_Work_Location__c pWorkLoc) {
        CandidateDashboard_Helper.delteWorkLocation(pWorkLoc);
    }
     
    @RemoteAction
    public static Job_Requisition__c getRequisition(string requisitionId) {
        return CandidateDashboard_Helper.RequisitionDetails(requisitionId);

    }
    @RemoteAction
    public static list<CandidateDashboard_Helper.CandidateShiftWithSkills> getTempJobs(string conId,string filterCity, List<string> JobType,List<string> skillType) {
        system.debug('skillType--'+skillType+'---'+JobType);
        return CandidateDashboard_Helper.getTempJobs(conId,filterCity,JobType,skillType);
    }
    
    @RemoteAction
    public static void applyForShift(string conId,string shiftId, string sDate, string eDate,string startTime,string endTime,string strtDateTime, string endDateTime) {
        CandidateDashboard_Helper.applyForShift(conId, shiftId, sDate, eDate, startTime, endTime,strtDateTime,endDateTime);
    }  

    @RemoteAction
    public static string referCandidate(string candidateId, string refralEmail){
        return CandidateDashboard_Helper.referCandidate(candidateId, refralEmail);
    }
    @RemoteAction
    public static void acceptJob(string jobId){
        CandidateDashboard_Helper.acceptJob(jobId);     
    }
    @RemoteAction
    public static void rejectJob(string jobId){
        CandidateDashboard_Helper.rejectJob(jobId);
    }
    @RemoteAction
    public static list<CandidateDashboard_Helper.UserDocumentWrapper> getContactUserDoc(string parentId) {
        list<CandidateDashboard_Helper.UserDocumentWrapper> userDocList = CandidateDashboard_Helper.getContactUserDoc(parentId);
        return userDocList; 
    }

    @RemoteAction
    public static List<CandidateDashboard_Helper.CandidateShiftWithSkills> getAllocatedShifts(string conid){
        return CandidateDashboard_Helper.getAllocatedShifts(conId);
    }
   
    @RemoteAction
    public static void acceptShift(string shiftId, string candidateId) {
        CandidateDashboard_Helper.acceptShift(shiftId,candidateId);
    }
    @RemoteAction
    public static void rejectShift(string shiftId, string candidateId){
        CandidateDashboard_Helper.rejectShift(shiftId,candidateId);
    }

    @RemoteAction
    public static string withdrawTempJob(string candidateId, string clientShiftId){
       return CandidateDashboard_Helper.withdrawTempJob(candidateId,clientShiftId);
    }

    @RemoteAction
    public static void updateDocExpirydate(integer day,integer month,integer year,string userDocId){
        CandidateDashboard_Helper.updateDocExpirydate(day,month,year,userDocId);
    }

    @RemoteAction
    public static blob getResumeuserDoc(string conId) {
        if(CandidateDashboard_Helper.getResumeuserDoc(conId) != null){
            CandidateDashboard_Helper.UserDocumentWrapper resumeUserDoc = CandidateDashboard_Helper.getResumeuserDoc(conId);
            return resumeUserDoc.contentVersion.VersionData;
        }else{
            return null;
        }
           
    }
}