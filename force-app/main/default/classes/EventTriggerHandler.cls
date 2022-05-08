/**
 * Author: Prithvi
 */
public without sharing class EventTriggerHandler {
    static final String ONDONTE_INTERVIEW = 'Ondonte Interview';
    static final String CLIENT_CANDIDATE_INTERVIEW = 'Client Interview';
    static final String INTERVIEW_STATUS_SCHEDULED = 'Scheduled';
    static final String INTERVIEW_STATUS_REJECTED = 'Rejected';
    static final String INTERVIEW_STATUS_SELECTED = 'Selected';
    static final String CANDIDATE_STATUS_ACTIVE = 'Active';
    static final String CANDIDATE_STATUS_DOC_UPLOAD = 'Document Upload';
    static final String CANDIDATE_STATUS_REJECTED = 'Rejected';
    static final String JOB_APP_STATUS_SELECTED = 'Selected by Client';
    static final String JOB_APP_STATUS_REJECTED = 'Rejected by Client';


    static EventTriggerHandler instance;
    private EventTriggerHandler() {}
    
    public static EventTriggerHandler getInstance() {
        if(instance == null)
            instance = new EventTriggerHandler();
        return instance;
    }
    
    public void handleAfterInsert(List<Event> eventList) {
        system.debug('After Insert of Event');
        List<Event> zoomEventsListToUpdate = new List<Event>();
        List<Event> zoomEventsList = new List<Event>();
        Set<Id> candidateEventIdSet = new Set<Id>();
        Set<Id> permanentAppEventIdSet = new Set<Id>();
        for(Event eObj: eventList) {
            system.debug('eObj::'+eObj);
            if(eObj.Type == ONDONTE_INTERVIEW || eObj.Type == CLIENT_CANDIDATE_INTERVIEW) {
                zoomEventsList.add(eObj);
                if(eObj.WhoId != null) {
                    candidateEventIdSet.add(eObj.WhoId);
                }else if(eObj.WhatId != null) {
                    permanentAppEventIdSet.add(eObj.whatId);
                }
            }
        }
		system.debug('zoomEventsList>>'+zoomEventsList);
        system.debug('candidateEventIdSet>>'+candidateEventIdSet);
        Set<Id> zoomRequiredEventHoldersSet = new Set<Id>();
        if(!candidateEventIdSet.isEmpty()) {
            for(Contact candidate: [SELECT Id FROM Contact WHERE Id IN: candidateEventIdSet AND Interview_Type__c = 'Online']) {
                zoomRequiredEventHoldersSet.add(candidate.Id);
            }
        }
        system.debug('zoomRequiredEventHoldersSet>>'+zoomRequiredEventHoldersSet);
        if(!permanentAppEventIdSet.isEmpty()) {
            for(Job_Application__c jApp: [SELECT Id FROM Job_Application__c WHERE Id IN: permanentAppEventIdSet AND Interview_Type__c = 'Online']) {
                zoomRequiredEventHoldersSet.add(jApp.Id);
            }
        }

        if(!zoomRequiredEventHoldersSet.isEmpty()) {
            for(Event eventRec: zoomEventsList) {
                if(eventRec.WhoId != null && zoomRequiredEventHoldersSet.contains(eventRec.WhoId)) {
                    zoomEventsListToUpdate.add(eventRec);
                }else if(eventRec.WhatId != null && zoomRequiredEventHoldersSet.contains(eventRec.WhatId)) {
                    zoomEventsListToUpdate.add(eventRec);
                }
            }
            system.debug('zoomEventsListToUpdate --- '+zoomEventsListToUpdate);
            if(!zoomEventsListToUpdate.isEmpty()) {
                //TODO: call future method here.
                for(Event eventRec : zoomEventsListToUpdate){
                    system.debug('eventRec --- '+eventRec);
                    if(eventRec.WhoId != null){
                        system.debug('contact Tagged');
                        EventSchedularHelper.CreateZoomMeetingWithOutlook(eventRec.StartDateTime, eventRec.EndDateTime, eventRec.Description, eventRec.WhoId, eventRec.Id);
                    }else if(eventRec.WhatId != null){
                        system.debug('Account Tagged');
                        EventSchedularHelper.CreateZoomMeetingWithOutlook(eventRec.StartDateTime, eventRec.EndDateTime, eventRec.Description, eventRec.WhatId, eventRec.Id);
                    }
                    
                }
            }
        }

        
    }
    
    public void handleBeforeUpdate(Map<Id,Event> oldEventMap, List<Event> newEventList) {
        System.debug('--- event before update');
        handleInterviewedEvents(oldEventMap, newEventList);
    }
    
    private void handleInterviewedEvents(Map<Id,Event> oldEventMap, List<Event> newEventList) {
        List<Contact> contactUpdateList = new List<Contact>();
        List<Job_Application__c> jobAppList = new List<Job_Application__c>();
        
        for(Event eObj: newEventList) {
            if(eObj.WhoId !=null && eObj.whoId.getSObjectType() == Contact.sObjectType && eObj.Interview_Status__c != null && oldEventMap.get(eObj.Id).Interview_Status__c == INTERVIEW_STATUS_SCHEDULED && oldEventMap.get(eObj.Id).Interview_Status__c != eObj.Interview_Status__c) {
                if(eObj.Interview_Status__c == INTERVIEW_STATUS_SELECTED)
                    contactUpdateList.add(new Contact(Id = eObj.WhoId, Candidate_Status__c = CANDIDATE_STATUS_DOC_UPLOAD));
                else if(eObj.Interview_Status__c == INTERVIEW_STATUS_REJECTED)
                    contactUpdateList.add(new Contact(Id = eObj.WhoId, Candidate_Status__c = CANDIDATE_STATUS_REJECTED));
            }else if(eObj.WhatId != null && eObj.WhatId.getSObjectType() == Job_Application__c.sObjectType && eObj.Interview_Status__c != null && oldEventMap.get(eObj.Id).Interview_Status__c == INTERVIEW_STATUS_SCHEDULED && oldEventMap.get(eObj.Id).Interview_Status__c != eObj.Interview_Status__c) {
                if(eObj.Interview_Status__c == INTERVIEW_STATUS_SELECTED)
                    jobAppList.add(new Job_Application__c(Id = eObj.WhatId, Application_Stage__c = JOB_APP_STATUS_SELECTED));
                else if(eObj.Interview_Status__c == INTERVIEW_STATUS_REJECTED)
                    jobAppList.add(new Job_Application__c(Id = eObj.WhatId, Application_Stage__c = JOB_APP_STATUS_REJECTED));
            }
        }
        List<SObject> objectsToUpdate = new List<SObject>();
        if(!contactUpdateList.isEmpty())
            objectsToUpdate.addAll(contactUpdateList);
        
        if(!jobAppList.isEmpty())
            objectsToUpdate.addAll(jobAppList);

        System.debug('--- Candidate/Job Application interview result '+objectsToUpdate);
        if(!objectsToUpdate.isEmpty()) {
            try {
                update objectsToUpdate;
            }catch(DMLException e) {
                HandleBusinessException.captureError('EventTriggerHandler', 'handleInterviewedEvents', e);
            }

        }
    }

    
    
    
    
    
}