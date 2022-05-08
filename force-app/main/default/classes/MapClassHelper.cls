public class MapClassHelper {
    @AuraEnabled(cacheable=true)
    public static map<string,object> getaccountCoordinates(String accid){
        
        Account acct = [SELECT id,Name,Description, geolocation_Add__c FROM Account where id =:accid] ;

        List<ContactWrapper> conWrapperList = new List<ContactWrapper>();
        List< map<string,object>> markerList = new List< map<string,object>>();
        map<string,object> mainMap = new map<string,object>();

        Location loc = new Location();
        
        map<string,object> markerMap = new map<string,object>();
        markerMap.put('title', acct.name);
        markerMap.put('icon','custom:custom24');
        markerMap.put('description',acct.Description != null ? acct.Description : '');
        markerMap.put('value',acct.Id);
 
        
        map<string,object> addressMap = new map<string,object>();
        addressMap.put('Latitude',acct.geolocation_Add__c.getLatitude());
        addressMap.put('Longitude',acct.geolocation_Add__c.getLongitude());
        markerMap.put('location',addressMap);
        markerList.add(markerMap); 

        conWrapperList.add(new ContactWrapper(acct.Id,acct.Name,acct.Description,double.valueOf('0.0')));
    
        system.debug('+++++++'+JSON.serialize(markerList));
        mainMap.put('markerList',markerList);
        mainMap.put('conList',conWrapperList);  

        return mainMap;
    }
    @AuraEnabled
    public static map<string,object> getAllcandidate(Integer Distance,String accId, String sortByType ){ 
        system.debug('Distance'+sortByType);
        list< map<string,object>> markerList = new list< map<string,object>>();

        map<string,object> mainMap = new map<string,object>();
        
        
        Account acct = [SELECT id,Name,Description, geolocation_Add__c FROM Account where id =:accid] ;
        Location accloc = new Location();
        
        accloc = acct.geolocation_Add__c;
        map<string,object> markerMap = new map<string,object>();
        markerMap.put('title', acct.name);
        markerMap.put('icon','standard:account');
        
        
        markerMap.put('type', 'Circle');
        markerMap.put('radius', Distance*1000);
        markerMap.put('strokeColor','#FFF000');
        markerMap.put('strokeOpacity', 0.8);
        markerMap.put('strokeWeight',2);
        markerMap.put('fillColor','#FFF000');
        markerMap.put('fillOpacity',0.35);
        
        markerMap.put('description',acct.Description != null ? acct.Description : '');
        map<string,object> addressMap = new map<string,object>();
        addressMap.put('Latitude',acct.geolocation_Add__c.getLatitude());
        addressMap.put('Longitude',acct.geolocation_Add__c.getLongitude());
        markerMap.put('location',addressMap);
        markerList.add(markerMap);
        
       

        List<Contact> conList = new List<Contact>(); 
        List<ContactWrapper> conWrapperList = new List<ContactWrapper>();

        if(sortByType=='distance'){
            conList = [Select Id, Name, GeoLocation__c,Description FROM Contact where DISTANCE(GeoLocation__c, GEOLOCATION(:acct.geolocation_Add__c.getLatitude(),:acct.geolocation_Add__c.getLongitude()),'km') < :Distance LIMIT 20];
            system.debug('Running');
        }else{
            system.debug('RunningElse');
        }
        
        
        for(Contact order : conList){   

            Location conloc = order.GeoLocation__c;
            Double lat = conloc.latitude;
            Double lon = conloc.longitude;
            Double dist = Location.getDistance(accloc, conloc, 'km');

            Decimal toround = dist;
            Decimal rounded = toround.setScale(2);
        

            conWrapperList.add(new ContactWrapper(order.Id,order.Name,order.Description,rounded));

            if(dist < Distance){
                markerMap = new map<string,object>();
                markerMap.put('title', order.name);
                markerMap.put('description',order.Description != null ? order.Description : '');
                markerMap.put('icon','standard:person_name');
                markerMap.put('value',order.Id);
                addressMap = new map<string,object>();
                addressMap.put('Latitude',order.GeoLocation__c.getLatitude());
                addressMap.put('Longitude',order.GeoLocation__c.getLongitude());
                markerMap.put('location',addressMap);
                markerList.add(markerMap);  
            }
        }
        
        mainMap.put('markerList',markerList);
        mainMap.put('conList',conWrapperList);
        
        system.debug('+++++++'+JSON.serialize(conWrapperList));  
        // return JSON.serialize(markerList);
        return mainMap;  
    } 


    public class ContactWrapper{
        @AuraEnabled public string id;
        @AuraEnabled public string name;
        @AuraEnabled public string description;
        @AuraEnabled public Decimal distance;

        public ContactWrapper(String id, String name, string description ,Decimal distance){
            this.id = id;
            this.name = name;
            this.description = description;
            this.distance = distance;
        }
    }
    
}