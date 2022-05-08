/**
 * Author: DeaGle
 */
trigger JobApplicationTrigger on Job_Application__c (before update) {
    SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('Job_Application__c');
    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        JobApplicationTriggerHandler handlerInstance = JobApplicationTriggerHandler.getInstance();
        if(Trigger.isBefore && Trigger.isUpdate) {
            handlerInstance.onBeforeUpdate(Trigger.New, Trigger.OldMap);
        }
    }
}