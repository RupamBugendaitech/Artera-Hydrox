@isTest
private class UpdateResourceTest {
    // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 40 22 * * ? *' ;
    static testmethod void testScheduledJob() {
        
        Artera_Region__c ArteraRegion= new Artera_Region__c();
        ArteraRegion.Name='MS-Jackson';
        insert ArteraRegion;
        Artera_Resource__c ARR= new  Artera_Resource__c();
        ARR.Home_WorkLocation__c='MS-Jackson';
        ARR.Artera_Region__c= ArteraRegion.Id;  
        ARR.Supervisor_Name__c='TREER098';
        ARR.Employee_ID__c='ARR-00989';
        insert ARR;
        
        
        
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-',''); 
            
            Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id 
                         ); 
        
        insert uu;
        Test.startTest();
        // Schedule the test job
        UpdateResource sc = new UpdateResource();
        string cronExp = '0 40 14 * * ? *';
        string JobId = system.schedule('Update Resource', cronExp, sc);
        Test.stopTest();
        
    }
}