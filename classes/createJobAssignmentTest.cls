@isTest
public class createJobAssignmentTest {
  /*  @isTest 
    static void addJobTest(){
        // List <Artera_Job_Allocation__c> jobAssignment = new List<Artera_Job_Allocation__c>();
       
       Account acc = new Account();
        acc.Name  = 'Test Account 04';
        insert acc;
        
        List <Artera_Job__c> job = new List<Artera_Job__c>();
        Artera_Resource__c r = new Artera_Resource__c();
        r.Name = 'Tim';
        r.Employee_ID__c = 'E1S50X2BA23';
        r.Email__c= 'ritisha.chavan@artera.com';
        insert r;
        
        List <Leave__c> leaveList = new List<Leave__c>();
        Artera_Resource__c res = new Artera_Resource__c();
        res.Name = 'Elmore, Timothy L';
        res.Employee_ID__c = 'PJE9DX5R7I';
        res.Email__c= 'telmore@hydroexcavators.com';
        insert res;

        Leave__c l = new Leave__c();
        DateTime dt = DateTime.now();
         Time endtime =dt.timeGmt();
        l.Status__c = 'Rejected';
        l.Reason_for_leave_rejection__c= 'Bereave';
        l.Half_Day_Leave__c = true;
        l.Leave_Start_date__c = Date.newInstance(2022, 05, 1);
        l.Leave_End_Date__c = Date.newInstance(2022, 05, 2);
        l.Reason__c = 'HOLWRK';
        l.Half_Day_Leave__c=True;
        l.Leave_Start_Time__c= endtime;
        
        l.Artera_Resource__c = r.Id;
        Insert l;
        
        List <Artera_Job__c> newJob = new List<Artera_Job__c>();
        
        Project__c project = new Project__c();
        project.Name = 'Test Project';
        project.Company_Id__c = '025';
        project.Account__c = acc.Id;
        project.Status__c = 'A';
        insert project;
        
        Test.startTest();
        leaveList.add(l); 
        System.debug('leaveList' + leaveList);
        createJobAssignment.addJob(leaveList);
        Test.stopTest();
    }*/
    
    @isTest static void addJobTest1(){
        List <Leave__c> leaveList1 = new List<Leave__c>();
        Artera_Resource__c r = new Artera_Resource__c();
        r.Name = 'Tom';
        r.Employee_ID__c = 'E1S50X2BA23';
        r.Email__c= 'ritisha.chavan@artera.com';
        insert r;
        
        Leave__c l = new Leave__c();
        l.Status__c = 'Rejected';
        l.Leave_Start_date__c = Date.newInstance(2022, 05, 1);
        l.Leave_End_Date__c = Date.newInstance(2022, 05, 2);
        l.Reason__c = 'HOLWRK';
        l.Reason_for_leave_rejection__c = 'No leaves remaining';
        l.Artera_Resource__c = r.Id;
        
        Test.startTest();
        leaveList1.add(l);
        System.debug('leaveList1' + leaveList1);
        createJobAssignment.addJob(leaveList1);
        Test.stopTest();
    }  
     @isTest
     static  void testIncrement() {
         Test.startTest();
        createJobAssignment.justIncrement();
 		Test.stopTest();
     }
}