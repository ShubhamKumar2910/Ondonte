/**
 * Author: DeaGle
 */
global without sharing class CandidateOnboardingEmailServiceHandler implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        System.debug('--- email'+email);
        System.debug('--- envelope'+envelope);

        String myPlainText= '';
        // Add the email plain text into the local variable 
        myPlainText = email.plainTextBody;

        try {
            List<Contact> vConList = [SELECT Id, Name, Email FROM Contact WHERE Email = :email.fromAddress LIMIT 1];
            if(!vConList.isEmpty()) {
                System.debug('--- existing candidate');
                return result;
            }
            //Otherwise
            Contact newCandidate = new Contact(LastName = email.fromName != null ? email.fromName : 'NO_NAME', Email = email.fromAddress, Candidate_Source__c = 'Email');
            insert newCandidate;
            System.debug('--- text attach'+ email.textAttachments);
            
            
            if(email.binaryAttachments != null && !email.binaryAttachments.isEmpty()) {
                //reading only first file, expecting it to be resume always
                String ext = '.' + email.binaryAttachments[0].fileName.substringAfterLast('.');
                System.debug('--- file extention'+ ext);
                if(!String.isEmpty(ext)) {
                    this.insertResumeHelper(newCandidate.Id, ext, email.binaryAttachments[0].body);
                }
            }
            //SovernAPIHandler.parseResumeAndGetResult(blob);
        }catch(Exception e) {
            HandleBusinessException.captureError('CandidateOnboardingEmailServiceHandler', 'handleInboundEmail', e);
        }
        return result;
    }

    private void insertResumeHelper(Id candidateID, String fileExt, Blob fileBlob) {
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = 'candidate_resume'+fileExt; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'candidate_resume'; // Display name of the files
        conVer.VersionData = fileBlob; // converting your binary string to Blog
        insert conVer;    //Insert ContentVersion

        // First get the Content Document Id from ContentVersion Object
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = candidateID; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDocId;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;

        System.debug('--- calling API with candidate '+ candidateID + ' and att '+ conVer.Id);
        //call future method here to process sovern
        SovernAPIHandler.processEmailOnboardedCandidate(conVer.Id, candidateID);
        
    }
}