@isTest

public class JobStatusCancelledHandlerTest {
    public static string JobAllocationId = '';
    public static string  JobId ='';
    public static string ResourceId = '';
    @isTest static void onStatusChangeTest(){
        
        Artera_Job__c JobTest1 = new Artera_Job__c();
        JobTest1.Job_Location__c ='Birmingham' ;
        JobTest1.Status__c = 'Cancelled';
        insert JobTest1 ;
        JobId=JobTest1.Id;
              
        Artera_Job_Allocation__c JobAllocationTest = new Artera_Job_Allocation__c();
        JobAllocationTest.Job__c = JobTest1.Id ;
        System.debug('res '+JobAllocationTest.Artera_Resource__c);
        insert JobAllocationTest;
        JobAllocationId = JobAllocationTest.Id ;
        
        
        Artera_Job_Allocation__c JobAlloc = [SELECT ID, Name ,Artera_Resource__c,Artera_Resource__r.Phone_Number__c,
                                             Artera_Resource__r.Email__c,Status__c FROM Artera_Job_Allocation__c WHERE Id =: JobAllocationId] ;
        
       
        
        
        Map<Id, Artera_Job__c> oldJob = new  Map<Id, Artera_Job__c>();
        JobTest1.Job_Location__c ='Birmingham' ;
        System.debug('JobAllocationTest.Job__r.Id ' + JobAllocationTest.Job__c);
        JobTest1.Status__c = 'Dispatched';       
        oldJob.put(JobAllocationTest.Job__c , JobTest1);
        
      
         Artera_Job__c JobTest2 = new Artera_Job__c();
        JobTest2.Job_Location__c ='NYC' ;
        JobTest2.Status__c = 'Dispatched';
        insert JobTest2 ;
        JobId=JobTest2.Id;
        
         List<Artera_Job__c> JobTest3 = new List<Artera_Job__c>();
        JobTest2.Status__c = 'Cancelled';
        JobTest3.add(JobTest2);
        
        Test.startTest();
        List <Artera_job__c> newJobList = new List <Artera_job__c>();
        newJobList.add(JobTest1);
        update JobTest3;
        JobStatusCancelledHandler.onStatusChange(newJobList, oldJob);
        //update oldJob;
        Test.stopTest();          
    }
    
    
    @isTest
    public static void SendSMSToOperatotWithNotes()
    {
        
        Artera_Job__c JobTest = new Artera_Job__c();
        JobTest.Job_Location__c ='Birmingham' ;
        JobTest.Status__c = 'Cancelled';
        insert JobTest ;
        JobId=JobTest.Id;
        
        Artera_Job_Allocation__c JobAllocationTest = new Artera_Job_Allocation__c();
        JobAllocationTest.Job__c = JobTest.Id ;
        insert JobAllocationTest;
        JobAllocationId = JobAllocationTest.Id ;
        
        Artera_Job_Allocation__c JobAlloc = [SELECT ID, Name ,Artera_Resource__c,Artera_Resource__r.Phone_Number__c,Artera_Resource__r.Email__c,Status__c FROM Artera_Job_Allocation__c WHERE Id =: JobAllocationId] ;
        
        Test.startTest();
        JobStatusCancelledHandler.SendSMSToOperatorWithNotes(JobAlloc);
        Test.stopTest();
        
    }
    
}