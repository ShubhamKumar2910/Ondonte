public class CandidateRegistration_Controller {
    
    public String candidateId{get;set;}
    public String crownPicklistVal{get;set;}
    public String imgeSoftwarePickVal{get;set;}
    public string compSkillPickVal {get;set;}
    
    public CandidateRegistration_Controller(){
        candidateId = '';
        candidateId = ApexPages.currentPage().getParameters().get('Id');
        System.debug('!@@@'+ApexPages.currentPage().getParameters().get('abcd'));
        crownPicklistVal = JSON.serialize(Utility.getPicklistValues('Contact','Types_of_Crowns__c'));
        imgeSoftwarePickVal = JSON.serialize(Utility.getPicklistValues('Contact','Image_X_ray_Software__c'));
        compSkillPickVal = JSON.serialize(Utility.getPicklistValues('Contact','Computer_Skills__c'));
        
    }
    @RemoteAction
    public static String updateCandidateRecord(Contact conRecord){
        try{
            update conRecord;
            return Constants.RECORD_UPDATE_SUCCESS;
        }catch(Exception e){
            system.debug(e.getLineNumber()+'---error Message---'+e.getMessage());
            HandleBusinessException.captureError('CandidateRegistration_Controller','updateCandidateRecord',e);
            return Constants.CONTACT_ONDONTE;
        }
    }

    
}