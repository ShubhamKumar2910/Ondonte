public class GoogleMap_controller {

    public string complatedVisit{get;set;}
    public string userId{get;set;}
    public GoogleMap_controller() {
        list<contact> contactList = [select name,id,MailingLatitude,MailingLongitude from contact];
        complatedVisit = JSON.serialize(contactList);
    }

    
}