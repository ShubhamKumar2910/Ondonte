public class ResumeDetailWrapper {
    public Contact con{get;set;}
        public List<Work_Experience__c> workList{get;set;}
        public List<Education__c> eduList{get;set;}
        public List<Credential__c> credList{get;set;}
    
        public ResumeDetailWrapper(Contact con,List<Work_Experience__c> workList,List<Education__c> eduList,List<Credential__c> credList){
            this.credList=credList;
            this.eduList=eduList;
            this.workList=workList;
            this.con=con;
        }
}