/**
 * Author: DeaGle
 */
public without sharing class JobApplicationTriggerHandler {
    //constants
    static final String APP_STAGE_PLACED = 'Placed';
    static final List<String> OUT_PROGRESS_APP_STATUSES = new List<String> {'Withdrawn by Candidate', 'Final Candidate Selected', 'Rejected by Client'};
    static final String APP_STAGE_FCS = 'Final Candidate Selected';
    static JobApplicationTriggerHandler handlerInstance;
    /*
     *	Applied
        Interview Scheduled
        Rejected by Client
        Selected by Client
        Withdrawn by Candidate
        Submitted To Client
        Placed
        Accepted By Candidate
        Final Candidate Selected
	*/
    private JobApplicationTriggerHandler() {}
    

    public static JobApplicationTriggerHandler getInstance() {
        if(handlerInstance == null)
            handlerInstance = new JobApplicationTriggerHandler();
        return handlerInstance;
    }

    public void onBeforeUpdate(List<Job_Application__c> jobAppsList, Map<Id,Job_Application__c> oldMap) {
        Map<Id,Integer> reqXplacedappCount = new Map<Id,Integer>();
        Set<Id> currentjobAppIdSet = new Set<Id>();
        for(Job_Application__c jApp: jobAppsList) {
            if(jApp.Job_Requisition__c != null && oldMap.get(jApp.Id).Application_Stage__c != APP_STAGE_PLACED && jApp.Application_Stage__c == APP_STAGE_PLACED) {
                currentjobAppIdSet.add(jApp.Id);
                if(reqXplacedappCount.containsKey(jApp.Job_Requisition__c)) {
                    reqXplacedappCount.put(jApp.Job_Requisition__c, reqXplacedappCount.get(jApp.Job_Requisition__c) + 1);
                }
                else {
                    reqXplacedappCount.put(jApp.Job_Requisition__c, 1);
                }
                    
            }
        }
        if(!reqXplacedappCount.isEmpty()) {
            permanentJobClosureHelper(reqXplacedappCount, currentJobAppIdSet);
        }
    }
    
    
    private void permanentJobClosureHelper(Map<Id,Integer> reqXplacedappCount, Set<Id> currentjobAppIdSet) {
        List<Job_Requisition__c> pRequisitionsList = [SELECT Id, Requisition_Closed_Date__c, (SELECT Id, Application_Stage__c FROM Job_Applications__r WHERE Application_Stage__c NOT IN :OUT_PROGRESS_APP_STATUSES AND Id NOT IN :currentjobAppIdSet), No_Of_Positions__c FROM Job_Requisition__c WHERE Id IN:reqXplacedappCount.keySet() AND Placement_Type__c = 'Permanent' AND No_Of_Positions__c != null];
        List<Job_Requisition__c> closedRequisitionList = new List<Job_Requisition__c>();
        List<Job_Application__c> appListtoUpdate = new List<Job_Application__c>();
        List<Job_Application__c> currentPlacedApps = new List<Job_Application__c>();
        List<Job_Application__c>  unSelectedApps = new List<Job_Application__c>();
        if(!pRequisitionsList.isEmpty()) {
            for(Job_Requisition__c jReq: pRequisitionsList) {
                currentPlacedApps = new List<Job_Application__c>();
                for(Job_Application__c jApp: jReq.Job_Applications__r) {
                    if(jApp.Application_Stage__c == APP_STAGE_PLACED) {
                        currentPlacedApps.add(jApp);
                    }else {
                        jApp.Application_Stage__c = APP_STAGE_FCS;
                        unSelectedApps.add(jApp);
                    }
                }
                if(jReq.No_Of_Positions__c <= currentPlacedApps.size() + reqXplacedappCount.get(jReq.Id)) { // Wink ;)
                    jReq.No_Of_Positions_Filled__c = currentPlacedApps.size() + reqXplacedappCount.get(jReq.Id);
                    jReq.Status__c = 'Closed';
                    jReq.Display_On_Portal__c = false;
                    jReq.Requisition_Closed_Date__c = System.today();
                    closedRequisitionList.add(jReq);
                    if(!unselectedApps.isEmpty())
                    	appListtoUpdate.addAll(unSelectedApps);
                }
            }
            
            if(!closedRequisitionList.isEmpty()) {
                Savepoint sp = Database.setSavepoint();
                try {
                    update closedRequisitionList;
                    if(!appListtoUpdate.isEmpty()){
                        update appListtoUpdate;
                    }
                }catch(DMLException e) {
                    Database.rollback(sp);
                    HandleBusinessException.captureError('JobApplicationTriggerHandler', 'permanentJobClosureHelper', e);
                }
            }
        }
    }
}