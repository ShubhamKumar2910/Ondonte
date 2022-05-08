public class UserDocumentBatch implements Database.Batchable <Sobject>, Database.Stateful {
    
    List<String> expiredConList = new List<String>();
    List<String> rejectedConList = new List<String>();
    List<String> pendingConList = new List<String>();
    
    public Database.QueryLocator Start(Database.BatchableContext bc){
        String var = 'SELECT Name, Contact__r.Id,Contact__r.Email,Rejected_Date__c,Document_Expiry_Date__c,Status__c,CreatedDate FROM User_Document__c';
        return Database.getQueryLocator(var);
    }
    public void Execute(Database.BatchableContext bc, List<User_Document__c> udList){
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        Map<String,String> emailTempIdByTempName = new Map<String, String>();
        List<String> emailTempName = new List<String>{'Expiration Date Over','Rejected Mail','Pending Template'};
        List<EmailTemplate> TempList =[SELECT Id,Name FROM EmailTemplate WHERE Name IN :emailTempName ];

      
        try{
            if(!TempList.isEmpty()){
                for(EmailTemplate tempRec : TempList) {
                    emailTempIdByTempName.put(tempRec.Name, tempRec.Id);
                }   
            }

            for(User_Document__c UD : udList){
            // Expire Date Email
                System.debug('UDList--->'+UD);
                if(UD.Document_Expiry_Date__c !=null && UD.Document_Expiry_Date__c.isSameDay(System.today())){
                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                    mailTemp.setTemplateId(emailTempIdByTempName.get('Expiration Date Over'));
                    mailTemp.setTargetObjectId(UD.Contact__r.Id);
                    mailList.add(mailTemp);
                    System.debug('CONTACT_EXPIRED'+UD.Contact__c);
                    expiredConList.add(UD.Contact__r.Id);
                }

            // Rejected Mail
                if( UD.Status__c == 'Rejected' && UD.Rejected_Date__c.isSameDay(System.today().addDays(-7))){
                    System.debug('Status ---> '+UD.Status__c +' '+UD.Rejected_Date__c);
                    Messaging.SingleEmailMessage mailTemp1 = new Messaging.SingleEmailMessage();
                    mailTemp1.setTemplateId(emailTempIdByTempName.get('Rejected Mail'));
                    mailTemp1.setTargetObjectId(UD.Contact__r.Id);
                    mailList.add(mailTemp1);
                    System.debug('CONTACT_REJECTED'+UD.Contact__r.Id);
                    rejectedConList.add(UD.Contact__c);
                }
                
                // Pending Template
                if(UD.Status__c == 'Pending' && UD.CreatedDate.isSameDay(System.today())){
                    System.debug('Status::'+UD.Status__c +' CreatedDate::'+UD.CreatedDate);
                    Messaging.SingleEmailMessage mailTemp2 = new Messaging.SingleEmailMessage();
                    mailTemp2.setTemplateId(emailTempIdByTempName.get('Pending Template'));
                    mailTemp2.setTargetObjectId(UD.Contact__r.Id);
                    mailList.add(mailTemp2);
                    System.debug('CONTACT_PENDING'+UD.Contact__r.Id);
                    pendingConList.add(UD.Contact__c);
                }

            }

            if(!mailList.isEmpty()){
                Messaging.sendEmail(mailList);
            }
          
        }
        catch(Exception e){
            System.debug('The Error is '+e.getMessage());      
        }
        
    }
    public void Finish(Database.BatchableContext bc){
        
        if(!expiredConList.isEmpty()){
            String templateId = 'a0f3N0000021P3mQAE';
            Database.executeBatch(new SendSMSBatch(expiredConList,templateId,'Contact'));
        }
        if(!rejectedConList.isEmpty()){
            String templateId = 'a0f3N0000021P3wQAE'; 
            Database.executeBatch(new SendSMSBatch(rejectedConList,templateId,'Contact'));
        }
        if(!pendingConList.isEmpty()){
            String templateId = 'a0f3N0000021P3rQAE';
            Database.executeBatch(new SendSMSBatch(pendingConList,templateId,'Contact'));
        }

    }
}