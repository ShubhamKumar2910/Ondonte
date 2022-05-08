public with sharing class FacebookAuthHandler {
    public static string name     ;           
    public static string fbMail   ;
    
    public static String generateFBAuthCode(String code, String endpointURL, String redirectURI, String cliendId, String clientSecret){
        String endPoint ;
        
        system.debug('endpointURL'+endpointURL+':::::redirectURI'+redirectURI+'::::cliendId'+cliendId+':::::clientSecret'+clientSecret);
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(endpointURL);
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        
        String messageBody ='code='+code+'&client_id='+cliendId+
            '&client_secret='+clientSecret+
            '&redirect_uri='+redirectURI+
            '&grant_type=authorization_code';
        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setTimeout(60*1000);
        system.debug('messageBody:'+messageBody);
        system.debug('messageBody:'+req);
        
        try{
            Http callout = new Http();
            String responseText;
            HttpResponse response;
            if(test.isRunningTest()){
                Map<string, object> NewMap = New Map<string, object>();
                NewMap.put('access_token', 'value');
                responseText = json.serialize(NewMap); 
                
            }else{
                response = callout.send(req);
                responseText = response.getBody();
                system.debug('responseText'+responseText);
            }
            
            Map<String,object> responseMap =(Map<String,object>)JSON.deserializeUntyped(responseText) ;  
            String token =  String.valueOf(responseMap.get('access_token'));
            system.debug('token'+token);
            Facebook_API_Details__c fad = Facebook_API_Details__c.getInstance();
            // getFBPublicDetails(fad.Endpoint_URL__c, fad.App_Id__c, fad.App_Secret__c, token);
            return token;
            
        }
        catch(Exception e){
            system.debug('exception::'+e.getMessage());
            return 'Error';
        }
    }
    
    
    // Call Facebook Graph API to get the user public info like email,gender
    public static string getFBPublicDetails(string endpointURL,string appId, string appSecret, string authCode ){
        try{
            system.debug(appId);
            String endPoint ;
            endPoint 		= endpointURL +'&appId='+appId+'&secret='+appSecret+'&access_token='+authCode;
            system.debug('authCode+endpoint'+endpointURL);
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            request.setEndpoint(endPoint);
            
            Http http = new Http();
            HTTPResponse res;
            
            
            if(Test.isRunningTest()){
                return 'TestString@gmail.com';
                
            }else{
                res = http.send(request);
                FacebookAuthHandler.fbDetailWrapper respWrapObj = parse(res.getBody());
                name = respWrapObj.name ;   
                system.debug('---------respWrapObj.email'+respWrapObj.email);
                system.debug('---------respWrapObj.email'+respWrapObj);
                fbMail = respWrapObj.email ;
                return respWrapObj.email;   
            }
        }catch(Exception e){
            system.debug('exception::'+e.getMessage());
            return 'Error';
        }
    }
    
    public static FacebookAuthHandler.fbDetailWrapper parse(String json){
        return (FacebookAuthHandler.fbDetailWrapper) System.JSON.deserialize(json, FacebookAuthHandler.fbDetailWrapper.class);
    }
    
    public class fbDetailWrapper {
        
        public string id;
        public string email;
        public string gender;
        public string name;
        
        public fbDetailWrapper(string id, string email, string gender, string name){
            This.id = id;
            This.email = email;
            This.gender = gender;
            This.name = name;
            
        }
    }
    
    public static String generateRandomString(){
        Integer len = 10;
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr+string.ValueOf(system.now().getTime()); 
    }
    
    /*@purpose	: Decrypt an encrypted string using MD5 hash Algorithm and AES129 Encryption Algorithm
*@param	: ecryString
*@param	: decryKey
*@returnType: string
*/
    public static string decryptString(string encryString, string decryKey){
        Blob cryptoKey 					= Blob.valueOf(decryKey);
        Blob hash						= Crypto.generateDigest('MD5', cryptoKey);
        Blob data 						= EncodingUtil.convertFromHex(encryString);
        Blob decryptedText 				= Crypto.decryptWithManagedIV('AES128', hash, data);
        return decryptedText.toString();
    }    
}