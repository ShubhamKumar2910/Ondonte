public with sharing class ResumeUploadController {
   
    public class relatedFile {
        public String PathOnClient;
        public String Title;
        public Blob VersionData;
    }

    @AuraEnabled
    public static FileDetails uploadFiles(List<Map<String, Object>> files){
        FileDetails FD = new FileDetails();
        Boolean isSuccess = false;
        List<ContentVersion> relatedDocuments = new List<ContentVersion>();
        for (Map<String, Object> file : files) {
            String fileJson = JSON.serialize(file);
            relatedFile relatedDocument = (relatedFile) JSON.deserialize(fileJson, relatedFile.class);
            ContentVersion contentVersionFile = new ContentVersion();
            contentVersionFile.PathOnClient = relatedDocument.PathOnClient;
            contentVersionFile.Title = relatedDocument.Title;
            contentVersionFile.VersionData = relatedDocument.VersionData;
            relatedDocuments.add(contentVersionFile);
        }
        Database.saveResult[] srFiles = Database.insert(relatedDocuments);
        for (Database.SaveResult saveResult : srFiles) {
            isSuccess = saveResult.isSuccess();
            system.debug('Attached File Details' + saveResult);
            FD.FileId = saveResult.getId();
            FD.res = saveResult.isSuccess();
        }
        return FD;
    }
    
    public class FileDetails {
        @AuraEnabled public string FileId {get; set;}
        @AuraEnabled public Boolean res {get; set;}
 
    }
}