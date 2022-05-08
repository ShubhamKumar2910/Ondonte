/**
 * CreatedDate : Mar 3, 2022
 * Author : DeaGle
 */
public without sharing class ContactTriggerHandler {
    public static final String CANDIDATE_RECORD_TYPE = 'Candidate';

    static ContactTriggerHandler handlerInstance;
    private ContactTriggerHandler() {}

    public static ContactTriggerHandler getInstance() {
        if(handlerInstance == null) 
            handlerInstance = new ContactTriggerHandler();
        return handlerInstance;
    }


    public void onBeforeUpdate(Map<Id,Contact> oldContactMap, List<Contact> newContactList) {
        List<Id> shiftAlignmentCandidateList = new List<Id>();
        Id candidateRectypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CANDIDATE_RECORD_TYPE).getRecordTypeId();
        for(Contact candidate : newContactList) {
            if(candidate.Candidate_Status__c == 'Active' && candidate.RecordTypeId == candidateRectypeID && (candidate.Preferred_Working_Days__c != null && oldContactMap.get(candidate.Id).Preferred_Working_Days__c != candidate.Preferred_Working_Days__c) || (candidate.Preferred_Start_Time__c != null && oldContactMap.get(candidate.Id).Preferred_Start_Time__c != candidate.Preferred_Start_Time__c) || (candidate.Preferred_End_Time__c != null && oldContactMap.get(candidate.Id).Preferred_End_Time__c != candidate.Preferred_End_Time__c)) {
                shiftAlignmentCandidateList.add(candidate.Id);
            }
        }
        if(!shiftAlignmentCandidateList.isEmpty()) {
            handleShiftAlignment(shiftAlignmentCandidateList);
        }

    }

    /**
     * If any shift related candidate amendment, should go here.
     */
    private void handleShiftAlignment(List<Id> shiftAlignmentCandidateList) {
        ShiftUtility.handleShiftAlignmentFuture(shiftAlignmentCandidateList);
    }
}