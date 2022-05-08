public withOut sharing class DocumentLifeCycleRepository {
 /*   private static DocumentLifeCycleRepository handlerInstance;
    private DocumentLifeCycleRepository() {}

    public static DocumentLifeCycleRepository getInstance() {
        if(handlerInstance == null)
            handlerInstance = new DocumentLifeCycleRepository();
        return handlerInstance;
    }

    public Map<Id,Job_Application__c> getApplicationMapById(Set<Id> applicaitonIdSet) {
        return new Map<Id,Job_Application__c>([SELECT Id FROM Job_Application__c WHERE Id IN :applicaitonIdSet ]); //AND Product__c != null
    } */
    
    /*public Map<Id,Facility__c> getFacilityMapById(Set<Id> applicaitonIdSet) {
        return new Map<Id,Facility__c>([SELECT Id,Job_Application__c, Loan_Product__c FROM Facility__c WHERE Job_Application__c IN :applicaitonIdSet AND Loan_Product__c != null]);
    }*/

    /*public List<Product_Document_Association__c> getProductDocAssociationWithProductAndType(Set<Id> productIdSet, Set<String> documentTypeSet, Boolean generateSignDocument) {
        return [SELECT Id, Loan_Product__c, Display_Order__c, Document_Category__r.Sign_Document__c, Document_Category__c, Document_Category__r.Name, 
            Document_Category__r.Document_Type__c FROM Product_Document_Association__c 
            WHERE /* Loan_Product__c IN :productIdSet AND*/ /*AND Legal_Entity__c = null  AND Document_Category__r.Sign_Document__c = :generateSignDocument */ /* Document_Category__r.Document_Type__c IN :documentTypeSet];
    } */

   /* public Map<Id,Contact> getContactMapById(Set<Id> contactSet) {
        return new Map<Id,Contact>([SELECT Id, FirstName, LastName FROM Contact WHERE Id IN :contactSet]);
    }

    public List<Application_Document_Category__c> getAppDocByParty(Set<Id> applicationIdSet, List<Id> accountIdList) {
        return [SELECT Id, Account__c, Job_Application__c FROM Application_Document_Category__c WHERE Job_Application__c IN : applicationIdSet AND Account__c IN :accountIdList];
    }

    public void deleteApplicationDocuments(Set<Id> applicationIdSet) {
        List<Application_Document_Category__c> appDocList = [SELECT Id FROM Application_Document_Category__c WHERE Job_Application__c IN : applicationIdSet];
        if(!appDocList.isEmpty())
            Database.delete(appDocList);
    } */

}