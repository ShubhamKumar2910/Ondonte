public with sharing class RecruiterDashboardContentController {
    
    @AuraEnabled(cacheable=true) 
    public static List<ContactWrapper> getRecommendedCandidates(String jobIdString, List<String> preSelectedCandidates){
        List<Contact> conList = new List<Contact>();
        List<ContactWrapper> conWrapperList = new List<ContactWrapper>();
        String preSelectedcandidatesId = '';

        System.debug('preSelectedCandidates----'+preSelectedCandidates);

        // String query = 'Select Id, Name, email, Desired_Pay__c, Candidate_Status__c, MailingAddress,Phone,  GeoLocation__c ,Description FROM Contact Where Recordtype.Name = \''+RequiterDashboardConstants.CANDIDATE_RECORD_TYPE+'\'';

        // if(!preSelectedCandidates.isEmpty()){
        //     Integer k=0;

        //     for(String s: preSelectedCandidates){
        //         if(k>0)
        //             preSelectedcandidatesId += ' , ';
        //         preSelectedcandidatesId += '\''+s+'\'';
        //         k++;
        //     }
        //     query += ' And Id EXCLUDES ('+preSelectedcandidatesId+')';
        // }

        // query+= 'LIMIT 20'
        preSelectedCandidates.add('0033N00000j01r6QAA');
        preSelectedCandidates.add('0033N00000ipR43QAE');

        try{
            conList = [Select Id, Name,Email,Profile_Picture_URL__c, Desired_Pay__c,Candidate_Status__c, MailingAddress ,Phone,  GeoLocation__c ,Description FROM Contact where Recordtype.Name =: RequiterDashboardConstants.CANDIDATE_RECORD_TYPE  And Candidate_Status__c='Active' And ID NOT IN :preSelectedCandidates LIMIT 20];

            for(Contact order: conList){
                conWrapperList.add(new ContactWrapper(order.Id,order.Name,order.Profile_Picture_URL__c,40,order.Description,0,order.Email,order.Desired_Pay__c, order.Candidate_Status__c,order.Phone));
            }
        }catch(DMLException ex){
            HandleBusinessException.captureError('EventTriggerHandler','handleInterviewedEvents',ex);
        }

        return conWrapperList;
    }

    @AuraEnabled(cacheable=true)
    public static Map<string,object> getNearByCandidates(String jobName, Double lat, Double lang, Integer distance, String sortByType, List<String> preSelectedCandidates){ 
        System.debug('DISTANCE----'+distance);
    	System.debug('LAT------'+lat);
        System.debug('LONG------'+lang);

        Map<string,object> mainMap = new Map<string,object>();
        Map<string,object> markerMap = new Map<string,object>();
        Map<string,object> addressMap = new Map<string,object>();
        List<Map<string,object>> markerList = new List<Map<string,object>>();

        Location accloc = Location.newInstance(lat,lang);
        
        List<Contact> conList = new List<Contact>(); 
        List<ContactWrapper> conWrapperList = new List<ContactWrapper>();

        if(sortByType=='distance'){
            conList = [Select Id, Name,Profile_Picture_URL__c,Email, Desired_Pay__c,Candidate_Status__c, MailingAddress ,Phone,  GeoLocation__c ,Description FROM Contact where DISTANCE(GeoLocation__c, GEOLOCATION(:lat,:lang),'km') < :distance AND  Recordtype.Name =: RequiterDashboardConstants.CANDIDATE_RECORD_TYPE And Candidate_Status__c='Active' And ID NOT IN :preSelectedCandidates LIMIT 20];
            system.debug('Running');
        }else{
            system.debug('RunningElse');
        }

        markerMap.put('title', jobName);
        markerMap.put('icon','standard:account');
        
        markerMap.put('type', 'Circle');
        markerMap.put('radius', Distance*1000);
        markerMap.put('strokeColor','#FFF000');
        markerMap.put('strokeOpacity', 0.8);
        markerMap.put('strokeWeight',2);
        markerMap.put('fillColor','#FFF000');
        markerMap.put('fillOpacity',0.35);
        
        markerMap.put('description','');
        
        addressMap.put('Latitude',lat);
        addressMap.put('Longitude',lang);
        
        markerMap.put('location',addressMap);
        markerList.add(markerMap);

        for(Contact order : conList){   
            
            Location conloc = order.GeoLocation__c;

            Double dist = Location.getDistance(accloc, conloc, 'km');

            Decimal toround = dist;
            Decimal rounded = toround.setScale(2);
        
            conWrapperList.add(new ContactWrapper(order.Id,order.Name,order.Profile_Picture_URL__c,40,order.Description,rounded,order.Email,order.Desired_Pay__c, order.Candidate_Status__c,order.Phone));

            if(dist < Distance){
                markerMap = new map<string,object>();
                markerMap.put('title', order.name);
                markerMap.put('description',order.Description != null ? order.Description : '');
                markerMap.put('icon','standard:person_name');
                markerMap.put('value',order.Id);
                addressMap = new map<string,object>();
                addressMap.put('Latitude',order.GeoLocation__c.getLatitude());
                addressMap.put('Longitude',order.GeoLocation__c.getLongitude());
                markerMap.put('location',addressMap);
                markerList.add(markerMap);  
            }
        }
        
        mainMap.put('markerList',markerList);
        mainMap.put('conList',conWrapperList);
        
        system.debug('+++++++'+JSON.serialize(conWrapperList));  
        return mainMap;  
    }


    @AuraEnabled(cacheable=true)
    public static List<ContactWrapper> filterSearchHandler(Double lat, Double lang, String city, String experience,List<String> skills,List<String> preSelectedCandidates,String subQuery){ 

        System.debug('LAT---'+lat);
        System.debug('LONG---'+lang);
        System.debug('city---'+city);
        System.debug('experience---'+experience);
        System.debug('Skills---'+skills);
        System.debug('PreSelectedCandidates---'+preSelectedCandidates);

        Location accloc = Location.newInstance(lat,lang);
        List<ContactWrapper> conWrapperList = new List<ContactWrapper>();

        String query = 'Select Id, Name, Profile_Picture_URL__c,email, Desired_Pay__c, Candidate_Status__c, MailingAddress,Phone,  GeoLocation__c ,Description FROM Contact Where Recordtype.Name = \''+RequiterDashboardConstants.CANDIDATE_RECORD_TYPE+'\'';

        if(!String.isBlank(city)){
            query 		+=		' And MailingCity LIKE \'%' + city + '%\'';
        }

        if(!String.isBlank(experience)){
            query 		+=		' And Years_of_Experience__c = \''+experience+'\'';
        }

        if(!skills.isEmpty()){
            Integer k=0;
            String skillInString = '';

            for(String s: skills){
                if(k>0)
                    skillInString += ' , ';
                skillInString += '\''+s+'\'';
                k++;
            }
            query += ' And Computer_Skills__c includes ('+skillInString+')';
        }

        String preSelectedCandidatesString = '';

        for(String s: preSelectedCandidates){
            preSelectedCandidatesString += '\''+s+'\',';
        }
        preSelectedCandidatesString = preSelectedCandidatesString.removeEnd(',');
        
        query+= ' And Candidate_Status__c=\'Active\' And ID NOT IN  ('+preSelectedCandidatesString+')';

        
        if(subQuery!=null){
            query+=' And '+subQuery;
        }

        System.debug('Query----'+query);
        List<Contact> filteredConList = Database.query(query);

        for(Contact con: filteredConList){
            Location conloc = con.GeoLocation__c;
            Double dist = Location.getDistance(accloc, conloc, 'km');
            Decimal toround = dist;
            Decimal rounded = toround.setScale(2);

            conWrapperList.add(new ContactWrapper(con.Id,con.Name,con.Profile_Picture_URL__c,40,con.Description,rounded,con.email,con.Desired_Pay__c, con.Candidate_Status__c,con.Phone));
        }

        return conWrapperList;
    }

    @AuraEnabled
    public static String createJOBApplication(Map<String,Object> conWrapperObj, String jobId, String jobTitle){
        
        System.debug('JOBID-----'+jobId);
        System.debug('candidatesList----------'+conWrapperObj);
        System.debug('JobTitle----------'+jobTitle);

        List<Job_Application__c> jobApplicationList =  new List<Job_Application__c>();

        if(!conWrapperObj.isEmpty()){

            for(String key : conWrapperObj.keySet()){

                Object obj = conWrapperObj.get(key);
                System.debug('MAPValues-----'+obj);

                Job_Application__c jobApp = new Job_Application__c(
                    Job_Requisition__c = jobId,
                    Contact__c = key,
                    Job_Title__c = jobTitle,
                    Application_Stage__c = 'Applied',
                    Type__c = 'Recruiter'
                );

                jobApplicationList.add(jobApp);
            }
            try{
                System.debug('Before Insert');
                insert jobApplicationList;

                // List<String> ids = new List<String>();
                // for(Job_Application__c job:jobApplicationList){
                //     ids.add(job.Id);
                // }
               // sendSMS(ids);
                return 'Success';
            }catch(DMLException e){
                System.debug('Error'+e);
                return 'Failure';
            }
        }
        return 'Failure';
    }

    // @future(callout=true)
    // private static void sendSMS(List<String> ids){
    //     SMSUtiliity.sendSMSNotification(ids,'a0f3N000002156zQAA');
    // }


    @AuraEnabled
    public static string submitToClient(List<String> applications,String status){
        try {
            List<Job_Application__c> jobApplications = [SELECT Id, Name FROM Job_Application__c Where Id IN:applications];
            List<Job_Application__c> updateJobApplications = new List<Job_Application__c>();

            for (Job_Application__c application : jobApplications) {
                application.Application_Stage__c = status;
                updateJobApplications.add(application);
            }

            update updateJobApplications;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string sendRequestInterviewFeedback(List<String> applications){
        try {
            List<Job_Application__c> jobApplications = [SELECT Id, Name, Request_Interview_Feedback__c FROM Job_Application__c Where Id IN:applications];
            List<Job_Application__c> updateJobApplications = new List<Job_Application__c>();

            for (Job_Application__c application : jobApplications) {
                application.Request_Interview_Feedback__c = true;
                updateJobApplications.add(application);
            }

            update updateJobApplications;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string updateInterviewStatus(String eventId,String insterviewStatus){
        try {
            if(!String.isBlank(eventId) && !String.isBlank(insterviewStatus)){
                Event event = new Event(Id=eventId,Interview_Status__c=insterviewStatus);
                update event;
                return 'Success';
            }else{
                return 'error, paremeters are null';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string createPlacement(List<String> applications){
        try {
            List<Job_Application__c> jobApplications = [SELECT Id,Application_Stage__c,Bg_Verification_Initiated__c, Name FROM Job_Application__c Where Id IN:applications];
            List<Job_Application__c> updateJobApplications = new List<Job_Application__c>();

            for (Job_Application__c application : jobApplications) {
                application.Application_Stage__c = 'Placed';
                application.Placement_Accepted_Date__c = System.today();
                application.Bg_Verification_Initiated__c = true;
                updateJobApplications.add(application);
            }

            System.debug('JOBTOUPDATE----'+updateJobApplications);

            update updateJobApplications;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<PickListWrapper> getPicklistValues(String objName, List<String>fields){
        List<PickListWrapper> picklistWrapper = new List<PickListWrapper>();
        for(String fieldAPI: fields){
            List<String> picklistVal = Utility.getPicklistValues(objName, fieldAPI);
            picklistWrapper.add(new PickListWrapper(fieldAPI,picklistVal));
        }
        return picklistWrapper;
    }

    public class PickListWrapper{
        @AuraEnabled public String fieldName;
        @AuraEnabled public List<String> pickValues;

        public PickListWrapper(String fieldName, List<String> pickValues){
            this.fieldName = fieldName;
            this.pickValues = pickValues;
        }
    }
    public class ContactWrapper{
        @AuraEnabled public String id;
        @AuraEnabled public String Name;
        @AuraEnabled public String profileId;
        @AuraEnabled public Decimal score;
        @AuraEnabled public String description;
        @AuraEnabled public Decimal distance;

        @AuraEnabled public String email;
        @AuraEnabled public Decimal desiredPay;
        @AuraEnabled public String candidateStatus;
        @AuraEnabled public String phone;

        public ContactWrapper(String id, String Name,String profileId, Decimal score,String description ,Decimal distance,String email, Decimal desiredPay, String candidateStatus, String phone){
            this.id = id;
            this.Name = Name;
            this.profileId = profileId;
            this.score = score;
            this.description = description;
            this.distance = distance;
            this.email = email;
            this.desiredPay = desiredPay;
            this.candidateStatus = candidateStatus;
            this.phone = phone;
        }

        public ContactWrapper(String id, String Name, String profileId ,Decimal score ,Decimal distance,String email, String candidateStatus, String phone){
            this.id = id;
            this.Name = Name;
            this.profileId = profileId;
            this.score = score;
            this.distance = distance;
            this.email = email;
            this.candidateStatus = candidateStatus;
            this.phone = phone;
        }
    }  
}