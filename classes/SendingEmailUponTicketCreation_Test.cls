@IsTest(SeeAllData=true)
public class SendingEmailUponTicketCreation_Test {
    
    @isTest
    static void sendemailnotifytest(){
        
        List<Artera_Job__c> ArtJob = new List<Artera_Job__c>();
        
        Artera_Resource__c resource = new Artera_Resource__c();
                resource.Name = 'Test Resource';
                resource.Employee_ID__c = 'Emp-22451678';
                resource.Email__c = 'simran.vyas@bugendaitech.com';
                insert resource;
        
        Artera_Job__c jobrec= new Artera_Job__c();
                jobrec.Job_Date__c= Date.today();
                jobrec.Job_Location__c = 'NYC Testing Job'; 
                insert jobrec;     
                     
        Artera_Job_Allocation__c jobAllocation = new Artera_Job_Allocation__c();
                jobAllocation.Artera_Resource__c = resource.Id;
                jobAllocation.Job__c = jobrec.Id;
                insert  jobAllocation; 
         
        List<Job_Ticket__c> jobTktList = new List<Job_Ticket__c>();
                for(Integer i=1; i<5 ; i++){
                    Job_Ticket__c jobTktObj = new Job_Ticket__c();
                    jobTktObj.Location__c = 'Location '+i;
                    jobTktObj.job1__c = jobrec.Id;
                    jobTktList.add(jobTktObj);
                }
                insert jobTktList;
        
        ArtJob.add(jobrec);
         
        Test.startTest();
        SendingEmailUponTicketCreation.SendingEmailToResources(ArtJob);      
        Test.stopTest(); 
        
    }
    
}