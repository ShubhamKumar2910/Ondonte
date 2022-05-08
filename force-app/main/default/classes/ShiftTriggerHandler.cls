/**
* Author : Deagle
*/

public without sharing class ShiftTriggerHandler {
    
    
    static final String SHIFT_STAGE_ALLOCATED = 'Allocated';
    static final String OUT_PROGRESS_SHIFT_STATUSES = 'Assigned';
    static final String CAN_SHIFT_STATUS_AVAILABLE = 'Available';
    static final String CAN_SHIFT_STATUS_NOT_AVAILABLE = 'Not Available';
    static final String CLIENT_SHIFT_REQ_STATUS_FILLED = 'Filled';
    static final String CLIENT_SHIFT_REQ_STATUS_OPEN = 'Open';

    static ShiftTriggerHandler handlerInstance;
    private ShiftTriggerHandler() {}

    public static ShiftTriggerHandler getInstance() {
        if(handlerInstance == null)
            handlerInstance = new ShiftTriggerHandler();
        
        return handlerInstance;
    }

    public void onBeforeInsert(List<Shift__c> shiftList) {
        this.validateShift(shiftList);
    }

    public void onBeforeUpate(Map<Id, Shift__c> newMap, Map<Id, Shift__c> oldMap) {

        Id candidateShiftRecordTypeId = ShiftUtility.getCandidateShiftRTId();
        Map<Id,Integer> reqXplacedshiftsCount = new Map<Id,Integer>();
        Set<Id> currentShiftIdSet = new Set<Id>();
        Set<Id> jobShiftsToOpenIdSet = new Set<Id>();
        Map<Id,Integer> clientTocandidateShiftClosureMap = new Map<Id,Integer>();
        //Send email vars
        Map<String, Shift__c> shiftByCandidateId = new Map<String,Shift__c>();
        Set<Id> candidatesId = new Set<Id>();
        Set<Id> clientsShiftId = new Set<Id>();

        for(Shift__c candidateShift: newMap.values()) {

            if(candidateShift.RecordTypeId == candidateShiftRecordTypeId) {
                if(candidateShift.Allocated_To__c != null && oldMap.get(candidateShift.Id).Status__c != Constants.SHIFT_STATUS_ALLOCATED && candidateShift.Status__c == Constants.SHIFT_STATUS_ALLOCATED) {
                    currentShiftIdSet.add(candidateShift.Id);
                    if(reqXplacedshiftsCount.containsKey(candidateShift.Allocated_To__c)) {
                        reqXplacedshiftsCount.put(candidateShift.Allocated_To__c, reqXplacedshiftsCount.get(candidateShift.Allocated_To__c) + 1);
                    }
                    else {
                        reqXplacedshiftsCount.put(candidateShift.Allocated_To__c, 1);
                    }
                        
                }else if(oldMap.get(candidateShift.Id).Status__c == SHIFT_STAGE_ALLOCATED && candidateShift.Status__c == CAN_SHIFT_STATUS_NOT_AVAILABLE && candidateShift.Allocated_To__c != null) {
                    jobShiftsToOpenIdSet.add(candidateShift.Allocated_To__c);
                    if(clientTocandidateShiftClosureMap.containsKey(candidateShift.Allocated_To__c)) {
                        clientTocandidateShiftClosureMap.put(candidateShift.Allocated_To__c, clientTocandidateShiftClosureMap.get(candidateShift.Allocated_To__c) + 1);
                    }else {
                        clientTocandidateShiftClosureMap.put(candidateShift.Allocated_To__c, 1);
                    }
                }
    
                if(candidateShift.Contact__c != null && candidateShift.Allocated_To__c != null && candidateShift.status__c != oldMap.get(candidateShift.Id).status__c && candidateShift.status__c == Constants.SHIFT_STATUS_ALLOCATED){
                    shiftByCandidateId.put(candidateShift.Contact__c, candidateShift);
                    candidatesId.add(candidateShift.Contact__c);
                    clientsShiftId.add(candidateShift.Allocated_To__c);
                }
            }
        }
        System.debug('--- reqXplacedshiftsCount'+reqXplacedshiftsCount);
        if(!reqXplacedshiftsCount.isEmpty()) {
            tempShiftClosureHelper(reqXplacedshiftsCount, currentShiftIdSet);
        }
        //open requisition helper
        if(!jobShiftsToOpenIdSet.isEmpty()) {
            openClientShiftFromClosed(jobShiftsToOpenIdSet, clientTocandidateShiftClosureMap);
        }
        //OTHER
        if(!shiftByCandidateId.isEmpty()) {
            sendEmailAlertToCandidate(shiftByCandidateId, candidatesId, clientsShiftId);
        }
    }

    private void tempShiftClosureHelper(Map<Id,Integer> reqXplacedshiftsCount, Set<Id> currentShiftIdSet) {
        List<Shift__c> clientShiftList = [SELECT Id, Shift_Closed_Date__c, (SELECT Id, Status__c FROM Shifts__r WHERE /*Status__c  = :OUT_PROGRESS_SHIFT_STATUSES AND*/ Id NOT IN :currentShiftIdSet), No_Of_Required_Candidates__c FROM Shift__c WHERE Id IN:reqXplacedshiftsCount.keySet() AND RecordType.DeveloperName = 'Client' AND No_Of_Required_Candidates__c != null];
        List<Shift__c> filledShiftList = new List<Shift__c>();
        List<Shift__c> canShiftstoAvailableUpdate = new List<Shift__c>();
        List<Shift__c> currentAllocatedShifts = new List<Shift__c>();
        List<Shift__c>  mkAvailableShifts = new List<Shift__c>();
        if(!clientShiftList.isEmpty()) {
            for(Shift__c clShift: clientShiftList) {
                currentAllocatedShifts = new List<Shift__c>();
                for(Shift__c canShift: clShift.Shifts__r) {
                    if(canShift.Status__c == SHIFT_STAGE_ALLOCATED) {
                        currentAllocatedShifts.add(canShift);
                    }else {
                        canShift.Status__c = CAN_SHIFT_STATUS_AVAILABLE;
                        canShift.Allocated_To__c = null;
                        canShiftstoAvailableUpdate.add(canShift);
                    }
                }
                System.debug('--- currentAllocatedShifts'+currentAllocatedShifts);
                System.debug('--- canShiftstoAvailableUpdate'+canShiftstoAvailableUpdate);
                System.debug('--- clShift'+clShift);
                if(clShift.No_Of_Required_Candidates__c <= currentAllocatedShifts.size() + reqXplacedshiftsCount.get(clShift.Id)) { // Wink ;)
                    clShift.Number_Of_Allocated_Candidates__c = currentAllocatedShifts.size() + reqXplacedshiftsCount.get(clShift.Id);
                    clShift.Status__c = 'Filled';
                    clShift.Shift_Closed_Date__c = System.today();
                    filledShiftList.add(clShift);
                    if(!canShiftstoAvailableUpdate.isEmpty())
                    	mkAvailableShifts.addAll(canShiftstoAvailableUpdate);
                }
            }
            
            if(!filledShiftList.isEmpty()) {
                Savepoint sp = Database.setSavepoint();
                try {
                    System.debug('--- filledShiftList'+filledShiftList);
                    System.debug('--- mkAvailableShifts'+mkAvailableShifts);
                    update filledShiftList;
                    if(!mkAvailableShifts.isEmpty()){
                        update mkAvailableShifts;
                    }
                }catch(DMLException e) {
                    Database.rollback(sp);
                    HandleBusinessException.captureError('ShiftTriggerHandler', 'tempShiftClosureHelper', e);
                }
            }
        }
    }
	
    //TODO: handle current dataset validation, bulk error ui
    private void validateShift(List<Shift__c> shiftList) {
        Id candidateShiftRecordTypeId = ShiftUtility.getCandidateShiftRTId();
        Id clientShiftRecordTypeId = ShiftUtility.getClientShiftRTId();
        Map<Id,List<Shift__c>> candidateShiftMap = new Map<Id,List<Shift__c>>();

        for(Shift__c shift: shiftList) {
            if(shift.recordTypeId == candidateShiftRecordTypeId && shift.Contact__c != null) {
                if(candidateShiftMap.containsKey(shift.Contact__c))
                    candidateShiftMap.get(shift.Contact__c).add(shift);
                else
                    candidateShiftMap.put(shift.Contact__c, new List<Shift__c>{shift});
            }
        }
        if(!candidateShiftMap.isEmpty())
            validateCandidateShift(candidateShiftMap);
    }

    private void validateCandidateShift(Map<Id,List<Shift__c>> candidateShiftMap) {
        List<Shift__c> currentCandidateShiftList = [SELECT Id, Name, Start_DateTime__c, End_DateTime__c, Contact__c FROM Shift__c WHERE Contact__c IN:candidateShiftMap.keySet() AND Start_DateTime__c >= TODAY];
        for(Shift__c extShift : currentCandidateShiftList) {
            for(Shift__c  newShift: candidateShiftMap.get(extShift.Contact__c)) {
                if(newShift.Start_DateTime__c >= extShift.Start_DateTime__c && newShift.Start_DateTime__c <= extShift.End_DateTime__c) {
                    newShift.addError('You already have an existing schedule on this day and time:'+extShift.Name);
                    break;
                }
            }
        }
    }

    private void openClientShiftFromClosed(Set<Id> jobShiftsToOpenIdSet, Map<Id,Integer> clientTocandidateShiftClosureMap) {
        List<Shift__c> requisitionShiftToOpenList = new List<Shift__c>();
        for(Shift__c jShift: [SELECT Id,Number_Of_Allocated_Candidates__c FROM Shift__c WHERE Id IN:jobShiftsToOpenIdSet AND RecordType.DeveloperName = 'Client' AND Status__c = :CLIENT_SHIFT_REQ_STATUS_FILLED]) {
            jShift.Status__c = CLIENT_SHIFT_REQ_STATUS_OPEN;
            if(jShift.Number_Of_Allocated_Candidates__c > 0 && clientTocandidateShiftClosureMap.get(jShift.Id) > 0) {
                jShift.Number_Of_Allocated_Candidates__c  = jShift.Number_Of_Allocated_Candidates__c - clientTocandidateShiftClosureMap.get(jShift.Id);
            }
            requisitionShiftToOpenList.add(jShift);
        }
        if(!requisitionShiftToOpenList.isEmpty()) {
            try {
                update requisitionShiftToOpenList;
            }catch(DMLException e) {
                HandleBusinessException.captureError('ShiftTriggerHandler', 'openJobRequisition', e);
            }
        }
    }
    
    // Email alert to candidarte when Status on shift is updated to Allocated
    public void sendEmailAlertToCandidate(Map<String, Shift__c> shiftByCandidateId, set<Id> candidatesId, set<Id> clientsShiftId) {
        try{
            Map<String, String> clientNameByCandidateId = new Map<String, String>();
            List<Shift__c> shiftsList = new List<Shift__c>();
            List<Shift__c> clientShiftList = new List<Shift__c>();
            Map<string,List<Shift__c>> shiftsByClientId = new Map<String, List<Shift__c>>();
            
           /*  for(Shift__c shift : newMap.values()){
                if(shift.recordTypeId == system.label.Shift_Candidate_Recordtype_Id && shift.Contact__c != null && shift.Allocated_To__c != null && shift.status__c != oldMap.get(shift.Id).status__c && shift.status__c == Constants.SHIFT_STATUS_ALLOCATED){
                    shiftByCandidateId.put(shift.Contact__c, shift);
                    candidatesId.add(shift.Contact__c);
                    clientsShiftId.add(shift.Allocated_To__c);
                }
            } */
            //Candidates Notification
            if(!candidatesId.isEmpty()){
                shiftsList = [Select Contact__c,Job_Requisition__r.Client__r.Name From Shift__C Where Contact__c In : candidatesId];
                if(!shiftsList.isEmpty()){
                    for(Shift__c shiftRec : shiftsList){
                       clientNameByCandidateId.put(shiftRec.Contact__c, shiftRec.Job_Requisition__r.Client__r.Name);
                    }
                }
                EmailHelper.notifyCandidatesForShift(candidatesId, clientNameByCandidateId, shiftByCandidateId);
            }
            system.debug('clientsShiftId::'+clientsShiftId);
            // Client Notification
            if(!clientsShiftId.isEmpty()){
                clientShiftList = [Select Id,Contact__r.Name,Job_Requisition__r.Client__r.Name,Job_Requisition__r.Client__c,Job_Requisition__r.Client__r.Account_Email__c From Shift__c where Allocated_To__c In : clientsShiftId AND Status__c =: Constants.SHIFT_STATUS_ALLOCATED ];
                if(!clientShiftList.isEmpty()){
                    for(Shift__c shiftRec : clientShiftList){
                        if(shiftsByClientId.containsKey(shiftRec.Job_Requisition__r.Client__c)){
                            List<Shift__C> shiftToBeAdded = shiftsByClientId.get(shiftRec.Job_Requisition__r.Client__c);
                            shiftToBeAdded.add(shiftRec);
                            shiftsByClientId.put(shiftRec.Job_Requisition__r.Client__c, shiftToBeAdded);
                        }else{
                            shiftsByClientId.put(shiftRec.Job_Requisition__r.Client__c,new List<Shift__C> {shiftRec});
                        }
                    }
                    system.debug('shiftsByClientId::'+shiftsByClientId);
                    if(!shiftsByClientId.isEmpty()){
                        EmailHelper.notifyClientsForShift(shiftsByClientId);
                    }
                    
                }
            }

        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage());
            system.debug('Error@@==>'+ex.getLineNumber());
        }
        
    }

}