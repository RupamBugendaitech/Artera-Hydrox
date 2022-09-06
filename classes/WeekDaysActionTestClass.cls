@isTest
public class WeekDaysActionTestClass {
    @isTest
    public static void testMethod1()
    {        
       List<Artera_Job__c> jobList=new List<Artera_Job__c>();
            Artera_Job__c  job = new Artera_Job__c (
                    Job_Date__c = date.ValueOf('2022-09-21'),
                    Project__c = 'a1i8Z000006N8nvQAC',
                    Contact__c = '0038Z00002qR43NQAS',
                    Job_Location__c = 'US',
                    Job_Description__c = 'Description',
                    Customer_Job_No__c = '986577',
            created_by_using_multi_Job_creation__c = True);
        //jobList.add(aJob);
        system.debug(jobList);
        insert job;
        test.startTest();
               WeekDaysActionClass.WeekDaysActionClasswrapper pp=new WeekDaysActionClass.WeekDaysActionClasswrapper();

        List<WeekDaysActionClass.WeekDaysActionClasswrapper> pp1=new List<WeekDaysActionClass.WeekDaysActionClasswrapper>();
         pp.strtDate=date.ValueOf('2022-09-21');
         pp.Projects= 'a1i8Z000006N8nvQAC';
         pp.enddate=date.ValueOf('2022-09-22');
         pp.daysList='Monday;Tuesday';
         pp.Contacts='0038Z00002qR43NQAS';
         pp.Location='US';
         pp.Description= 'Description';
         pp.Customer_Job_Number='Description';
        pp1.add(pp);
           WeekDaysActionClass.calculateDayWeeks(pp1);  
        test.stopTest();
    }
     @isTest
     public static void testMethod2()
    {        
       List<Artera_Job__c> jobList=new List<Artera_Job__c>();
            Artera_Job__c  job = new Artera_Job__c (
                    Job_Date__c = date.ValueOf('2022-09-21'),
                    Project__c = 'a1i8Z000006N8nvQAC',
                    Contact__c = '0038Z00002qR43NQAS',
                    Job_Location__c = 'US',
                    Job_Description__c = 'Description',
                    Customer_Job_No__c = '986577',
                    created_by_using_multi_Job_creation__c = True);
        //jobList.add(aJob);
        system.debug(jobList);
        insert job;
        test.startTest();
               WeekDaysActionClass.WeekDaysActionClasswrapper pp=new WeekDaysActionClass.WeekDaysActionClasswrapper();

        List<WeekDaysActionClass.WeekDaysActionClasswrapper> pp1=new List<WeekDaysActionClass.WeekDaysActionClasswrapper>();
         pp.strtDate=date.ValueOf('2022-09-21');
         pp.Projects= 'a1i8Z000006N8nvQAC';
         pp.enddate=date.ValueOf('2022-09-22');
         pp.daysList='';
         pp.Contacts='0038Z00002qR43NQAS';
         pp.Location='US';
         pp.Description= 'Description';
         pp.Customer_Job_Number='Description';
        pp1.add(pp);
           WeekDaysActionClass.calculateDayWeeks(pp1);  
        test.stopTest();
    }
}