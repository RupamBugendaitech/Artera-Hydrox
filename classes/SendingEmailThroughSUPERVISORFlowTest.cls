/**
 @author Ritisha 
 @date 11/04/2022
 @group Artera_Job__c
 @description Apex invocable class for sending mail to supervisor with dispatcher notes upon being called by a running flow.
 they have been assigned
 Name : SendingEmailThroughSUPERVISORFlow .
 @lastModifiedOn 15/04/2022 
 @lastModifiedBy Ritisha
*/
@IsTest
public class SendingEmailThroughSUPERVISORFlowTest {
    
    
    
    @testSetup static void setup() {
       
        UserRole r = new UserRole(DeveloperName= 'MyCustomRole' , Name = 'MyRole');
        insert r ;
        
        User u = new User(
        ProfileId=[SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'Kamran',
            Email = 'Kkamran336@gmail.com',
            username = 'kk000@gmail.com' + System.currentTimeMillis(),
            CompanyName ='Artera',
            Title ='Associate Developer',
            Alias =' alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey ='en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = r.Id
			);
        insert u;
       
        }
		
    @IsTest
    static void SendingEmailThroughDISPATCHERTest() {
        
        User Myuser = [SELECT ID ,Name FROM user WHERE LastName = 'Kamran' LIMIT 1];
        Artera_Resource__c Resource = new Artera_Resource__c();
    Resource.Name = 'New Resource test' ;
        Resource.Worker_Status__c = 'Active';
    Resource.Employee_ID__c ='83643434';
        Resource.supervisor__c = Myuser.Id ;
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
        //List<Artera_Job_Allocation__c> ArteraJobAllocations = new List<Artera_Job_Allocation__c>();
        //ArteraJobAllocations.add(JobAssignmentTest);
        
        Test.startTest();
        SendingEmailThroughSUPERVISORFlow.SendingEmailThroughSUPERVISOR(JobAssignmentTest);
        Test.stopTest();
    

}

}