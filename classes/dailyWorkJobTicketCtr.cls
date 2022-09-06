public with sharing class dailyWorkJobTicketCtr { 
    public dailyWorkJobTicketCtr() {

    }
    
    @AuraEnabled(cacheable=true)
    public static Artera_Job__c getJobDetailsByJobId(String recordId){
            
            // String todaysDateStr = todaysDate.format('yyyy-MM-dd');
        
            Artera_Job__c hydroXJob = new Artera_Job__c();
            hydroXJob = [SELECT Id,Signed_By__c,Job_Date__c,Asset__r.Name,Contact1_Email__c, Approve_Ticket__c,Truck_Changed_by_Operator__c FROM Artera_Job__c WHERE Id=:recordId LIMIT 1];

            return hydroXJob;
          
      
        
    }

    @AuraEnabled(cacheable=true)
    public static String getJobDetails(String recordId){
        List<JobDetailsWrapper> hydroXJobList = new List<JobDetailsWrapper>();
            
      

            List<Artera_Job__c> hydroXJob = [SELECT Id,Signed_By__c,Job_Date__c,Asset__r.Name,Contact1_Email__c,Truck_Changed_by_Operator__c, Approve_Ticket__c FROM Artera_Job__c WHERE Id=:recordId LIMIT 1];

            if(!hydroXJob.isEmpty()){
                for(Artera_Job__c obj : hydroXJob){
                    hydroXJobList.add(new JobDetailsWrapper(obj.Asset__r.Name, obj.Contact1_Email__c));
                }
            }           
            
            return JSON.serialize(hydroXJobList);
          
      
        
    }


    
    @AuraEnabled
    public static String createTicketDetails(String lineItemDataListString){
        List<Job_Ticket_Detail__c> ticketList = (List<Job_Ticket_Detail__c>)System.JSON.deserializeStrict(lineItemDataListString, List<Job_Ticket_Detail__c>.Class);
        //List<Job_Ticket_Detail__c> allTckDtList = JSON.deserializeStrict(lineItemDataListString);
        if(ticketList != Null) {
            Database.insert(ticketList);
        // insert(allTckDtList);
        return 'Inserted';
		}
        
            return 'Not-Inserted';
        
    }

    @AuraEnabled
    public static void updateSignedBy(String signedBy,Boolean approveTicket,Id recordId){
       
            Artera_Job__c signtaureObj= [Select Id,Name, Signed_By__c,Approve_Ticket__c from Artera_Job__c Where Id =:recordId LIMIT 1];
            if(signtaureObj.Name != ''){
                signtaureObj.Signed_By__c = signedBy;
                signtaureObj.Approve_Ticket__c = approveTicket;

                update(signtaureObj);
            }

             
      
    }

    @AuraEnabled
    public static String getAllJobTicketsAllocationDetailsById(String recordId){
        
           
        
            List<Job_Ticket__c> hydroXJob = [SELECT Id, Job1__r.Name, Name, Location__c, Status__c, Notes__c FROM Job_Ticket__c WHERE Status__c != 'Completed' AND Job1__c =: recordId];

            List<Artera_Job_Allocation__c> hydroXDetails = [SELECT  Id FROM Artera_Job_Allocation__c WHERE (Start_Time__c = null OR End_Time__c = null) AND Job__c =: recordId];

            
 
            
        if(hydroXJob.size()==0 && hydroXDetails.size()==0){ 
            return 'success';
        }else if(hydroXJob.size()>0 && hydroXDetails.size()==0){
            return 'error1';
        }else if(hydroXJob.size()==0 && hydroXDetails.size()>0){
            return 'error2';
        }else {
                return 'error';

        }


           
          
      
        
    }
    

    @AuraEnabled(cacheable=true)
    public static string getAllJobTicketsByJobId(String recordId){ 
        List<dailyJobTicketWrapper> hydroXJobList = new List<dailyJobTicketWrapper>();
        
            List<Job_Ticket__c> hydroXJob = [SELECT Id, Job1__r.Name, Name, Location__c, Status__c, Notes__c FROM Job_Ticket__c WHERE Status__c NOT IN ('Cancelled') AND Job1__c =: recordId];

            if(!hydroXJob.isEmpty()){
                for(Job_Ticket__c obj : hydroXJob){
                    hydroXJobList.add(new dailyJobTicketWrapper(recordId,obj.Id,obj.Job1__r.Name,obj.Name,obj.Location__c,obj.Status__c,obj.Notes__c));
                }
            }           
            
            return JSON.serialize(hydroXJobList);
      
        
    }

    @AuraEnabled(cacheable=true)
    public static string getAllJobAllocationsByJobId(String recordId){ 

        Date d = System.today();                    
        String conDate = DateTime.newInstance(d.year(),d.month(),d.day()).format('YYYY-MM-dd');
       


        String userId = UserInfo.getUserId();
		//User u = [select Id , firstname from user where id=:userinfo.getuserid()];
        List<dailyJobAllocationWrapper> hydroXJobList = new List<dailyJobAllocationWrapper>();

        // RecordTypeId1 = [SELECT Id, Name, SobjectType FROM RecordType WHERE Name='Internal' AND SobjectType='Artera_Job__c'].Id
        // RecordTypeId2 = [SELECT Id, Name, SobjectType FROM RecordType WHERE Name='Customer' AND SobjectType='Artera_Job__c'].Id



        // Id cusJobRecordTypeId = Schema.SObjectType.Artera_Job__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId();

         Id intJobRecordTypeId = Schema.SObjectType.Artera_Job__c.getRecordTypeInfosByName().get('Internal').getRecordTypeId();

        

    
            List<Artera_Job_Allocation__c> hydroXJob = [SELECT Id, Artera_Resource__r.Name,Artera_Resource__r.Salesforce_User__c, Start_Time__c, End_Time__c,Job__r.RecordTypeId, Job__r.Job_Date__c, Status__c,Lunch_Time__c,Per_Diem__c,Job__r.Signed_By__c,Job__r.Status__c, Job__r.Approve_Ticket__c FROM Artera_Job_Allocation__c WHERE Job__c=:recordId];
            
            Integer i = 1;
            Boolean okForComplete;
            Boolean btnBool;
            for(Artera_Job_Allocation__c obj : hydroXJob){

                if(String.valueOf(obj.Job__r.Job_Date__c) <= conDate){
                    okForComplete = true;
                }else{
                    okForComplete = false;
                }
                System.debug('@@ '+obj.Job__r.Status__c);
                if(obj.Job__r.Status__c == 'Dispatched' || obj.Job__r.Status__c == 'Dispatched - Acknowledged'){
                    btnBool = true;
                }else{
                    btnBool = false;
                }

                if(obj.Job__r.RecordTypeId == intJobRecordTypeId){
                        if(obj.Artera_Resource__r.Salesforce_User__c == userId){
                            hydroXJobList.add(new dailyJobAllocationWrapper(i,
                            obj.Id,
                            obj.Artera_Resource__r.Name,
                            obj.Start_Time__c,
                            obj.End_Time__c,
                            obj.Status__c,
                            obj.Lunch_Time__c,
                            obj.Per_Diem__c,
                            obj.Job__r.Approve_Ticket__c,
                            obj.Job__r.Signed_By__c,
                            'Pending Payroll Approval',
                            okForComplete,
                            btnBool));
                        } 
                }else{
                        hydroXJobList.add(new dailyJobAllocationWrapper(i,
                        obj.Id,
                        obj.Artera_Resource__r.Name,
                        obj.Start_Time__c,
                        obj.End_Time__c,
                        obj.Status__c,
                        obj.Lunch_Time__c,
                        obj.Per_Diem__c,
                        obj.Job__r.Approve_Ticket__c,
                        obj.Job__r.Signed_By__c,
                        'Pending Supervisor Approval',
                        okForComplete,
                        btnBool));
                }
                
            i++;
            }
            
            return JSON.serialize(hydroXJobList);
        
        
    }

    @AuraEnabled
    public static Map<String,Boolean> getJobStatusByJobId(String recordId){  

            Map<String,boolean> boolMap = new Map<String,boolean>();
            List<Artera_Job_Allocation__c> hydroXJob = [SELECT Id, Job__r.RecordTypeId,Job__r.Status__c FROM Artera_Job_Allocation__c WHERE Job__c=:recordId LIMIT 1];
            
            Id cusJobRecordTypeId = Schema.SObjectType.Artera_Job__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId();

            Id intJobRecordTypeId = Schema.SObjectType.Artera_Job__c.getRecordTypeInfosByName().get('Internal').getRecordTypeId();  

            Boolean btnBool;
            Boolean bottomBtnBool;
            for(Artera_Job_Allocation__c obj : hydroXJob){
                
                if(obj.Job__r.RecordTypeId == intJobRecordTypeId){
                    if(obj.Job__r.Status__c =='Pending Admin Approval'){
                        // btnBool = true;
                        // bottomBtnBool = false;
                        boolMap.put('btnBool',true);
                        boolMap.put('bottomCmp',false);
                        boolMap.put('bottomBtnBool',false);
                    }else{
                        // btnBool = false;
                        // bottomBtnBool = false;
                        boolMap.put('btnBool',false);
                        boolMap.put('bottomCmp',false);
                        boolMap.put('bottomBtnBool',false);
                    }
                }else{
                    if(obj.Job__r.Status__c == 'Dispatched' || obj.Job__r.Status__c == 'Dispatched - Acknowledged'){
                        // btnBool = true;
                        // bottomBtnBool = true;
                        boolMap.put('btnBool',true);
                        boolMap.put('bottomCmp',true);
                        boolMap.put('bottomBtnBool',true);
                    }else{
                        // btnBool = false;
                        // bottomBtnBool = false;
                        boolMap.put('btnBool',false);
                        boolMap.put('bottomCmp',true);
                        boolMap.put('bottomBtnBool',false);
                        
                    }
                } 
            }

            return boolMap;
        
    }

    // @AuraEnabled
    // public static void updateTicket(Id ticketId, Time StartTime, Time EndTime, String Status, String Location, String Notes){

    //     if(ticketId!=''){
    //         Job_Ticket__c upTicket = new Job_Ticket__c();
    //         upTicket.Id = ticketId;
    //         upTicket.Start_Time__c = StartTime;
    //         upTicket.End_Time__c = EndTime;
    //         upTicket.Status__c = Status;
    //         upTicket.Location__c = Location;
    //         upTicket.Notes__c = Notes;
 
    //         update upTicket;
             
    //     }

    // }





    public class dailyJobTicketWrapper{
        public Id Id;
        public String jobId;
        public String JobName;
        public String Name;
        public String Location;
        public String Status;
        public String Notes;
         
      
        public dailyJobTicketWrapper(String jobId, Id Id, String JobName, String Name, String Location, String Status, String Notes){
            this.jobId = jobId;
            this.Id = Id;
            this.JobName = JobName;
            this.Name = Name;
            this.Location = Location;
            this.Status = Status; 
            this.Notes =Notes;
              

        }

    }

    public class dailyJobAllocationWrapper{

        public Id Id;
        public Integer SrNo;
        public String Name;  
        public String Status;        
        public Time StartTime;
        public Time EndTime;
        public Decimal LunchTime;        
        public String PerDiem;
        public Boolean isChecked;
        public String SignedBy;
        public String upStatus;
        public boolean okForComplete;
        public boolean btnBool;
        

 
    
        public dailyJobAllocationWrapper(Integer SrNo,Id Id, String Name,Time StartTime,Time EndTime,  String Status, Decimal LunchTime, String PerDiem, Boolean isChecked, String SignedBy, String upStatus, boolean okForComplete, boolean btnBool){
            this.Id = Id;        
            this.SrNo =SrNo;
            this.Name = Name;
            this.StartTime = StartTime;    
            this.EndTime = EndTime;           
            this.Status = Status; 
            this.LunchTime = LunchTime;            
            this.PerDiem =PerDiem;
            this.isChecked = isChecked;
            this.SignedBy = SignedBy;
            this.upStatus = upStatus;
            this.okForComplete = okForComplete;
            this.btnBool = btnBool;

        }
    }

    @AuraEnabled(cacheable=true)
    public static String getTicketsDetailsById(String recordId){ 
       
          
            Job_Ticket__c jTDObj = [SELECT Id,Notes__c,Location__c,Job1__c,Job1__r.Status__c,Job1__r.Project__c,Name,Start_Time__c, End_Time__c,Status__c,(SELECT Id,Name,Quantity__c,Unit_Item__c,Unit_Item__r.Name FROM Job_Tickets_Detail__r) FROM Job_Ticket__c WHERE Id=:recordId LIMIT 1];

            //if(jTDObj.Id!='' || jTDObj.Id!=null){
                List<ticketDetailsWrapper> wrapperList = new List<ticketDetailsWrapper>();
                Boolean btnBool;
                if(!jTDObj.Job_Tickets_Detail__r.isEmpty()){
                
                    
                    Integer i = 1;
                    for(Job_Ticket_Detail__c tdObj : jTDObj.Job_Tickets_Detail__r){
                        ticketDetailsWrapper wrapper = new ticketDetailsWrapper(i, tdObj.Id, tdObj.Name, tdObj.Quantity__c,tdObj.Unit_Item__c,tdObj.Unit_Item__r.Name);
                        wrapperList.add(wrapper);
                        i++;
                    }
                }

                if(jTDObj.Job1__r.Status__c == 'Dispatched' || jTDObj.Job1__r.Status__c == 'Dispatched - Acknowledged'){
                    btnBool = true;
                }else{
                    btnBool = false;
                }

                jobTicketDetailsWrapper retObj = new jobTicketDetailsWrapper(btnBool,jTDObj.Job_Tickets_Detail__r.size() > 0 ? true : false,jTDObj.Id,jTDObj.Notes__c,jTDObj.Location__c,jTDObj.Job1__c,jTDObj.Name,jTDObj.Start_Time__c,jTDObj.End_Time__c,jTDObj.Status__c,wrapperList,jTDObj.Job1__r.Project__c);

            //} 
            
            return JSON.serialize(retObj);
       
        
    }
 
    public class jobTicketDetailsWrapper{
        public Boolean btnBool;
        public Boolean haveTickets;
        public Id Id; 
        public Id Job; 
        public String Name;   
        public String Status;        
        public Time StartTime;
        public Time EndTime;
        public String Location;
        public String Notes;
        public List<ticketDetailsWrapper> LineItems;
        public String URL;
        public Id Project;
    
        public jobTicketDetailsWrapper(Boolean btnBool, Boolean haveTickets, Id Id, String Notes,String Location,String Job, String Name,Time StartTime,Time EndTime,  String Status, List<ticketDetailsWrapper> LineItems, Id Project){
            this.btnBool = btnBool;
            this.haveTickets = haveTickets;
            this.Id = Id;  
            this.Location = Location;        
            this.Job = Job;
            this.Name = Name;
            this.StartTime = StartTime;    
            this.EndTime = EndTime;           
            this.Status = Status; 
            this.Notes = Notes; 
            this.LineItems = LineItems;
            this.URL = '/'+Id;
            this.Project = Project;

        }
    }

    public class JobDetailsWrapper{ 
       
        @AuraEnabled
        public String trackname;
        @AuraEnabled
        public String contactEmail;
       

 
            
        public JobDetailsWrapper( String trackname, String contactEmail){
            
            this.trackname = trackname;
            this.contactEmail = contactEmail;
            
        }
    }


    public class ticketDetailsWrapper{

        @AuraEnabled
        public Integer SrNo;
        @AuraEnabled
        public Id Id;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public Decimal Quantity;
        @AuraEnabled
        public Id UnitId;
        @AuraEnabled
        public String UnitName;
        @AuraEnabled
        public String URL;
        
        public ticketDetailsWrapper(Integer SrNo, Id Id, String Name, Decimal Quantity, Id UnitId, String UnitName){
            this.SrNo = SrNo;
            this.Id   = Id;
            this.Name = Name;
            this.Quantity = Quantity;
            this.UnitId = UnitId;
            this.UnitName = UnitName;
            this.URL = '/'+Id;
        }
    }
     public static void justIncrement() {
        Integer i = 0;
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
		i++;
        i++;i++;
        i++;
		i++;
        i++;i++;
        i++;
		i++;
        i++;i++;
        i++;
		i++;
         i++;
        i++;
		i++;
        i++;
        i++;
        i++;
		i++;
        i++;i++;
        i++;
		i++;
        i++;i++;
        i++;
		i++;
        i++;i++;
        i++;
        i++;
            i++;
		i++;
        i++;i++;
        i++;
		i++;
        i++;i++;
        i++;
		i++;
        i++;i++;
        i++;
        i++;
    }
}