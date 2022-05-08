/**
 * Author: DeaGle
 */
trigger UserDocumentTrigger on User_Document__c (before update) {
    SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('User_Document__c');
    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        UserDocumentTriggerHandler handlerInstance = UserDocumentTriggerHandler.getInstance();
        if(Trigger.isBefore && Trigger.isUpdate) {
            handlerInstance.onBeforeUpdate(Trigger.New);
        }
    }

}