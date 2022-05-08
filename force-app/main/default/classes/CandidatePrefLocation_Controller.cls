public without sharing class CandidatePrefLocation_Controller {

@AuraEnabled(cacheable=true)
public static List<County__c> getAccountList() {
    return [SELECT Id, Name FROM County__c];
}

@AuraEnabled
public static List<City__c> getContacts(String accountId){
    return [Select Id,Name from City__c where County__c=:accountId];
}  

@AuraEnabled
public static string savePrefLocation(list<string> cityList, string countyId, string recordId){
    system.debug(cityList+'--------'+ countyId+'---------'+recordId);
    try{
        list<Preferred_Work_Location__c> preLocationList = New List<Preferred_Work_Location__c>();
        if(cityList.size() > 0){
            for(string city:cityList){
                System.debug(city);
                Preferred_Work_Location__c preLocation = New Preferred_Work_Location__c();
                preLocation.City__c = city;
                preLocation.County__c = countyId;
                preLocation.Contact__c = recordId;
                preLocationList.add(preLocation);
            }
            system.debug(preLocationList+'preLocationList');
            insert preLocationList;
        }
        return 'success';
    }catch(exception e){
        system.debug(e.getLineNumber()+'----'+e.getMessage());
        return e.getMessage();
    }

}
/* @AuraEnabled(cacheable=true)
public static List<Preferred_Work_Location__c> displayContactRecord(string recordId){
    return [Select Id,Name from Preferred_Work_Location__c where Contact__c =:recordId];
}  
*/
@AuraEnabled(cacheable=true)
public static List<Preferred_Work_Location__c> displayContactRecord(string recordId){
    system.debug('recordId--'+recordId);
    return [Select Id,Name,City__r.Name,County__r.Name from Preferred_Work_Location__c where contact__c =:recordId];
}

@AuraEnabled
public static void deleteContacts(list<Id> lstConIds){
    try {
        list<Preferred_Work_Location__c> lstConsToDelete = new list<Preferred_Work_Location__c>();
        System.debug('lstConIds ====> '+lstConIds);
        for(Id idCon : lstConIds) {
            lstConsToDelete.add(new Preferred_Work_Location__c(Id = idCon));
            system.debug('lstConsToDelete----'+lstConsToDelete);
        }
        if(!lstConsToDelete.isEmpty()) {
            delete lstConsToDelete;
        }
    }
    catch(Exception ex) {
        throw new AuraHandledException(ex.getMessage());
    }
}
}