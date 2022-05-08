/**
 * Author : DeaGle
 */

public without sharing class UserDocumentTriggerHandler {
    
    static UserDocumentTriggerHandler handlerInstance;
    static Id CANDIDATE_RECTYPE_ID = Schema.SObjectType.User_Document__c.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
    private UserDocumentTriggerHandler() {}

    public static UserDocumentTriggerHandler getInstance() {
        if(handlerInstance == null)
            handlerInstance = new UserDocumentTriggerHandler();
        return handlerInstance;
    }


    public void onBeforeUpdate(List<User_Document__c> userDocumentList) {
        Set<Id> userDocIdSet = new Set<Id>();
        Set<Id> candidateIdSet = new Set<Id>();
        for(User_Document__c userDoc: userDocumentList) {
            if(userDoc.Required__c && userDoc.RecordTypeId == CANDIDATE_RECTYPE_ID && userDoc.Required__c && userDoc.Contact__c != null) {
                userDocIdSet.add(userDoc.Id);
                candidateIdSet.add(userDoc.Contact__c);
            }
        }

        if(!candidateIdSet.isEmpty()) {
            validateDocumentApproval(userDocIdSet, candidateIdSet);
        }
    }

    private void validateDocumentApproval(Set<Id> userDocIdSet, Set<Id> candidateIdSet) {
        List<User_Document__c> candidateDocsList = [SELECT Id, Contact__c FROM User_Document__c WHERE Id NOT IN :userDocIdSet AND Contact__c = :candidateIdSet AND RecordTypeId = :CANDIDATE_RECTYPE_ID AND Status__c IN ('Pending', 'Rejected', 'Uploaded') AND Required__c = true AND Contact__r.Candidate_Status__c = 'Document Upload' AND Contact__r.RecordType.Name = 'Candidate'];
        Map<Id, Contact> currentCandidatesMap = new Map<Id,Contact>([SELECT Id FROM Contact WHERE Id IN :candidateIdSet AND RecordType.Name = 'Candidate' AND Candidate_Status__c = 'Document Upload']);
        if(!currentCandidatesMap.isEmpty()) {
            for(User_Document__c uDoc: candidateDocsList) {
                currentCandidatesMap.remove(uDoc.Contact__c);
            }
            List<Contact> candidatesToActivate = new List<Contact>();
            if(!currentCandidatesMap.isEmpty()) {
                for(Id candidateId : currentCandidatesMap.keySet()) {
                    candidatesToActivate.add(new Contact(Id = candidateId, Candidate_Status__c = 'Active'));
                }
    
                if(!candidatesToActivate.isEmpty()) {
                    try{
                        update candidatesToActivate;
                    }catch(DmlException ex) {
                        HandleBusinessException.captureError('UserDocumentTriggerHandler', 'validateDocumentApproval', ex);
                    }
                }
            }
        }


    }
}