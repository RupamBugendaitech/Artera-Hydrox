public with sharing class jobTicketPicklist {
  
    @AuraEnabled(cacheable = true)
public static List<Job_Ticket__c> getTicketNumberLists(String recordId){

    

        List<Job_Ticket__c> ticket = new List <Job_Ticket__c> ();
        ticket = [select Id, Name from Job_Ticket__c WHERE Job1__c =:recordId];

        return ticket;
    
}
}