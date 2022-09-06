@isTest
public with sharing class CustomLookupLwcControllerTest {
    @isTest
    public static void test1() {

        Artera_Job__c sobj= new Artera_Job__c();
//        sobj.Name = 'test';
        insert sobj;

        Test.startTest();
        CustomLookupLwcController.fetchLookupData(sobj.name, 'Artera_Job__c');
        CustomLookupLwcController.fetchDefaultRecord(sobj.Id, 'Artera_Job__c');
        Test.stopTest();
        

    }
}