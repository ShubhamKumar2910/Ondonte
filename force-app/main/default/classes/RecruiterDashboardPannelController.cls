public without sharing class RecruiterDashboardPannelController {
    
    static final Set<String> OOB_QUERY_OPTIONS = new Set<String>{'THIS_MONTH', 'TODAY', 'TOMORROW', 'NEXT_WEEK', 'NEXT_MONTH', 'NEXT_90_DAYS', 'THIS_WEEK'};
    static final String INPROGRESS_JOBS = 'in_progress';

    static final String DONT_HIRE_RT_NAME = 'Do_Not_Hire';
    static final String PREFFERED_CANDIDATES_RT_NAME = 'Preferred';    
    static final String JAPP_INTERVIEW_SCHEDULED = 'Interview Scheduled';
    static final String EVT_INTERVIEW_TYPE_CLIENT = 'Client Interview';
    static final String EVT_INTERVIEW_STATUS_SCHEDULED = 'Scheduled';


    @AuraEnabled(cacheable = true)
    public static RequisitionResponseWrapper getJobRequisitions(String accId, String filter, Boolean isTemp, Boolean isPermnt){
        filter = String.escapeSingleQuotes(filter);
        accId = String.escapeSingleQuotes(accId);
        System.debug('--- filter '+filter);
        System.debug('--- accid '+accId);

        Set<String> setOfAccId = new Set<String>(); 
        Map<String,List<Contact>> clientPrefCandidatesMap = new Map<String,List<Contact>>();
        Map<String,Set<Id>> clientDonothireCandidateIdMap = new Map<String,Set<Id>>();
        List<JobRequestionClassWrapper> jobRequestionClassWrapperList = new List<JobRequestionClassWrapper>();

        Set<Id> tempRequisitionIdSet = new Set<Id>();
        RequisitionResponseWrapper responseWrapper = new RequisitionResponseWrapper();
        try {
            String requisitionQuery = 'SELECT Id, RD_Last_Refreshed_On__c, No_Of_Positions__c, (SELECT Id, Name, Type__c, Contact__r.Name, Contact__r.Email, Contact__r.Phone, CreatedDate, Application_Stage__c, Request_Interview_Feedback__c, Job_Requisition__c FROM Job_Applications__r), Name, Client__r.Name,Client__r.BillingLatitude,Client__r.BillingLongitude, GeoLocation__Latitude__s,  Placement_Type__c, Staff_Type__c, Status__c, Expected_Start_Date__c, Expected_End_Date__c, Description__c, Desired_Skills__c FROM Job_Requisition__c WHERE (Status__c = \'Open\' OR Requisition_Closed_Date__c = TODAY)';
            
            if(isPermnt) {
                responseWrapper.responseType = 'PERMANENT';
                if(OOB_QUERY_OPTIONS.contains(filter)) {
                    requisitionQuery += ' AND Expected_Start_Date__c = '+ filter;
                }

                requisitionQuery += ' AND Placement_Type__c = \'Permanent\'';
                
                if(!String.isBlank(accId)) {
                    requisitionQuery += ' AND Client__c = :accId';
                }

                requisitionQuery += ' ORDER BY Expected_Start_Date__c LIMIT 500';

                List<Job_Requisition__c> JOBReqList = Database.query(requisitionQuery);

                Map<Id, Job_Application__c> InterviewJobAppMap = new Map<Id, Job_Application__c>();
                for(Job_Requisition__c job: JOBReqList) {
                    setOfAccId.add(job.Client__c); 
                    for(Job_Application__c jApp : job.Job_Applications__r) {
                        if(jApp.Application_Stage__c == JAPP_INTERVIEW_SCHEDULED) {                        
                            InterviewJobAppMap.put(jApp.Id, jApp);
                        }
                            
                    }
                }

                Map<Id,Map<Id,Event>> jobReqToAppInterviewMap = new Map<Id,Map<Id,Event>>();
                if(!InterviewJobAppMap.isEmpty()) {
                    List<Event> interviewEvents = [SELECT Id, WhatId FROM Event WHERE WhatId IN :InterviewJobAppMap.keySet() AND Type = :EVT_INTERVIEW_TYPE_CLIENT AND Interview_Status__c = :EVT_INTERVIEW_STATUS_SCHEDULED];
                    for(Event evt: interviewEvents) {
                        if(InterviewJobAppMap.containsKey(evt.WhatId)) {
                            if(jobReqToAppInterviewMap.containsKey(InterviewJobAppMap.get(evt.WhatId).Job_Requisition__c)) {
                                jobReqToAppInterviewMap.get(InterviewJobAppMap.get(evt.WhatId).Job_Requisition__c).put(evt.WhatId, evt);
                            }else {
                                jobReqToAppInterviewMap.put(InterviewJobAppMap.get(evt.WhatId).Job_Requisition__c, new Map<Id, Event> { evt.WhatId => evt});
                            }
                        }
                    }
                }
                //TODO: Might need below as well.
                if(!setOfAccId.isEmpty()) {
                    List<Preferred_Candidates__c> prefCandidates = [SELECT Id, Name, Candidate__r.Id, Candidate__r.Name, Candidate__r.Email, Candidate__r.Phone, Recordtype.Name , Client_Notes__c, Client__c FROM Preferred_Candidates__c WHERE Client__c IN : setOfAccId AND Candidate__r.Candidate_Status__c = 'Active' ];
                    
                    for(Preferred_Candidates__c prefCandidate: prefCandidates){
                        if(prefCandidate.RecordType.Name == PREFFERED_CANDIDATES_RT_NAME) {
                            if(clientPrefCandidatesMap.containsKey(prefCandidate.Client__c)) {
                                clientPrefCandidatesMap.get(prefCandidate.Client__c).add(prefCandidate.Candidate__r);
                            }else {
                                clientPrefCandidatesMap.put(prefCandidate.Client__c, new List<Contact> { prefCandidate.Candidate__r });
                            }
                        }else {
                            if(clientDonothireCandidateIdMap.containsKey(prefCandidate.Client__c)) {
                                clientDonothireCandidateIdMap.get(prefCandidate.Client__c).add(prefCandidate.Candidate__c);
                            }else {
                                clientDonothireCandidateIdMap.put(prefCandidate.Client__c, new Set<Id> { prefCandidate.Candidate__c });
                            }
                        }
                    }
                }
                for(Job_Requisition__c job: JOBReqList) {
                    List<Id> dnhCandidateIdList;
                    if(clientDonothireCandidateIdMap.containsKey(job.Client__c)) {
                        dnhCandidateIdList = new List<Id>(clientDonothireCandidateIdMap.get(job.Client__c));
                    }else {
                        dnhCandidateIdList = new List<Id>();
                    }
                    jobRequestionClassWrapperList.add(new JobRequestionClassWrapper(job, clientPrefCandidatesMap.get(job.Client__c), dnhCandidateIdList, jobReqToAppInterviewMap.get(job.Id)));
                }

                System.debug('--- Requisition Query '+requisitionQuery);
                System.debug('prefCandidates----'+jobRequestionClassWrapperList);
                responseWrapper.responseObject = jobRequestionClassWrapperList;
                // return Database.query(requisitionQuery);
                return responseWrapper;

            }else if(isTemp) {
                responseWrapper.responseType = 'TEMPORARY';
                Date tempStartDate = System.today()-30;
                Date tempEndDate = System.today();
                String groupBy = 'Client';
                //Temp query:
                String tempShiftsQuery = 'SELECT Id, Name, Job_Requisition__c, Job_Requisition__r.Client__c, Job_Requisition__r.Client__r.Name, Start_DateTime__c, End_DateTime__c, Start_Date__c, End_Date__c, Status__c FROM Shift__c WHERE RecordType.DeveloperName = \'Client\' AND Job_Requisition__r.Placement_Type__c = \'Temporary\' AND Start_Date__c >= :tempStartDate AND End_Date__c <= :tempEndDate AND Job_Requisition__r.Client__c != null ORDER BY Start_DateTime__c';

                List<Shift__c> uxShiftsList = Database.query(tempShiftsQuery);
                
                if(groupBy == 'Client') {
                    Map<String, TempRequisitionWrapper> clientShiftsMap = new Map<String, TempRequisitionWrapper>();
                    for(Shift__c reqShift : uxShiftsList) {
                        if(clientShiftsMap.containsKey(reqShift.Job_Requisition__r.Client__c)) {
                            clientShiftsMap.get(reqShift.Job_Requisition__r.Client__c).requisitionShiftList.add(reqShift);
                        }
                        else {
                            clientShiftsMap.put(reqShift.Job_Requisition__r.Client__c, new TempRequisitionWrapper(reqShift.Job_Requisition__r.Client__c, reqShift.Job_Requisition__r.Client__r.Name, reqShift));
                        }
                    }

                    responseWrapper.responseObject = clientShiftsMap.values();
                    return responseWrapper;
                }else {
                    Map<String, List<Shift__c>> shiftsByDateMap = new Map<String, List<Shift__c>>();
                    for(Shift__c reqShift : uxShiftsList) {
                        
                    }
                }
                /* requisitionQuery += ' AND Placement_Type__c = \'Temporary\'';
                String tempReqQuery = 'SELECT Id, Job_Requisition__c FROM Shift__c WHERE RecordType.DeveloperName = \'Client\' AND Job_Requisition__c != null';
                
                if(OOB_QUERY_OPTIONS.contains(filter)) {
                    tempReqQuery += ' AND (Start_DateTime__c = '+ filter + ' OR Shift_Closed_Date__c = TODAY)';
                }

                tempReqQuery += ' AND Job_Requisition__r.Placement_Type__c = \'Temporary\'';
    
                if(!String.isBlank(accId)) {
                    tempReqQuery += ' AND Job_Requisition__r.Client__c = :accId';
                }
                System.debug('--- TempQuery '+tempReqQuery);
                List<Shift__c> shiftList = Database.query(tempReqQuery);
                if(!shiftList.isEmpty()) {
                    for(Shift__c tempShift : shiftList) {
                        tempRequisitionIdSet.add(tempShift.Job_Requisition__c);
                    }
    
                }

                if(!tempRequisitionIdSet.isEmpty()) {
                    requisitionQuery += ' AND Id IN : tempRequisitionIdSet ORDER BY Latest_Temp_Shift_Created_On__c NULLS LAST LIMIT 500';
                }else {
                    System.debug('--- no Temp placements are available for selected filter');
                    return jobRequestionClassWrapperList;
                } */
            }
            return null;
            
        } catch (Exception e) {
            System.debug('--- ex message'+e.getMessage());
            return null;
        }
    }

    public class JobRequestionClassWrapper {
        @AuraEnabled public Job_Requisition__c jobReq;
        @AuraEnabled public List<Contact> prefList;
        @AuraEnabled public List<Id> donothireCandidateIds;
        @AuraEnabled public List<String> staffTypeList = new List<String>();
        @AuraEnabled public Map<Id,Event> appInterviewEvent = new Map<Id,Event>();
        public JobRequestionClassWrapper(Job_Requisition__c jobReq, List<Contact> prefList, List<Id> donothireCandidateIds, Map<Id,Event> appInterviewEvent){
            this.jobReq = jobReq;
            this.prefList = prefList != null ? prefList : new List<Contact>();
            this.donothireCandidateIds = donothireCandidateIds != null ? donothireCandidateIds : new List<Id>();
            this.appInterviewEvent = appInterviewEvent;
            if(!String.isBlank(this.jobReq.Staff_Type__c))
                staffTypeList = this.jobReq.Staff_Type__c.split(';');
        }
    }

    public class TempRequisitionWrapper {
        @AuraEnabled public String accordianHeader;
        @AuraEnabled public String uniqueId;
        @AuraEnabled public List<Shift__c> requisitionShiftList = new List<Shift__c>();

        public TempRequisitionWrapper(String uniqueId, String accordianHeader, Shift__c initialShift) {
            this.accordianHeader = accordianHeader;
            this.uniqueId = uniqueId;
            this.requisitionShiftList.add(initialShift);
        }
    }

    public class RequisitionResponseWrapper {
        @AuraEnabled public String responseType;
        @AuraEnabled public Object responseObject;
    }

}