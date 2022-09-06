@isTest(SeeAllData=true)
public  without sharing  class UpdateJobAllocationStatusTest {
  
  @isTest
  public static void handleInboundEmailTest(){
    Artera_Resource__c Resource = new Artera_Resource__c();
    Resource.Name = 'New Resource' ;
       Resource.Worker_Status__c = 'Active';
    Resource.Employee_ID__c ='83649';
    insert Resource ;


    Artera_Job__c Job = new Artera_Job__c ();
    //Job.Name = 'New Job';
    Job.Job_Location__c='Atlanta';

    insert Job ;
   

    Artera_Job_Allocation__c  ArtJobAssignment = new Artera_Job_Allocation__c();
    ArtJobAssignment.Job__c= Job.Id; 
    ArtJobAssignment.Artera_Resource__c = Resource.Id ;
    insert ArtJobAssignment ; 
    string jobid= ArtJobAssignment.id;
    Id sampleId = ArtJobAssignment.Id;
    List<Artera_Job_Allocation__c> obj = [SELECT Id , Name FROM Artera_Job_Allocation__c WHERE Id =:jobid LIMIT 1];
 
    String JNumber =obj[0].Name ;
  
  
	Messaging.InboundEmail email = new Messaging.InboundEmail() ;
    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    email.subject = 'Re: '+JNumber+' Sandbox:';
    email.fromAddress = 'Anybody@email.com';
    email.plainTextBody = 'email body';

    test.startTest();
    UpdateJobAllocationStatus.handleInboundEmail(email , env);
    test.stopTest();

}
  
}