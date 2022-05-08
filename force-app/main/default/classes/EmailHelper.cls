public with sharing class EmailHelper {
    //Send email to candidates if status of shift is changed to allocated
    public static void notifyCandidatesForShift(Set<Id> candidateIds,Map<String, String> clientNameByCandidateId, Map<String, Shift__c> shiftByCandidateId) {
        try{
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<Contact> candidatesListToBeNotified = new LIst<Contact>();
            List<String> recipients = new List<String>();
            EmailTemplate emailTempRec = [Select id, Name, DeveloperName, Subject, Body, HtmlValue from EmailTemplate where name =: Constants.emailTempNameToNotifyCandidateOnShiftChange limit 1];
    
            if(!candidateIds.isEmpty()){
                candidatesListToBeNotified = [Select Id,Name,Email From Contact where Id in : candidateIds];
                if(!candidatesListToBeNotified.isEmpty()){
                    for(Contact conRec  : candidatesListToBeNotified){
                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        recipients.add(conRec.Email);
                        mail.setToAddresses(recipients);
                        mail.setReplyTo('ondonte@mailinator.com');
                        mail.setSenderDisplayName('Ondonte');
                        String subject = emailTempRec.Subject;
                        String htmlBody = emailTempRec.HtmlValue;
                        htmlBody = htmlBody.replace('{!Contact.Name}', conRec.Name);
                        htmlBody = htmlBody.replace('{!Account.Name}', clientNameByCandidateId.get(conRec.Id));      
                        htmlBody = htmlBody.replace('{!Shift.StartTime}', String.valueOf(shiftByCandidateId.get(conRec.Id).Start_DateTime__c));      
                        htmlBody = htmlBody.replace('{!Shift.EndTime}', String.valueOf(shiftByCandidateId.get(conRec.Id).End_DateTime__c));       
                        mail.setSubject(subject);
                        mail.setHtmlBody(htmlBody);
                        mails.add(mail);
                    }
                    system.debug('mails::'+mails);
                        if(!mails.isEmpty()){
                            system.debug('Sending Email');
                            Messaging.sendEmail(mails);
                        }
                }
            }
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage());
            system.debug('Error@@==>'+ex.getLineNumber());
        }
        
        
    }

     //Send email to Clients if status of shift is changed to allocated
     public static void notifyClientsForShift(Map<string,List<Shift__C>> shiftsByClientId) {
        try{
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTempRec = [Select id, Name, DeveloperName, Subject, Body, HtmlValue from EmailTemplate where name =: Constants.emailTempNameToNotifyClientOnShiftChange limit 1];

            if(!shiftsByClientId.isEmpty()){
                for(String clientRec  : shiftsByClientId.keySet()){
                    List<String> recipients = new List<String>();
                    String candidatesAssigned = '' ;
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    recipients.add(shiftsByClientId.get(clientRec)[0].Job_Requisition__r.Client__r.Account_Email__c);
                
                        mail.setToAddresses(recipients);
                        mail.setReplyTo('ondonte@mailinator.com');
                        mail.setSenderDisplayName('Ondonte');
                        String subject = emailTempRec.Subject;
                        String htmlBody = emailTempRec.HtmlValue;
                        htmlBody = htmlBody.replace('{!Account.Name}', shiftsByClientId.get(clientRec)[0].Job_Requisition__r.Client__r.Name);      
                       
                    for(Shift__c shiftRec : shiftsByClientId.get(clientRec)){
                        
                        candidatesAssigned += shiftRec.Contact__r.Name+', ';
                        
                    }
                    candidatesAssigned = candidatesAssigned.removeEnd(', ');
                    htmlBody = htmlBody.replace('{!Candidate.Name}', candidatesAssigned);       
                    mail.setSubject(subject);
                    mail.setHtmlBody(htmlBody);
                    mails.add(mail);
                    system.debug('mails::'+mails);
                }
                if(!mails.isEmpty()){
                    system.debug('Sending Email');
                    Messaging.sendEmail(mails);
                }
            }
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage());
            system.debug('Error@@==>'+ex.getLineNumber());
        }
        
    }
}