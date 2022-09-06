@isTest
private class jobTicketPicklistTest {
    
    @isTest
    public static void positiveScenarioTest(){
        
        // test data
        
        Artera_Job__c artJob = new Artera_Job__c();
        
        
        //artJob.Name             = 'Test Job Name';
        artJob.Job_Location__c  = 'Location Name';
        artJob.Job_Date__c      = Date.today();
        
        
        insert artJob;
        
        Test.startTest();        
        jobTicketPicklist.getTicketNumberLists(artJob.Id);
        Test.stopTest();
    }
    
    
}