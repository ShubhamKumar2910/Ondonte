public without sharing class RecruiterDashboardTemporaryJobController {
    public RecruiterDashboardTemporaryJobController() {}

    @AuraEnabled(cacheable=false) 

    public static String getShiftsByJobReqId(String jobId){
        System.debug('JOBREQID-----'+jobId);
        
        Integer tillDate = 30;
        if(Ondonte_Configuration__c.getOrgDefaults() !=null && Ondonte_Configuration__c.getOrgDefaults().Tot_Num_Of_Shifts_On_Req_Dash__c != null){
            tillDate = Integer.valueOf(Ondonte_Configuration__c.getOrgDefaults().Tot_Num_Of_Shifts_On_Req_Dash__c);
        }
        
        DateTime currentStartDate = DateTime.Now();
        DateTime currenEndDate = DateTime.Now().AddDays(tillDate);

        System.debug('CurrentStartDate---'+currentStartDate);
        System.debug('CurrentEndDate---'+currenEndDate);

        Map<String,List<Shift__c>> shiftMap = new Map<String,List<Shift__c>>();
        List<Shift__c> shiftList = [SELECT Id,Name,Status__c,Staff_Type__c,(SELECT Id, Name,Start_DateTime__c, Status__c,End_DateTime__c,Type__c,Submitted__c, Contact__r.FirstName, Contact__r.Email,Contact__r.Phone, Contact__r.LastName, Contact__r.Profile_Picture_URL__c FROM Shifts__r),Job_Requisition__r.GeoLocation__c, Start_DateTime__c, No_Of_Required_Candidates__c ,End_DateTime__c  from Shift__c where  Recordtype.Name =:RequiterDashboardConstants.CLIENT_RECORD_TYPE AND Job_Requisition__c =:jobId AND Start_DateTime__c >= :currentStartDate AND End_DateTime__c <= :currenEndDate];

        for(Shift__c shift : shiftList){

            string keyName =    shift.Start_DateTime__c.day()+'/'+ shift.Start_DateTime__c.month() + '/' +shift.Start_DateTime__c.year() ;
            system.debug('keyName--'+keyName);
            List<Shift__c> tempShiftList = new List<Shift__c>();

            if(shiftMap.containsKey(keyName)){tempShiftList = shiftMap.get(keyName);}
            tempShiftList.add(shift);
            shiftMap.put(keyName, tempShiftList);            
        }

        System.debug('ShiftMap-----'+shiftMap);

        return JSON.serialize(shiftMap);
    }

    @AuraEnabled
    public static Map<String,List<Object>> getRecommendedCandidate(Long startDateString, Long endDateString,List<String> prefCandidates){
        try {
            System.debug('prefCandidates---'+prefCandidates);
            
            Map<String,List<Object>> respMap  = new Map<String,List<Object>>();

            DateTime startDate = DateTime.newInstance(startDateString);
            DateTime endDate = DateTime.newInstance(endDateString);

            Date sDate = startDate.date();  
            Date eDate = endDate.date().addDays(1);

            List<Shift__c> prefCandidateShifts =  [SELECT Id,Name,Type__c, Start_DateTime__c, End_DateTime__c,Status__c, Contact__r.Name,Contact__r.FirstName,Contact__r.Email,Contact__r.Phone, Contact__r.LastName, Contact__r.Profile_Picture_URL__c FROM Shift__c Where Status__c='Available' AND Recordtype.Name =:RequiterDashboardConstants.CANDIDATE_RECORD_TYPE AND Start_Date__c = :sDate And Contact__c IN : prefCandidates];
            List<Shift__c> recommendedCandidates = [SELECT Id,Name,Type__c, Start_DateTime__c, End_DateTime__c,Status__c, Contact__r.Name,Contact__r.FirstName,Contact__r.Email,Contact__r.Phone, Contact__r.LastName, Contact__r.Profile_Picture_URL__c FROM Shift__c where  Status__c='Available' AND Contact__c!=null AND Recordtype.Name =:RequiterDashboardConstants.CANDIDATE_RECORD_TYPE AND Start_Date__c = :sDate /*AND End_DateTime__c <= :eDate*/];

            List<RecommendedWrapper> recList = new List<RecommendedWrapper>();

            for(Shift__c shift: recommendedCandidates){

                Double matchPer =  MatchingAlgorithm.getMatchPercentage(shift.Start_DateTime__c,shift.End_DateTime__c,startDate,endDate);
                if(matchPer>40){
                    recList.add(new RecommendedWrapper(shift.Id,shift.Name,shift.Contact__r.Id,shift.Contact__r.Name,
                    shift.Contact__r.Email, shift.Contact__r.Phone, shift.Start_DateTime__c,shift.End_DateTime__c, shift.Status__c,
                    shift.Type__c,shift.Contact__r.Profile_Picture_URL__c,matchPer.intValue()));
                }
            }

            respMap.put('pref_can',prefCandidateShifts);
            respMap.put('rec_can',recList);

            return respMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string assignedCandidates(String clientShifId, List<String> candidateShiftListId){
        try {
            
            List<Shift__c> candidateShiftList = [Select Id, Name from Shift__c where Id IN : candidateShiftListId];
            List<Shift__c> updatedcandidateShiftList = new List<Shift__c>();

            for(Shift__c shift: candidateShiftList){
                shift.Status__c = 'Assigned';
                shift.Type__c = 'Recruiter';
                shift.Allocated_To__c = clientShifId;
                updatedcandidateShiftList.add(shift);
            }

            System.debug('STATUS-----'+updatedcandidateShiftList);

            update updatedcandidateShiftList;
            return 'Success';
        } catch (Exception e) {
            System.debug('Failed to update'+e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string allocateCandidates(List<String> candidateList,String status){
        System.debug('ListSize----'+candidateList);
        
        try {
            List<Shift__c> shitftsToUpdate = new List<Shift__c>();
            List<Shift__c> shiftList = [SELECT Id, Submitted__c ,Placement_Accepted_Date__c,Name,Status__c FROM Shift__c where Id In:candidateList];
            
            for(Shift__c shift : shiftList){
                if(status.equals('Submit') && shift.Submitted__c!=true){
                    shift.Submitted__c = true;
                    shitftsToUpdate.add(shift);
                }else if(status.equals('Accepted By Candidate')){
                    shift.Status__c = status;
                    shitftsToUpdate.add(shift);
                }else if(status.equals('Allocated')){
                    shift.Placement_Accepted_Date__c = System.today();
                    shift.Status__c = status;
                    shitftsToUpdate.add(shift);
                }
            }
            System.debug('SHIFTLIST----'+shitftsToUpdate);

            update shitftsToUpdate;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string filterSearchHandler(String startDateString, String endDateString, String city, String experience,List<String> skills){
        try {
            System.debug('StartedDate '+startDateString);
            System.debug('endDateString '+endDateString);
            List<ContactWrapper> conWrapperList = new List<ContactWrapper>();
            
            DateTime startDate = DateTime.ValueofGmt(startDateString.replace('T', ' '));
            DateTime endDate = DateTime.ValueofGmt(endDateString.replace('T', ' '));

            Date sDate = startDate.date();

            System.debug('EnDate'+endDate);

            String query = 'SELECT Id,Name, Start_DateTime__c, End_DateTime__c,Status__c,Type__c,Contact__r.Name,Contact__r.Id,Contact__r.Email,Contact__r.Phone,Contact__r.FirstName, Contact__r.Description, Contact__r.LastName, Contact__r.GeoLocation__c ,Contact__r.Profile_Picture_URL__c,Contact__r.Candidate_Status__c FROM Shift__c where Contact__r.Candidate_Status__c=\'Active\' AND Status__c=\'Available\' AND Recordtype.Name=\''+RequiterDashboardConstants.CANDIDATE_RECORD_TYPE+'\' AND Start_Date__c=:sDate';
            System.debug('SimpleQuery---'+query);
            if(!String.isBlank(city)){
                query 		+=		' And Contact__r.MailingCity LIKE \'%' + city + '%\'';
            }

            if(!String.isBlank(experience)){
                query 		+=		' And Contact__r.Years_of_Experience__c = \''+experience+'\'';
            }

            System.debug('EXP---'+query);

            if(!skills.isEmpty()){
                Integer k=0;
                String skillInString = '';

                for(String s: skills){
                    if(k>0)
                        skillInString += ' , ';
                    skillInString += '\''+s+'\'';
                    k++;
                }
                query += ' And Contact__r.Computer_Skills__c includes ('+skillInString+')';
            }

            System.debug('Query----'+query);

            List<Shift__c> filteredShifts = Database.query(query);
            System.debug('FilteredShift----'+filteredShifts);
            for(Shift__c shift : filteredShifts){
                Double score =  MatchingAlgorithm.getMatchPercentage(shift.Start_DateTime__c,shift.End_DateTime__c,startDate,endDate);
                conWrapperList.add(new ContactWrapper(shift.Id,shift.Name,shift.Contact__r.Profile_Picture_URL__c,shift.Start_DateTime__c,shift.End_DateTime__c,shift.Contact__r.Id,shift.Contact__r.Name,score,shift.Contact__r.Description,0,shift.Contact__r.Email, shift.Contact__r.Candidate_Status__c,shift.Type__c,shift.Contact__r.Phone));
            }

            return JSON.serialize(conWrapperList);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Map<string,object> getNearByCandidateForTempShift(String startDateString, String endDateString ,String shiftName, String sortByType, Double lat, Double lang, Integer distance){
        System.debug('StartedDate '+startDateString);
        System.debug('endDateString '+endDateString);
        System.debug('shiftName '+shiftName);
        System.debug('sortByType '+sortByType);
        System.debug('lat '+lat);
        System.debug('lang '+lang);
        System.debug('distance '+distance);

        try{
            Map<string,object> mainMap = new Map<string,object>();
            Map<string,object> markerMap = new Map<string,object>();
            Map<string,object> addressMap = new Map<string,object>();
            List<Map<string,object>> markerList = new List<Map<string,object>>();

            Location jobRequestLocation = Location.newInstance(lat,lang);
            List<ContactWrapper> conWrapperList = new List<ContactWrapper>();
            List<Shift__c> shiftList;

            DateTime startDate = DateTime.ValueofGmt(startDateString.replace('T', ' '));
            DateTime endDate = DateTime.ValueofGmt(endDateString.replace('T', ' '));

            if(sortByType=='distance'){
            
                Date sDate = startDate.date();

                System.debug('StartDate'+startDate);
                System.debug('EndDate'+endDate);

                shiftList = [SELECT Id,Name, Start_DateTime__c,Type__c, End_DateTime__c,Status__c,Contact__r.Name,Contact__r.Id,Contact__r.Email,Contact__r.Phone,Contact__r.FirstName, Contact__r.Description, Contact__r.LastName, Contact__r.GeoLocation__c ,Contact__r.Profile_Picture_URL__c,Contact__r.Candidate_Status__c FROM Shift__c where Contact__r.Candidate_Status__c='Active' AND Status__c='Available' AND Recordtype.Name =:RequiterDashboardConstants.CANDIDATE_RECORD_TYPE AND Start_Date__c = :sDate AND DISTANCE(Contact__r.GeoLocation__c, GEOLOCATION(:lat,:lang),'km') < :distance];   
                // conList = [Select Id, Name,Email, Desired_Pay__c,Candidate_Status__c, MailingAddress ,Phone,  GeoLocation__c ,Description FROM Contact where DISTANCE(GeoLocation__c, GEOLOCATION(:lat,:lang),'km') < :distance AND  Recordtype.Name =: RequiterDashboardConstants.CANDIDATE_RECORD_TYPE And Candidate_Status__c='Active' And ID NOT IN :preSelectedCandidates LIMIT 20];
            }else{
                //TODO:-
            }

            System.debug('JSJSJSJJSJS '+shiftList);

            markerMap.put('title', shiftName);
            markerMap.put('icon','standard:account');
            markerMap.put('type', 'Circle');
            markerMap.put('radius', distance*1000);
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

            if(!shiftList.isEmpty()){
                for(Shift__c shift: shiftList){
                    Location conloc = shift.Contact__r.GeoLocation__c;

                    Double dist = Location.getDistance(jobRequestLocation, conloc, 'km');
                    Decimal toround = dist;
                    Decimal rounded = toround.setScale(2);
                    Double score =  MatchingAlgorithm.getMatchPercentage(shift.Start_DateTime__c,shift.End_DateTime__c,startDate,endDate);
                    conWrapperList.add(new ContactWrapper(shift.Id,shift.Name,shift.Contact__r.Profile_Picture_URL__c,shift.Start_DateTime__c,shift.End_DateTime__c,shift.Contact__r.Id,shift.Contact__r.Name,score,shift.Contact__r.Description,rounded,shift.Contact__r.Email, shift.Contact__r.Candidate_Status__c,shift.Type__c,shift.Contact__r.Phone));

                    if(dist < distance){
                        markerMap = new map<string,object>();
                        markerMap.put('title', shift.Contact__r.Name);
                        markerMap.put('description',shift.Contact__r.Description != null ? shift.Contact__r.Description : '');
                        markerMap.put('icon','standard:person_name');
                        markerMap.put('value',shift.Contact__r.Id);

                        addressMap = new map<string,object>();
                        addressMap.put('Latitude',shift.Contact__r.GeoLocation__c.getLatitude());
                        addressMap.put('Longitude',shift.Contact__r.GeoLocation__c.getLongitude());

                        markerMap.put('location',addressMap);
                        markerList.add(markerMap);  
                    }
                }
                mainMap.put('markerList',markerList);
                mainMap.put('shiftList',conWrapperList);
                system.debug('+++++++'+JSON.serialize(conWrapperList));  
                return mainMap;  
            }
            return mainMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class RecommendedWrapper{
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String shiftName;
        @AuraEnabled public String conId;
        @AuraEnabled public String conName;
        @AuraEnabled public String conEmail;
        @AuraEnabled public String conPhone;
        @AuraEnabled public DateTime sDate;
        @AuraEnabled public DateTime eDate;
        @AuraEnabled public String status;
        @AuraEnabled public String type;
        @AuraEnabled public String profile;
        @AuraEnabled public Integer matchPercentage;

        public RecommendedWrapper(String id, String name, String conId, String conName, String conEmail, String conPhone, DateTime sDate, DateTime eDate, String status,String type, String profile, Integer matchPercentage){
            this.id = id;
            this.name = name;
            this.conId = conId;
            this.conName = conName;
            this.conEmail = conEmail;
            this.conPhone = conPhone;
            this.sDate = sDate;
            this.eDate = eDate;
            this.status = status;
            this.type = type;
            this.profile = profile;
            this.matchPercentage = matchPercentage;
        }
    }

    public class ContactWrapper{
        
        @AuraEnabled public String shiftId;
        @AuraEnabled public String shiftName;
        @AuraEnabled public String profileId;
        @AuraEnabled public DateTime startDate;
        @AuraEnabled public DateTime endDate;
        @AuraEnabled public String id;
        @AuraEnabled public String Name;
        @AuraEnabled public Decimal score;
        @AuraEnabled public String description;
        @AuraEnabled public Decimal distance;
        @AuraEnabled public String email;
        @AuraEnabled public String candidateStatus;
        @AuraEnabled public String type;
        @AuraEnabled public String phone;

        public ContactWrapper(String shiftId,String shiftName,String profileId, DateTime startDate,DateTime endDate,String id, String Name, Decimal score,String description ,Decimal distance,String email, String candidateStatus, String type,String phone){
            this.shiftId = shiftId;
            this.shiftName  = shiftName;
            this.profileId = profileId;
            this.startDate = startDate;
            this.endDate = endDate;
            this.id = id;
            this.Name = Name;
            this.score = score;
            this.description = description;
            this.distance = distance;
            this.email = email;
            this.candidateStatus = candidateStatus;
            this.type = type;
            this.phone = phone;
        }

        public ContactWrapper(String shiftId,String shiftName,String profileId, DateTime startDate,DateTime endDate, String id, String Name, Decimal score ,Decimal distance,String email, String candidateStatus, String type,String phone){
            this.shiftId = shiftId;
            this.shiftName = shiftName;
            this.profileId = profileId;
            this.startDate = startDate;
            this.endDate = endDate;
            this.id = id;
            this.Name = Name;
            this.score = score.setscale(0,system.RoundingMode.DOWN);
            this.distance = distance;
            this.email = email;
            this.candidateStatus = candidateStatus;
            this.type = type;
            this.phone = phone;
        }
    }  
}