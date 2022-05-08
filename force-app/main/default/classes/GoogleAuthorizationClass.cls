public without sharing class GoogleAuthorizationClass {
    public static String generateAuthCode(String code, String endpointURL, String redirectURI, String cliendId, String clientSecret){
        String endPoint ;
       
        endPoint             = endpointURL + '?code='+code+'&redirect_uri='+redirectURI+'&client_id='+cliendId+'&client_secret='+clientSecret+'&grant_type=authorization_code';
        HttpRequest request = new HttpRequest();
       
        request.setMethod('POST');
        request.setEndpoint(endPoint);
        request.setBody('');
       
        Http http = new Http();
        HTTPResponse res;
       
        try{
            res = http.send(request);  
             AuthResponseWrapper respWrapObj = AuthResponseWrapper.parse(res.getBody());
            return respWrapObj.access_token;   
        }catch(Exception e){
            system.debug('exception::'+e.getMessage());
            return 'Error';
        }
       
       /* try{
            AuthResponseWrapper respWrapObj = AuthResponseWrapper.parse(res.getBody());
            return respWrapObj.access_token;   
        }catch(Exception e){
            system.debug('exception::'+e.getMessage());
            return Constants.ERROR_MESSAGE;
        } */
       
        //return Constants.ERROR_MESSAGE;
    }
   
/* Dummy Response
{
"access_token": "ya29.Ci_BA3MuM_SU9qwG1f7EyklO-ZssVxyxVZPYmq7C-OT74KZnNnwzdmiAd9kiY7vG5w",
"token_type": "Bearer",
"expires_in": 3600,
"refresh_token": "1/1k3lWRN1DoHV1esWHLeDxLMy031aNYgao-p8kYLsLPo",
"id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6ImI5N2FmM2E4OTk4MzJmNTU1ODAzOWQ1NDg4MzY0ZDEyOWViNmE3YjcifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwiaWF0IjoxNDgyODE3NTUwLCJleHAiOjE0ODI4MjExNTAsImF0X2hhc2giOiJnSVF1cVNEc0JZcnl2SXFVOEI4d0VRIiwiYXVkIjoiNjI0MTIzMTQ1MTIxLW85YjdyaDZwOWticTAyY3NrbjRnYzQ5YXRwdjBxOW9sLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwic3ViIjoiMTE0MzIzMTA1OTg1MDg0NTM3MTk0IiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF6cCI6IjYyNDEyMzE0NTEyMS1vOWI3cmg2cDlrYnEwMmNza240Z2M0OWF0cHYwcTlvbC5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsImVtYWlsIjoiYW5pcnVkaC5zYW5nd2FuMDAxQGdtYWlsLmNvbSJ9.RH1OaLHuPKK1kTHDGQDuQtawCBcQhiYnisd4EmqtdKxYTxC0S7v79Ksw8w5dsdAncVBlFBqjb3YoWFjc5sYpfoqoWDI_InnO-6akinjAcW7b4RLb7jvO-JSa1_s2vhnQIcFksknwjRaNm4JiIuqNZE32x5hgJadKpg4L5cTkiCyUSWOz-KLah-rphDMlZCVeSouBTu9SV-utgJRvtilUYY_Nf6pqRmno7w3sKJqG5apZO1r9fy-KCMeyE4DAdz-xdg5Exhhn7dpxM6sRGfB6-aTd8g3iDcU-qv0j8k0gzSZR7Up_SkFqH6kRccMlEh2Wwliw23S3-7MqJbjxr95i8A"
}
*/
}