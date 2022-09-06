@isTest
public class dispatcherCtrlTest {

    @isTest
    public static void testMethod1(){
        Artera_Region__c art = new Artera_Region__c();
        art.Name = 'GA - Conyers';
        insert art;
        List<String> listArt = new List<String>();
        listArt.add(art.id);

        //
        Account acc =new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Artera_Job__c job1 = new Artera_Job__c();
        //job1.Name = '9Filling';
        job1.Status__c ='Dispatched - Acknowledged';
        job1.Job_Date__c = System.today().addDays(1);
        job1.account__c = acc.Id;
        job1.Job_Location__c = 'test location';
        insert job1;
       
        
        Artera_Resource__c resource = new Artera_Resource__c();
        resource.Name = 'test operator';
        resource.Artera_Region__c = art.Id;
        resource.Email__c = 'aamir@bugendaitech.com';
        resource.Salesforce_User__c = userinfo.getUserId();
        resource.Employee_ID__c = 'test emp';
        resource.Worker_Status__c= 'Active';
        resource.Job_Title__c = 'CDL Operator VI';
        insert resource; 
        String name1 = resource.Name;
        Artera_Job_Allocation__c alloc = new Artera_Job_Allocation__c();
        alloc.Artera_Resource__c = resource.Id;
        alloc.Job__c = job1.Id ;
        alloc.Type__c = 'Leave';
        Date today1    = Date.today();
        Date tomorrow1 = today1.addDays(1);     
        alloc.Job_Assignment_Date_Field__c = tomorrow1;
        insert alloc;
        
        Artera_Job_Allocation__c alloc2 = new Artera_Job_Allocation__c();
        alloc2.Artera_Resource__c = resource.Id;
        alloc2.Job__c = job1.Id ;
        alloc2.Type__c = 'Leave';
        Date today2    = Date.today();
        Date tomorrow2 = today2.addDays(1);     
        alloc2.Job_Assignment_Date_Field__c = tomorrow2;
        insert alloc2;
        //
        Test.startTest();
        dispatcherCtrl.getRegionList();
        dispatcherCtrl.getAllResources();

        //dispatcherCtrl.getAllResourcesByFilterByName(resource.Name, null, listArt);
        dispatcherCtrl.getAllResourcesByFilters(resource.Name,tomorrow2, listArt );
        
       // dispatcherCtrl.getAllResourcesByFilterDate(null);
        Test.stopTest();

        
    }
}