public without sharing class CP_LoginPage_Controller {

    static String code;
    public Boolean isSignUp                 {get;set;}
    public Boolean isLogin                  {get;set;}
    public Boolean isCustomer               {get;set;}
    public Boolean isCandidate              {get;set;}
    public boolean isMentorExist            {get;set;}
    public string  name                     {get;set;}
    public string  FbId                     {get;set;}
    public string  gId                      {get;set;}
    public string  gFname                   {get;set;}
    public string hasCodeUpdate             {get;set;}
    public string Error                     {get;set;}
    public static final String SITE  =      'Login';
    public string currentUserId             {get;set;}
    public string hasCode                   {get;set;}
    public string currentdonorId            {get;set;}
    public Boolean SignupCandidate          {get;set;}
    public Boolean SignupCustomer           {get;set;}
    public Boolean docUplaodCustomer        {get;set;}
    public string isFBcustomerSignup        {get;set;}
    public string isFBcandidateSignup       {get;set;}
    public string selfAssesmentQuestions    {get;set;}
    public string jobFuncList               {get;set;}
    public string asignmentStatusList       {get;set;}
    public string jobShiftTimings           {get;set;}
    public string jobShiftAvailiblity       {get;set;}
    public string industryType              {get;set;}
    public String candidateSiteURL          {get;set;}
    public String candidateHashcode         {get;set;}
    public static String candidateId        {get;set;}
    public string skillList                 {get;set;}
    public string staffList                 {get;set;}
    public String crownPicklistVal          {get;set;}
    public String imgeSoftwarePickVal       {get;set;}
    public string compSkillPickVal          {get;set;}
    public string docCategoryName           {get;set;}

    Public CP_LoginPage_Controller(){
        system.debug('CP_LoginPage_Controller-Google');
        skillList = JSON.serialize(Utility.getPicklistValues('Contact', 'Computer_Skills__c'));
        staffList = JSON.serialize(Utility.getPicklistValues('Contact', 'Staff_Type__c'));
        crownPicklistVal = JSON.serialize(Utility.getPicklistValues('Contact','Types_of_Crowns__c'));
        imgeSoftwarePickVal = JSON.serialize(Utility.getPicklistValues('Contact','Image_X_ray_Software__c'));
        compSkillPickVal = JSON.serialize(Utility.getPicklistValues('Contact','Computer_Skills__c'));
        //PageReference MyNewPage     = Page.redirectProfilePage;
    }

   
    @RemoteAction
    public static contact loginUser(string userName, string password){
        try{
            list<contact> conRec = [select firstName,LastName,id,email,Phone,Login_Hash_Code__c,Candidate_Status__c from contact where email =:userName AND Password__c =:password AND (Candidate_Status__c = 'Active' OR Candidate_Status__c = 'Document Upload') limit 1];
            system.debug('conRec----'+conRec);
            if(conRec.size() > 0 ){
                conRec[0].Login_Hash_Code__c = Utility.generateRandomString();
                update conRec[0];
                return conRec[0];
            }else{
                return null;
            }
        }catch(exception e){
            system.debug(e.getLineNumber()+'---error Message---'+e.getMessage());
            HandleBusinessException.captureError('CandidateDashboard_Helper','loginUser',e);
            return null;
        }

    }

    public PageReference redirectProfilePage(){
        system.debug('redirectProfilePage--');
        code                        = ApexPages.currentPage().getParameters().get('code');
        SignupCandidate            = ApexPages.currentPage().getParameters().get('m') == '2' ? true : false;
        SignupCustomer            = ApexPages.currentPage().getParameters().get('m') == '1' ? true : false;
        isLogin            = ApexPages.currentPage().getParameters().get('m') == '0' ? true : false;
        system.debug('ApexPages.currentPage().getParameters().get--'+ApexPages.currentPage().getParameters().get('m'));
        system.debug('code---'+code+'---SignupCandidate----'+SignupCandidate+'---SignupCustomer----'+SignupCustomer+'---isLogin----'+isLogin);
        Cookie cookieObj            = new Cookie('googleCode', code, null, 100, false);
        Cookie cookieLoginTypeObj   = new Cookie('loginType', 'googleLogin', null, 86400, false);
        Cookie isCandidate              = new Cookie('isSignupCandidate',SignupCandidate == true ? 'true' : 'false', null, 100, false);
        Cookie isCustomer               = new Cookie('isSignupCustomer',SignupCustomer == true ? 'true' : 'false', null, 100, false);
        Cookie isLogin                  = new Cookie('isLogin',isLogin == true ? 'true' : 'false', null, 100, false);
        PageReference MyNewPage     = Page.redirectProfilePage;

        MyNewPage.setCookies(new Cookie[]{cookieObj, cookieLoginTypeObj,isCandidate,isCustomer,isLogin});
        
        MyNewPage.setRedirect(true);
        return MyNewPage;
        
    }

    public void googleAuth(){
        try{
            system.debug('google auth');
            Cookie logType = ApexPages.currentPage().getCookies().get('loginType');
            system.debug('loginid::'+logType);
            system.debug('logType.getValue() -----'+logType.getValue());
            if(logType.getValue()   == 'googleLogin'){
                try{
                    //recordType = '';
                    Cookie candidate = ApexPages.currentPage().getCookies().get('isSignupCandidate');
                    Cookie customer = ApexPages.currentPage().getCookies().get('isSignupCustomer');
                    Cookie Login = ApexPages.currentPage().getCookies().get('isLogin');
                    system.debug('SignupCandidate----'+candidate.getValue());
                    system.debug('SignupCustomer----'+customer.getValue());
                    if(candidate.getValue() == 'True'){
                        SignupCandidate = True;
                        system.debug('SignupCandidate----');
                    }
                    if(customer.getValue() == 'True'){
                        SignupCustomer = True;
                        system.debug('SignupCustomer----');
                    }
                    if(Login.getValue() == 'True'){
                        islogin = True;
                    }
                    system.debug('registrationFromGoogle'); 
                    String authCode ;        
                    System.debug(Apexpages.currentPage().getParameters().get('code'));
                    Cookie lkcode = ApexPages.currentPage().getCookies().get('googleCode');
                    System.debug('CODE'+lkcode);
                    if(lkcode != null){
                        code = lkcode.getValue();
                        Cookie cookiegObj   = new Cookie('googleCode', '', null, 100, false);
                        ApexPages.currentPage().setCookies(new Cookie[]{cookiegObj});
                    }
                    if(String.isBlank(code)){
                        Cookie gSessId = ApexPages.currentPage().getCookies().get('googleSessionId');
                        if(gSessId != null){
                            authCode = gSessId.getValue();
                        }
                    }
                    System.debug('code'+code);
                    if(!String.isBlank(code)){
                        if(candidate.getValue() == 'True'){
                             System.debug('code @ 134');
                            authCode = LoginAuthentication_Helper.getGoogleAuthCode(code,'candidate');
                        }
                        if(customer.getValue() == 'True'){
                            System.debug('code @ 138');
                            authCode = LoginAuthentication_Helper.getGoogleAuthCode(code,'customer');
                        }
                        if(Login.getValue() == 'True'){
                            System.debug('code @ 142');
                            authCode = LoginAuthentication_Helper.getGoogleAuthCode(code,'login');
                        }
                        authCode = LoginAuthentication_Helper.getGoogleAuthCode(code,'login');
                        
                    }
                    System.debug('AUTHCODE'+AUTHCODE);
                    if(!String.isBlank(authCode)){
                        System.debug('AUTHCODE');
                        if(!authCode.equalsIgnoreCase('Error')){
                            GooglePublicDetailsClass.GoogleDetails gResp = LoginAuthentication_Helper.getGoogleEmail(authCode);
                            System.debug('gResp---'+gResp);
                            system.debug('gResp.email===='+gResp.email);
                            if(gResp != null && !String.isBlank(gResp.email)){
                                gId = gResp.email;
                                gFname = gResp.firstName;
                                System.debug('AUTHCODE');
                                try{
                                    list<Contact> currentCandidate    = [Select id,name,Login_Hash_Code__c,Candidate_Status__c from Contact where Email =:gResp.email];
                                    system.debug('currentCandidate------'+currentCandidate);
                                    if(currentCandidate.size() >0){
                                        if(currentCandidate[0].Candidate_Status__c == 'Active'){
                                            currentdonorId          = currentCandidate[0].Id;
                                            Contact contact=new Contact();
                                            contact.Login_Hash_Code__c=FacebookAuthHandler.generateRandomString();
                                            contact.Id=currentdonorId;
                                            hasCode=contact.Login_Hash_Code__c;
                                            system.debug('inside if');
                                            update contact;
                                        }else if(currentCandidate[0].Candidate_Status__c == 'Document Upload'){
                                            docUplaodCustomer = true;
                                            currentdonorId          = currentCandidate[0].Id;
                                            Contact contact=new Contact();
                                            contact.Login_Hash_Code__c=FacebookAuthHandler.generateRandomString();
                                            contact.Id=currentdonorId;
                                            hasCode=contact.Login_Hash_Code__c;
                                            system.debug('inside if');
                                            update contact;
                                            system.debug('docUplaodCustomer---'+docUplaodCustomer);
                                        }
                                       
                                    }else{
                                         /* Contact contact=new Contact();
                                        contact.LastName = gResp.lastName;
                                        contact.FirstName = gResp.firstName;
                                        contact.Email = gResp.email;
                                        contact.Login_Hash_Code__c = FacebookAuthHandler.generateRandomString();
                                        hasCodeUpdate = contact.Login_Hash_Code__c ;
                                        system.debug('inside else');
                                        insert contact;   */
                                        SignupCandidate = true;
                                    }
                                    
                                    System.debug('HASH CODE===>'+contact.Login_Hash_Code__c);
                                    
                                    Cookie cookieObj1 = new Cookie('googleSessionId', authCode, null, 3600, false);
                                    ApexPages.currentPage().setCookies(new Cookie[]{cookieObj1});
                                }catch(Exception e){
                                    system.debug(e.getMessage());
                                }
                            }
                        }
                    }
                    
                }catch(Exception e){
                    system.Debug('linenum------'+e.getLineNumber()+'error-------'+e.getMessage());
                }
            }  
        }catch(exception e){
            system.debug('get line---'+e.getLineNumber()+'--message--'+e.getMessage());
        }
    }

    public PageReference checkUserAuth(){
        isMentorExist=false;
        PageReference pg   = new PageReference('/'); 
        string encStudentId   = Apexpages.currentPage().getParameters().get('encStudentId');
        string hashCode     = Apexpages.currentPage().getParameters().get('d');  
        
        system.debug('hashCode===>'+hashCode + 'enc StudentId====>'+encStudentId);  
        
        if(encStudentId != null){
            currentUserId          = FacebookAuthHandler.decryptString(encStudentId, 'FFE12ORDER34KEY56QWERTY56QAXWSX');
            Cookie cookieEncStudent   = new Cookie('cookieEncStudent', currentUserId, null, 86400, false);
            ApexPages.currentPage().setCookies(new Cookie[]{cookieEncStudent});            
        }
        
        if(hashCode != null){
            Cookie cookiehashCode   = new Cookie('hashCodeLog', currentUserId, null, 1800, false);
            ApexPages.currentPage().setCookies(new Cookie[]{cookiehashCode});
        }
        
        if(currentUserId == null){
            Cookie encStd = ApexPages.currentPage().getCookies().get('cookieEncStudent');
            system.debug('encStd==>'+encStd);
            if(encStd != null) currentUserId = encStd.getValue();
            if(currentUserId != null){
                Cookie cookieEncDonor   = new Cookie('cookieEncStudent', currentUserId, null, 86400, false);
                ApexPages.currentPage().setCookies(new Cookie[]{cookieEncDonor}); 
            }            
        }
        
        
        if(currentUserId == null){
            Cookie chashcode = ApexPages.currentPage().getCookies().get('hashCodeLog');
            if(chashcode != null) currentUserId    = chashcode.getValue();
            if(currentUserId != null){
                Cookie cookiehashCode   = new Cookie('hashCodeLog', currentUserId, null, 1800, false);
                ApexPages.currentPage().setCookies(new Cookie[]{cookiehashCode});
            }          
        }
        System.debug('currentUserId'+currentUserId);
        if(currentUserId == null || currentUserId==''){
            Cookie logType = ApexPages.currentPage().getCookies().get('loginType');
            system.debug('loginid::'+logType);
            system.debug('logType.getValue() -----'+logType.getValue());
            if(logType != null){
                if(logType.getValue()   == 'googleLogin'){
                    try{
                        Cookie candidate = ApexPages.currentPage().getCookies().get('isSignupCandidate');
                        Cookie customer = ApexPages.currentPage().getCookies().get('isSignupCustomer');
                        system.debug('SignupCandidate----'+candidate.getValue());
                        system.debug('SignupCustomer----'+customer.getValue());
                        if(candidate.getValue() == 'True'){
                            SignupCandidate = True;
                            system.debug('SignupCandidate----');
                        }
                        if(customer.getValue() == 'True'){
                            SignupCustomer = True;
                            system.debug('SignupCustomer----');
                        }
                        //recordType = '';
                        checkGoogleAuth();
                        system.debug('registrationFromGoogle');
                        //PageReference pageRef = new PageReference('https://testingv2-leadersinternational.cs18.force.com/login/redirectprofilepage');
                        
                    }catch(Exception e){
                        system.Debug('linenum------'+e.getLineNumber()+'error-------'+e.getMessage());
                        system.debug('pg'+pg);
                        return pg;
                    }
                }
                if(logType.getValue()   == 'fbLogin'){
                    try{
                        Cookie candidate = ApexPages.currentPage().getCookies().get('isSignupCandidate');
                        Cookie customer = ApexPages.currentPage().getCookies().get('isSignupCustomer');
                        system.debug('SignupCandidate----'+candidate.getValue());
                        isFBcustomerSignup = customer.getValue();
                        isFBcandidateSignup = candidate.getValue();
                        system.debug('SignupCustomer----'+customer.getValue());
                        system.debug('checkFacebookAuth----');
                        
                        checkFacebookAuth();  
                        if(ApexPages.currentPage().getCookies().get('signUp').getValue() == 'true') {
                            isSignUp = true;
                            System.debug('facebook signup');
                            return null;
                        }
                        if(ApexPages.currentPage().getCookies().get('Login').getValue() == 'true') {
                            isLogin = true;
                            System.debug('facebook login');
                            return null;
                        }
                        
                    }catch(Exception e){
                        system.debug('exception '+e.getMessage()+'line no '+e.getLineNumber());
                        return pg;
                    }
                }
                
            }else{
                return pg;
            }
        }
        
        // If current user is not an authorized user 
        // then redirect to login page
        if(currentUserId == null) return pg;
        
        return null;
    }
    
    public void checkGoogleAuth(){
        
        String authCode ;        
        System.debug(Apexpages.currentPage().getParameters().get('code'));
        Cookie lkcode = ApexPages.currentPage().getCookies().get('googleCode');
        System.debug('CODE'+lkcode);
        System.debug(ApexPages.currentPage().getCookies());
        if(lkcode != null){
            code = lkcode.getValue();
            Cookie cookiegObj   = new Cookie('googleCode', '', null, 100, false);
            ApexPages.currentPage().setCookies(new Cookie[]{cookiegObj});
        }
        
        if(String.isBlank(code)){
            Cookie gSessId = ApexPages.currentPage().getCookies().get('googleSessionId');
            if(gSessId != null){
                authCode = gSessId.getValue();
            }
        }
        System.debug('code'+code);
        if(!String.isBlank(code)){
            authCode = LoginAuthentication_Helper.getGoogleAuthCode(code,LoginAuthentication_Helper.DONOR_STIE);
            System.debug('authCode'+authCode);
        }
        System.debug('AUTHCODE');
        if(!String.isBlank(authCode)){
            System.debug('AUTHCODE');
            if(!authCode.equalsIgnoreCase('Error')){
                GooglePublicDetailsClass.GoogleDetails gResp = LoginAuthentication_Helper.getGoogleEmail(authCode);
                System.debug('gResp---'+gResp);
                system.debug('gResp.email===='+gResp.email);
                if(gResp != null && !String.isBlank(gResp.email)){
                    gId = gResp.email;
                    System.debug('AUTHCODE');
                    try{
                        list<Contact> currentdonor    = [Select id,name,Login_Hash_Code__c from Contact where Email =:gResp.email AND Candidate_Status__c ='Active'];
                        if(currentdonor.size() >0){
                            currentdonorId          = currentdonor[0].Id;
                            Contact contact=new Contact();
                            contact.Login_Hash_Code__c=FacebookAuthHandler.generateRandomString();
                            contact.Id=currentdonorId;
                            hasCode=contact.Login_Hash_Code__c;
                            system.debug('inside if');
                            update contact;
                        }else{
                           /* Contact contact=new Contact();
                            contact.LastName = gResp.lastName;
                            contact.firstName = gResp.firstName;
                            contact.Email = gResp.email;
                            contact.Login_Hash_Code__c = FacebookAuthHandler.generateRandomString();
                            contact.Last_Hash_Code_Updated__c = System.now();
                            hasCodeUpdate = contact.Login_Hash_Code__c ;
                            system.debug('inside else');
                            insert contact;  */

                            SignupCandidate = true;
                        }
                        
                        System.debug('HASH CODE===>'+contact.Login_Hash_Code__c);
                        
                        Cookie cookieObj1 = new Cookie('googleSessionId', authCode, null, 3600, false);
                        ApexPages.currentPage().setCookies(new Cookie[]{cookieObj1});
                    }catch(Exception e){
                        system.debug(e.getMessage());
                    }
                }
            }
        }
        
    }
    public void checkFacebookAuth(){
        String authCode ;        
        Cookie lkcode = ApexPages.currentPage().getCookies().get('facebookCode');
        
        string isSignup = ApexPages.currentPage().getCookies().get('signUp').getValue();
        string isLogin = ApexPages.currentPage().getCookies().get('Login').getValue();
        //string isCandidate = ApexPages.currentPage().getCookies().get('isCandidate').getValue();
        //string isCustomer = ApexPages.currentPage().getCookies().get('isCustomer').getValue();
        if(lkcode != null){
            code = lkcode.getValue();
            Cookie cookiefObj   = new Cookie('facebookCode', '', null, 100, false);
            ApexPages.currentPage().setCookies(new Cookie[]{cookiefObj});
        }
        if(String.isBlank(code)){
            Cookie gSessId = ApexPages.currentPage().getCookies().get('fbSessionId');   
            if(gSessId != null){
                authCode = gSessId.getValue();
            }
        }
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@code'+code);
        string token;
        if(!String.isBlank(code)){
            Facebook_API_Details__c fad = Facebook_API_Details__c.getInstance();
            if(isLogin == 'true' || isFBcandidateSignup == 'true' || isFBcustomerSignup == 'true'){
                token = FacebookAuthHandler.generateFBAuthCode(code,fad.Auth_Endpoint_URL__c,fad.login_Site_URL__c, fad.App_Id__c, fad.App_Secret__c);    
            }else{
                system.debug('is candiddate');
                token = FacebookAuthHandler.generateFBAuthCode(code,fad.Auth_Endpoint_URL__c,fad.candidate_login_site_url__c, fad.App_Id__c, fad.App_Secret__c);   
            }
            
            system.debug('is token---'+token);
        }
        
        if(!String.isBlank(token)){
            Facebook_API_Details__c fad = Facebook_API_Details__c.getInstance();
            String fbEmail  = FacebookAuthHandler.getFBPublicDetails(fad.Endpoint_URL__c, fad.App_Id__c, fad.App_Secret__c, token);
            FbId            = fbEmail;
            name            = FacebookAuthHandler.name;
            system.debug('fbEmail----------'+fbEmail);
            system.debug(name);
            if(!String.isBlank(fbEmail)){
                
                try{
                    if(isLogin == 'true'){
                        system.debug('login is true-----');
                    }
                    system.debug('isLogin------'+isLogin);
                    system.debug('fbEmail------'+fbEmail);
                    
                    Contact[] currentUser;
                    //currentUser     = [Select id,Internal_Status__c,RecordTypeId,RecordType.developerName from Contact where (Email =:fbEmail OR Facebook_login_ID__c =:fbEmail) and (RecordTypeId=:conStdRecordTypeId OR RecordTypeId=:conFacRecordTypeId OR RecordTypeId=:manRecordTypeId)];
                    currentUser     = [Select id,name,Candidate_Status__c,Login_Hash_Code__c from Contact where Email =:fbEmail]; 
                    system.debug('currentUser--'+currentUser);
                    
                    string recordType;
                    Boolean isSignupFromFb;
                    if (currentUser.size() > 0){
                        
                        if(currentUser[0].Candidate_Status__c == 'Active' || currentUser[0].Candidate_Status__c == 'Document Upload'){
                            currentUserId           = currentUser[0].Id;
                            System.debug('FBEMAIL  '+fbEmail);
                            Contact contact=new Contact();
                            contact.Login_Hash_Code__c=FacebookAuthHandler.generateRandomString();
                            hasCodeUpdate=contact.Login_Hash_Code__c;
                            contact.id=currentUser[0].id;
                            update contact;
                            System.debug('LOGIN HASHCODE===>'+contact.Login_Hash_Code__c);
                            if( currentUser[0].Candidate_Status__c == 'Document Upload'){
                                docUplaodCustomer = true;
                            }
                        }
                        
                        
                        Cookie cookieObj1 = new Cookie('fbSessionId', authCode, null, 3600, false);
                        ApexPages.currentPage().setCookies(new Cookie[]{cookieObj1});
                        return ;
                    }
                    else{
                            isSignupFromFb = true;
                            System.debug('isSignupFromFb'+isSignupFromFb);
                            Cookie cookieObj1 = new Cookie('fbSessionId', authCode, null, 3600, false);
                            ApexPages.currentPage().setCookies(new Cookie[]{cookieObj1});
                    }
                    
                }
                catch(Exception e){
                    system.debug(e.getMessage());
                }
            }
        }
    } 

    public PageReference redirectProfilePagefoFB() {
        isSignUp            = false;
        isLogin         = false;
        system.debug('redirectProfilePagefoFB cookiessssssssssssss');
        system.debug('ApexPages.currentPage().getParameters().get(m)------'+ApexPages.currentPage().getParameters().get('m'));
        code                        = ApexPages.currentPage().getParameters().get('code');
        isSignUp            = ApexPages.currentPage().getParameters().get('m') == '1' ? true : false;
        string mValue = ApexPages.currentPage().getParameters().get('m');
        system.debug('code----'+code);
        if(mValue == '1'|| mValue == '2'){
            isSignUp = True;
            system.debug('isSignUp---'+isSignUp);
        }
        isLogin             = ApexPages.currentPage().getParameters().get('m') == '0' ? true : false;
        isCustomer          = ApexPages.currentPage().getParameters().get('m') == '1' ? true : false;
        isCandidate         = ApexPages.currentPage().getParameters().get('m') == '2' ? true : false;
        Cookie cookieObj            = new Cookie('facebookCode', code, null, 100, false);
        Cookie cookieLoginTypeObj   = new Cookie('loginType', 'fbLogin', null, 86400, false);
        Cookie mSite                = new Cookie('signUp',isSignUp == true ? 'true' : 'false', null, 100, false);
        Cookie aSite                = new Cookie('Login',isLogin == true ? 'true' : 'false', null, 100, false);
        Cookie isCandidate              = new Cookie('isSignupCandidate',isCandidate == true ? 'true' : 'false', null, 100, false);
        Cookie isCustomer               = new Cookie('isSignupCustomer',isCustomer == true ? 'true' : 'false', null, 100, false);
        system.debug('code'+code);
        system.debug('isSignUp'+isSignUp);
        Facebook_API_Details__c fad = Facebook_API_Details__c.getInstance();
       // String token = FacebookAuthHandler.generateFBAuthCode(code,fad.Auth_Endpoint_URL__c,fad.login_Site_URL__c, fad.App_Id__c, fad.App_Secret__c);    
       // FacebookAuthHandler.getFBPublicDetails(fad.Endpoint_URL__c,fad.App_Id__c,fad.App_Secret__c,token);
       // system.debug('token'+token);
        PageReference MyNewPage     = Page.RedirectToFBProfilePage;
        
        MyNewPage.setCookies(new Cookie[]{cookieObj, cookieLoginTypeObj, mSite,aSite,isCandidate,isCustomer});
        
        MyNewPage.setRedirect(true);
        return MyNewPage;
    }
    
    @RemoteAction
    public static string registerFromFacebook(string name,string email, string password, string signUpType){
        try{
            system.debug('name--'+name+'email----'+email+'----password'+password);
            Document_Category__c candDocCategry = [select name,id from Document_Category__c where Name =:System.Label.CandidateOnboardingDocCategoryName];
            Id candidateRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
                contact con = New contact();
                con.lastName = name;
                con.Email = email;
                con.password__c = password;
                con.login_hash_code__c = Utility.generateRandomString();
                con.recordTypeId  = candidateRecordTypeId;
                con.Document_Category__c = candDocCategry.Id;
                insert con;
                return con.login_hash_code__c;
        }catch(exception e){
            system.debug(e.getLineNumber()+'----------'+e.getMessage());
            return null;
        }
    }

    @RemoteAction
    public static string registerCandidate(contact con,string referalId) {
        try{
            if(!string.isBlank(referalId)){
                contact referedCandidate = [select name,id from contact where Ondonte_UID__c =:referalId];
                con.Referred_By__c = referedCandidate.Id;
            }
            if(con.Email != null){
                List<contact> candidateRec = [select id from contact where email =:con.Email];
                if(candidateRec.size() > 0){
                    return 'recexists';
                }
            }
            system.debug('con---------'+con);
            con.Candidate_Source__c = 'Website';
            Account acc = New Account(Name =con.LastName,Client_Currency__c='USD $');
            insert acc;
            con.AccountId = acc.Id;
            con.Candidate_Status__c = 'New';
            con.login_hash_code__c = Utility.generateRandomString();
            insert con;
            system.debug('con.Id--'+con.Id);
            return con.login_hash_code__c;
            
        }Catch(Exception e){
        System.debug(e.getMessage());
        return null;
        }
    }

    @RemoteAction
    public static string verifyEmail(string emailId) {
        list<contact> candidateRec = [select name,id from contact where Email=:emailId AND Candidate_Status__c ='Active' AND RecordType.developerName = :Constants.CANDIDATE];
        system.debug('candidateRec---'+candidateRec);
        if(candidateRec.size() > 0){
            contact candidateToUpdate = New contact(Id=candidateRec[0].Id,login_Hash_code__c =utility.generateRandomString());
            update candidateToUpdate;
            EmailTemplate et = [SELECT Id,Name FROM EmailTemplate where Name = 'Reset Password Link' limit 1];
            system.debug('et.Id---'+et.Id);
            Utility.sendEmailWithTemplate(candidateToUpdate.Id,et.Id);
            return candidateToUpdate.login_hash_code__c;
        }else{
            return null;
        }
    }

    @RemoteAction
    Public static string resetPassword(string email,string password,string hashcode){
        Contact conRecToUpdate = [select name,id from contact where Email =:email AND Login_Hash_code__c =:hashcode limit 1];
        conRecToUpdate.Password__c = password;
        conRecToUpdate.login_hash_code__c = utility.generateRandomString();
        update conRecToUpdate;
        return conRecToUpdate.login_hash_code__c;
    }

    @RemoteAction
    public static contact getUserDetails(string hashcode) {
        List<contact> conRec = [select name,id,email from contact where Login_Hash_code__c =:hashcode];
        system.debug('conRec----'+conRec);
        if(conRec.size() > 0){
            return conRec[0];
        }else{
            return null;
        }
    }
    
}