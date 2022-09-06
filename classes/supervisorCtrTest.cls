@isTest
public with sharing class supervisorCtrTest {
    @isTest
    public static void getAllStatusTest(){
        supervisorCtr.PROFILENAME_TEST = 'Hydro-X Supervisor';

        System.Test.startTest();
            List<String> allStatus = SupervisorCtr.getAllStatus();
         	SupervisorCtr.PROFILENAME_TEST = 'Hydro-X Supervisor';
            allStatus = SupervisorCtr.getAllStatus();
            SupervisorCtr.PROFILENAME_TEST = 'Hydro-X Admin';
            allStatus = SupervisorCtr.getAllStatus();
            SupervisorCtr.PROFILENAME_TEST = 'Hydro-X Account Receivables';
            allStatus = SupervisorCtr.getAllStatus();
            SupervisorCtr.PROFILENAME_TEST = 'System Administrator';
            allStatus = SupervisorCtr.getAllStatus();

        System.Test.stopTest();
    }

    @isTest
    public static void approveJobsTest(){
        supervisorCtr.PROFILENAME_TEST = 'Hydro-X Supervisor';
        //Artera_Job__c theJob = new Artera_Job__c(/*Name = 'Test Job'*/);
        Artera_Job__c theJob = new Artera_Job__c();
        insert theJob;
        List<String> jobIds = new List<String>{theJob.Id};

        System.Test.startTest();       
            SupervisorCtr.approveJobs(jobIds);
        	SupervisorCtr.PROFILENAME_TEST = 'Hydro-X Supervisor';
        	SupervisorCtr.approveJobs(jobIds);
            SupervisorCtr.PROFILENAME_TEST = 'Hydro-X Admin';
            SupervisorCtr.approveJobs(jobIds);
            SupervisorCtr.PROFILENAME_TEST = 'Hydro-X Account Receivables';
            SupervisorCtr.approveJobs(jobIds);
            SupervisorCtr.PROFILENAME_TEST = 'System Administrator';
            SupervisorCtr.approveJobs(jobIds);
        System.Test.stopTest();
    }

    @isTest
    public static void getSearchListTest(){
        supervisorCtr.PROFILENAME_TEST = 'Hydro-X Supervisor';
        List<String> allStatus = SupervisorCtr.getAllStatus();

        Id userId = UserInfo.getUserId(); 
        Artera_Job__c theJob = new Artera_Job__c(
            //Name = 'Test Job a',
            Supervisor__c = userId, Status__c = allStatus[0],
            Job_Date__c = System.today()
        );
        Artera_Region__c reg = new Artera_Region__c(name = 'FL - Tampa');
        String regionName = 'FL - Tampa';
        List<String> regList = new List<String>();
        regList.add(regionName);
        insert theJob;

        System.Test.startTest();
            SupervisorCtr.getSearchListByFilter('My', '', null,regList);
            SupervisorCtr.getSearchListByFilter('All','a',null,regList);
            
            SupervisorCtr.PROFILENAME_TEST = 'System Administrator';
            theJob = new Artera_Job__c(
                // Name = 'Test Job b', 
                Supervisor__c = userId, Status__c = 'Assignment in Progress',
                Job_Date__c = System.today()
            );
            insert theJob;
            SupervisorCtr.getSearchListByFilter('My', '', null, regList);
            SupervisorCtr.getSearchListByFilter('All', 'a', null, regList);
        System.Test.stopTest();

    }

    @isTest
    public static void getSearchListByDateTest(){
        supervisorCtr.PROFILENAME_TEST = 'Hydro-X Supervisor';
        List<String> allStatus = SupervisorCtr.getAllStatus();

        Id userId = UserInfo.getUserId(); 
        Artera_Job__c theJob = new Artera_Job__c(
            //Name = 'Test Job a', 
            Supervisor__c = userId, Status__c = allStatus[0],
            Job_Date__c = System.today()
        );
        insert theJob;

    }

    @isTest
    public static void getAllJobAllocationsForSupervisorTest(){
        supervisorCtr.PROFILENAME_TEST = 'Hydro-X Supervisor';
        List<String> allStatus = SupervisorCtr.getAllStatus();

        Id userId = UserInfo.getUserId(); 

        Artera_Resource__c resource = new Artera_Resource__c();
                resource.Name = 'Test Resource';
                resource.Employee_ID__c = 'Emp-23251329';
                resource.Email__c = 'simran.vyas@bugendaitech.com';
                insert resource;
        
        Artera_Job__c jobrec= new Artera_Job__c();
        
                jobrec.Job_Date__c= Date.today();
                jobrec.Job_Location__c = 'NYC Testing Job'; 
        		jobrec.Status__c = 'Pending Supervisor Approval'; 
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
         

        System.Test.startTest(); 
            SupervisorCtr.getAllJobAllocationsForSupervisor('All');


            SupervisorCtr.PROFILENAME_TEST = 'System Administrator';
                Artera_Job__c jobrec2 = new Artera_Job__c(); 
                jobrec2.Job_Date__c= Date.today();
                jobrec2.Job_Location__c = 'NYC Testing Job 2'; 
        		jobrec2.Status__c = 'Pending Admin Approval'; 
                insert jobrec2; 
        	SYstem.debug('Data s '+jobrec2);
            SupervisorCtr.getAllJobAllocationsForSupervisor('All');
        System.Test.stopTest();

    }

    

    @isTest
    public static void wrappersCoverageTest(){
        supervisorCtr.PROFILENAME_TEST = 'Hydro-X Supervisor';
        Id userId = UserInfo.getUserId(); 
        List<String> allStatus = SupervisorCtr.getAllStatus();
        Artera_Job__c theJob = new Artera_Job__c(
            //Name = 'Test Job a', 
            Supervisor__c = userId, Status__c = allStatus[0],
            Job_Date__c = System.today()
        );
        insert theJob;
        Artera_Resource__c res = new Artera_Resource__c(
            Employee_ID__c = '12345'
        );
        Artera_Resource__c artRes = new Artera_Resource__c(
            Name = 'someTest Name',
            Employee_ID__c = '12345'
        );
        insert artRes;
        Artera_Job_Allocation__c joal = new Artera_Job_Allocation__c(
            Artera_Resource__c = artRes.Id,
            Job__c = theJob.Id
        );
        insert joal;
        System.Test.startTest();
            SupervisorCtr.JobAllocWrapper jaw = new SupervisorCtr.JobAllocWrapper(
                theJob.Id,
                theJob.Name,
                theJob.Id,
                theJob.Name,
                theJob.Name,
                theJob.Name
            );
            jaw = new SupervisorCtr.JobAllocWrapper(
                new Artera_Job_Allocation__c(),
                theJob.Id,
                theJob.Name,
                theJob.Id,
                theJob.Name,
                theJob.Name,
                theJob.Name
            );
            jaw = new SupervisorCtr.JobAllocWrapper(
                joal
            );
            jaw = new SupervisorCtr.JobAllocWrapper(
                new Artera_Job_Allocation__c(
                    Job__c = theJob.Id
                )
            );


            SupervisorCtr.tktDetWrapper tktdtl = new SupervisorCtr.tktDetWrapper(
                theJob.Id, theJob.Name
            );
            SupervisorCtr.JobTicketWrapper jtw = new SupervisorCtr.JobTicketWrapper(
                theJob.Id, theJob.Name, new List<SupervisorCtr.tktDetWrapper> {tktdtl}
            );

            SupervisorCtr.ResponseData resData = new SupervisorCtr.ResponseData(
                new List<SupervisorCtr.JobDetailsWrapper>(), 2
            );
        
        supervisorCtr.getAllJobAllocationsForSupervisorRefreshData('All');
        System.Test.stopTest();
    }
    
    @isTest
     static  void testIncrement() {
         Test.startTest();
        supervisorCtr.justIncrement();
 		Test.stopTest();
     }
    
}