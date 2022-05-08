global class SenderResumeToClient {
    @InvocableMethod(label='Send Resume To Client' description='Method will be called from Flow to Send Resume of candidates to Client')
    public static void sendResume(List<Id> jobApplicationId){
        system.debug('jobApplicationId'+jobApplicationId);
        
        List<Job_Application__c> jobApplicationList = new List<Job_Application__c>();
        Map<string, List<String>> listofCandidateIdByClientid = new Map<String, List<String>>();

        if(!jobApplicationId.isEmpty()){
            jobApplicationList = [Select Job_Requisition__r.Client__r.Account_Email__c,Job_Requisition__r.Client__c,Contact__c From  Job_Application__c where id In : jobApplicationId ];
            if(!jobApplicationList.isEmpty()){
                for(Job_Application__c jobApplicationRec : jobApplicationList){
                    if(listofCandidateIdByClientid.containsKey(jobApplicationRec.Job_Requisition__r.Client__c)){
                        listofCandidateIdByClientid.get(jobApplicationRec.Job_Requisition__r.Client__c).add(jobApplicationRec.Contact__c);
                    }
                    else{
                        listofCandidateIdByClientid.put(jobApplicationRec.Job_Requisition__r.Client__c, new List<String>{jobApplicationRec.Contact__c});
                    }
                }
            }
            system.debug('listofCandidateIdByClientid>>'+listofCandidateIdByClientid)  ;          
            if(!listofCandidateIdByClientid.isEmpty()){
                for(String clientId : listofCandidateIdByClientid.keyset()){
                  GenerateResumeController.sendResumeToClientFromApplication(listofCandidateIdByClientid.get(clientId), clientId, 'Final Candidate Notification');
                }
            }
        }
    }
}