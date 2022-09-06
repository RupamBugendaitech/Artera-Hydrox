public class WeekDaysActionClass {
    @InvocableMethod(label = 'DaysWeek Calculation')
    public static void calculateDayWeeks(List<WeekDaysActionClasswrapper> param) {
        Date strtDate = param[0].strtdate;
        Date endDate = param[0].enddate;
        String daysList = param[0].daysList;
        String Contacts = param[0].Contacts;
        String Projects  = param[0].Projects;
        String Location = param[0].Location;
        String Description = param[0].Description;
        String Customer_Job_Number = param[0].Customer_Job_Number;
        String StartTime = param[0].StartTime;

        List<Artera_Job__c> jobList = new List<Artera_Job__c>();
        Artera_Job__c aJob;

        List<String> daylst = new List<String>();

        if(daysList != null){
            daylst = daysList.split(';'); 
            // System.debug('day'+daylst);
        }

        System.debug('startdate:: ' + strtDate);
        System.debug('enddate:: ' + endDate);
        System.debug('dayList:: ' + daylst);
      String[] strTimeSplit = StartTime.split(':');
  Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                     ,Integer.valueOf(strTimeSplit[1]) //min
                                     ,0                                //sec
                                     ,0);                              //ms
        Date sdt = strtDate;
        DateTime dayDate = (DateTime)sdt;
        
        System.debug('outside loop dayDate :: ' + dayDate);
       
        String day;
        Boolean isTrue = false;

        // String timezone  = String.valueof(UserInfo.getTimeZone().getID());
        System.debug('dayDate::'+dayDate);
        // dayDate = dayDate.addDays(1);

        while(dayDate <= endDate){

            system.debug('in loop daysList::' + daysList);

            if(daysList != null && String.isNotEmpty(daysList)){   
                system.debug('date :: ' + dayDate);
                
                day = dayDate.formatGmt('EEEE');
                System.debug('day::'+day);
                System.debug('day Lists::'+daylst);
                // Boolean dayContain = daylst.contains(day);
                //System.debug('dayContain:'+dayContain);
                if(daylst.contains(day)){
                    isTrue = true;
                    system.debug('isTrue: ' + istrue);
                }
            } else{
                isTrue = true;
                system.debug('date :: ' + dayDate);                
                system.debug('if False then isTrue: ' + istrue);
                
            }
            // dateForLoop + 1day
            if(isTrue){
                System.debug('dayDate.date() :: ' + dayDate.dateGmt());
                aJob = new Artera_Job__c (
                    Job_Date__c = dayDate.dateGmt(),
                    Project__c = Projects,
                    Contact__c = Contacts,
                    Job_Location__c = Location,
                    Job_Description__c = Description,
                    Customer_Job_No__c = Customer_Job_Number,
                    created_by_using_multi_Job_creation__c = True,
             	    Start_Date__c = timeChange
   );

                jobList.add(aJob);
                system.debug('List Of Jobs'+jobList);
            }
            
            isTrue = false;
            aJob = null;
            // dateForLoop = dateForLoop.addDays(1);
            dayDate = dayDate.addDays(1);
            system.debug('dayDate + 1 :: '+dayDate);
            // dateForStrt = dateForStrt.addDays(1);
        }
        system.debug('List Of Jobs'+jobList);
        
        try{
            Database.insert(jobList,false);
        }catch(DMLException e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
    }
    public class WeekDaysActionClasswrapper{
        @InvocableVariable(required = true)
        public Date strtDate;
        @InvocableVariable(required = true)
        public Date endDate;
        @InvocableVariable
        public String daysList;
        @InvocableVariable
        public String Contacts;
        @InvocableVariable(required = true)
        public String Projects;
        @InvocableVariable(required = true)
        public String Location;
        @InvocableVariable
        public String Description;
        @InvocableVariable
        public String Customer_Job_Number;
         @InvocableVariable
        public String StartTime;
    }
}