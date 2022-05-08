public without sharing class CandidateDashboard_Helper {

    public static list<Job_Requisition__c> getAllJobs(string candidateId) {
        try{
            Id Do_Not_Hire = Schema.SObjectType.Preferred_Candidates__c.getRecordTypeInfosByName().get('Do Not Hire').getRecordTypeId();
            List<Preferred_Candidates__c> prefCandidate = [select name,id,Client__c from Preferred_Candidates__c where Candidate__c =:candidateId AND RecordTypeId =:Do_Not_Hire];
            Set<string> notPrefClients = New Set<string>();
            for(Preferred_Candidates__c candidate:prefCandidate){
                notPrefClients.add(candidate.Client__c);
            }
            system.debug(notPrefClients+'----notPrefClients');
            list<Job_Application__c> jobApplications  = [select name,id,Job_Requisition__c  from Job_Application__c where contact__c =:candidateId];

            list<string> jobReq = New List<string>();
            if(jobApplications.size() > 0){
                for(Job_Application__c job:jobApplications){
                    jobReq.add(job.Job_Requisition__c);
                }
            }
            list<Job_Requisition__c> allJobs = [select name,Placement_Type__c,id,Billing_Fee__c,Description__c,Estimated_Close_Date__c,Expected_Start_Date__c,Expected_End_Date__c,Job_Term__c,Status__c from Job_Requisition__c where id NOT IN :jobReq AND Display_On_Portal__c = true AND Placement_Type__c = 'Permanent' AND Client__c NOT IN :notPrefClients AND Status__c = 'Open'];
           
            return allJobs;
        }catch(Exception e){
            //HandleBusinessException.captureError('CandidateDashboard_Helper', 'getAllJobs', e);
            system.debug(e.getLineNumber()+'-----get Message----'+e.getMessage());
            return null;
        }
    }

    public static list<Job_Application__c> getMyJobs(string candidateId) {
        try{
            List<Job_Application__c> myApplications = [select name,id,Application_Stage__c,Bg_Verification_Initiated__c,Bg_Consent_Approved__c,Job_Requisition__r.Name,Job_Requisition__r.Description__c,Job_Requisition__r.Expected_End_Date__c,Job_Requisition__r.Expected_Start_Date__c from Job_Application__c where Contact__c = :candidateId AND Application_stage__c != 'Withdrawl by Candidate'];
            return myApplications;
        }catch(Exception e){
            //HandleBusinessException.captureError('CandidateDashboard_Helper', 'getMyJobs', e);
            system.debug(e.getLineNumber()+'-----get Message----'+e.getMessage());
            return null;
        }
    }

    public static list<Job_Requisition__c> getFilteredJobs(string candidateId,string filterJobCity,string placementType,string filterJobName,string filterJobsDate,string filterJobeDate) {
        list<Job_Application__c> jobApplications  = [select name,id,Job_Requisition__c  from Job_Application__c where contact__c =:candidateId];

        list<string> jobReq = New List<string>();
        if(jobApplications.size() > 0){
            for(Job_Application__c job:jobApplications){
                jobReq.add(job.Job_Requisition__c);
            }
        }
        
        String Query = 'select name,Placement_Type__c,id,Billing_Fee__c,Description__c,Estimated_Close_Date__c,Expected_End_Date__c,Job_Term__c,Status__c from Job_Requisition__c where id NOT IN :jobReq AND Display_On_Portal__c = true';
       
		
        if(!String.isBlank(filterJobName)){
            Query 		+=		' AND Name =: filterJobName';
        }
        
     /*   if(!String.isBlank(filterJobCity)){
            Query 		+= 		' AND City =: filterJobCity';
        } */

        if(!String.isBlank(placementType)){
            Query 		+= 		' AND Placement_Type__c =: placementType';
        }

        if(!String.isBlank(filterJobsDate)){
            String[] startArr = filterJobsDate.split('T');
            string[] startDateArray = startArr[0].split('-');
            
            Integer startYear = Integer.valueOf(startDateArray[0]);
            Integer startMonth = Integer.valueOf(startDateArray[1]);
            Integer startDay = Integer.valueOf(startDateArray[2]);
            date startOfDate = date.newInstance(startYear, startMonth, startDay);
            system.debug('startOfDate----'+startOfDate);
            Query		+=		' AND Expected_Start_Date__c >: startOfDate';
        }


        if(!String.isBlank(filterJobeDate)){
            String[] EndArr = filterJobeDate.split('T');
            string[] endDateArray = EndArr[0].split('-');
            
            Integer endYear = Integer.valueOf(endDateArray[0]);
            Integer endMonth = Integer.valueOf(endDateArray[1]);
            Integer endDay = Integer.valueOf(endDateArray[2]);
            date endOfDate = date.newInstance(endYear, endMonth, endDay);
            system.debug('endDate==='+endOfDate);
            Query		+=		' AND Expected_End_Date__c <: endOfDate';
            
        }
        list<Job_Requisition__c> listOfallJobs = Database.query(Query);
        
        return listOfallJobs;
    }

    public static list<UserDocumentWrapper> getAllUserDoc(string parentId) {
        try{
            list<UserDocumentWrapper> udWrapperList = New List<UserDocumentWrapper>();
            map<string,ContentDocumentLink> userDocIdXcdLink = New map<string,ContentDocumentLink>();
            map<string,User_Document__c> idXUserDoc = New Map<string,User_Document__c>();
            map<string,ContentDocumentLink> udIdXcdLink = New Map<string,ContentDocumentLink>();
            list<User_Document__c> getUserDoc = [select name,id,Status__c from User_Document__c where Job_Application__c =:parentId];
            system.debug('getUserDoc----'+getUserDoc);
            set<string> userDocIdSet = New set<string>();
            for(User_Document__c userDoc:getUserDoc){
                userDocIdSet.add(userDoc.id);
                idXUserDoc.put(userDoc.Id,userDoc);
            }
           
           list<ContentDocumentLink> allDocuments = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType,
            ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId =:userDocIdSet];
            system.debug('allDocuments---'+allDocuments);
            set<string> allDocId = New set<string>();     
            for(ContentDocumentLink doc:allDocuments){
                system.debug('doc--'+doc.Id);
                userDocIdXcdLink.put(doc.LinkedEntityId,doc);
        
               
                allDocId.add(doc.ContentDocumentId);  
            }

            for(string userDocId:userDocIdSet ){
                udIdXcdLink.put(userDocId,userDocIdXcdLink.get(userDocId));
            }
            Map<string,ContentDocumentLink> docNameXcVersion = New Map<string,ContentDocumentLink>();
           
            Map<string,ContentVersion> cdocIdXcVersion = New Map<string,ContentVersion>();
            ContentVersion[] cvs = [SELECT Id, Title, ContentDocumentId from  contentversion where isLatest=true and ContentDocumentId IN :allDocId];
            system.debug('cvs--'+cvs);
            for(ContentVersion doc :cvs){
                cdocIdXcVersion.put(doc.ContentDocumentId,doc);
            }
            system.debug('cdocIdXcVersion--'+cdocIdXcVersion);
            for(string udId: userDocIdSet){
                system.debug('udId----------'+udId);
                UserDocumentWrapper udWrapper = New UserDocumentWrapper();
                udWrapper.userDocument = idXUserDoc.get(udId);
                System.debug('@@@@@'+userDocIdXcdLink.get(udId) );
                
                if(userDocIdXcdLink.get(udId) != null){
                    System.debug('@@@@@-----------'+cdocIdXcVersion.get(userDocIdXcdLink.get(udId).ContentDocumentId));
                    udWrapper.contentVersion = cdocIdXcVersion.get(userDocIdXcdLink.get(udId).ContentDocumentId) ;
                }
                
                udWrapperList.add(udWrapper);
            }
            return udWrapperList;
    }catch(Exception e){
            //HandleBusinessException.captureError('CandidateDashboard_Helper', 'getAllUserDoc', e);
            system.debug(e.getLineNumber()+'-----get Message----'+e.getMessage());
            return null;
    }
    }

    public static list<UserDocumentWrapper> getContactUserDoc(string parentId) {
        try{
            list<UserDocumentWrapper> udWrapperList = New List<UserDocumentWrapper>();
            map<string,ContentDocumentLink> userDocIdXcdLink = New map<string,ContentDocumentLink>();
            map<string,User_Document__c> idXUserDoc = New Map<string,User_Document__c>();
            map<string,ContentDocumentLink> udIdXcdLink = New Map<string,ContentDocumentLink>();
            list<User_Document__c> getUserDoc = [select name,id,Status__c,Description__c,Document_Expiry_Applicable__c,Required__c,Document_Expiry_Date__c from User_Document__c where Contact__c =:parentId];
            system.debug('getUserDoc----'+getUserDoc);
            set<string> userDocIdSet = New set<string>();
            for(User_Document__c userDoc:getUserDoc){
                userDocIdSet.add(userDoc.id);
                idXUserDoc.put(userDoc.Id,userDoc);
            }
           
           list<ContentDocumentLink> allDocuments = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType,
            ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId =:userDocIdSet];
            system.debug('allDocuments---'+allDocuments);
            set<string> allDocId = New set<string>();     
            for(ContentDocumentLink doc:allDocuments){
                system.debug('doc--'+doc.Id);
                userDocIdXcdLink.put(doc.LinkedEntityId,doc);
        
               
                allDocId.add(doc.ContentDocumentId);  
            }

            for(string userDocId:userDocIdSet ){
                udIdXcdLink.put(userDocId,userDocIdXcdLink.get(userDocId));
            }
            Map<string,ContentDocumentLink> docNameXcVersion = New Map<string,ContentDocumentLink>();
           
            Map<string,ContentVersion> cdocIdXcVersion = New Map<string,ContentVersion>();
            ContentVersion[] cvs = [SELECT Id, Title, ContentDocumentId from  contentversion where isLatest=true and ContentDocumentId IN :allDocId];
            system.debug('cvs--'+cvs);
            for(ContentVersion doc :cvs){
                cdocIdXcVersion.put(doc.ContentDocumentId,doc);
            }
            system.debug('cdocIdXcVersion--'+cdocIdXcVersion);
            for(string udId: userDocIdSet){
                system.debug('udId----------'+udId);
                UserDocumentWrapper udWrapper = New UserDocumentWrapper();
                udWrapper.userDocument = idXUserDoc.get(udId);
                System.debug('@@@@@'+userDocIdXcdLink.get(udId) );
                
                if(userDocIdXcdLink.get(udId) != null){
                    System.debug('@@@@@-----------'+cdocIdXcVersion.get(userDocIdXcdLink.get(udId).ContentDocumentId));
                    udWrapper.contentVersion = cdocIdXcVersion.get(userDocIdXcdLink.get(udId).ContentDocumentId) ;
                }
                
                udWrapperList.add(udWrapper);
            }
            return udWrapperList;
    }catch(Exception e){
            //HandleBusinessException.captureError('CandidateDashboard_Helper', 'getAllUserDoc', e);
            system.debug(e.getLineNumber()+'-----get Message----'+e.getMessage());
            return null;
    }
    }

    public static UserDocumentWrapper getResumeuserDoc(string conId) {
        UserDocumentWrapper resumeUserDocWrapper = New UserDocumentWrapper();
        User_Document__c getUserDoc = [select name,id,Status__c from User_Document__c where Contact__c =:conId AND Name='Resume' Limit 1];
        System.debug('@@@@@--getUserDoc------'+getUserDoc);
        if(getUserDoc == null)
            return null;
            resumeUserDocWrapper.userDocument = getUserDoc;
        list<ContentDocumentLink> allDocuments = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType,
        ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId =:getUserDoc.Id Limit 1];
        if(allDocuments.size() == 0)
            return null;

        System.debug('@@@@@--allDocuments------'+allDocuments);
        ContentVersion cvs = [SELECT Id, Title, ContentDocumentId,VersionData  from  contentversion where isLatest=true and ContentDocumentId = :allDocuments[0].ContentDocumentId AND IsLatest=true Limit 1];
        if(cvs == null)
            return null;
        resumeUserDocWrapper.contentVersion = cvs;
        System.debug('@@@@@--cvs------'+cvs);

        return resumeUserDocWrapper;
    }

    public static Pagereference authenticateUser(String hashCode) {
        PageReference pg   = new PageReference('/');        
        if(String.isBlank(hashCode))
            return pg;
        
        system.debug('hashCode===>'+hashCode);  
        
        Id currentUserId = getContactId(hashCode);
        System.debug('auth user id ---'+currentUserId);
        // If current user is not an authorized user 
        // then redirect to login page
        if(currentUserId == null) return pg;
        
        return null;
    }

    private static Id getContactId(String hashCode){
        try{
            list<Contact> user = New List<Contact> ();
            System.debug('--- hash '+hashCode);
            user =  [SELECT id,RecordTypeId,RecordType.developerName, Last_Hash_Code_Updated__c FROM Contact 
                                WHERE Login_hash_Code__c =: hashCode AND Login_Hash_Code__c != null
                                AND RecordType.developerName = :Constants.CANDIDATE ];
            system.debug('user--'+user);
            if(user.size() > 0 && user[0].Last_Hash_Code_Updated__c != null){
                system.debug('Last_Hash_Code_Updated__c not null--'+user[0].Last_Hash_Code_Updated__c);
                if(user[0].Last_Hash_Code_Updated__c.date().daysBetween(system.today()) > 0)
                    return null;
                Long milliseconds = DateTime.now().getTime() - user[0].Last_Hash_Code_Updated__c.getTime();
                Long hours = milliseconds / 1000 / 60 / 60;
                System.debug('---'+hours+'milliseconds---'+milliseconds);
                if(hours > 2) {
                    System.debug('token expired ---');
                    return null;
                }
                system.debug('user[0].Id--'+user[0].Id);
                return user[0].Id;  
            }
            return null;
        }catch(Exception e){
            //HandleBusinessException.captureError('MentorMenteeAuthHelper', 'getContactId', e);
            system.debug(e.getLineNumber()+'-----get Message----'+e.getMessage());
        }
        return null;
    }

    public static contact loginUser(string userName, string password){
        try{
            list<contact> conRec = [select firstName,LastName,id,email,Phone,Login_Hash_Code__c from contact where email =:userName AND Password__c =:password limit 1];
            system.debug('conRec----'+conRec);
            if(conRec.size() > 0 ){
                conRec[0].Login_Hash_Code__c = Utility.generateRandomString();
                update conRec[0];
                return conRec[0];
            }else{
                return null;
            }
        }catch(exception e){
            system.debug(e.getLineNumber()+'---error Message---'+e.getMessage());
            HandleBusinessException.captureError('CandidateDashboard_Helper','loginUser',e);
            return null;
        }

    }

    public static ContactUserDocumentWrapper getUserDetails(string hashCode){
        try{
            Id candidateUDRectypeID = Schema.SObjectType.User_Document__c.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();

            List<contact> UserDetails = [select FirstName,Contact_Role__c,mailingCity,mailingCountry,mailingStreet,LastName,id,email,Preferred_Working_Days__c,Preferred_Start_Time__c,Preferred_End_Time__c,Background_Check_Submission_Date__c,Phone,Profile_Pic_Attachment_Id__c,Login_Hash_Code__c,Background_Check__c,(select name,id,Status__c from user_documents__r where RecordTypeId =:candidateUDRectypeID),(select name,id,Job_Requisition__r.Name,Job_Requisition__r.Description__c,Job_Requisition__r.Expected_Start_Date__c,Job_Requisition__r.Expected_End_Date__c from Job_Applications__r where Application_Stage__c = 'Applied') from contact where Login_Hash_Code__c =:hashCode];
            system.debug('UserDetails-------'+UserDetails);
            system.debug('UserDetails-------'+UserDetails[0]);
            ContactUserDocumentWrapper contactDocWrapper = New ContactUserDocumentWrapper();
            list<UserDocumentWrapper> udWrapperList = New List<UserDocumentWrapper>();
            map<string,ContentDocumentLink> userDocIdXcdLink = New map<string,ContentDocumentLink>();
            map<string,User_Document__c> idXUserDoc = New Map<string,User_Document__c>();
            map<string,ContentDocumentLink> udIdXcdLink = New Map<string,ContentDocumentLink>();
            set<string> userDocIdSet = New set<string>();
            if(UserDetails[0].user_documents__r.size() > 0){
                for(user_document__c userDoc:UserDetails[0].User_Documents__r){
                    userDocIdSet.add(userDoc.id);
                    idXUserDoc.put(userDoc.Id,userDoc);
                }
            }
            system.debug('userDocIdSet-------'+userDocIdSet);
            if(userDocIdSet.size() > 0){
                list<ContentDocumentLink> allDocuments = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType,
            ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId IN :userDocIdSet];
            system.debug('allDocuments---'+allDocuments);
            set<string> allDocId = New set<string>();     
                for(ContentDocumentLink doc:allDocuments){
                    system.debug('doc--'+doc.Id);
                    userDocIdXcdLink.put(doc.LinkedEntityId,doc);
                    allDocId.add(doc.ContentDocumentId);  
                }

                for(string userDocId:userDocIdSet ){
                    udIdXcdLink.put(userDocId,userDocIdXcdLink.get(userDocId));
                }
                Map<string,ContentDocumentLink> docNameXcVersion = New Map<string,ContentDocumentLink>();
           
                Map<string,ContentVersion> cdocIdXcVersion = New Map<string,ContentVersion>();
                ContentVersion[] cvs = [SELECT Id, Title, ContentDocumentId from  contentversion where isLatest=true and ContentDocumentId IN :allDocId];
                system.debug('cvs--'+cvs);
                for(ContentVersion doc :cvs){
                    cdocIdXcVersion.put(doc.ContentDocumentId,doc);
                }
                system.debug('cdocIdXcVersion--'+cdocIdXcVersion);
                for(string udId: userDocIdSet){
                    system.debug('udId----------'+udId);
                    UserDocumentWrapper udWrapper = New UserDocumentWrapper();
                    udWrapper.userDocument = idXUserDoc.get(udId);
                    System.debug('@@@@@'+userDocIdXcdLink.get(udId) );
                    
                    if(userDocIdXcdLink.get(udId) != null){
                        System.debug('@@@@@-----------'+cdocIdXcVersion.get(userDocIdXcdLink.get(udId).ContentDocumentId));
                        udWrapper.contentVersion = cdocIdXcVersion.get(userDocIdXcdLink.get(udId).ContentDocumentId) ;
                    }
                    
                    udWrapperList.add(udWrapper);
                }
            }


            if(UserDetails.size() > 0){
                contactDocWrapper.userDetails = UserDetails[0];
                contactDocWrapper.userDocWrapper = udWrapperList;
                contactDocWrapper.jobsToAcceptByCandidate = UserDetails[0].Job_Applications__r;
                return contactDocWrapper;
            }else{
                return null;
            }
        }
    catch(exception e){
            system.debug(e.getLineNumber()+'---error Message---'+e.getMessage());
            //HandleBusinessException.captureError('CandidateDashboard_Helper','getUserDetails',e);
            return null;
        }
    }  

    @RemoteAction
    public static String doUploadAttachment(string type, String attachmentBody, String attachmentName,string conId, String attachmentId, string attId) {
        system.debug('appId--'+attachmentId+'attachmentBody---'+attachmentName+'---attachmentId---'+attId+'---attId---');

    ContentVersion conVer = new ContentVersion();
    conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
    conVer.PathOnClient = 'attachmentName'; // The files name, extension is very important here which will help the file in preview.
    conVer.Title = attachmentName; // Display name of the files
    conVer.VersionData = EncodingUtil.base64Decode(attachmentBody); // converting your binary string to Blog
    insert conVer;    //Insert ContentVersion


    // First get the Content Document Id from ContentVersion Object
    Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
    //create ContentDocumentLink  record 
    ContentDocumentLink conDocLink = New ContentDocumentLink();
    conDocLink.LinkedEntityId = attId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
    conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
    conDocLink.shareType = 'V';
    insert conDocLink;
    if(type == 'profilePic' && String.isNotEmpty(conId)){
        updateContactProfilepicId(conId,conVer.Id);
    } else if(type == 'resume'){
        system.debug('type ==  resume');
        User_Document__c udoc = New User_Document__c(id=attId,Status__c='Uploaded');
        update udoc;
       /* SovernAPIHandler sovernHandler = SovernAPIHandler.getInstance();
        string  response = sovernHandler.parseResumeAndGetResult(conVer.VersionData); */
        //system.debug('response-----'+response);
    }else{
        User_Document__c udoc = New User_Document__c(id=attId,Status__c='Uploaded',User_Document_Attachment_Id__c=conVer.Id);
        update udoc;
    }
        return conVer.Id;
    }
    public static void updateContactProfilepicId(string conId,string picAttId){
        Contact conRec = New Contact(id=conid,Profile_Pic_Attachment_Id__c=picAttId);
        update conRec;
    }

    public static string applyForJob(string jobId, string candidateId) {
        try{
            Job_Application__c jobApp = New Job_Application__c(Job_Requisition__c=jobId,Application_Stage__c=Constants.APPCANDIDATESTAGE,contact__c=candidateId,Type__c='Online');
            insert jobApp;
            Job_Application__c jApp = New Job_Application__c(id=jobApp.Id,Application_Stage__c='Accepted By Candidate');
            update jApp;
            return jApp.Id;
        }Catch(Exception e){
        System.debug(e.getMessage());
        return null;
        }
    }
    public static void updateUserDetails(contact candidateDetails) {
        //candidateDetails.phone = String.valueOf(candidateDetails.phone);
        update candidateDetails;
    }

    public static list<Work_Experience__c> getAllWorkExperience(string conId){
        return [select name,id,Contact__c,Duration__c,Employer_Name__c,End_Date__c,Start_Date__c from Work_Experience__c where Applicant__c = :conId];
    }

    @RemoteAction
    public static string updateAvailabllity(string candidateId, list<string> availableDays, integer strtMin,integer strtHour, integer endMin,integer endHour) {
        try{
            system.debug('availableDays--'+availableDays);
            string colenSepratedList = '';
            for(String str : availableDays){
            colenSepratedList += str.substring(0, 3) + ';' ;
            }
            system.debug('colenSepratedList--'+colenSepratedList);
            contact conRec = New contact(id=candidateId, Preferred_Working_Days__c =colenSepratedList, Preferred_Start_Time__c = Time.newInstance(strtHour, strtMin, 0, 0),Preferred_End_Time__c = Time.newInstance(endHour, endMin, 0, 0));
            update conRec;
            return 'success';
        }catch(exception e){
            system.debug(e.getLineNumber()+'-------'+e.getMessage());
            return null;
        }
    }

    public static Work_Experience__c addWorkExperience(Work_Experience__c wExperience,string startdate, string endDate){
        wExperience.Start_Date__c = Date.parse(startdate);
        wExperience.End_date__c = Date.parse(endDate);
        insert wExperience;
        return wExperience;
    }

    public static string withdrawApplication(string appId) {
        Job_Application__c applictn = New Job_Application__c(id=appId,Application_stage__c='Withdrawn by Candidate');
        update applictn;
        return applictn.id;
    }

    public static list<event> getAllEvents(string cnadidateId){
        list<job_application__c> allApplications = [select name,id from job_application__c where Contact__c =:cnadidateId];
        List<string> appId = New List<string>();
        for(job_application__c app:allApplications){
            appId.add(app.id);
        }
        list<event> allcandidateEvents = [select id,what.id,StartDateTime,Description,Subject,IsRecurrence,RecurrenceEndDateOnly,whatId,whoId,Interview_Status__c,Zoom_Invite_Link__c  from Event where (WhoId =:cnadidateId OR WhatId IN:appId) AND Interview_Status__c = 'Scheduled'];
        system.debug('allcandidateEvents----'+allcandidateEvents);
       /* if(appId.size() > 0){
            
            list<event> allApplicationEvents = [select id,what.id,StartDateTime,Description,Subject,IsRecurrence,RecurrenceEndDateOnly,whatId,whoId  from Event where WhatId =:cnadidateId];
            system.debug('allApplicationEvents----'+allApplicationEvents);

            allcandidateEvents.addAll(allApplicationEvents);
        }  */
        return allcandidateEvents;
    }

    public static string mapResumeParserResponse(SovernResponeWrapper sovrenWrapper){

        return null;
    }
    public static void saveResumeResponse(list<education__c> eduDetails, list<Work_Experience__c> wrkExpDetails) {
      /*  for(education__c edu:eduDetails){
            edu.End_Year__c = Date.parse(edu.End_Year__c);
        }
        for(Work_Experience__c edu:wrkExpDetails){
            edu.Start_Date__c = Date.parse(edu.Start_Date__c);
            edu.End_Date__c = Date.parse(edu.End_Date__c);
        } */
        insert eduDetails;
        insert wrkExpDetails;
    }

    public static list<County__c> getAllCounties() {
        return [select name,id from county__c];
    }
    public static list<City__c> getAllCityInCounty(string countyId, List<string> selectedCity) {
        return [select name,id from City__c where County__c =:countyId AND Id NOT IN :selectedCity];
    }

    public static string addNewPreferedWorkLocation(string countyId,list<string> cityIdList, string conId) {
        system.debug('Insert New Preferred work locationd');
        try{
            if(cityIdList.size() > 0){
                list<Preferred_Work_Location__c> pWorkLocList = New list<Preferred_Work_Location__c>();
    
                for(string city:cityIdList){
                    Preferred_Work_Location__c pWorkLoc = New Preferred_Work_Location__c();
                    pWorkLoc.City__c = city;
                    pWorkLoc.Contact__c = conId;
                    pWorkLoc.County__c = countyId;
                    pWorkLocList.add(pWorkLoc);
                }
                insert pWorkLocList;
                return 'success';
            }
            return null;
        }catch(exception e){
            system.debug(e.getLineNumber()+'----'+e.getMessage());
            if(e.getMessage().contains('Update ExternalId Value')){
                return 'duplicate';
            }
            return 'error';  
        }
    }

    public static List<Preferred_Work_Location__c> getPreferredWorkingLocation(string conId) {
        return [select name,id,City__r.Name,County__r.Name from Preferred_Work_Location__c where contact__c=:conId];
    }

    public static void delteWorkLocation(Preferred_Work_Location__c pWorkLoc) {
       delete pWorkLoc;
    }

    public static List<CandidateShiftWithSkills> getTempJobs(string conId,string filterCity, List<string> JobType, List<string> skillType) {
    
         Id Do_Not_Hire = Schema.SObjectType.Preferred_Candidates__c.getRecordTypeInfosByName().get('Do Not Hire').getRecordTypeId();
        List<Preferred_Candidates__c> prefCandidate = [select name,id,Client__c from Preferred_Candidates__c where Candidate__c =:conId AND RecordTypeId =:Do_Not_Hire];
        
        Set<string> notPrefClients = New Set<string>();
        if(prefCandidate.size() > 0){
            for(Preferred_Candidates__c candidate:prefCandidate){
                notPrefClients.add(candidate.Client__c);
            }    
        }
        system.debug('---notPrefClients----'+notPrefClients);
        system.debug('Ondonte_Configuration__c.getOrgDefaults().Candidate_Calday_View_count__c'+Ondonte_Configuration__c.getOrgDefaults().Candidate_Calday_View_count__c);
        dateTime sDate = datetime.now();
        dateTime eDate = sDate.addDays(Integer.valueOf(Ondonte_Configuration__c.getOrgDefaults().Candidate_Calday_View_count__c)); 
        List<shift__c> allCandidateSifts = [SELECT Id, Name,Status__c, format(Start_DateTime__c), format(End_DateTime__c),Allocated_To__c,Staff_Type__c from Shift__c where Start_DateTime__c>:sDate AND End_DateTime__c <:eDate AND Recordtype.Name =:RequiterDashboardConstants.CANDIDATE_RECORD_TYPE AND  Contact__c =: conId];  //AND status__c ='Open'
        Map<Date,List<shift__c>> jobDateXcandidateshift = New Map<Date,List<shift__c>>();
        Map<Date,string> jobDateXallocatedShift = New Map<Date,string>();
        system.debug('allCandidateSifts---'+allCandidateSifts);
        if(allCandidateSifts.size() > 0 ){
            for(shift__c shift:allCandidateSifts){
                date myDate = date.newinstance(shift.Start_DateTime__c.year(), shift.Start_DateTime__c.month(), shift.Start_DateTime__c.day());
                if(jobDateXcandidateshift.containsKey(myDate)){
                    system.debug('inside If');
                    List<shift__c> shiftList = jobDateXcandidateshift.get(myDate);
                    shiftList.add(shift);
                }else{
                    system.debug('inside else');
                    List<shift__c> shiftList = New List<shift__c>();
                    shiftList.add(shift);
                    jobDateXcandidateshift.put(myDate,shiftList);
                }
                if(shift.Allocated_To__c != null){
                    jobDateXallocatedShift.put(Date.newInstance(shift.Start_DateTime__c.year(), shift.Start_DateTime__c.month(), shift.Start_DateTime__c.day()),shift.Allocated_To__c);
                }
            }
    
        }
        system.debug('jobDateXcandidateshift--'+jobDateXcandidateshift);
      //  List<shift__c> allClientSifts = [SELECT Id, Name, Type__c,format(Start_DateTime__c), format(End_DateTime__c),Status__c,Job_Requisition__r.Street_Address__c  from Shift__c where Start_DateTime__c>:sDate AND End_DateTime__c <:eDate AND Recordtype.Name =:RequiterDashboardConstants.CLIENT_RECORD_TYPE AND  Job_Requisition__r.Client__c NOT IN:notPrefClients AND status__c = 'Open'];  //

        string clientShiftQueryString = 'SELECT Id, Name, Type__c,Start_DateTime__c,End_DateTime__c,Status__c,Job_Requisition__r.Street_Address__c,City__c,Staff_Type__c,Special_Skills__c  from Shift__c where Start_DateTime__c>:sDate AND End_DateTime__c <:eDate AND Recordtype.Name =\'Client\' AND  Job_Requisition__r.Client__c NOT IN:notPrefClients AND status__c = \'Open\'';
        if(!string.isBlank(filterCity)){
            system.debug('filterCity---'+filterCity);
            clientShiftQueryString += ' AND City__c =:filterCity';
        }
        if(JobType.size() > 0){
            string filterString = string.join(JobType,';');
            clientShiftQueryString += ' AND Staff_Type__c INCLUDES (:filterString )';
           
        }
        if(skillType.size() > 0){
            string skillTypeString = string.join(skillType,';');
            clientShiftQueryString += ' AND Special_Skills__c INCLUDES (:skillTypeString )';
           
        }
        system.debug('clientShiftQueryString---'+clientShiftQueryString);
        List<shift__c> allClientSifts  = Database.query(clientShiftQueryString);
      system.debug('allClientSifts--'+allClientSifts.size());
        set<shift__c> clientShiftsToDisplay = New set<shift__c>();
        Map<Date,List<shift__c>> jobDateXclientshift = New Map<Date,List<shift__c>>();
        for(shift__c shift:allClientSifts){
            date myDate = date.newinstance(shift.Start_DateTime__c.year(), shift.Start_DateTime__c.month(), shift.Start_DateTime__c.day());
            list<shift__c> candidateShift = New List<shift__c>();
            if(jobDateXcandidateshift.containsKey(myDate))
                candidateShift = jobDateXcandidateshift.get(myDate);
            if(candidateShift.size() > 0){
                system.debug(candidateShift.size()+'---candidateShift.size()');
                for(shift__c candShift:candidateShift){
                    system.debug('candShift.Start_DateTime__c--'+candShift.Start_DateTime__c +'shift.Start_DateTime__c--'+shift.Start_DateTime__c +'--candShift.End_DateTime__c--'+ candShift.End_DateTime__c +'----shift.End_DateTime__c---'+shift.End_DateTime__c);
                   /* if(candShift.Start_DateTime__c <= shift.Start_DateTime__c && candShift.End_DateTime__c >= shift.End_DateTime__c){
                        system.debug('candShift.Start_DateTime__c--'+candShift.Start_DateTime__c +'shift.Start_DateTime__c--'+shift.Start_DateTime__c +'--candShift.End_DateTime__c--'+ candShift.End_DateTime__c +'----shift.End_DateTime__c---'+shift.End_DateTime__c);
                        clientShiftsToDisplay.add(shift);
                    } */
                    system.debug(MatchingAlgorithm.getMatchPercentage(candShift.Start_DateTime__c, candShift.End_DateTime__c, shift.Start_DateTime__c, shift.End_DateTime__c));
                date candiStartDate = Date.newInstance(candShift.Start_DateTime__c.Year(), candShift.Start_DateTime__c.month(), candShift.Start_DateTime__c.day()); 
                date clientStrtDate =    Date.newInstance(shift.Start_DateTime__c.Year(), shift.Start_DateTime__c.month(), shift.Start_DateTime__c.day());    
                if(candiStartDate == clientStrtDate){
                    if(MatchingAlgorithm.getMatchPercentage(candShift.Start_DateTime__c, candShift.End_DateTime__c, shift.Start_DateTime__c, shift.End_DateTime__c) > 30){
                        clientShiftsToDisplay.add(shift);
                    }
                }
               
                }
            }
        }
        system.debug('clientShiftsToDisplay----'+clientShiftsToDisplay);
        List<CandidateShiftWithSkills> candiShiftDetailList = New List<CandidateShiftWithSkills>();
       // List<string> skillsToDisplay = New List<string>{ };
       // Map<string,string> apiNameXlabel = Utility.getAllFields('shift__c',skillsToDisplay);
        for(shift__c shift:clientShiftsToDisplay){
            CandidateShiftWithSkills candiShiftDetail = New CandidateShiftWithSkills();
            List<string> skillLists = New List<string>();
          /*  for(string apiName:apiNameXlabel.keySet()){
                system.debug('shift.get(apiName)---'+shift.get(apiName));
                if(shift.get(apiName) == True){
                    skillLists.add(apiNameXlabel.get(apiName));
                }
                system.debug('shift---'+shift);
                system.debug('skillLists---'+skillLists);
            }  */
            if(jobDateXallocatedShift.get(Date.newInstance(shift.Start_DateTime__c.Year(), shift.Start_DateTime__c.month(), shift.Start_DateTime__c.day())) != null){
                candiShiftDetail.haveShiftOnSameDay = true;
                if(jobDateXallocatedShift.get(Date.newInstance(shift.Start_DateTime__c.Year(), shift.Start_DateTime__c.month(), shift.Start_DateTime__c.day())) == shift.Id){
                    candiShiftDetail.shiftAlreadyAllocated = true;
                }else{
                    candiShiftDetail.shiftAlreadyAllocated = false;
                }
            }else{
                candiShiftDetail.shiftAlreadyAllocated = false;
                candiShiftDetail.haveShiftOnSameDay = false;
            }
            candiShiftDetail.shift = shift;
            candiShiftDetail.skillList = skillLists;
            candiShiftDetailList.add(candiShiftDetail);
        }
        system.debug('candiShiftDetailList---'+candiShiftDetailList);
        return candiShiftDetailList;
    }


    Public static contact getCandidateDetails(string conId){
        return [select name,id,Preferred_Working_Days__c,Preferred_Start_Time__c,Preferred_End_Time__c from contact where Id =:conId];
    }

    public static void applyForShift(string conId,string shiftId, string sDate, string eDate,string startTime,string endTime,string strtDateTime, string endDateTime) {
        system.debug('conId----'+conId+'-----'+shiftId+'-------shiftId-----'+sDate+'--startTime--'+startTime+'----eDate-------'+eDate+'===='+strtDateTime+'------'+endDateTime);
        String[] startDateArray = sDate.split('/');
        String[] endDateArray = eDate.split('/');
        system.debug(startDateArray[0]);
        system.debug(startDateArray[1]);

        Long startDatetimestamp = Long.valueOf(strtDateTime);
        DateTime gmtstrtDatetime = DateTime.newInstance(startDatetimestamp);
        Long endtimestamp = Long.valueOf(endDateTime);
        DateTime gmtendDatetime = DateTime.newInstance(endtimestamp);
     
        system.debug(gmtstrtDatetime+'---startDate---'+gmtendDatetime+'--endDate---');
        List<shift__c> allSifts = [SELECT Id, Name, Start_DateTime__c, End_DateTime__c  from Shift__c where Start_DateTime__c <=:gmtstrtDatetime AND End_DateTime__c >=:gmtendDatetime AND Recordtype.Name =:RequiterDashboardConstants.CANDIDATE_RECORD_TYPE AND Contact__c =:conId LIMIT 1];  //AND status__c ='Open'
        system.debug('allSifts--'+allSifts);
        if(allSifts.Size() > 0){
            shift__c candidateShift = New shift__c(id=allSifts[0].Id,Allocated_To__c=shiftId,Status__c='Assigned',Type__c='Online');
            update candidateShift;
            shift__c clientShiftAccepted = New shift__c(Id=candidateShift.Id,Status__c='Accepted By Candidate');
            update clientShiftAccepted;
        }
    }  

    public static string referCandidate(string candidateId, string refralEmail){
        return Utility.returnOndonteUid(refralEmail,candidateId);
    }

    public static void acceptJob(string jobId){
        Job_Application__c jApplication = New Job_Application__c(id=jobId,Application_Stage__c='Accepted By Candidate');
            update jApplication;        
    }

    public static void rejectJob(string jobId){
        Job_Application__c jApplication = New Job_Application__c(id=jobId,Application_Stage__c='Withdrawn by Candidate');
            update jApplication;
    }

    public static void backgroundcheckConcent(string conId){
        Contact conRec = New Contact(id=conId,Background_Check__c='Yes');
        List<Job_Application__c> myApplications = [select name,id,Application_Stage__c,Bg_Verification_Initiated__c,Bg_Consent_Approved__c,Job_Requisition__r.Name,Job_Requisition__r.Description__c,Job_Requisition__r.Expected_End_Date__c,Job_Requisition__r.Expected_Start_Date__c from Job_Application__c where Contact__c = :conId];
        for(Job_Application__c app:myApplications){
            app.Bg_Consent_Approved__c = true;
        }
        update myApplications;
    }

    public static List<CandidateShiftWithSkills> getAllocatedShifts(string conid){
        datetime myDateTime = datetime.now();
        List<shift__c> allocatedShifts = [select name,Allocated_To__c,id,End_DateTime__c from shift__c where Contact__c =:conId and Start_DateTime__c >= :myDateTime AND Status__c ='Assigned'];
        system.debug('allocatedShifts-----'+allocatedShifts);
        List<string> clientShiftId = New List<string>();
        for(shift__c shift:allocatedShifts){
            clientShiftId.add(shift.Allocated_To__c);
        }
        if(clientShiftId.size() == 0){
            return null;
        }
        List<shift__c> assignedClientShift =  [select name,Allocated_To__c,id,Start_DateTime__c from shift__c where Id IN :clientShiftId];   

        List<CandidateShiftWithSkills> candiShiftDetailList = New List<CandidateShiftWithSkills>();
        List<string> skillsToDisplay = New List<string>{};
        Map<string,string> apiNameXlabel = Utility.getAllFields('shift__c',skillsToDisplay);
        system.debug('apiNameXlabel-----'+apiNameXlabel);
        for(shift__c shift:assignedClientShift){
            CandidateShiftWithSkills candiShiftDetail = New CandidateShiftWithSkills();
            List<string> skillLists = New List<string>();
            for(string apiName:apiNameXlabel.keySet()){
                system.debug('shift.get(apiName)---'+shift.get(apiName));
                if(shift.get(apiName) == True){
                    skillLists.add(apiNameXlabel.get(apiName));
                }
                system.debug('shift---'+shift);
                system.debug('skillLists---'+skillLists);
            }
            candiShiftDetail.shift = shift;
            candiShiftDetail.skillList = skillLists;
            candiShiftDetailList.add(candiShiftDetail);
        }
       
        return candiShiftDetailList;
    }

    public static void acceptShift(string shiftId, string candidateId) {
        shift__c clientShift = [select name,id,(select name,id from Shifts__r where Contact__c =:candidateId limit 1) from shift__c where Id =:shiftId];
        if(clientShift.Shifts__r != null ){
            Shift__c shift = New Shift__c(Id=clientShift.Shifts__r[0].Id, status__c='Accepted By Candidate');
            update shift;
        }
       
    }

    public static void rejectShift(string shiftId, string candidateId){
        shift__c clientShift = [select name,id,(select name,id from Shifts__r where Contact__c =:candidateId limit 1) from shift__c where Id =:shiftId];
        if(clientShift.Shifts__r != null ){
        Shift__c shift = New Shift__c(Id=clientShift.Shifts__r[0].Id, status__c='Available', Allocated_To__c=null);
        update shift;
        }
    }

    @RemoteAction
    public static Job_Requisition__c RequisitionDetails(string jobReqId) {
        return [select name,id,Intraoral_Camera__c,Invisalign__c,General_Competency__c,Assist_w_Nitrous_Administration__c,Chairside_Scheduling__c,Loupes__c,Micro_Ultrasonic__c,Perio_Charting__c,Treatment_Plan_to_Goal__c,Goal_Oriented_scheduling__c,Insurance_Benefit_Coordination__c,Insurance_Processing__c,Insurance_Verification_and_Pre_Auth__c,Medicare_Billing__c,Practice_Management_Software_Reports__c,Prepare_Daily_Deposit__c,Prepare_Day_Sheet__c,Recall_Maintenance__c,Treatment_Planning_Software__c,Treatment_Presentation__c,AR_Management__c from Job_Requisition__c where id=:jobReqId];
    }

    public static string withdrawTempJob(string candidateId, string clientShiftId){
        system.debug('candidateId'+candidateId+'----clientShiftId---'+clientShiftId);
        List<shift__c> candidateShift = [select name,status__c,id from shift__c where Allocated_To__c =:clientShiftId AND Contact__c =:candidateId ORDER BY createdDate DESC limit 1];
        system.debug('candidateShift----'+candidateShift);
        if(candidateShift.size() > 0){
            candidateShift[0].status__c = 'Available';
            candidateShift[0].Allocated_To__c = null;
            update candidateShift[0];
            return 'success';
        }
        return 'notfound';
    }

    public static void updateDocExpirydate(integer day,integer month,integer year,string userDocId){
        user_document__c useDoc = New user_document__c(id=userDocId,Document_Expiry_Date__c=date.newInstance(year,month,day));
        update useDoc;
    }

    public class CandidateShiftWithSkills{
        public shift__c shift;
        public shift__c candidateShift;
        public List<string> skillList;
        public boolean haveShiftOnSameDay;
        public boolean shiftAlreadyAllocated;
    }

    public class ContactUserDocumentWrapper{
        public list<UserDocumentWrapper> userDocWrapper;
        public Contact userDetails;
        public list<Job_Application__c> jobsToAcceptByCandidate;
    }

    public class UserDocumentWrapper{
        public User_Document__c userDocument;
        public ContentVersion contentVersion;
    }
}