public without sharing class LoginAuthentication_Helper {
    public static final string DONOR_STIE		=	'Login';
    public static final string APPLICATION_SITE	= 	'Login';
    public static final String MENTORSHIP_SITE  =	'Login';
    // Call GoogleAuthorizationClass to get access token using authorization code
    public static string getGoogleAuthCode(String code, string loginSite){
        system.debug('code'+code);
        system.debug('loginSite'+loginSite);
        Google_API_Details__c gad = Google_API_Details__c.getInstance();
        if(loginSite == 'candidate'){
            return GoogleAuthorizationClass.generateAuthCode(code,gad.Auth_Endpoint_URL__c,gad.candidate_login_site_url__c, gad.Client_Id__c, gad.Client_Secret__c);
        }else if(loginSite == 'customer'){
            return GoogleAuthorizationClass.generateAuthCode(code, gad.Auth_Endpoint_URL__c,gad.customer_login_site_url__c, gad.Client_Id__c,gad.Client_Secret__c);
        }else if(loginSite == 'login'){
            system.debug('code'+code);
            system.debug('loginSite'+loginSite);
            return GoogleAuthorizationClass.generateAuthCode(code, gad.Auth_Endpoint_URL__c,gad.Login_Redirect_URI__c, gad.Client_Id__c,gad.Client_Secret__c);
        }
        return null;
    }
    
    // Call GooglePublicDetailsClass to get google email using access token
    public static GooglePublicDetailsClass.GoogleDetails getGoogleEmail(string authcode){
        //system.debug('Getting the G-mail'+authcode);
        return GooglePublicDetailsClass.getPublicDetails(authCode, Google_API_Details__c.getInstance().Endpoint_URL__c);
        
    }
    
    // Call FacebookAuthHandler to get access token using authorization code
    public static string getFBAuthCode(String code, string loginSite){
        Facebook_API_Details__c fad = Facebook_API_Details__c.getInstance();
            return FacebookAuthHandler.generateFBAuthCode(code,fad.Auth_Endpoint_URL__c,fad.login_Site_URL__c, fad.App_Id__c, fad.App_Secret__c);
        
    }
    
    // Call GooglePublicDetailsClass to get google email using access token
    public static string getFacebookEmail(string authcode){
        Facebook_API_Details__c fad = Facebook_API_Details__c.getInstance();
        return FacebookAuthHandler.getFBPublicDetails(fad.Endpoint_URL__c, fad.App_Id__c, fad.App_Secret__c, authcode);        
    }
}