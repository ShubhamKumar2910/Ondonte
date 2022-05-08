Public class ZoomApis {
    public String bodyprint{get;set;}
    public String pswrd{get;set;}
    public static String meetingLink{get;set;}
    
    @future(callout=true)
    public  Static void createMeeting(String Subject,String startSlot,Decimal Duration,String Email,String Timings,String meetDate, String eventID) {
        system.debug('createMeeting');
        Zoom_Api__c Zoom_Details = [Select id,Endpoint_URL__c,JWT_Token__c from Zoom_Api__c];
        system.debug('Zoom_Details>>>='+Zoom_Details);
        ZoomApis.createMeetingWapper newWapper = new ZoomApis.createMeetingWapper();
        newWapper.topic = Subject;
        newWapper.type = 2;
        newWapper.start_time = startSlot;//'2021-04-21T16:54:14Z';
        newWapper.duration = integer.valueOf(Duration);
        newWapper.timezone = 'Asia/Kolkata';
        string jsonString = JSON.serialize(newWapper);
        System.debug('jsonString >>'+jsonString); 
        
        String endPoint = Zoom_Details.Endpoint_URL__c;
        HttpRequest req = new HttpRequest();
        req.setBody(jsonString);
        req.setMethod('POST');
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'bearer '+Zoom_Details.JWT_Token__c);
        req.setEndpoint(endPoint); 
        Http http = new Http();
        HttpResponse res = http.send(req);
        system.debug('res.getStatusCode()>>'+res.getStatusCode());
        if(res.getStatusCode() == 201){
            // bodyprint = res.getBody();
            ZoomResponseWrapper respWrapObj = ZoomResponseWrapper.parse(res.getBody());
            //bodyprint = respWrapObj.join_url.substringBefore('?');
            //pswrd = respWrapObj.join_url.substringAfter('?');
            //pswrd = pswrd.replace('pwd=', 'Password : ');
            System.debug('Meeting Link >>>' +respWrapObj.join_url);
            System.debug('res pass >>>' +res.getBody());  
            system.debug('eventID:'+eventID);
            system.debug('respWrapObj.join_url::>'+respWrapObj.join_url);
            ZoomApis.meetingLink = respWrapObj.join_url;
            system.debug('meetingLink::'+meetingLink);
            //OutlookIntegration.GenerateEventLinkwithoutMeeting( Email, Subject, Timings, meetDate, respWrapObj.join_url);
            
         /*   string startTime = Timings.substring(0,2) ;
        String EndeTime = Timings.substring(6,8);
        
        OutlookeventCreatingWrapper newWapperOutlook = new OutlookeventCreatingWrapper();
        
        newWapperOutlook.subject = Subject;
        
        OutlookeventCreatingWrapper.body bd =new OutlookeventCreatingWrapper.body();
        bd.content = Subject+'Kindly join the zoom meeting using the link below :: '+respWrapObj.join_url;
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
        
        newWapperOutlook.body = bd;
        newWapperOutlook.start = st;
        newWapperOutlook.ends = ed;
        newWapperOutlook.location = nt;
        newWapperOutlook.attendees = attList;
        
        newWapperOutlook.allowNewTimeProposals = true;
        //newWapper.isOnlineMeeting = true;
        //newWapper.onlineMeetingProvider = 'teamsForBusiness';
        Integer randomNumber = Integer.valueof((Math.random() * 10));
        newWapperOutlook.transactionId = '7E'+randomNumber+'3156-77'+randomNumber+'-4BEB-A1C6-7'+randomNumber+'EA807'+randomNumber+'A7';
        //newWapper.transactionId = '7E163156-7756-4BEB-A1C6-729EA817'+randomNumber+'A7';
        //newWapper.transactionId = '7E163156-7756-4BEB-A1C6-729EA81021A7';
        
        string jsonStringOutlook = JSON.serialize(newWapperOutlook);
        
        jsonStringOutlook = jsonStringOutlook.replace('ends','end');
        jsonStringOutlook = jsonStringOutlook.replace('dateTimes','dateTime');
        
        System.debug('jsonStringOutlook >>'+jsonStringOutlook); 
        
        String eventLink = OutlookIntegration.createevent(jsonStringOutlook);
        
        System.debug('eventLink >>'+eventLink);
            
            //return respWrapObj.join_url;
        }else{
            System.debug('res fail >>>' +res.getBody());
            //return 'res.getBody()';
        }
        system.debug('meetingLink::'+meetingLink);
*/
        Event eventRecToBeUpdated = new Event();
        eventRecToBeUpdated.Id = eventID;
        eventRecToBeUpdated.Zoom_Invite_Link__c = meetingLink;
        update eventRecToBeUpdated;        
        }
    }
    public class createMeetingWapper{
        Public String topic {get;set;}
        Public Integer type {get;set;}
        Public String start_time {get;set;}
        Public Integer duration {get;set;}
        Public String timezone {get;set;}
        Public String password {get;set;}
    }
}