@isTest
public class DispatchJobsInBulkTest {

    public static string JobAllocationId = '';
    public static string  JobId ='';
    public static string ResourceId = '';
    public static string ProjectId ='';
    public static string SupervisorId = '';
    public static string USerId = '';
    // public static string JobAllocationId1 = '';
    // public Static string  JobId1 ='';
    // Public Static string ResourceId1 = '';
    // Public static string ProjectId1 ='';
    // Public static string SupervisorId1 = '';
    //Public static string USerId1 = '';

    // new variable

    
    @TestSetup
    static void makeData(){
        
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole' , Name = 'MyRole');
        insert r ;
        
        User u = new User(
            ProfileId=[SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'Kamran',
            Email = 'Kkamran336@gmail.com',
            MobilePhone = '8340277080',
            username = 'kk000@gmail.com' + System.currentTimeMillis(),
            CompanyName ='Artera',
            Title ='Associate Developer',
            Alias ='alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey ='en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = r.Id
        ); 
        UserId = u.Id;
        insert u;
        
        
           UserRole r1 = new UserRole(DeveloperName = 'MyCustomRole1' , Name = 'MyRole1');
    insert r1 ;
    User sup = new User(
        ProfileId=[SELECT Id FROM Profile WHERE Name = 'Hydro-X Supervisor'].Id,
        LastName = 'Kamran Supervisor',
        Email = 'Kkamran336@gmail.com',
        MobilePhone = '8340277080',
        username = 'kk000@gmail.com' + System.currentTimeMillis(),
        CompanyName ='Artera',
        Title ='Associate Developer',
        Alias ='alias',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey ='en_US',
        LocaleSidKey = 'en_US',
        UserRoleId = r1.Id
    );  
    insert sup;        
   
 }
    
    @isTest
    public static void SendSMSToSupervisorTest() {      
      
        User Myuser = [SELECT ID ,Name FROM user WHERE LastName = 'Kamran' LIMIT 1];
        

        Artera_Resource__c resource = new Artera_Resource__c();
        resource.Name = 'Tim';
        resource.Employee_ID__c = 'E1S50X2BA24';
        resource.Email__c= 'test@artera.com';
        resource.Supervisor__c = Myuser.Id;
        resource.Salesforce_User__c = Myuser.Id;
        
        insert resource;
        ResourceId =resource.Id;
        Project__c ProjectTest = new Project__c();
        ProjectTest.Name = 'Test Project company';
        ProjectTest.Status__c = 'A';
        
        insert ProjectTest ;
        ProjectId =ProjectTest.Id ;
        
        Artera_Job__c JobTest = new Artera_Job__c();
        JobTest.Job_Location__c ='Birmingham' ;
        insert JobTest ;
        JobId=JobTest.Id;
        
        Artera_Job_Allocation__c JobAllocationTest = new Artera_Job_Allocation__c();
        JobAllocationTest.Job__c = JobTest.Id ;
        JobAllocationTest.Artera_Resource__c = resource.Id;
        
        insert JobAllocationTest;
        JobAllocationId = JobAllocationTest.Id ;


        Artera_Job_Allocation__c JobAlloc = [SELECT ID, Name ,Artera_Resource__c,Artera_Resource__r.Phone_Number__c,Artera_Resource__r.Supervisor__c,Artera_Resource__r.Supervisor__r.MobilePhone ,Status__c FROM Artera_Job_Allocation__c WHERE Id =: JobAllocationId] ;
        Test.startTest();
        DispatchJobsinBulk.SendSMSToSupervisor(JobAlloc);
        Test.stopTest();
    }

@isTest
public static void SendSMSToOperatotWithNotes()
{

    User Myuser = [SELECT ID ,Name FROM user WHERE LastName = 'Kamran' LIMIT 1];
        

    Artera_Resource__c resource = new Artera_Resource__c();
    resource.Name = 'Tim';
    resource.Employee_ID__c = 'E1S50X2BA23';
    resource.Email__c= 'test@artera.com';
    resource.Supervisor__c = Myuser.Id;
    resource.Salesforce_User__c = Myuser.Id;
    
    insert resource;
    ResourceId =resource.Id;
    Project__c ProjectTest = new Project__c();
    ProjectTest.Name = 'Test Project company';
    ProjectTest.Status__c = 'A';
    
    insert ProjectTest ;
    ProjectId =ProjectTest.Id ;
    
    Artera_Job__c JobTest = new Artera_Job__c();
    JobTest.Job_Location__c ='Birmingham' ;
     insert JobTest ;
     JobId=JobTest.Id;
    
    Artera_Job_Allocation__c JobAllocationTest = new Artera_Job_Allocation__c();
    JobAllocationTest.Job__c = JobTest.Id ;
    JobAllocationTest.Artera_Resource__c = resource.Id;
    
    insert JobAllocationTest;
    JobAllocationId = JobAllocationTest.Id ;

    Artera_Job_Allocation__c JobAlloc = [SELECT ID, Name ,Artera_Resource__c,Artera_Resource__r.Phone_Number__c,Artera_Resource__r.Supervisor__c,Artera_Resource__r.Supervisor__r.MobilePhone ,Status__c FROM Artera_Job_Allocation__c WHERE Id =: JobAllocationId] ;

    Test.startTest();
        DispatchJobsinBulk.SendSMSToOperatorWithNotes(JobAlloc);
        Test.stopTest();

}

@isTest  
public static void SendSMSToOperatorWithoutNotes()
{

    User Myuser = [SELECT ID ,Name FROM user WHERE LastName = 'Kamran' LIMIT 1];
        

    Artera_Resource__c resource = new Artera_Resource__c();
    resource.Name = 'Tim';
    resource.Employee_ID__c = 'E1S50X2BA23';
    resource.Email__c= 'test@artera.com';
    resource.Supervisor__c = Myuser.Id;
    resource.Salesforce_User__c = Myuser.Id;
    
    insert resource;
    ResourceId =resource.Id;
    Project__c ProjectTest = new Project__c();
    ProjectTest.Name = 'Test Project company';
    ProjectTest.Status__c = 'A';
    
    insert ProjectTest ;
    ProjectId =ProjectTest.Id ;
    
    Artera_Job__c JobTest = new Artera_Job__c();
    JobTest.Job_Location__c ='Birmingham' ;
     insert JobTest ;
     JobId=JobTest.Id;
    
    Artera_Job_Allocation__c JobAllocationTest = new Artera_Job_Allocation__c();
    JobAllocationTest.Job__c = JobTest.Id ;
    JobAllocationTest.Artera_Resource__c = resource.Id;
    
    insert JobAllocationTest;
    JobAllocationId = JobAllocationTest.Id ;

    Artera_Job_Allocation__c JobAlloc = [SELECT ID, Name ,Artera_Resource__c,Artera_Resource__r.Phone_Number__c,Artera_Resource__r.Supervisor__c,Artera_Resource__r.Supervisor__r.MobilePhone ,Status__c FROM Artera_Job_Allocation__c WHERE Id =: JobAllocationId] ;

    Test.startTest();
        DispatchJobsinBulk.SendSMSToOperatorWithoutNotes(JobAlloc);
    Test.stopTest();
}

@isTest
public static void SendCustomNotificationTest()
{

    User Myuser = [SELECT ID ,Name FROM user WHERE LastName = 'Kamran' LIMIT 1];
        

    Artera_Resource__c resource = new Artera_Resource__c();
    resource.Name = 'Tim';
    resource.Employee_ID__c = 'E1S50X2BA23';
    resource.Email__c= 'test@artera.com';
    resource.Supervisor__c = Myuser.Id;
    resource.Salesforce_User__c = Myuser.Id;
    
    insert resource;
    ResourceId =resource.Id;
    Project__c ProjectTest = new Project__c();
    ProjectTest.Name = 'Test Project company';
    ProjectTest.Status__c = 'A';
    
    insert ProjectTest ;
    ProjectId =ProjectTest.Id ;
    
    Artera_Job__c JobTest = new Artera_Job__c();
    JobTest.Job_Location__c ='Birmingham' ;
     insert JobTest ;
     JobId=JobTest.Id;
    
    Artera_Job_Allocation__c JobAllocationTest = new Artera_Job_Allocation__c();
    JobAllocationTest.Job__c = JobTest.Id ;
    JobAllocationTest.Artera_Resource__c = resource.Id;
    
    insert JobAllocationTest;
    JobAllocationId = JobAllocationTest.Id ;

    Artera_Job_Allocation__c JobAlloc = [SELECT ID, Name ,Artera_Resource__c,Artera_Resource__r.Phone_Number__c,
                                         Artera_Resource__r.Supervisor__c,Artera_Resource__r.Salesforce_User__c,
                                         Artera_Resource__r.Supervisor__r.MobilePhone ,Job__r.Project__c,
                                         Job__r.Name,
                                         Status__c FROM Artera_Job_Allocation__c WHERE Id =: JobAllocationId] ;

    Test.startTest();
        DispatchJobsinBulk.SendCustomNotification(JobAlloc);
    Test.stopTest();


}
    
     @isTest
     static  void testIncrement() {
         Test.startTest();
        DispatchJobsInBulk.justIncrement();
        Test.stopTest();
     }


}