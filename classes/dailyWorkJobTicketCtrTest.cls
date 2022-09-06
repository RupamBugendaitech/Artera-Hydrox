@isTest
public class dailyWorkJobTicketCtrTest {

    @isTest
    public static void testMethod1(){
        Account acc =new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        
        Artera_Job__c job1 = new Artera_Job__c();
        //job1.Name = 'f tFilling';
        job1.Status__c ='Dispatched - Acknowledged';
        job1.Job_Date__c = System.today();
        job1.account__c = acc.Id;
        job1.Job_Location__c = 'test location';
        insert job1;
        
        
        Artera_Job__c job2 = new Artera_Job__c();
        //job2.Name = 'f tFilling';
        job2.Status__c ='Dispatched';
        job2.Job_Date__c = System.today();
        job2.account__c = acc.Id;
        job2.Job_Location__c = 'test location';
        insert job2;
        
       User u = [select Id , firstname from user where id=:userinfo.getuserid()];
            
        Artera_Resource__c resource = new Artera_Resource__c(); 
        resource.Name = 'test operator';
        resource.Email__c = 'aamir@bugendaitech.com';
        resource.Salesforce_User__c = u.Id;
        resource.Employee_ID__c = 'test emp';
        insert resource; 
        
          Artera_Resource__c resource1 = new Artera_Resource__c(); 
        resource1.Name = 'Kamil Kamran';
        resource1.Email__c = 'kkamran336@gmail.com';
        resource1.Salesforce_User__c = u.Id;
        resource1.Employee_ID__c = 'test emp1';
        insert resource1; 
        
        
        
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
        
        Artera_Job__c Job_for_ticket = new Artera_Job__c();
        //job1.Name = 'f tFilling';
        Job_for_ticket.Status__c ='Dispatched';
        Job_for_ticket.Job_Date__c = System.today();
        Job_for_ticket.account__c = acc.Id;
        Job_for_ticket.Approve_Ticket__c = False;
		Job_for_ticket.Job_Location__c = 'test location';
        insert Job_for_ticket;
        Id JobId = Job_for_ticket.Id ;
        
        
        List<Job_Ticket_Detail__c> jobtickdetailsList = new List<Job_Ticket_Detail__c>();
        for(Integer i=0;i<2;i++){
            Job_Ticket_Detail__c jobticketdetails = new Job_Ticket_Detail__c();
            jobticketdetails.Job_Ticket__c = jobticket.Id;
            jobtickdetailsList.add(jobticketdetails);        
        }
        insert jobtickdetailsList;
		//For Both 0 ----------------------------------------------------------------------------------
        Artera_Job__c job3 = new Artera_Job__c();
        job3.Status__c ='Dispatched - Acknowledged';
        job3.Job_Date__c = System.today();
        job3.account__c = acc.Id;
        job3.Job_Location__c = 'test location';
        insert job3;
        
        //For hydroXJob =1 and hydroXDetails = 0-------------------------------------------------------
        Artera_Job__c job4 = new Artera_Job__c();
        job4.Status__c ='Dispatched - Acknowledged';
        job4.Job_Date__c = System.today();
        job4.account__c = acc.Id;
        job4.Job_Location__c = 'test location';
        insert job4;
        
         Artera_Job_Allocation__c alloc2 = new Artera_Job_Allocation__c();
        alloc2.Artera_Resource__c = resource.Id;
        alloc2.Job__c = job4.Id ;
        alloc2.Start_Time__c = null; 
        alloc2.End_Time__c = null;
		alloc2.Lunch_Time__c =20;
        alloc2.Per_Diem__c = 'Yes';
		insert alloc2;
        
          Job_Ticket__c jobticket1 = new Job_Ticket__c();
        jobticket1.Job1__c = job4.id;
        jobticket1.Location__c='Atlanta';
        insert jobticket1;
        
        
        
        Test.startTest();
        dailyWorkJobTicketCtr MyWorkTicket = new dailyWorkJobTicketCtr(); 
        dailyWorkJobTicketCtr.updateSignedBy('KamilK' , True , JobId );
        dailyWorkJobTicketCtr.getJobDetailsByJobId(job1.Id);
        dailyWorkJobTicketCtr.getJobDetails(job1.Id);
        dailyWorkJobTicketCtr.getAllJobTicketsByJobId(job1.Id);
        dailyWorkJobTicketCtr.getAllJobTicketsAllocationDetailsById(job3.id);
          dailyWorkJobTicketCtr.getAllJobTicketsAllocationDetailsById(job4.id);
        System.runAs(u) {
        dailyWorkJobTicketCtr.getAllJobAllocationsByJobId(job1.Id);
        }
        dailyWorkJobTicketCtr.getTicketsDetailsById(jobticket.Id);
        Test.stopTest();
        System.assertEquals('error', dailyWorkJobTicketCtr.getAllJobTicketsAllocationDetailsById(job4.id));
        
    }
     @isTest
     static  void testIncrement() {
         Test.startTest();
        dailyWorkJobTicketCtr.justIncrement();
 		Test.stopTest();
     }
}