public class ResumeParseClass {
    
     @AuraEnabled(cacheable=true)
     public static SovernResponeWrapper resumeParser(string attId, string conId) {

        ContentVersion contentVer =  [SELECT VersionData from ContentVersion where id = :attId];
        SovernAPIHandler sovernHandler = SovernAPIHandler.getInstance();
        string  response = sovernHandler.parseResumeAndGetResult(contentVer.VersionData);
        system.debug('response-----'+response);
        Resume_Parser_Response__c resParser = New Resume_Parser_Response__c(Contact__c=conId,Response__c=response);
        insert resParser;
         system.debug('SovernResponeWrapper' + SovernResponeWrapper.parse(response));
        return SovernResponeWrapper.parse(response);
         

    }

}