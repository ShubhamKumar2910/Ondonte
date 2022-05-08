public without sharing class SendSMSBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    List <String> ids;
    String templateId;
    String objectType;

    public SendSMSBatch(List<String> ids, String templateId, String objectType) {
        System.debug('Calling SMS Batch');
        this.ids = ids;
        this.templateId = templateId;  
        this.objectType = objectType;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){ 
        return Database.getQueryLocator([Select Id from Contact limit 1]); 
    } 

    public void execute(Database.BatchableContext BC, List<sObject> scope){ 

        System.debug('Executing SMS Batch');
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

 

    public void finish(Database.BatchableContext BC){ 
        System.debug('finishing SMS Batch');
    } 


}