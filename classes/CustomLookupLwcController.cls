public with sharing class CustomLookupLwcController {

    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName) {    
        List < sObject > returnList = new List < sObject > ();
        string sWildCardText = '%' + searchKey + '%';
        string sQuery;
        string dataStatus = 'Active';
        if(sObjectApiName=='Artera_Resource__c'){
            System.debug('Resource');
            sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : sWildCardText AND Worker_Status__c =: dataStatus order by createdDate DESC LIMIT 5';
            System.debug('Query '+sQuery);
        }else{
            sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
        }


        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    // Method to fetch lookup default value 
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
        string sRecId = recordId;    
        string dataStatus = 'Active';
        string sQuery;
        if(sObjectApiName=='Artera_Resource__c'){
            sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId AND Worker_Status__c =: dataStatus LIMIT 1';
        }else{
            sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        }
        
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }
}