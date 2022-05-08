/**
 * Author : Anjali;
 */

public without sharing class RegistrationForm_Controller {
    
    public string skillList    {get;set;}
    public String crownPicklistVal{get;set;}
    public String xrayProficiencyPickVal{get;set;}
    public String pmsKnowledgePickval{get;set;}
    public String imgSoftwarePickVal{get;set;}
    public string compSkillPickVal {get;set;}
    public string docCategoryName {get;set;}
    static final String UNAUTH_RETURN_URL = 'https://www.ondonte.com/';

    public String candidateRecord{get;set;}

    Public RegistrationForm_Controller() {
        String candidateId = Apexpages.currentPage().getParameters().get('id'); 
        if(!String.isBlank(candidateId)) {
            candidateRecord = JSON.serialize([SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE RecordType.Name = 'Candidate' AND Id = :candidateId]);
            skillList = JSON.serialize(Utility.getPicklistValues('Contact', 'Computer_Skills__c'));
            crownPicklistVal = JSON.serialize(Utility.getPicklistValues('Contact','Types_of_Crowns__c'));
            pmsKnowledgePickval = JSON.serialize(Utility.getPicklistValues('Contact','PMS_Knowledge__c'));
            xrayProficiencyPickVal = JSON.serialize(Utility.getPicklistValues('Contact','X_ray_Proficiency__c'));
            imgSoftwarePickVal = JSON.serialize(Utility.getPicklistValues('Contact','Image_X_ray_Software__c'));
            compSkillPickVal = JSON.serialize(Utility.getPicklistValues('Contact','Computer_Skills__c'));
        }
        else {
            return;
        }
    }


    public Pagereference authenticateUser() {
        String candidateHashcode = Apexpages.currentPage().getParameters().get('h'); 
        if(String.isEmpty(candidateHashcode))
            return new Pagereference(UNAUTH_RETURN_URL);
        
        List<Contact> candidateList = [SELECT Id FROM Contact WHERE Login_Hash_Code__c =:candidateHashcode];
        if(!candidateList.isEmpty()) {
            return null;
        }
        return new Pagereference(UNAUTH_RETURN_URL);
    }
    
    
    @RemoteAction
    public static String updateContact(Contact contactDetails) {
        if(contactDetails != null) {
            try {
                contactDetails.Login_Hash_Code__c = Utility.generateRandomString();
                update contactDetails;
                return 'SUCCESS';
            }catch(DmlException e) {
                HandleBusinessException.captureError('RegistrationForm_Controller', 'updateContact', e);
                return 'ERROR';
            }
        }
        return 'ERROR';
    } 
}