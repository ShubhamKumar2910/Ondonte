global with sharing class SMSUtiliity {
    public SMSUtiliity() {}
    public static String sendTempJobCancelNotification(List<String> conIds) {
        List<Contact> contacts = [SELECT Id, Name, Phone, Email From Contact WHERE Id in :conIds];

        System.debug('ConList'+contacts);

        tdc_tsw__Message_Template__c template = [Select Id, Name from tdc_tsw__Message_Template__c Where Name = 'Temporary Job Cancel Notification'];

        System.debug('TemplateId---'+template.Id);
        for(Contact con:contacts){
            map<String,object> params = new map<String,object>();

            params.put('recordId', con.Id);
            params.put('phoneApi', 'Phone');// phone api

            //params.put('documentId', '0151h000000tMGm');
            params.put('phoneNumber', con.Phone);
            params.put('templateId', template.Id);

            //params.put('messageText', 'Text message here');
            tdc_tsw.GlobalSmsSender.senderNumber = con.Phone; // when we need to use specific sender number for sms.
            tdc_tsw.GlobalSmsSender.sendSmsAndReturnHistory(params);
        }
        return 'SUCCESS';
    }


    @future(callout=true)
    public static void sendSMSNotification(String ids, String templateId){
        if(ids!=null){
            System.debug('Ids inside method----'+ids);

            map<String,object> params = new map<String,object>();
            params.put('recordId',ids);
            params.put('phoneApi', 'Phone__c');// phone api
            params.put('templateId', templateId);

            System.debug('PARAMSSSS_______'+params);
            tdc_tsw.GlobalSmsSender.sendSmsAndReturnHistory(params);
            tdc_tsw.GlobalSmsSender.insertSmsHistory(null);
        }
    }

    @future(callout=true)
    public static void sendSMSNotificationFromBatch(List<String> ids, String templateId,String objectType){
        if(ids!=null){
            for(String id:ids){
                map<String,object> params = new map<String,object>();
                params.put('recordId',id);
                params.put('phoneApi', objectType.equals('Contact')?'Phone':'Phone__c');// phone api
                params.put('templateId', templateId);
                System.debug('PARAMSSSS_______'+params);
                tdc_tsw.GlobalSmsSender.sendSmsAndReturnHistory(params);
            }
            tdc_tsw.GlobalSmsSender.insertSmsHistory(null); 
        }
    }

   

    @InvocableMethod(label='CandidateAssignedToJobApp') 
    public static void initiateNotification(List<SendSMSWrapper> smsWrappers){
        
        List<String> receiverIds = new List<String>();
       
        try{
            String templateId = Utility.getSMSTemplateId(smsWrappers[0].getTempName());
            String objApi = smsWrappers[0].getObjApi();
            for(SendSMSWrapper sm: smsWrappers){
                receiverIds.add(sm.getIds());
            }
            Database.executeBatch(new SendSMSBatch(receiverIds,templateId,objApi));
        }catch(Exception e){
            HandleBusinessException.captureError('EventTriggerHandler','handleInterviewedEvents',e);
        }
    }


    global class SendSMSWrapper{
        @InvocableVariable
        public String ids;

        @InvocableVariable
        public String templateName;

        @InvocableVariable
        public String objApi;

        public String getIds(){
            return this.ids;
        }

        public String getTempName(){
            return this.templateName;
        }
        public String getObjApi(){
            return this.objApi;
        }
    }

    // ritusharmasvs@gmail.com

    
}