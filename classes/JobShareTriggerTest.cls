@isTest
private class JobShareTriggerTest {

    
 static testMethod void shareJobTest(){
     List<Artera_Job__c> job = new LisT<Artera_Job__c>();
     Artera_Job__c j = new Artera_Job__c();
     Artera_Region__c region = new Artera_Region__c();
     
    
     j.Job_Date__c = Date.newInstance(2022, 05, 21);
     j.Artera_Region__c = region.Name;
     region.Name = 'FL-Tampa';

     List<Artera_Job__Share> jShrs = [SELECT Id, UserOrGroupId, AccessLevel, 
         RowCause FROM Artera_Job__Share WHERE ParentId = :j.Id];
    insert j;
 
 
 
 }
}