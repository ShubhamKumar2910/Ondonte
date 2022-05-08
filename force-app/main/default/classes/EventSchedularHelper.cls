public class EventSchedularHelper {
    
    @AuraEnabled 
    public Static List<wrapUser> getDaysAndTime(String RecordId){
        RecordId = userinfo.getUserId();        
        Map<String, String> daysWithDate = new Map<String, String>();
        Datetime dt = System.today();
        string currentDt = string.valueOf(dt);
        string currentdayAndTime = currentDt.substring(0,10)+'T'+currentDt.substring(11,13)+':00:00Z';
        string endDayAndTime = currentDt.substring(0,10)+'T'+currentDt.substring(11,13)+':00:00Z';
        system.debug('currentdayAndTime'+currentdayAndTime); 
        
        system.debug('daysWithDate'+daysWithDate);
        USer us = [select firstName,Email,lastName,Name from user where id = :RecordId];
        String name = us.Name;
        String Email = us.Email;
        String ShortName = us.FirstName.substring(0,1) + us.LastName.substring(0,1);
        
        system.debug('name'+name+'ShortName'+ShortName+'daysWithDate'+daysWithDate);
        List<wrapUser> wrapUserList = new List<wrapUser>();
        wrapUserList.add(new wrapUser(currentdayAndTime,name,ShortName,Email));
        
        system.debug('wrapUserList'+wrapUserList);
        return wrapUserList;
    }
    
    
    @AuraEnabled 
    public Static void scheduleMeetingforUser(String startSlot,String endSlot,String description,List<String> secondEmail){
        system.debug('secondEmail'+secondEmail);
        string emails='';
        for(String str:secondEmail){
            emails = str+','+emails;
        }
        emails = emails.removeEnd(',');
        system.debug('emails'+emails);
        String slot = startSlot.substring(11,16) +':' + endSlot.substring(11,16);
        system.debug('slot'+slot);
        
        OutlookIntegration.GenerateEventLink(emails,description,Slot,startSlot.substring(0,10));
    } 
    //method to be called from trigger
    //@future(callout=true)
    public Static void CreateZoomMeetingWithOutlook(DateTime startSlot,DateTime endSlot,String description,String secondEmail,String eventID){
        system.debug('CreateZoomMeetingWithOutlook');
        String slot = String.valueOf(startSlot).substring(11,16) +':' + String.valueOf(endSlot).substring(11,16);
        
        decimal decMinutes = ((endSlot.getTime())/1000/60) - ((startSlot.getTime())/1000/60);
        
        String StartTime = String.valueOf(startSlot).substring(0,10)+'T'+String.valueOf(startSlot).substring(11,19)+'Z';
        
        system.debug('startSlot'+StartTime+'---SLot'+decMinutes);
        //String meetingLink = 
        ZoomApis.createMeeting(description,StartTime,decMinutes,secondEmail,Slot,String.valueOf(startSlot).substring(0,10), eventID);
       //system.debug('meetingLink'+meetingLink);
       /*if(!String.isBlank(ZoomApis.meetingLink)){
            OutlookIntegration.GenerateEventLinkwithoutMeeting(secondEmail,description,Slot,String.valueOf(startSlot).substring(0,10),meetingLink);    
        }else{
            system.debug('Some Proble Occured..');
        }
*/
    }
    
    public class wrapUser {
        @AuraEnabled
        public  String currentdayAndTime {get; set;}
        @AuraEnabled
        public String UserName {get; set;}
        @AuraEnabled
        public String Email {get; set;}
        @AuraEnabled
        public String ShortName {get; set;}
        //This is the contructor method. When we create a new wrapAccount object we pass a Account that is set to the acc property. We also set the selected value to false
        public wrapUser(String currentdayAndTime,String UserName,String ShortName,String Email ) {
            this.currentdayAndTime = currentdayAndTime;
            this.Email = Email;
            this.UserName = UserName;
            this.ShortName = ShortName;
        }
    }
}