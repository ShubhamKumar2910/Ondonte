trigger ContactTrigger on Contact (before update) {
    SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('Contact');
    system.debug('triggerConfig----'+triggerConfig);
    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        ContactTriggerHandler handlerInstance = ContactTriggerHandler.getInstance();
        
        if(Trigger.isBefore && Trigger.isUpdate) {
            handlerInstance.onBeforeUpdate(Trigger.OldMap, Trigger.New);
        }
        
    }
}