global class GenerateResumeController {
    public String currentRecordId {get; set;}
    public Contact contactDetails {get; set;}
    public ResumeDetailWrapper rWrapper {get; set;}
    global GenerateResumeController(){
        currentRecordId =  ApexPages.CurrentPage().getparameters().get('id');
        system.debug('currentRecordId===>'+currentRecordId);
        contactDetails = [select Id,FirstName,LastName,Name,Skillset__c,Computer_Skills__c,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,Phone,Email,MobilePhone,
                          (SELECT Name,Candidate__c,Applicant__c,Duration__c,Employer__c,Job_Ttle__c,Start_Date__c,Employer_Name__c,End_date__c,Contact__c FROM Work_Experiences__r), 
                          (SELECT Candidate__c,Course_Description__c,End_Year__c,Course_Name__c, Start_Year__c,University_College_Name__c FROM Educations__r),
                          (SELECT Name,End_Date__c,Start_Date__c,Expiry_Date__c FROM Credentials__r) FROM Contact where id= :currentRecordId];
        rWrapper = New ResumeDetailWrapper(contactDetails,[SELECT Name,Job_Ttle__c,Start_Date__c,End_date__c FROM Work_Experience__c Where Applicant__c =: currentRecordId],
                  [SELECT Course_Name__c,University_College_Name__c,Course_Description__c,End_Year__c,Start_Year__c FROM Education__c Where Candidate__c =: currentRecordId],
                  [SELECT Name FROM Credential__c Where Contact__c =: currentRecordId]);
    
    }
    
    
    public static void sendResumeToClientFromApplication(List<String> candidateIds, String clientId, string emailtempame){
        try{
            List<Contact> candidateList = new List<Contact>();
            Account accRecord  = new Account();
            EmailTemplate emailTempRec= new EmailTemplate();

            candidateList   = [select Id,Name from Contact where id in : candidateIds];
            emailTempRec    = [Select id, Name, DeveloperName, Subject, Body, HtmlValue from EmailTemplate where Name =: emailtempame];
            accRecord       = [Select Id,Name,Account_Email__c From Account Where Id =: clientId limit 1];

            PageReference pdfPage = Page.CandidateResumeVF;
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<Messaging.EmailFileAttachment> attachmentList = new List<Messaging.EmailFileAttachment>();
            List<String> recipients = new List<String>();
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{accRecord.Account_Email__c});
            mail.setReplyTo('ondonte@mailinator.com');
            mail.setSenderDisplayName('Ondonte');
            String subject = emailTempRec.Subject;
            String htmlBody = emailTempRec.HtmlValue;
            htmlBody = htmlBody.replace('{!Account.Name}', accRecord.Name);
            String candidateName = '<ul>';

            if(!candidateList.isEmpty()){
                for(Contact candidateRec : candidateList){
                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                    pdfPage.getParameters().put('id',candidateRec.Id);
                    Blob pdfBlob = pdfPage.getContent(); 
                    attach.setContentType('application/pdf');
                    attach.setFileName('CandidateResume.pdf');
                    attach.setBody(pdfBlob);
                    attachmentList.add(attach);
                    candidateName += '<li>'+candidateRec.Name+'</li>';
                }
            }
            candidateName += '</ul>'; 
            htmlBody = htmlBody.replace('{!Candidate.Name}', candidateName);
            mail.setSubject(subject);
            mail.setHtmlBody(htmlBody);
            mail.setFileAttachments(attachmentList);
            mails.add(mail);
            system.debug('mails::'+mails);
            if(!mails.isEmpty()){
                system.debug('Sending Email');
                Messaging.sendEmail(mails);
            }
        }catch(Exception ex){
            system.debug('e==='+ex);
        }
    }
    public static void sendResumeToClientFromShift(List<String> candidateIds, String clientId, string emailtempame){
        try{
            List<Contact> candidateList = new List<Contact>();
            Account accRecord  = new Account();
            EmailTemplate emailTempRec= new EmailTemplate();

            candidateList   = [select Id,Name from Contact where id in : candidateIds];
            emailTempRec    = [Select id, Name, DeveloperName, Subject, Body, HtmlValue from EmailTemplate where Name =: emailtempame];
            accRecord       = [Select Id,Name,Account_Email__c From Account Where Id =: clientId limit 1];

            PageReference pdfPage = Page.CandidateResumeVF;
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<Messaging.EmailFileAttachment> attachmentList = new List<Messaging.EmailFileAttachment>();
            List<String> recipients = new List<String>();
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{accRecord.Account_Email__c});
            mail.setReplyTo('ondonte@mailinator.com');
            mail.setSenderDisplayName('Ondonte');
            String subject = emailTempRec.Subject;
            String htmlBody = emailTempRec.HtmlValue;
            htmlBody = htmlBody.replace('{!Account.Name}', accRecord.Name);
            String candidateName = '<ul>';

            if(!candidateList.isEmpty()){
                for(Contact candidateRec : candidateList){
                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                    pdfPage.getParameters().put('id',candidateRec.Id);
                    Blob pdfBlob = pdfPage.getContent(); 
                    attach.setContentType('application/pdf');
                    attach.setFileName('CandidateResume.pdf');
                    attach.setBody(pdfBlob);
                    attachmentList.add(attach);
                    candidateName += '<li>'+candidateRec.Name+'</li>';
                }
            }
            candidateName += '</ul>'; 
            htmlBody = htmlBody.replace('{!Candidate.Name}', candidateName);
            mail.setSubject(subject);
            mail.setHtmlBody(htmlBody);
            mail.setFileAttachments(attachmentList);
            mails.add(mail);
            system.debug('mails::'+mails);
            if(!mails.isEmpty()){
                system.debug('Sending Email');
                Messaging.sendEmail(mails);
            }
        }catch(Exception ex){
            system.debug('e==='+ex);
        }
    }
   
}