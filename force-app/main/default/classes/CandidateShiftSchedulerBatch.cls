/*
* Author: DeaGle
*/
public without sharing class CandidateShiftSchedulerBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Preferred_Working_Days__c, Preferred_Start_Time__c, Preferred_End_Time__c, Last_Shift_Synced_On__c FROM Contact WHERE Preferred_Working_Days__c != null AND (Last_Shift_Synced_On__c <= LAST_N_MONTHS:6 OR Error_While_Shift_Sync__c = true) AND Candidate_Status__c = \'Active\' AND RecordType.developerName = \'Candidate\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Contact> candidateList) {
        List<Id> candidateIdList = new List<Id>();
        for(Contact c : candidateList) {
            candidateIdList.add(c.Id);
        }
        ShiftUtility.handleShiftAlignment(candidateIdList, candidateList);
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('--- batch job execution complete');
    }
}