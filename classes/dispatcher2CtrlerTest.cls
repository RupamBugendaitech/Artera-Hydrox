@isTest
public class dispatcher2CtrlerTest {

    @isTest
    public static void testMethod1(){
        Account acc =new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        
        
        Artera_Job__c job1 = new Artera_Job__c();
        Artera_Region__c reg = new Artera_Region__c(name = 'FL - Tampa');
        String regionName = 'FL - Tampa';
        List<String> regList = new List<String>();
        regList.add(regionName);
        //job1.Name = 'Testing';
        job1.Status__c ='Dispatched - Acknowledged';
        job1.Job_Date__c = System.today();
        job1.account__c = acc.Id;
        job1.Job_Location__c = 'test location';
        insert reg;
        insert job1;
        
        
        Artera_Job__c job2 = new Artera_Job__c();
        //job2.Name = 'f tFilling';
        job2.Status__c ='Dispatched';
        job2.Job_Date__c = System.today();
        job2.account__c = acc.Id;
        job2.Job_Location__c = 'test location';
        insert job2;
        list<id> jobids = new list<id>();
        jobids.add(job2.Id);
        jobids.add(job1.Id);
        
        Artera_Resource__c resource = new Artera_Resource__c();
        resource.Name = 'test operator';
        resource.Email__c = 'aamir@bugendaitech.com';
        resource.Salesforce_User__c = userinfo.getUserId();
        resource.Employee_ID__c = 'test emp';
        insert resource; 
        
        Artera_Job_Allocation__c alloc = new Artera_Job_Allocation__c();
        alloc.Artera_Resource__c = resource.Id;
        alloc.Job__c = job1.Id ;
        alloc.Start_Time__c = null; 
        alloc.End_Time__c = null;
        alloc.Lunch_Time__c =20;
        alloc.Per_Diem__c = 'Yes';
        insert alloc;
        
        
        Job_Ticket__c jobticket = new Job_Ticket__c();
        jobticket.Job1__c = job1.id;
        jobticket.Location__c='Atlanta';
        insert jobticket;
        
        Job_Ticket_Detail__c jobticketdetails = new Job_Ticket_Detail__c();
        jobticketdetails.Job_Ticket__c = jobticket.Id;
        insert jobticketdetails;
        
        Test.startTest();
        dispatcher2ctrler.updateAssignmentData(alloc);
        dispatcher2ctrler.updateTicketData(jobticket);
        dispatcher2ctrler.deleteAssigns(alloc.id);
        //dispatcher2ctrler.getSearchList('All', '');
        //dispatcher2ctrler.getSearchList('My', '');
        dispatcher2ctrler.getAllJobAllocationsForDis('All', true);
        dispatcher2ctrler.getAllJobAllocationsForDisRefreshData('All', true);
        dispatcher2ctrler.getSearchListByFilter('My','',null,regList,true);
        dispatcher2ctrler.getSearchListByFilter('All','',null,regList,true);
        Test.stopTest();
    }
    @isTest
    static void JobAllocationWrapperTest()
    {
         Account acc =new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        
        Artera_Job__c job1 = new Artera_Job__c();
        Artera_Region__c reg = new Artera_Region__c(name = 'FL - Tampa');
        String regionName = 'FL - Tampa';
        List<String> regList = new List<String>();
        regList.add(regionName);
        //job1.Name = 'Testing';
        job1.Status__c ='Dispatched - Acknowledged';
        job1.Job_Date__c = System.today();
        job1.account__c = acc.Id;
        job1.Job_Location__c = 'test location';
        insert reg;
        insert job1;
        
        Artera_Resource__c resource = new Artera_Resource__c();
        resource.Name = 'test operator';
        resource.Email__c = 'aamir@bugendaitech.com';
        resource.Salesforce_User__c = userinfo.getUserId();
        resource.Employee_ID__c = 'test emp';
        insert resource; 
        
        Artera_Job_Allocation__c alloc = new Artera_Job_Allocation__c();
        alloc.Artera_Resource__c = resource.Id;
        alloc.Job__c = job1.Id ;
        alloc.Start_Time__c = null; 
        alloc.End_Time__c = null;
        alloc.Lunch_Time__c =20;
        alloc.Per_Diem__c = 'Yes';
        insert alloc;
        
        // Parameters 
        String URLs = '/' +alloc.Id ;
        string AllocationName =alloc.Name;
        string ResNameEx = 'John'; 
        
        string ResEmpId = '12323453123';
        string JobAllocStatus = 'Assigned';
        //dispatcher2ctrler.JobAllocWrapper(alloc.Id , AllocationName,alloc.Id ,ResNameEx,ResEmpId,JobAllocStatus);

    }
     @isTest
     static  void testIncrement() {
         Test.startTest();
        dispatcher2Ctrler.justIncrement();
 		Test.stopTest();
     }
}