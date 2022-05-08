/**
 * Author: Deagle
 */
public without sharing class JobRequisitionBroadcastExtention {
    
    public List<Contact> candidatesList{get;set;}
    public String uiErrorMsg {get; set;}
    public Boolean showErrorMsg {get;set;}
    static final String CANDIDATE_RECORD_TYPE_NAME = 'Candidate';
    public List<RequisitionWrapper> requisitionWrapperList{get;set;}
    static final String JOB_BROADCAST_DOMAIN_URL = 'http://www.ondonte.com/';
    public JobRequisitionBroadcastExtention(ApexPages.StandardSetController controller) {
        candidatesList = (Contact[]) controller.getSelected();
        showErrorMsg = false;
        if(candidatesList.isEmpty()) {
            uiErrorMsg = 'Please select at least one candidate.';
            showErrorMsg = true;
            return;
        }

        Set<Id> candidateIdSet = new Set<Id>();
        for(Contact candidate : candidatesList) {
            candidateIdSet.add(candidate.Id);
        }

        candidatesList = [SELECT Id, Name, Email, Phone FROM Contact WHERE Id IN : candidateIdSet AND RecordType.Name = :CANDIDATE_RECORD_TYPE_NAME AND Candidate_Status__c = 'Active' AND Email != null];
        if(candidatesList.isEmpty()) {
            showErrorMsg = true;
            uiErrorMsg = 'Please select at least one candidate.';
            return;
        }

        List<Job_Requisition__c> requisitionList = [SELECT Id,Name FROM Job_Requisition__c WHERE Placement_Type__c = 'Permanent' AND Status__c = 'Open' AND Display_On_Portal__c = true /* limit :list_size 
                                offset :counter */];

        total_size = [select count() FROM Job_Requisition__c WHERE Placement_Type__c = 'Permanent' AND Status__c = 'Open'];
        if(requisitionList.isEmpty()) {
            uiErrorMsg = 'No active Requisitions to broadcast';
            showErrorMsg = true;
            return;
        }
        total_size = requisitionList.size();
        requisitionWrapperList = new List<RequisitionWrapper>();
        for(Job_Requisition__c req : requisitionList) {
            requisitionWrapperList.add(new RequisitionWrapper(req));
        }

    }

    private integer counter=0;  //keeps track of the offset
    private integer list_size=1; //sets the page size or number of rows
    public integer total_size; //used to show user the total size of the list

    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        return null;
    }

    public PageReference Previous() { //user clicked previous button
        counter -= list_size;
        return null;
    }

    public PageReference Next() { //user clicked next button
        counter += list_size;
        return null;
    }

    public PageReference End() { //user clicked end
        counter = total_size - math.mod(total_size, list_size);
        return null;
    }

    public Boolean getDisablePrevious() { 
        //this will disable the previous and beginning buttons
        if (counter>0) return false; else return true;
    }

    public Boolean getDisableNext() { //this will disable the next and end buttons
        if (counter + list_size < total_size) return false; else return true;
    }

    public Integer getTotal_size() {
        return total_size;
    }

    public Integer getPageNumber() {
        return counter/list_size + 1;
    }

    public Integer getTotalPages() {
        if (math.mod(total_size, list_size) > 0) {
            return total_size/list_size + 1;
        } else {
            return (total_size/list_size);
        }
    }


    public PageReference SendEmail()
    {
        //get selected job requisisions:
        String jobsBroadcastLinks = '';
        for(RequisitionWrapper requisitionWrapper: requisitionWrapperList) {
            if(requisitionWrapper.isSelected) {
                jobsBroadcastLinks += JOB_BROADCAST_DOMAIN_URL+'?job_id='+requisitionWrapper.requisition.Id+'<br/>';
            }
        }
        if(String.isBlank(jobsBroadcastLinks)) {
            uiErrorMsg = 'Please select Requisitions to send email.';
            showErrorMsg = true;
            return null;
        }
        String subject = 'Daily/Weekly Job notification';
        // Create a master list to store the emails that we will send
        List<Messaging.SingleEmailMessage> masterListMails = new List<Messaging.SingleEmailMessage>();
        for (Contact candidate : candidatesList)
        {
            String body = 'Hello '+candidate.Name+', <br/> Below are some hot job Openings for you - Please apply from our portal if it fits your skills:<br/>'+jobsBroadcastLinks;
            // Define the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            // Set list of peoples who should recieve an email
            List<String> sendTo = new List<String>();
            sendTo.add(candidate.Email);
            email.setToAddresses(sendTo);
 
            email.setSenderDisplayName('Ondonte');
 
            // Sets the paramaters of the email    
            email.setSubject( subject ); 
            email.setHtmlBody( body );
 
            // Add your email address into the master list
            masterListMails.add(email);
        }
        // Sends mass emails
        Messaging.sendEmail(masterListMails);
        return new PageReference('/003/o');
    }

    public PageReference sendSMS() {

        /* for (Contact candidate : candidatesList) {
            map<String,object> params = new map<String,object>();
            params.put('recordId', candidate.Id);
            params.put('phoneApi', 'Phone');// phone api
            params.put('documentId', '0151h000000tMGm');
            //params.put('phoneNumber', '151680xxxxx');
            params.put('templateId', 'a091h0xxxxxx');
            //params.put('messageText', 'Text message here');
    
            // tdc_tsw.GlobalSmsSender.ownerId = '0051h0xxxxxx';
    
            tdc_tsw.GlobalSmsSender.senderNumber = '15106069379xxxxx'; // when we need to use specific sender number for sms.
            //this method is used to send sms
            tdc_tsw.GlobalSmsSender.sendSmsAndReturnHistory(params);
        } */
        return null;
    }


    public class RequisitionWrapper {
        public Job_Requisition__c requisition {get; set;}
        public Boolean isSelected {get;set;}
        public RequisitionWrapper(Job_Requisition__c requisition) {
            this.requisition = requisition;
            this.isSelected = false;
        }
    }
}