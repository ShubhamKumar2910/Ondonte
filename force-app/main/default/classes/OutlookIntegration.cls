public class OutlookIntegration {
    
    @future(callout=true) 
    public  Static void GenerateEventLink(String Email,String Subject,String Timings,String meetDate){
        system.debug('Timings'+Timings+'meetDate'+meetDate);
        string startTime = Timings.substring(0,2) ;
        String EndeTime = Timings.substring(6,8);
        
        OutlookeventCreatingWrapper newWapper = new OutlookeventCreatingWrapper();
        
        newWapper.subject = Subject;
        
        OutlookeventCreatingWrapper.body bd =new OutlookeventCreatingWrapper.body();
        bd.content = Subject;
        bd.contentType = 'HTML';
        
        OutlookeventCreatingWrapper.start st =new OutlookeventCreatingWrapper.start();
        st.timeZone = 'Pacific Standard Time';
        st.dateTimes = meetDate+'T'+startTime+':00:00';//'2019-03-15T14:00:00';
        
        OutlookeventCreatingWrapper.location nt = new OutlookeventCreatingWrapper.location();
        nt.displayName = 'Utilitarianlab Office';
        
        OutlookeventCreatingWrapper.ends ed =new OutlookeventCreatingWrapper.ends();
        ed.timeZone = 'Pacific Standard Time';
        ed.dateTimes = meetDate+'T'+EndeTime+':00:00';//'2019-03-15T15:00:00';
        
        List<OutlookeventCreatingWrapper.attendees> attList = new List<OutlookeventCreatingWrapper.attendees>();
        
        List<String> EmailList = new List<String>();
        
        if (Email!='' && Email!=null){
            EmailList = Email.split(',', 0);
        }
        map<string,String> Emailbyname = new map<string,String>();
        
        List<Contact> Conlist= [select id,name,Email from contact where email in:EmailList];
        
        for(Contact con : Conlist){
            Emailbyname.put(con.name,con.Email);
        }
        
        system.debug('Emailbyname'+Emailbyname);
        
        for(String abc: Emailbyname.keyset()){
            OutlookeventCreatingWrapper.emailAddress ea = new OutlookeventCreatingWrapper.emailAddress();
            ea.address = Emailbyname.get(abc);
            ea.name = abc;
            OutlookeventCreatingWrapper.attendees att  = new OutlookeventCreatingWrapper.attendees();
            att.emailAddress = ea;
            att.type = 'required';
            attList.add(att);
        }
        
        /*OutlookeventCreatingWrapper.emailAddress ea = new OutlookeventCreatingWrapper.emailAddress();
        ea.address = 'kshubham.skr29@gmail.com';
        ea.name = 'Shubham Kumar';
        
        OutlookeventCreatingWrapper.attendees att  = new OutlookeventCreatingWrapper.attendees();
        att.emailAddress = ea;
        att.type = 'required';
        
        attList.add(att);*/
        
        newWapper.body = bd;
        newWapper.start = st;
        newWapper.ends = ed;
        newWapper.location = nt;
        newWapper.attendees = attList;
        
        newWapper.allowNewTimeProposals = true;
        newWapper.isOnlineMeeting = true;
        newWapper.onlineMeetingProvider = 'teamsForBusiness';
        Integer randomNumber = Integer.valueof((Math.random() * 10));
        newWapper.transactionId = '7E'+randomNumber+'3156-7756-4BEB-A1C6-729EA807'+randomNumber+'A7';
        //newWapper.transactionId = '7E163156-7756-4BEB-A1C6-729EA81721A7';
        
        string jsonString = JSON.serialize(newWapper);
        
        jsonString = jsonString.replace('ends','end');
        jsonString = jsonString.replace('dateTimes','dateTime');
        
        System.debug('jsonString >>'+jsonString); 
        
        String eventLink = OutlookIntegration.createevent(jsonString);
        
        System.debug('eventLink >>'+eventLink);
    }
    
    @future(callout=true) 
    public  Static void GenerateEventLinkwithoutMeeting(String Email,String Subject,String Timings,String meetDate,String ZoomMeetingLink){
        system.debug('Timings'+Timings+'meetDate'+meetDate);
        string startTime = Timings.substring(0,2) ;
        String EndeTime = Timings.substring(6,8);
        
        OutlookeventCreatingWrapper newWapper = new OutlookeventCreatingWrapper();
        
        newWapper.subject = Subject;
        
        OutlookeventCreatingWrapper.body bd =new OutlookeventCreatingWrapper.body();
        bd.content = Subject+'Kindly join the zoom meeting using the link below :: '+ZoomMeetingLink;
        bd.contentType = 'HTML';
        
        OutlookeventCreatingWrapper.start st =new OutlookeventCreatingWrapper.start();
        st.timeZone = 'Pacific Standard Time';
        st.dateTimes = meetDate+'T'+startTime+':00:00';//'2019-03-15T14:00:00';
        
        OutlookeventCreatingWrapper.location nt = new OutlookeventCreatingWrapper.location();
        nt.displayName = 'Utilitarianlab Office';
        
        OutlookeventCreatingWrapper.ends ed =new OutlookeventCreatingWrapper.ends();
        ed.timeZone = 'Pacific Standard Time';
        ed.dateTimes = meetDate+'T'+EndeTime+':00:00';//'2019-03-15T15:00:00';
        
        List<OutlookeventCreatingWrapper.attendees> attList = new List<OutlookeventCreatingWrapper.attendees>();
        
        OutlookeventCreatingWrapper.emailAddress ea = new OutlookeventCreatingWrapper.emailAddress();
        ea.address = Email;
        ea.name = 'Shubham Kumar';
        
        OutlookeventCreatingWrapper.attendees att  = new OutlookeventCreatingWrapper.attendees();
        att.emailAddress = ea;
        att.type = 'required';
        
        attList.add(att);
        
        newWapper.body = bd;
        newWapper.start = st;
        newWapper.ends = ed;
        newWapper.location = nt;
        newWapper.attendees = attList;
        
        newWapper.allowNewTimeProposals = true;
        //newWapper.isOnlineMeeting = true;
        //newWapper.onlineMeetingProvider = 'teamsForBusiness';
        Integer randomNumber = Integer.valueof((Math.random() * 10));
        newWapper.transactionId = '7E'+randomNumber+'3156-77'+randomNumber+'-4BEB-A1C6-7'+randomNumber+'EA807'+randomNumber+'A7';
        //newWapper.transactionId = '7E163156-7756-4BEB-A1C6-729EA817'+randomNumber+'A7';
        //newWapper.transactionId = '7E163156-7756-4BEB-A1C6-729EA81021A7';
        
        string jsonString = JSON.serialize(newWapper);
        
        jsonString = jsonString.replace('ends','end');
        jsonString = jsonString.replace('dateTimes','dateTime');
        
        System.debug('jsonString >>'+jsonString); 
        
        String eventLink = OutlookIntegration.createevent(jsonString);
        
        System.debug('eventLink >>'+eventLink);
    }
    
    public static String createevent(String jasonString) {
        System.debug('jason>>'+jasonString);
        
        String endPoint = 'https://graph.microsoft.com/v1.0/me/events';
        String accToken = OutlookIntegration.generateAcessToken();
        // String accToken = 'eyJ0eXAiOiJKV1QiLCJub25jZSI6IlU0aURId3FOQVh2WWlYMGtESHJGZGVySXFFdVJjLXdwdGY4cFpha2xZRGciLCJhbGciOiJSUzI1NiIsIng1dCI6Imwzc1EtNTBjQ0g0eEJWWkxIVEd3blNSNzY4MCIsImtpZCI6Imwzc1EtNTBjQ0g0eEJWWkxIVEd3blNSNzY4MCJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC85ZDk0Y2IyZi0wNWNlLTRhYzMtOTZhMC04YThhOTc0MzdkMmEvIiwiaWF0IjoxNjMyMzA1NDMxLCJuYmYiOjE2MzIzMDU0MzEsImV4cCI6MTYzMjMwOTMzMSwiYWNjdCI6MCwiYWNyIjoiMSIsImFpbyI6IkFTUUEyLzhUQUFBQXZYT09aTUoyaXJlZUxzaHZoYm5qazNVTFNxZUp5M2FTdG0rSUNmbnYrak09IiwiYW1yIjpbInB3ZCJdLCJhcHBfZGlzcGxheW5hbWUiOiJVdGlsIHNmZGMiLCJhcHBpZCI6ImY4ZGU5ZjZjLTA0MTItNGZhNi04NDc2LTg0NThkMzIwMmU5NyIsImFwcGlkYWNyIjoiMSIsImZhbWlseV9uYW1lIjoiS3VtYXIiLCJnaXZlbl9uYW1lIjoiQWplZXQiLCJpZHR5cCI6InVzZXIiLCJpcGFkZHIiOiIxMy4xMDguMjM4LjgiLCJuYW1lIjoiQWplZXQgS3VtYXIiLCJvaWQiOiI3Y2UzNWE1ZS02ODVlLTQ0OTMtYjMxNi0xNjA4OTFkZmFhNzQiLCJwbGF0ZiI6IjE0IiwicHVpZCI6IjEwMDMyMDAwOTE3OUU1QjIiLCJyaCI6IjAuQVVrQUw4dVVuYzRGdzBxV29JcUtsME45S215ZjN2Z1NCS1pQaEhhRVdOTWdMcGRKQVBnLiIsInNjcCI6IkFkbWluaXN0cmF0aXZlVW5pdC5SZWFkLkFsbCBBZG1pbmlzdHJhdGl2ZVVuaXQuUmVhZFdyaXRlLkFsbCBBZ3JlZW1lbnRBY2NlcHRhbmNlLlJlYWQuQWxsIEFQSUNvbm5lY3RvcnMuUmVhZC5BbGwgQVBJQ29ubmVjdG9ycy5SZWFkV3JpdGUuQWxsIEFwcENhdGFsb2cuUmVhZFdyaXRlLkFsbCBBcHBsaWNhdGlvbi5SZWFkLkFsbCBBcHBsaWNhdGlvbi5SZWFkV3JpdGUuQWxsIEFwcFJvbGVBc3NpZ25tZW50LlJlYWRXcml0ZS5BbGwgQXBwcm92YWwuUmVhZFdyaXRlLkFsbCBBcHByb3ZhbFJlcXVlc3QuUmVhZC5BZG1pbkNvbnNlbnRSZXF1ZXN0IEFwcHJvdmFsUmVxdWVzdC5SZWFkLkN1c3RvbWVyTG9ja2JveCBBcHByb3ZhbFJlcXVlc3QuUmVhZC5FbnRpdGxlbWVudE1hbmFnZW1lbnQgQXBwcm92YWxSZXF1ZXN0LlJlYWQuUHJpdmlsaWdlZEFjY2VzcyBBcHByb3ZhbFJlcXVlc3QuUmVhZFdyaXRlLkN1c3RvbWVyTG9ja2JveCBBcHByb3ZhbFJlcXVlc3QuUmVhZFdyaXRlLkVudGl0bGVtZW50TWFuYWdlbWVudCBBcHByb3ZhbFJlcXVlc3QuUmVhZFdyaXRlLlByaXZpbGlnZWRBY2Nlc3MgQml0bG9ja2VyS2V5LlJlYWRCYXNpYy5BbGwgQ2FsZW5kYXJzLlJlYWQgQ2FsZW5kYXJzLlJlYWQuU2hhcmVkIENhbGVuZGFycy5SZWFkV3JpdGUgQ2FsZW5kYXJzLlJlYWRXcml0ZS5TaGFyZWQgQ2hhdE1lbWJlci5SZWFkV3JpdGUgQ29uc2VudFJlcXVlc3QuUmVhZC5BbGwgQ29uc2VudFJlcXVlc3QuUmVhZFdyaXRlLkFsbCBDdXN0b21TZWNBdHRyaWJ1dGVBc3NpZ25tZW50LlJlYWRXcml0ZS5BbGwgQ3VzdG9tU2VjQXR0cmlidXRlRGVmaW5pdGlvbi5SZWFkV3JpdGUuQWxsIERhdGFMb3NzUHJldmVudGlvblBvbGljeS5FdmFsdWF0ZSBEZWxlZ2F0ZWRQZXJtaXNzaW9uR3JhbnQuUmVhZFdyaXRlLkFsbCBEZXZpY2UuUmVhZC5BbGwgRGV2aWNlTWFuYWdlbWVudEFwcHMuUmVhZC5BbGwgRGV2aWNlTWFuYWdlbWVudEFwcHMuUmVhZFdyaXRlLkFsbCBEZXZpY2VNYW5hZ2VtZW50Q29uZmlndXJhdGlvbi5SZWFkLkFsbCBEZXZpY2VNYW5hZ2VtZW50Q29uZmlndXJhdGlvbi5SZWFkV3JpdGUuQWxsIERldmljZU1hbmFnZW1lbnRNYW5hZ2VkRGV2aWNlcy5Qcml2aWxlZ2VkT3BlcmF0aW9ucy5BbGwgRGV2aWNlTWFuYWdlbWVudE1hbmFnZWREZXZpY2VzLlJlYWQuQWxsIERldmljZU1hbmFnZW1lbnRNYW5hZ2VkRGV2aWNlcy5SZWFkV3JpdGUuQWxsIERldmljZU1hbmFnZW1lbnRSQkFDLlJlYWQuQWxsIERldmljZU1hbmFnZW1lbnRSQkFDLlJlYWRXcml0ZS5BbGwgRGV2aWNlTWFuYWdlbWVudFNlcnZpY2VDb25maWcuUmVhZC5BbGwgRGV2aWNlTWFuYWdlbWVudFNlcnZpY2VDb25maWcuUmVhZFdyaXRlLkFsbCBEaXJlY3RvcnkuQWNjZXNzQXNVc2VyLkFsbCBEaXJlY3RvcnkuUmVhZC5BbGwgRGlyZWN0b3J5LlJlYWRXcml0ZS5BbGwgRG9tYWluLlJlYWQuQWxsIERvbWFpbi5SZWFkV3JpdGUuQWxsIGVEaXNjb3ZlcnkuUmVhZC5BbGwgZURpc2NvdmVyeS5SZWFkV3JpdGUuQWxsIEVkdUFkbWluaXN0cmF0aW9uLlJlYWRXcml0ZSBFZHVBc3NpZ25tZW50cy5SZWFkIEVkdUFzc2lnbm1lbnRzLlJlYWRCYXNpYyBFZHVBc3NpZ25tZW50cy5SZWFkV3JpdGUgRWR1QXNzaWdubWVudHMuUmVhZFdyaXRlQmFzaWMgRWR1Um9zdGVyLlJlYWQgRWR1Um9zdGVyLlJlYWRCYXNpYyBFZHVSb3N0ZXIuUmVhZFdyaXRlIEVudGl0bGVtZW50TWFuYWdlbWVudC5SZWFkLkFsbCBFbnRpdGxlbWVudE1hbmFnZW1lbnQuUmVhZFdyaXRlLkFsbCBFeHRlcm5hbEl0ZW0uUmVhZC5BbGwgR3JvdXAuUmVhZC5BbGwgR3JvdXAuUmVhZFdyaXRlLkFsbCBHcm91cE1lbWJlci5SZWFkLkFsbCBHcm91cE1lbWJlci5SZWFkV3JpdGUuQWxsIElkZW50aXR5UHJvdmlkZXIuUmVhZC5BbGwgSWRlbnRpdHlQcm92aWRlci5SZWFkV3JpdGUuQWxsIElkZW50aXR5Umlza0V2ZW50LlJlYWQuQWxsIElkZW50aXR5Umlza0V2ZW50LlJlYWRXcml0ZS5BbGwgSWRlbnRpdHlSaXNreVVzZXIuUmVhZC5BbGwgSWRlbnRpdHlSaXNreVVzZXIuUmVhZFdyaXRlLkFsbCBJZGVudGl0eVVzZXJGbG93LlJlYWQuQWxsIElkZW50aXR5VXNlckZsb3cuUmVhZFdyaXRlLkFsbCBNYWlsLlJlYWQgTWFpbC5SZWFkLlNoYXJlZCBNYWlsLlJlYWRCYXNpYyBNYWlsLlJlYWRXcml0ZSBNYWlsLlJlYWRXcml0ZS5TaGFyZWQgTWVtYmVyLlJlYWQuSGlkZGVuIE9uUHJlbWlzZXNQdWJsaXNoaW5nUHJvZmlsZXMuUmVhZFdyaXRlLkFsbCBPcmdhbml6YXRpb24uUmVhZC5BbGwgT3JnYW5pemF0aW9uLlJlYWRXcml0ZS5BbGwgUHJpdmlsZWdlZEFjY2Vzcy5SZWFkLkF6dXJlQUQgUHJpdmlsZWdlZEFjY2Vzcy5SZWFkLkF6dXJlQURHcm91cCBQcml2aWxlZ2VkQWNjZXNzLlJlYWQuQXp1cmVSZXNvdXJjZXMgUHJpdmlsZWdlZEFjY2Vzcy5SZWFkV3JpdGUuQXp1cmVBRCBQcml2aWxlZ2VkQWNjZXNzLlJlYWRXcml0ZS5BenVyZUFER3JvdXAgUHJpdmlsZWdlZEFjY2Vzcy5SZWFkV3JpdGUuQXp1cmVSZXNvdXJjZXMgUHJvZ3JhbUNvbnRyb2wuUmVhZC5BbGwgUHJvZ3JhbUNvbnRyb2wuUmVhZFdyaXRlLkFsbCBSZXBvcnRzLlJlYWQuQWxsIFJvbGVNYW5hZ2VtZW50LlJlYWQuQWxsIFJvbGVNYW5hZ2VtZW50LlJlYWQuRGlyZWN0b3J5IFJvbGVNYW5hZ2VtZW50LlJlYWRXcml0ZS5EaXJlY3RvcnkgU2NoZWR1bGUuUmVhZC5BbGwgU2NoZWR1bGUuUmVhZFdyaXRlLkFsbCBTZWN1cml0eUFjdGlvbnMuUmVhZC5BbGwgU2VjdXJpdHlBY3Rpb25zLlJlYWRXcml0ZS5BbGwgU2VjdXJpdHlFdmVudHMuUmVhZC5BbGwgU2Vuc2l0aXZpdHlMYWJlbC5FdmFsdWF0ZSBTZXJ2aWNlSGVhbHRoLlJlYWQuQWxsIFNlcnZpY2VNZXNzYWdlLlJlYWQuQWxsIFNpdGVzLkZ1bGxDb250cm9sLkFsbCBTdWJzY3JpcHRpb24uUmVhZC5BbGwgVGVhbU1lbWJlci5SZWFkV3JpdGVOb25Pd25lclJvbGUuQWxsIFRlYW1zQXBwLlJlYWQuQWxsIFRlYW1zQXBwLlJlYWRXcml0ZS5BbGwgVGVhbXNBcHBJbnN0YWxsYXRpb24uUmVhZEZvclRlYW0gVGVhbXNBcHBJbnN0YWxsYXRpb24uUmVhZFdyaXRlRm9yQ2hhdCBUZWFtc0FwcEluc3RhbGxhdGlvbi5SZWFkV3JpdGVGb3JUZWFtIFRlYW1zQXBwSW5zdGFsbGF0aW9uLlJlYWRXcml0ZUZvclVzZXIgVGVhbXNBcHBJbnN0YWxsYXRpb24uUmVhZFdyaXRlU2VsZkZvckNoYXQgVGVhbXNBcHBJbnN0YWxsYXRpb24uUmVhZFdyaXRlU2VsZkZvclRlYW0gVGVhbVNldHRpbmdzLlJlYWQuQWxsIFRlYW1TZXR0aW5ncy5SZWFkV3JpdGUuQWxsIFRlYW1zVGFiLkNyZWF0ZSBUZWFtc1RhYi5SZWFkLkFsbCBUZWFtc1RhYi5SZWFkV3JpdGUuQWxsIFRlYW1zVGFiLlJlYWRXcml0ZUZvckNoYXQgVGVhbXNUYWIuUmVhZFdyaXRlRm9yVGVhbSBUZXJtU3RvcmUuUmVhZC5BbGwgVGVybVN0b3JlLlJlYWRXcml0ZS5BbGwgVGhyZWF0QXNzZXNzbWVudC5SZWFkV3JpdGUuQWxsIFRocmVhdEluZGljYXRvcnMuUmVhZC5BbGwgVGhyZWF0SW5kaWNhdG9ycy5SZWFkV3JpdGUuT3duZWRCeSBUcnVzdEZyYW1ld29ya0tleVNldC5SZWFkLkFsbCBVc2VyLkV4cG9ydC5BbGwgVXNlci5JbnZpdGUuQWxsIFVzZXIuTWFuYWdlSWRlbnRpdGllcy5BbGwgVXNlci5SZWFkIFVzZXIuUmVhZC5BbGwgVXNlci5SZWFkQmFzaWMuQWxsIFVzZXIuUmVhZFdyaXRlIFVzZXJBdXRoZW50aWNhdGlvbk1ldGhvZC5SZWFkIFVzZXJBdXRoZW50aWNhdGlvbk1ldGhvZC5SZWFkLkFsbCBVc2VyQXV0aGVudGljYXRpb25NZXRob2QuUmVhZFdyaXRlIiwic3ViIjoiYXowdk8wN1JhY3lBMXNPUnlNdmxYazhrczJuRUN0aWprN2dsYlNTWEduOCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJBUyIsInRpZCI6IjlkOTRjYjJmLTA1Y2UtNGFjMy05NmEwLThhOGE5NzQzN2QyYSIsInVuaXF1ZV9uYW1lIjoiYWplZXQua3VtYXJAdXRpbGl0YXJpYW5MYWIuY29tIiwidXBuIjoiYWplZXQua3VtYXJAdXRpbGl0YXJpYW5MYWIuY29tIiwidXRpIjoiNUtSUVBtQTcxMDJCci05RS02LTNBQSIsInZlciI6IjEuMCIsIndpZHMiOlsiNjJlOTAzOTQtNjlmNS00MjM3LTkxOTAtMDEyMTc3MTQ1ZTEwIiwiYjc5ZmJmNGQtM2VmOS00Njg5LTgxNDMtNzZiMTk0ZTg1NTA5Il0sInhtc190Y2R0IjoxNTc2NDAxNzYyfQ.mI4MAR4rwAgdP8uMmRZQ7S4udDeWBN3qOh5pduZpsM2UgDfT6tFImWkaLGXb8AKRqpwXJDvXnU0vp6pnFfhrXi3PrK9g-APagfMXvLXGnIJqOino4nNLIo-4iQQMlVELyBgp600qrylDHo_BtR4Htf6ZqVnGIfsOaWHS_KehGDaGIjxmw0pOjaviUVyARp5YK0I6bwT0R_ANjpXnBu2EVEaGN0IlgbIPkHjHyoiAoob_hCn3yAvZBam_wnSdXpUd9oSDPIAETFxFYAf9lzCPtPr6TJFkCDkl9W7KuAYWahOxYvKc1dGfVWgUou89ylRbJiX_jt-TGsEnYvcPJY7nFQ';
        HttpRequest req = new HttpRequest();
        req.setBody(jasonString);
        req.setHeader('Accept', 'application/json');
        req.setMethod('POST');
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'Bearer '+accToken);
        req.setEndpoint(endPoint); 
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if(res.getStatusCode() == 201 || res.getStatusCode() == 200){
            outlookEventResponse respWrapObj = outlookEventResponse.parse(res.getBody());
            System.debug('Meeting Link >>>' +respWrapObj.webLink);
            return respWrapObj.webLink; 
            
        }else{
            System.debug('res fail >>>'+res.getStatusCode()+'body'+res.getBody());
            return 'Fail';
        }
    }
    
    public static String generateAcessToken(){
        String endPoint ;
        String endpointURL = 'https://login.microsoftonline.com/common/oauth2/token';
        String username = 'ajeet.kumar@utilitarianlab.com';
        String password = 'jitu@2018';
        String cliendId = 'f8de9f6c-0412-4fa6-8476-8458d3202e97';
        String clientSecret = 'lSh7Q~CcNcVyJ_ztNxrdPF8Az2NIDb.K1Cdud';
        String resource = 'https://graph.microsoft.com';
        String authorization_code ;
        endPoint = endpointURL ;
        String Body = 'username='+username+'&password='+password+'&grant_type=password'+'&client_id='+cliendId+'&client_secret='+clientSecret+'&resource='+resource;
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endPoint);
        request.setBody(Body);
        Http http = new Http();
        HTTPResponse res;
        
        try{
            res = http.send(request);   
            JsonParser respWrapObj = JsonParser.parse(res.getBody());
            system.debug('access----token'+respWrapObj.access_token);
            //return respWrapObj.code; 
            return respWrapObj.access_token;
        }catch(Exception e){
            system.debug('exception::'+e.getMessage()+e.getLineNumber());
            return 'Success';
        }
    } 
    
}