public without sharing class BatchAutoShiftClose implements Database.Batchable<sObject>{
    

    public Database.querylocator start(Database.BatchableContext BC){
        Date todayDate = system.today();
        String query = 'SELECT Id, Name, Status__c, Recordtype.Name from Shift__c where End_Date__c <: todayDate AND (Status__c =\'Open\' OR Status__c = \'Available\')';
        System.debug('Query-----'+query);

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Shift__c> records){
        System.debug('RECORDS-----'+records.size());
        List<Shift__c> shifts = new List<Shift__c>();
        if(!records.isEmpty()){
            for(Shift__c s : records){
                if(s.Status__c.equals('Available') || s.Status__c.equals('Open')){
                    s.Status__c = 'Could not Fill';
                    shifts.add(s);
                }
            }
            if(!shifts.isEmpty()){
                update shifts;
            }  
        }
            
    }
    public void finish(Database.BatchableContext BC){
        System.debug('------------finish');
    }
}