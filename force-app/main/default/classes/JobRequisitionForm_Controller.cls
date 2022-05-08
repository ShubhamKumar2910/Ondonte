public without sharing class JobRequisitionForm_Controller {
    public string placementTypeValues {get;set;}
    public string staffTypeValues {get;set;}
    public string jobTermsValues {get;set;}
    public string workingDay {get;set;}
    public string ImageXRaySoftware {get;set;}
    public string XRayProficiency {get;set;}
    public string PMSKnowledge {get;set;}
    public string typesOfCrowns {get;set;}
    public string computerSkills {get;set;}
    
    public JobRequisitionForm_Controller() {    
        placementTypeValues = JSON.serialize(Utility.getPicklistValues('Job_Requisition__c', 'Placement_Type__c'));
        staffTypeValues = JSON.serialize(Utility.getPicklistValues('Job_Requisition__c', 'Staff_Type__c'));
        jobTermsValues = JSON.serialize(Utility.getPicklistValues('Job_Requisition__c', 'Job_Term__c'));
        workingDay=JSON.serialize(Utility.getPicklistValues('Job_Requisition__c', 'Working_Days__c'));
        ImageXRaySoftware=JSON.serialize(Utility.getPicklistValues('Job_Requisition__c', 'Image_X_ray_Software__c'));
        XRayProficiency=JSON.serialize(Utility.getPicklistValues('Job_Requisition__c', 'X_ray_Proficiency__c'));
        PMSKnowledge=JSON.serialize(Utility.getPicklistValues('Job_Requisition__c', 'PMS_Knowledge__c'));
        typesOfCrowns=JSON.serialize(Utility.getPicklistValues('Job_Requisition__c', 'Types_of_Crowns__c'));
        computerSkills=JSON.serialize(Utility.getPicklistValues('Job_Requisition__c', 'Computer_Skills__c'));
    }

    @RemoteAction
    public static string submitJobRequisitionForm(Job_Requisition__c jobReq, string clientId,integer startDate,integer startMonth,integer startYear,integer endDate,integer endMonth,integer endYear,Integer startHrs,Integer startMin,Integer endHr,Integer endMin){
        if(!string.isBlank(clientId)){
            Account acc = [select name,id,BillingLatitude,BillingLongitude from Account where Id =:clientId];
            jobReq.Geolocation__latitude__s =  acc.BillingLatitude;
            jobReq.Geolocation__longitude__s  =  acc.BillingLongitude;
        }
        if(startHrs!=null && startMin!=null)
        {
            Time startTime = Time.newInstance(startHrs,startMin, 0, 0);
			jobReq.Work_Start_Time__c=startTime;
        }
        if(endHr!=null && endMin!=null)
        {
            Time endTime = Time.newInstance(endHr,endMin, 0, 0);
			jobReq.Work_End_Time__c=endTime;
        }
        jobReq.Expected_Start_Date__c = date.newInstance(startYear, startMonth, startDate);
        jobReq.Expected_End_Date__c = date.newInstance(endYear, endMonth, endDate);
        jobReq.Placement_Type__c = 'Permanent';
        jobReq.RecordTypeId = Schema.SObjectType.Job_Requisition__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
        jobReq.Client__c = clientId;
        insert jobReq;
        return jobReq.Id;
    }
}