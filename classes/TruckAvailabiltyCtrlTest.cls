@isTest(seeAllData=True)
public class TruckAvailabiltyCtrlTest {
    
    @isTest
    public static void testMethod1(){
        Artera_Region__c art = new Artera_Region__c();
        art.Name = 'GA - Conyers';
        insert art;
        List<String> listArt = new List<String>();
        listArt.add(art.id);
        
        Account acc =new Account();
        acc.Name = 'Test Account 1';
        insert acc;
        
        Artera_Job__c job1 = new Artera_Job__c();
        job1.Status__c ='Dispatched - Acknowledged';
        job1.Job_Date__c = System.today().addDays(1);
        job1.account__c = acc.Id;
        job1.Job_Location__c = 'test location';
        insert job1;
        
        Asset__c asset = new Asset__c();
        asset.Name = '0005';
        asset.Asset_Type__c = 'Truck';
        insert asset; 
        
        Artera_Resource__c resource = new Artera_Resource__c();
        resource.Name = 'test operator';
        resource.Artera_Region__c = art.Id;
        resource.Email__c = 'ritisha.chavan@artera.com';
        resource.Employee_ID__c = 'test emp';
        insert resource; 
        
        Test.startTest();
        TruckAvailabiltyCtrl.getRegionList();
        TruckAvailabiltyCtrl.getAllAsset();
        TruckAvailabiltyCtrl.getAllAssetsByFilters(resource.Name, null, listArt);
        Test.stopTest();
        
    }
    
    
    @isTest
    public static void testMethod2(){
        Artera_Region__c art = new Artera_Region__c();
        art.Name = 'GA - Conyers';
        insert art;
        List<String> listArt = new List<String>();
        listArt.add(art.id);
        
        Account acc =new Account();
        acc.Name = 'Test Account 2';
        insert acc;
        
        Artera_Job__c job2 = new Artera_Job__c();
        job2.Status__c ='Dispatched - Acknowledged';
        Date fDate = Date.newInstance(2012, 04, 22);
        job2.Job_Date__c = fDate;
        job2.account__c = acc.Id;
        job2.Job_Location__c = 'test location';
        insert job2;
        
        Asset__c asset = new Asset__c();
        asset.Name = '0005';
        asset.Asset_Type__c = 'Truck';
        insert asset;
        
        Artera_Resource__c resource = new Artera_Resource__c();
        resource.Name = 'test operator';
        resource.Artera_Region__c = art.Id;
        resource.Email__c = 'ritisha.chavan@artera.com';
        resource.Employee_ID__c = 'test emp';
        insert resource; 
        
        Test.startTest();
        TruckAvailabiltyCtrl.getRegionList();
        TruckAvailabiltyCtrl.getAllAsset();
        TruckAvailabiltyCtrl.getAllAssetsByFilters(resource.Name, fDate, listArt);
        Test.stopTest();
        
    } 
}