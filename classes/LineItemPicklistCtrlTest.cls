@isTest
public class LineItemPicklistCtrlTest {
    
    @isTest
	public static void LineItemPicklistCtrlTest()
    {
      LineItemPicklistCtrl NewCtrl = new LineItemPicklistCtrl();
        
    }

    @isTest
    public static void getLineItemsListTest() {

        Unit_Item__c NewUnitItem = new Unit_Item__c ();
        NewUnitItem.Name ='product' ;
        insert NewUnitItem;
        Project__c Newproject = new Project__c ();
        NewProject.Name = 'MyProject';
        insert Newproject ;


        Project_Item__c NewProjectItem = new Project_Item__c();
        NewProjectItem.Name = 'MyProjectItem' ;
        NewProjectItem.Project__c = Newproject.ID ;
        NewProjectItem.Item__c = NewUnitItem.ID;
        Insert NewProjectItem ;
        string recordId = NewProject.Id;
        Test.startTest();
        LineItemPicklistCtrl.getLineItemsList(recordId);
        Test.stopTest();
    }
}