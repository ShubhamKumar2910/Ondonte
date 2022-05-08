public with sharing class InterviewFeedbackFormHelper {
    public static string jobAppRecid {get;set;}
    public InterviewFeedbackFormHelper() {
    }
    @RemoteAction
    public static string getInterviewFeedbackDetails(string jobAppid){
        system.debug('jobAppid'+jobAppid);
        jobAppRecid = jobAppid;
        // return job application if Stage is Interview Scheduled
        List<Job_Application__c> applicationStatus = [Select Request_Interview_Feedback__c,Application_Stage__c,Interview_Feedback__c From Job_Application__c Where Id =: jobAppid AND Application_Stage__c =:Constants.ApplicationStatusInterviewScheduled AND Interview_Feedback_Submitted__c = false limit 1];
        if(applicationStatus.isEmpty()){
        return null;
        }else {
        return applicationStatus[0].Application_Stage__c;
        }
    }
    @RemoteAction
    public static void updateInterviewFeedback(String candidateStatus, String feedback, string jobId){   
        try{
            if(!string.isBlank(candidateStatus) && !string.isBlank(feedback) && !string.isBlank(jobId)){
                system.debug('Inside update block');
                Job_Application__c jobAppRec = new Job_Application__c();
                jobAppRec.Id = jobId;
                if(candidateStatus == 'Rejected')
                jobAppRec.Application_Stage__c = Constants.ApplicationStatusRejected;
                else if(candidateStatus == 'Selected')
                jobAppRec.Application_Stage__c = Constants.ApplicationStatusSelected;
                jobAppRec.Interview_Feedback__c = feedback;
                jobAppRec.Interview_Feedback_Submitted__c = true;
                update jobAppRec;
            }
        }catch(exception ex){ 
            system.debug('Error>>'+ex.getMessage());
            system.debug('Error>>'+ex.getLineNumber());
        }
    }
}