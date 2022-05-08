public without sharing class DocumentLifecycleProcessor {
  /*  static final String PARTY_TYPE_BORROWER = 'BORROWER';

    private static DocumentLifecycleProcessor handlerInstance;
    private DocumentLifeCycleRepository docRepository;
    
    private DocumentLifecycleProcessor() {
        docRepository = DocumentLifeCycleRepository.getInstance();
    }

    public static DocumentLifecycleProcessor getInstance() {
        if(handlerInstance == null)
            handlerInstance = new DocumentLifecycleProcessor();
        return handlerInstance;
    }

    //Application documents
    public void createApplicationDocuments(Set<Id> applicationIdSet) {
        if(applicationIdSet == null || applicationIdSet.isEmpty())
            return;
        docRepository.deleteApplicationDocuments(applicationIdSet);
        Map<Id, Job_Application__c> appMap = docRepository.getApplicationMapById(applicationIdSet);
        Set<Id> productIdSet = new Set<Id>();
        for(Job_Application__c application : appMap.values()) {
        //    productIdSet.add(application.Product__c);
        }
        if(!productIdSet.isEmpty()) {
            List<Product_Document_Association__c> proDocAssociationList = docRepository.getProductDocAssociationWithProductAndType(productIdSet, new Set<String>{'APPLICATION DOCUMENT'}, true);
            Map<Id,List<Document_Category__c>> productXdoccategory = new Map<Id,List<Document_Category__c>>();
            Map<Id,Decimal> displayOrderMap = new Map<Id,Decimal>();
            for(Product_Document_Association__c assn : proDocAssociationList) {
                displayOrderMap.put(assn.Document_Category__c, assn.Display_Order__c);
                if(productXdoccategory.containsKey(assn.Loan_Product__c)) {
                    productXdoccategory.get(assn.Loan_Product__c).add(assn.Document_Category__r);
                }else {
                    productXdoccategory.put(assn.Loan_Product__c, new List<Document_Category__c> { assn.Document_Category__r });
                }
            }

            if(!productXdoccategory.isEmpty()) {
                Map<Id,List<Application_Document_Category__c>> appXdocsMap = new Map<Id,List<Application_Document_Category__c>>();
                for(Job_Application__c app : appMap.values()) {
                    if(productXdoccategory.containsKey(app.Product__c)) {
                        appXdocsMap.put(app.Id, getAppDocuments(app, productXdoccategory.get(app.Product__c), displayOrderMap));
                    }
                }

                createAppDocuments(appXdocsMap);
            }
        }
        
    }

    private List<Application_Document_Category__c> getAppDocuments(Job_Application__c app, List<Document_Category__c> partyDoccategoryList, Map<Id,Decimal> displayOrderMap) {
        List<Application_Document_Category__c> partyAppDocumentList = new List<Application_Document_Category__c>();
        Application_Document_Category__c appDocCategory;
        for(Document_Category__c doccategory : partyDoccategoryList) {
            appDocCategory = new Application_Document_Category__c();
            appDocCategory.Document_Category__c = doccategory.Id;
            appDocCategory.Job_Application__c = app.Id;
            appDocCategory.Name = doccategory.Name;
           // appDocCategory.Display_Order__c = displayOrderMap.containsKey(doccategory.Id) ? displayOrderMap.get(doccategory.Id) : null;
           // appDocCategory.Sign_Document__c = doccategory.Sign_Document__c;
            partyAppDocumentList.add(appDocCategory);
        }
        return partyAppDocumentList;
    }

    private void createAppDocuments(Map<Id,List<Application_Document_Category__c>> appXdocsMap) {
        Map<Id,Application_Document_Category__c> appDirectoryMap = new Map<Id,Application_Document_Category__c>();
        
        for(Id appId : appXdocsMap.keySet()) {
            appDirectoryMap.put(appId, new Application_Document_Category__c(
                Job_Application__c = appId,
                Name = 'Application Documents',                
                Display_Order__c = 1
            ));
        }
        if(!appDirectoryMap.isEmpty()) {
            insert appDirectoryMap.values();
            List<Application_Document_Category__c> docsToInsert = new List<Application_Document_Category__c>();
            for(Id appId : appDirectoryMap.keySet()) {
                for(Application_Document_Category__c appDoc : appXdocsMap.get(appId)) {
                    appDoc.Application_Document_Category__c = appDirectoryMap.get(appId).Id;
                    docsToInsert.add(appDoc);
                }
            }
            if(!docsToInsert.isEmpty()) {
                insert docsToInsert;
            }
        }
    }*/

    //Party documents
    /*public void createPartyDocuments(Map<Id,Key_Party__c> partiesMap) {
        Map<String,Key_Party__c> typeXparty = new Map<String,Key_Party__c>();
        Set<Id> applicationIdSet = new Set<Id>();
        Set<String> reqPartyTypes = new Set<String>();
        List<Key_Party__c> filteredPartyList = new List<Key_Party__c>();
        Set<Id> contactSet = new Set<Id>();
        for(Key_Party__c party: partiesMap.values()) {
            if(party.Party_Type__c != null && party.Util_Application__c != null && party.Contact__c != null) {
                applicationIdSet.add(party.Util_Application__c);
                reqPartyTypes.add(party.Party_Type__c);
                filteredPartyList.add(party);
                contactSet.add(party.Contact__c);
            }
        }
        if(!applicationIdSet.isEmpty()) {
            Map<Id, Job_Application__c> appMap = docRepository.getApplicationMapById(applicationIdSet);
            Map<Id, Contact> contactMap = docRepository.getContactMapById(contactSet);
            Set<Id> productIdSet = new Set<Id>();
            for(Job_Application__c application : appMap.values()) {
                productIdSet.add(application.Product__c);
            }
            if(!productIdSet.isEmpty()) {
                Map<Id,Map<String,List<Document_Category__c>>> productXdoccategory = new Map<Id,Map<String,List<Document_Category__c>>>();
                List<Product_Document_Association__c> proDocAssociationList = docRepository.getProductDocAssociationWithProductAndType(productIdSet, reqPartyTypes, true);
                Map<Id,Decimal> displayOrderMap = new Map<Id,Decimal>();
                for(Product_Document_Association__c assn : proDocAssociationList) {
                    displayOrderMap.put(assn.Document_Category__c, assn.Display_Order__c);
                    if(productXdoccategory.containsKey(assn.Loan_Product__c)) {
                        if(productXdoccategory.get(assn.Loan_Product__c).containsKey(assn.Document_Category__r.Document_Type__c))
                            productXdoccategory.get(assn.Loan_Product__c).get(assn.Document_Category__r.Document_Type__c).add(assn.Document_Category__r);
                        else
                            productXdoccategory.get(assn.Loan_Product__c).put(assn.Document_Category__r.Document_Type__c, new List<Document_Category__c>{ assn.Document_Category__r });
                    }else {
                        productXdoccategory.put(assn.Loan_Product__c, new Map<String,List<Document_Category__c>> { assn.Document_Category__r.Document_Type__c => new List<Document_Category__c>{ assn.Document_Category__r }});
                    }
                }
                if(!productXdoccategory.isEmpty()) {
                    Map<Id,List<Application_Document_Category__c>> partyXdocsMap = new Map<Id,List<Application_Document_Category__c>>();
                    for(Key_Party__c party : filteredPartyList) {
                        if(productXdoccategory.containsKey(appMap.get(party.Util_Application__c).Product__c) && productXdoccategory.get(appMap.get(party.Util_Application__c).Product__c).containsKey(party.Party_Type__c)) {
                            partyXdocsMap.put(party.Id, getPartyDocuments(party, productXdoccategory.get(appMap.get(party.Util_Application__c).Product__c).get(party.Party_Type__c), displayOrderMap));
                        }
                    }

                    createPartyDocuments(partiesMap, contactMap, partyXdocsMap);
                }
            }

        }

    }*/


    /*private List<Application_Document_Category__c> getPartyDocuments(Key_Party__c party, List<Document_Category__c> partyDoccategoryList, Map<Id,Decimal> displayOrderMap) {
        List<Application_Document_Category__c> partyAppDocumentList = new List<Application_Document_Category__c>();
        Application_Document_Category__c appDocCategory;
        for(Document_Category__c doccategory : partyDoccategoryList) {
            appDocCategory = new Application_Document_Category__c();
            appDocCategory.Account__c = party.Account__c;
            appDocCategory.Document_Category__c = doccategory.Id;
            appDocCategory.Application__c = party.Util_Application__c;
            appDocCategory.Name = doccategory.Name;
            appDocCategory.Display_Order__c = displayOrderMap.containsKey(doccategory.Id) ? displayOrderMap.get(doccategory.Id) : null;
            appDocCategory.Sign_Document__c = doccategory.Sign_Document__c; 
            partyAppDocumentList.add(appDocCategory);
        }
        return partyAppDocumentList;
    } */


    /*private void createPartyDocuments(Map<Id,Key_Party__c> triggeredPartyMap, Map<Id,Contact> contactMap, Map<Id,List<Application_Document_Category__c>> partyXdocsMap) {
        Map<Id,Application_Document_Category__c> partyDirectoryMap = new Map<Id,Application_Document_Category__c>();
        for(Id partyId : partyXdocsMap.keySet()) {
            Key_Party__c party = triggeredPartyMap.get(partyId);
            Contact partyContact = contactMap.get(party.Contact__c);
            partyDirectoryMap.put(partyId, new Application_Document_Category__c(
                Application__c = party.Util_Application__c,
                Name = partyContact.FirstName + ' ' + partyContact.LastName,
                Display_Order__c = party.Party_Type__c == PARTY_TYPE_BORROWER ? 2 : 3,
                Account__c = triggeredPartyMap.get(partyId).Account__c
            ));
        }
        if(!partyDirectoryMap.isEmpty()) {
            insert partyDirectoryMap.values();
            List<Application_Document_Category__c> docsToInsert = new List<Application_Document_Category__c>();
            for(Id partyId : partyXdocsMap.keySet()) {
                for(Application_Document_Category__c appDoc : partyXdocsMap.get(partyId)) {
                    appDoc.Application_Document_Category__c =  partyDirectoryMap.get(partyId).Id;
                    docsToInsert.add(appDoc);
                }
            }
            if(!docsToInsert.isEmpty()) {
                insert docsToInsert;
            }
        }
    }  */

  /*  public void deletePartyDocuments(List<Key_Party__c> deletedPartiesList) {
        Map<Id,Id> applicationXaccount = new Map<Id,Id>();

        for(Key_Party__c party : deletedPartiesList) {
            if(party.Account__c != null && party.Util_Application__c != null) {
                applicationXaccount.put(party.Util_Application__c, party.Account__c);
            }
        }
        if(!applicationXaccount.isEmpty()) {
            List<Application_Document_Category__c> docsToDelete = new List<Application_Document_Category__c>();
            for(Application_Document_Category__c appDoc : docRepository.getAppDocByParty(applicationXaccount.keySet(), applicationXaccount.values())) {
                if(applicationXaccount.get(appDoc.Application__c) == appDoc.Account__c)
                    docsToDelete.add(appDoc);
            }
            if(!docsToDelete.isEmpty())
                Database.delete(docsToDelete, false);
        }
    } */
}