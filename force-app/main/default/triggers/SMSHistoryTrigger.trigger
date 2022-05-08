trigger SMSHistoryTrigger on tdc_tsw__Message__c (after insert) {
    SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('tdc_tsw__Message__c');
    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        SMSHistoryTriggerHandler handlerInstance = SMSHistoryTriggerHandler.getInstance();
        if(Trigger.isAfter && Trigger.isInsert) {
            System.debug('permJobAcceptedAppIdSet'+Trigger.New);
            handlerInstance.onBeforeInsert(Trigger.New);
        }
    }
}