public with sharing class LineItemPicklistCtrl {
    public LineItemPicklistCtrl() {

    }

    @AuraEnabled(cacheable = true)
    public static List<Project_Item__c> getLineItemsList(String recordId){ 
        try { 
            List<Project_Item__c> lineItemList = new List <Project_Item__c> ();
                lineItemList = [SELECT Id, Name FROM Project_Item__c WHERE Project__c=:recordId AND Status__c = 'AC'];
            return lineItemList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}