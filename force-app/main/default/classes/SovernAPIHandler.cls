public without sharing class SovernAPIHandler {
    static SovernAPIHandler thisInstance;
    private SovernAPIHandler() {}

    public static SovernAPIHandler getInstance() {
        if(thisInstance == null)
            thisInstance = new SovernAPIHandler();
        return thisInstance;
    }

    
    public string parseResumeAndGetResult(blob attBlob) {
        //TODO: process this attachment and http callout, custom setting hierarchy - serKey and accId, Namedcredentials,
        try{
            SovernAPIDetails__c sovDetails = SovernAPIDetails__c.getOrgDefaults();
            SovernRequestWrapper sWrapper = New SovernRequestWrapper();
            sWrapper.DocumentAsBase64String = EncodingUtil.base64Encode(attBlob);
            sWrapper.DocumentLastModified  = String.valueOf(System.now().dateGmt());
            sWrapper.OutputHtml = false;
            sWrapper.OutputRtf =  false;
            sWrapper.OutputPdf = false;
            sWrapper.OutputCandidateImage = false;
           
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:SovernEndpointURL');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('Sovren-AccountId', sovDetails.Account_ID__c);
            req.setHeader('Sovren-ServiceKey', sovDetails.SaaS_Service_Key__c);
            req.setBody(JSON.serialize(sWrapper));
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());
            System.debug(res.getStatusCode());
            System.JSONParser parser = JSON.createParser(res.getBody());
            string responseBody = res.getBody().replaceAll('Date', 'cdate');
            responseBody = responseBody.replaceAll('Number', 'cNumber');           
            responseBody.replaceAll('\n','').replaceAll('\r','');
            System.debug('responseBody@@@@@---'+responseBody);
            return responseBody;
          //  system.debug(SovernResponeWrapper.parse(responseBody));
          //  return SovernResponeWrapper.parse(responseBody);

        }catch(exception e){
            system.debug(e.getLineNumber()+'----'+e.getMessage());
           // HandleBusinessException.captureError('SovernAPIHandler','parseResumeAndGetResult',e);
            return null;
        }
       
    }

    @future(callout=true)
    public static void processEmailOnboardedCandidate(string attId, string conId){
        SovernResponeWrapper respWrapper = CandidateDashboard_Controller.resumeParser(attId,conId);
        List<Education__c> educationList = New List<Education__c>();
        List<Work_Experience__c> experienceList = New List<Work_Experience__c>();
          for(integer i=0;i<respWrapper.Value.ResumeData.Education.EducationDetails.size();i++){
                Education__c education = New Education__c();
        if(respWrapper.Value.ResumeData.Education.EducationDetails[i].Majors != null)
                        education.Course_Name__c = respWrapper.Value.ResumeData.Education.EducationDetails[i].Majors[0];
                    if(respWrapper.Value.ResumeData.Education.EducationDetails[i].SchoolName != null)
                        education.University_College_Name__c = respWrapper.Value.ResumeData.Education.EducationDetails[i].SchoolName.Normalized;
                    if(respWrapper.Value.ResumeData.Education.EducationDetails[i].LastEducationcdate != null)
                        education.End_Year__c = respWrapper.Value.ResumeData.Education.EducationDetails[i].LastEducationcdate.cdate;
                    education.Candidate__c = conId;
                    educationList.add(education);
                }

                for(integer i=0;i<respWrapper.Value.ResumeData.EmploymentHistory.Positions.size();i++){
                Work_Experience__c experience = New Work_Experience__c();
                    if(respWrapper.Value.ResumeData.EmploymentHistory.Positions[i].Employer != null)
                        experience.Employer_Name__c = respWrapper.Value.ResumeData.EmploymentHistory.Positions[i].Employer.Name.Normalized;
                    if(respWrapper.Value.ResumeData.EmploymentHistory.Positions[i].Employer != null)
                        experience.Name = respWrapper.Value.ResumeData.EmploymentHistory.Positions[i].JobType;
                        experience.Applicant__c = conId;
                    if(respWrapper.Value.ResumeData.EmploymentHistory.Positions[i].Startcdate != null)
                      //  experience.Start_Date__c = respWrapper.Value.ResumeData.EmploymentHistory.Positions[i].Startcdate.cdate;
                    if(respWrapper.Value.ResumeData.EmploymentHistory.Positions[i].Endcdate != null)
                     //   experience.End_date__c = respWrapper.Value.ResumeData.EmploymentHistory.Positions[i].Endcdate.cdate;

                    experienceList.add(experience);
                }    
                if(!educationList.isEmpty())
                    insert educationList;
                if(!experienceList.isEmpty())
                    insert experienceList;

    }
}