@isTest
public class dispatchJobsHandlerTest {
    @isTest static void onStatusChangeTest(){
       
        Artera_Job__c job = new Artera_Job__c();
        job.Status__c = 'Dispatched';
        job.Job_Date__c = Date.newInstance(2022, 05, 2);
        insert job;
      
        
    }
}