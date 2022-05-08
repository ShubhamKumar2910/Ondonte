public class Test_BatchClass implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts { 

    public Database.QueryLocator start(Database.BatchableContext BC){ 
        List<string> conId = New List<string>{'0033N00000j0eO2','0033N00000jTTZZ'};
    return Database.getQueryLocator([select Id from Contact where Id IN :conId]); 

    } 

 

    public void execute(Database.BatchableContext BC, List<sObject> scope){ 
        system.debug('scope--'+scope);
        for(Sobject record : scope){ 
            map<String,object> params = new map<String,object>(); 
            params.put('recordId', record.get('Id')); 
            params.put('phoneApi', 'Phone');// phone api 
            params.put('messageText', 'Test through code.');
            tdc_tsw.GlobalSmsSender.sendSmsAndReturnHistory(params); 
            
        } 
        //this method is used to create sms history records 

        tdc_tsw.GlobalSmsSender.insertSmsHistory(null); 

    } 

 

    public void finish(Database.BatchableContext BC){ 

    } 

}