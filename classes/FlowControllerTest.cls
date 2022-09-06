@isTest
Public  class FlowControllerTest {
    
    @TestSetup
    static void makeData(){
                    
        
               UserRole r = new UserRole(DeveloperName = 'MyCustomRole' , Name = 'MyRole');
        insert r ;
			
        
        User u = new User(
        	ProfileId=[SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'Kamran',
            Email = 'Kkamran336@gmail.com',
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
        insert u;

        
        
        
    }
    
    @isTest
    public static void CallingFlowTest() {
        
        
        Artera_Job__c TestJob = new Artera_Job__c();
        //TestJob.Name = 'SampleJob';
        TestJob.Job_Location__c = 'Georgia';
        insert TestJob;
        List<Artera_Job_Allocation__c> JobAllocToInsert = new List<Artera_Job_Allocation__c>();
        

        for (Integer i= 0 ; i<3 ; i++)
        {
            
            //TestJobAllocation.Name = 'SampleJobAllocation' + i;
            //TestJobAllocation.Job__c= Testjob.id ;
            JobAllocToInsert.add(new Artera_Job_Allocation__c(Job__c=TestJob.Id));
        } 
        Insert JobAllocToinsert ;
        
        
        User Myuser = [SELECT ID ,Name FROM user WHERE LastName = 'Kamran' LIMIT 1];
        
        List<String> JobIdList = new List<Id>();
        Artera_Job__c Arterajob = [SELECT Id , Name FROM Artera_Job__c WHERE Job_location__c = 'Georgia' LIMIT 1];
        string ArtJobId =ArteraJob.Id ;
        List<Artera_Job_Allocation__c> JobIds = new List<Artera_Job_Allocation__c> ();
        jobIds = [SELECT Id ,Job__c , Name FROM Artera_Job_Allocation__c WHERE Job__c =: ArtjobId ];
        for(Artera_Job_Allocation__c obj : jobIds )
        {
            JobIdList.add(obj.Id);
        }
		
        
        
        test.startTest();
        System.runAs(Myuser){
        FlowController.callingFlow(JobIdList);
        }
            test.stopTest();
    
    }

    }