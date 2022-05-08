public withOut sharing class RecurringCandidateDashboardController {
   

    public static List<CandidateClientShiftWrapper> getCandidateXclientShifts(string conId, date startdate, date endDate, string jobId){

        List<Shift__c> candidateShift = [select name,id,Start_DateTime__c,End_DateTime__c,End_Time__c,End_Date__c,Start_Date__c,Start_Time__c from Shift__c where Contact__c =:conid AND recordType.Name = 'Candidate' AND Status__c = 'Available' AND Start_DateTime__c >= :startdate AND End_DateTime__c <= :endDate];
    
        Map<date,Shift__c> dateXCandidateShift = New Map<date,Shift__c>();
        for(Shift__c shift:candidateShift){
            dateXCandidateShift.put(shift.Start_Date__c,shift);
        }

        List<Shift__c> clientShift = [select name,id,Start_DateTime__c,End_DateTime__c,End_Time__c,End_Date__c,Start_Date__c,Start_Time__c from Shift__c where Job_Requisition__c =:jobId AND recordType.Name = 'Client' AND Status__c = 'Open' AND Start_DateTime__c >= :startdate AND End_DateTime__c <= :endDate];
    
        List<CandidateClientShiftWrapper> shiftWrapperList = New list<CandidateClientShiftWrapper>();
        for(Shift__c shift:clientShift){
            CandidateClientShiftWrapper shiftWrapper = New CandidateClientShiftWrapper();
            shiftWrapper.clientShift = shift;
            shiftWrapper.shiftDate = shift.Start_Date__c;
            if(dateXCandidateShift.get(shift.Start_Date__c) != null){
                shiftWrapper.candidateShift = dateXCandidateShift.get(shift.Start_Date__c);
                shiftWrapper.matchingPercentage = MatchingAlgorithm.getMatchPercentage(dateXCandidateShift.get(shift.Start_Date__c).Start_DateTime__c, dateXCandidateShift.get(shift.Start_Date__c).End_DateTime__c, shift.Start_DateTime__c , shift.End_DateTime__c);
            }
            shiftWrapperList.add(shiftWrapper);
        }
        return shiftWrapperList;
    }

    @AuraEnabled
    public static Contact getContactById(String id){
        if(!String.isEmpty(id)){
            return [Select Id, Name, Email, Phone,Profile_Picture_URL__c From Contact Where Id=:id];
        }else{
            return null;
        }
    }

    public class CandidateClientShiftWrapper{
        public shift__c clientShift;
        public shift__c candidateShift;
        public double matchingPercentage;
        public date shiftDate;
    }
}