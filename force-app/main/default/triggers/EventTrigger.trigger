trigger EventTrigger on Event (after insert, before update) {
    SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('Event');

    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        EventTriggerHandler handlerInstance = EventTriggerHandler.getInstance();
        if(Trigger.isInsert && Trigger.isAfter) {
            system.debug('After Insert in trigger');
            handlerInstance.handleAfterInsert(Trigger.New);
        }
        
        if(Trigger.isBefore && Trigger.isUpdate) {
            handlerInstance.handleBeforeUpdate(Trigger.OldMap, Trigger.New);
        }
    }
    
}