public with sharing class AdobePostDocumentAPICallout {
    public AdobePostDocumentAPICallout() {
    }

    public static String postDocument(){
        String transientDocId = '';
        String token = '3AAABLblqZhBB9SErSr4Hf8o3Kho8VDH3BTRFbwcEnw2op6mzUvwKdb5aS03ZxnKzurl7VHSen_B1s-Pr5W_KFrOcQwqt9Ajj';

        ContentVersion contentVersion = [SELECT Id,VersionData,FileExtension FROM ContentVersion WHERE ContentDocumentId = '0693N000001vdGp'];
        String fileName = contentVersion.Id;

        if(contentVersion.FileExtension!=null && contentVersion.FileExtension!=''){
            fileName = fileName + '.' + contentVersion.FileExtension;  
        }         
        
        System.debug('Callout Log 2:' + fileName);
        Blob blobs = contentVersion.VersionData;

        String body='';
        body += 'Content-Disposition: form-data; name="File"\r\n';
        body += blobs+'\r\n';
        body += 'Content-Disposition: form-data; name="File-Name"\r\n';
        body += fileName+'\r\n';

        System.debug('BODY----'+body);


        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.in1.adobesign.com/api/rest/v6/transientDocuments');
        req.setheader('Content-Type','multipart/form-data');
        req.setHeader('Authorization','Bearer '+ token);
        req.setMethod('POST');
        //req.setBody(body);
        req.setBodyAsBlob(blobs);

        HttpResponse res = h.send(req);
        system.debug('res: ' + res.getBody());

        return transientDocId;
    }
}