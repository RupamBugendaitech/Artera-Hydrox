@isTest
public class SendingEmailUponJobCancellationTest {
    
    @isTest
    public static void SendingEmailUponJobCancellationTest(){
       
        Artera_Resource__c Resource = new Artera_Resource__c();
    Resource.Name = 'New Resource test' ;
        Resource.Worker_Status__c = 'Active';
    Resource.Employee_ID__c ='83643434';
        Resource.Email__c= 'Kkamran336@gmail.com';
    insert Resource ;
        
        	Artera_Job__c TestJob = new Artera_Job__c ();
        //TestJob.Name = 	'ArteraJobTest' ;
        TestJob.Job_Location__c ='Birmingham';
        insert Testjob ;
        	
        Artera_Job_Allocation__c JobAssignmentTest = new Artera_Job_Allocation__c ();
        JobAssignmentTest.job__c = Testjob.Id ;
        JobAssignmentTest.Artera_Resource__c = Resource.Id ;
        Insert JobAssignmentTest ;
        
        List<Artera_Job_Allocation__c> ArteraJobAllocations = new List<Artera_Job_Allocation__c>();
        ArteraJobAllocations.add(JobAssignmentTest);
     
        
        Test.startTest() ;
        SendingEmailUponJobCancellation.InformResource(ArteraJobAllocations);
            Test.stopTest();
        
    }

}