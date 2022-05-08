Global without sharing class Utility {
    @AuraEnabled(Cacheable = true)
    public static List<String> getPicklistValues(String ObjectApi_name,String Field_name){ 
        
        List<String> lstPickvals                        = new List<String>();
        Schema.SObjectType targetType                   = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name                             = targetType.newSObject();
        Schema.sObjectType sobject_type                 = Object_name.getSObjectType(); 
        Schema.DescribeSObjectResult sobject_describe   = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map      = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values     = field_map.get(Field_name).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry a : pick_list_values) {
            
            lstPickvals.add(String.ValueOf(a.getLabel()).trim());  
        }
        return lstPickvals;
    }
    
    public static String generateRandomString(){
        Integer len = 10;
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr+string.ValueOf(system.now().getTime()); 
    }
    
    
    public static string sendEmailWithTemplate(string targetRecordId, String templateId){
        try{
            List<Account> accRecordList = new List<Account>();
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> recipients = new List<String>();
            
            EmailTemplate et=[Select id, Name, DeveloperName, Subject, Body, HtmlValue from EmailTemplate where Id =: templateId limit 1];
            accRecordList = [Select Id,Name,Account_Email__c From Account Where Id =: targetRecordId limit 1];
            system.debug('et::'+et);
            system.debug('accRecordList::'+accRecordList);
            recipients.add(accRecordList[0].Account_Email__c);
            
            mail.setToAddresses(recipients);
            mail.setReplyTo('ondonte@mailinator.com');
            mail.setSenderDisplayName('Ondonte');
            String subject = et.Subject;
            String htmlBody = et.HtmlValue;
            htmlBody = htmlBody.replace('{!Account.Name}', accRecordList[0].Name);
            htmlBody = htmlBody.replace('{!Account.Id}', accRecordList[0].Id);       
            mail.setSubject(subject);
            mail.setHtmlBody(htmlBody);
            mails.add(mail);
            system.debug('mails::'+mails);
            if(!mails.isEmpty()){
                system.debug('Sending Email');
                Messaging.sendEmail(mails);
            }
            return Constants.TEMP_URL_SENT_CONFIRMATION;
            
        }catch(Exception ex){
            system.debug('e==='+ex);
            return Constants.ERROR_MSG;
        }
    }
    
    public static void sendWelcomeEmailWithTemplate(string targetRecordId, String templateId){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();            
        mail.setTargetObjectId(targetRecordId); 
        List<OrgWideEmailAddress> owa = new List<OrgWideEmailAddress>();
        owa =[select id,displayName,Address from OrgWideEmailAddress Limit 1];
        if(owa.size()>0)
            mail.setOrgWideEmailAddressId(owa[0].id);
        else
            mail.setSenderDisplayName('Ondonte');
        
        mail.setTemplateId(templateId); 
        mail.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
    
    
    // @InvocableMethod (label='Send Jobrequisition Form' description='Sends Email' category='Account')
    @auraEnabled
    public static void sendReqForm(string accountId){
        try{
            if(!String.isBlank(accountId)){
               
                List<EmailTemplate> emailTemplateList = [SELECT id FROM EmailTemplate WHERE Developername = 'Job_Requisition_Form'];  
                system.debug('emailTemplateList::'+emailTemplateList);
                system.debug('accountId:'+accountId);
                sendEmailWithTemplate(accountId, emailTemplateList[0].Id);
            }
        }catch(exception ex){
            system.debug('error'+ex.getMessage());
            system.debug('Error::>'+ex.getLineNumber());
        }
        
    }
    
    @auraEnabled
    public static void sendTempReqForm(string jobReqId){
        try{
            System.debug('--- jobReqId'+jobReqId);
            if(!String.isBlank(jobReqId)) {
                List<Job_Requisition__c> tempReqList = [SELECT Id, Client__c, Client__r.Name, Client__r.Id, Client__r.Account_Email__c FROM Job_Requisition__c WHERE Id = :jobReqId AND Client__c != null];
                if(!tempReqList.isEmpty()) {
                    
                    List<EmailTemplate> emailTemplateList = [SELECT id, Subject, htmlValue, body FROM EmailTemplate WHERE Developername = 'Job_Temp_Requisition_Form'];  
                    system.debug('emailTemplateList::'+emailTemplateList);
                    system.debug('accountId:'+tempReqList[0].Client__c);
                    if(!emailTemplateList.isEmpty())
                    	sendTempReqEmail(tempReqList[0].Id,tempReqList[0].Client__r, emailTemplateList[0]);
                }

            }
        }catch(exception ex){
            system.debug('error'+ex.getMessage());
            system.debug('Error::>'+ex.getLineNumber());
        }
        
    }
    
    static void sendTempReqEmail(Id targetObjId, Account client, EmailTemplate et) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> recipients = new List<String>();
        recipients.add(client.Account_Email__c);
        
        mail.setToAddresses(recipients);
        mail.setReplyTo('ondonte@mailinator.com');
        mail.setSenderDisplayName('Ondonte');
        //mail.setTemplateId(et.Id);
        String subject = et.Subject;
        String htmlBody = et.HtmlValue;
        htmlBody = htmlBody.replace('{!Account.Name}', client.Name);
        htmlBody = htmlBody.replace('{!Account.Id}', client.Id);
        htmlBody = htmlBody.replace('{!Job_Requisition__c.Id}', targetObjId);
        mails.add(mail);
        mail.setSubject(subject);
        mail.setHtmlBody(htmlBody);
        mail.setPlainTextBody(et.body);
        system.debug('mails::'+mails);
        if(!mails.isEmpty()){
            system.debug('Sending Email');
            Messaging.sendEmail(mails);
        }
    }
    
    
    public static string returnOndonteUid(String referredConEmail, string referringConId){
        string response;
        system.debug('referredConEmail>>'+referredConEmail);
        system.debug('referringConId>>'+referringConId);
        try{
            List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
            string referalContactInfo;
            if(!String.isBlank(referringConId)){
                referalContactInfo = [Select id,name,Ondonte_UID__c From Contact Where Id =:referringConId limit 1].Ondonte_UID__c;
                system.debug('referalContactInfo>>'+referalContactInfo);
                if(!String.isBlank(referredConEmail) && !String.isBlank(referalContactInfo)){                
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[] {referredConEmail}; 
                        mail.setToAddresses(toAddresses);
                    EmailTemplate emailTempRec = [SELECT Id,subject,htmlvalue from EmailTemplate where developername =: Constants.ReferalEmailTemplate limit 1];
                    if(emailTempRec != null){
                        mail.setSubject(emailTempRec.Subject);
                        String htmlBody = emailTempRec.HtmlValue;
                        htmlBody = htmlBody.replace('{!Contact.Ondonte_UID__c}', referalContactInfo);
                        mail.setHtmlBody(htmlBody);
                        messageList.add(mail);
                        if(!messageList.isEmpty()){
                            Messaging.sendEmail(messageList);
                            response = 'Success';
                        }
                    }
                }
            }else{
                response = 'Referring Contact detail or Referred Email is null';
            }
            
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage());
            system.debug('Error==>'+ex.getLineNumber());
            response = ex.getMessage();
        }
        return response;
    }

    public static Map<string,string> getAllFields(string objName, List<string> skillsToDisplay ){
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        Map<string,string> apiNameXLabel = New Map<string,string>();
        for (String fieldName: fieldMap.keySet()) {
            system.debug('fieldName---------'+fieldName);
            system.debug('skillsToDisplay.contains(fieldName)'+skillsToDisplay.contains(fieldName));
            for(string skill:skillsToDisplay){
                system.debug('skill------'+skill);
                system.debug('fieldName------'+fieldName);
                system.debug(fieldName.equalsIgnoreCase(skill));
                if(fieldName.equalsIgnoreCase(skill)){
                    system.debug('inside If--------');
                    apiNameXLabel.put(fieldName,fieldMap.get(fieldName).getDescribe().getLabel());
                }
            }
            
        }
        return apiNameXLabel;
    }
    
    
    //Anjali
    @auraEnabled
    public static void sendRegistrationForm(string candidateId){
        try{
            System.debug('--- jobReqId'+candidateId);
            if(!String.isBlank(candidateId)) {
                Id myId = Id.valueOf(candidateId);
                String sObjName = myId.getSObjectType().getDescribe().getName();
                system.debug('sObjName---'+sObjName);
                if(sObjName == 'Contact'){
                    contact candidate = New Contact(id=candidateId,Login_Hash_Code__c=generateRandomString());
                    update candidate;
                }
                list<Messaging.SingleEmailMessage> mailList = new list<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();               
                
                EmailTemplate emailTemp = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName= 'Candidate_Requisition_Form'];
                Contact con = [SELECT Id, Email FROM Contact WHERE Id =: candidateId];
                List<String> recipients = new List<String>();
                recipients.add(con.Email);
                
                mail.setToAddresses(recipients);
                
                mail.setTemplateId(emailTemp.Id);
                mail.setTargetObjectId(con.Id);
                mailList.add(mail);
                if(!mailList.isEmpty())
                    Messaging.sendEmail(mailList);
        }
        }catch(exception ex){
            system.debug('error'+ex.getMessage());
            system.debug('Error::>'+ex.getLineNumber());
        }
    }


       @AuraEnabled
    public static string getSMSTemplateId(String templateName){
        try {
            tdc_tsw__Message_Template__c template = [Select Id, Name from tdc_tsw__Message_Template__c Where Name =: templateName];
            return template.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}