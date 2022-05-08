global class SenderResumeToClientFromShift {
  @InvocableMethod(label='Send Resume To Client From Shift' description='Method will be called from Flow to Send Resume of candidates to Client')
    public static void sendResume(List<Id> shiftId){
        system.debug('shiftId'+shiftId);
        
        List<Shift__c> shiftList = new List<Shift__c>();
        Map<string, List<String>> listofCandidateIdByClientid = new Map<String, List<String>>();

        if(!shiftId.isEmpty()){
            shiftList = [Select Job_Requisition__r.Client__r.Account_Email__c,Contact__c,Allocated_To__r.Job_Requisition__r.Client__c From  Shift__c where id In : shiftId AND Allocated_To__c != null AND Allocated_To__r.Job_Requisition__c != null];
            if(!shiftList.isEmpty()){
                for(Shift__c shiftRec : shiftList){
                        if(listofCandidateIdByClientid.containsKey(shiftRec.Allocated_To__r.Job_Requisition__r.Client__c)){
                            listofCandidateIdByClientid.get(shiftRec.Allocated_To__r.Job_Requisition__r.Client__c).add(shiftRec.Contact__c);
                        }
                        else{
                            listofCandidateIdByClientid.put(shiftRec.Allocated_To__r.Job_Requisition__r.Client__c, new List<String>{shiftRec.Contact__c});
                        }
                    }
                    if(!listofCandidateIdByClientid.isEmpty()){
                 for(String  clientId : listofCandidateIdByClientid.keyset()){
                    GenerateResumeController.sendResumeToClientFromShift(listofCandidateIdByClientid.get(clientId), clientId, 'Final Candidate Notification');
                }
            }
            }
        }
    }
}