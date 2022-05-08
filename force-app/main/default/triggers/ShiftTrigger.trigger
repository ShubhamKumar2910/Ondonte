trigger ShiftTrigger on Shift__c (before insert,before update) {
    SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('Shift__c');
    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        ShiftTriggerHandler handlerInstance = ShiftTriggerHandler.getInstance();
        if(Trigger.isBefore && Trigger.isInsert) {
            handlerInstance.onBeforeInsert(Trigger.New);
        }
        if(Trigger.isBefore && Trigger.isUpdate) {
            handlerInstance.onBeforeUpate(Trigger.NewMap, Trigger.oldMap);
        }

    }

}