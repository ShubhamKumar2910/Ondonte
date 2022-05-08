public without sharing class SMSHistoryTriggerHandler {
    static SMSHistoryTriggerHandler instance;
    private SMSHistoryTriggerHandler() {}
    
    public static SMSHistoryTriggerHandler getInstance() {
        if(instance == null)
            instance = new SMSHistoryTriggerHandler();
        return instance;
    }

    public void onBeforeInsert(List<tdc_tsw__Message__c> smsHistoryList) {
        System.debug('Started');
        List<tdc_tsw__Message__c> inboundCandidateResponseList = new List<tdc_tsw__Message__c>();
        Set<Id> smsOutgoingIdSet = new Set<Id>();
        Map<Id,tdc_tsw__Message__c> cResponseToTempMap = new Map<Id,tdc_tsw__Message__c>();
        for(tdc_tsw__Message__c smsRec : smsHistoryList) {
            
            if(smsRec.Name == 'Incoming' && smsRec.tdc_tsw__Message__c != null) {
                smsOutgoingIdSet.add(smsRec.tdc_tsw__Message__c);
                cResponseToTempMap.put(smsRec.Id, smsRec);
            }
        }


        if(!smsOutgoingIdSet.isEmpty()) {
            System.debug('Reading message');
            readSms(smsOutgoingIdSet, cResponseToTempMap);
        }
    }

    private void readSms(Set<Id> smsTemplateIdSet, Map<Id,tdc_tsw__Message__c> cResponseToTempMap) {
        Map<Id, tdc_tsw__Message__c> candidateResponseTemplateMap = new Map<Id,tdc_tsw__Message__c>([SELECT Id, tdc_tsw__SMS_Template__r.Name FROM tdc_tsw__Message__c WHERE Id IN:smsTemplateIdSet]);
        //Temporary     

        Set<Id> tempJobAcceptedShiftIdSet = new Set<Id>();
        Set<Id> tempJobRejectedShiftIdSet = new Set<Id>();
        //Permenant
        Set<Id> permJobAcceptedAppIdSet = new Set<Id>();
        Set<Id> permJobRejectedAppIdSet = new Set<Id>();
        
        for(tdc_tsw__Message__c smsTemp :cResponseToTempMap.values()) {
            if(candidateResponseTemplateMap.containsKey(smsTemp.tdc_tsw__Message__c) && smsTemp.tdc_tsw__Related_Object_Id__c != null) {
                if(candidateResponseTemplateMap.get(smsTemp.tdc_tsw__Message__c).tdc_tsw__SMS_Template__r.Name == SMSConstants.TEMP_JOB_ACCEPTANCE_TEMPLATE_NAME && smsTemp.tdc_tsw__Message_Text_New__c != null) {
                    if(smsTemp.tdc_tsw__Message_Text_New__c.contains(SMSConstants.SMS_RESPONSE_ACCEPTANCE)) {
                        tempJobAcceptedShiftIdSet.add(smsTemp.tdc_tsw__Related_Object_Id__c);
                    }else if(smsTemp.tdc_tsw__Message_Text_New__c.contains(SMSConstants.SMS_RESPONSE_REJECTION)) {
                        tempJobRejectedShiftIdSet.add(smsTemp.tdc_tsw__Related_Object_Id__c);
                    }
                }else if(candidateResponseTemplateMap.get(smsTemp.tdc_tsw__Message__c).tdc_tsw__SMS_Template__r.Name == SMSConstants.PERMANENT_JOB_ACCEPTANCE_TEMPLATE_NAME && smsTemp.tdc_tsw__Message_Text_New__c != null) {
                    if(smsTemp.tdc_tsw__Message_Text_New__c.contains(SMSConstants.SMS_RESPONSE_ACCEPTANCE)) {
                        permJobAcceptedAppIdSet.add(smsTemp.tdc_tsw__Related_Object_Id__c);
                    }else if(smsTemp.tdc_tsw__Message_Text_New__c.contains(SMSConstants.SMS_RESPONSE_REJECTION)) {
                        permJobRejectedAppIdSet.add(smsTemp.tdc_tsw__Related_Object_Id__c);
                    }
                }
            }
        }

        if(!tempJobAcceptedShiftIdSet.isEmpty()) {
            System.debug('tempJobAcceptedShiftIdSet'+tempJobAcceptedShiftIdSet);
            tempJobAcceptationHandler(tempJobAcceptedShiftIdSet);
        }
        if(!tempJobRejectedShiftIdSet.isEmpty()) {
            System.debug('tempJobRejectedShiftIdSet'+tempJobRejectedShiftIdSet);
            tempJobRejectionHandler(tempJobRejectedShiftIdSet);
        }
        if(!permJobAcceptedAppIdSet.isEmpty()) {
            System.debug('permJobAcceptedAppIdSet'+permJobAcceptedAppIdSet);
            perJobAcceptionHandler(permJobAcceptedAppIdSet);
        }
        if(!permJobRejectedAppIdSet.isEmpty()) {
            System.debug('permJobRejectedAppIdSet'+permJobRejectedAppIdSet);
            perJobRejectionHandler(permJobRejectedAppIdSet);
        }
        
        System.debug('Last Call');
    }

    private void tempJobRejectionHandler(Set<Id> tempJobRejectedShiftIdSet) {
        List<Shift__c> rejectionShiftList = new List<Shift__c>();
        for(Id candidateShiftId : tempJobRejectedShiftIdSet) {
            rejectionShiftList.add(new Shift__c(Id = candidateShiftId, Status__c = 'Available',Allocated_To__c=null));
        }
        try{
            update rejectionShiftList;
        }catch(DMLException e) {
            HandleBusinessException.captureError('SMSHistoryTriggerHandler', 'tempJobRejectionHandler', e);
        }
    }

    private void tempJobAcceptationHandler(Set<Id> tempJobAcceptedShiftIdSet) {
        List<Shift__c> acceptedShiftList = new List<Shift__c>();
        Map<Id, Shift__c> shiftMap = new Map<Id,Shift__c>([SELECT Id, Allocated_To__c FROM Shift__c WHERE Id IN:tempJobAcceptedShiftIdSet]);

        for(Id candidateShiftId : tempJobAcceptedShiftIdSet) {
            if(shiftMap.containsKey(candidateShiftId) && shiftMap.get(candidateShiftId).Allocated_To__c !=null) {
                acceptedShiftList.add(new Shift__c(Id = candidateShiftId, Status__c = 'Accepted By Candidate'));
            }
        }
        try{
            update acceptedShiftList;
        }catch(DMLException e) {
            HandleBusinessException.captureError('SMSHistoryTriggerHandler', 'tempJobRejectionHandler', e);
        }
    }

    private void perJobRejectionHandler(Set<Id> perJobRejectedShiftIdSet) {
        List<Job_Application__c> rejectionJobAppList = new List<Job_Application__c>();
        for(Id candidateShiftId : perJobRejectedShiftIdSet) {
            rejectionJobAppList.add(new Job_Application__c(Id = candidateShiftId, Application_Stage__c = 'Withdrawn by Candidate'));
        }
        try{
            update rejectionJobAppList;
        }catch(DMLException e) {
            HandleBusinessException.captureError('SMSHistoryTriggerHandler', 'tempJobRejectionHandler', e);
        }
    }

    private void perJobAcceptionHandler(Set<Id> perJobAcceptedAppIdSet) {
        List<Job_Application__c> acceptionJobAppList = new List<Job_Application__c>();
        for(Id candidateShiftId : perJobAcceptedAppIdSet) {
            acceptionJobAppList.add(new Job_Application__c(Id = candidateShiftId, Application_Stage__c = 'Accepted By Candidate'));
        }
        try{
            System.debug('Permanent Job Accepted-----'+acceptionJobAppList);
            update acceptionJobAppList;
        }catch(DMLException e) {
            HandleBusinessException.captureError('SMSHistoryTriggerHandler', 'tempJobRejectionHandler', e);
        }
    }

}