public with sharing class CandidateDetailsController {
    
    @AuraEnabled(cacheable=true)
    public static void saveResumeResponse(list<education__c> eduDetails, list<Work_Experience__c> wrkExpDetails) {
        CandidateDashboard_Helper.saveResumeResponse(eduDetails, wrkExpDetails);
    }

}