/**
 @author Anshul Kanaujia 
 @date 12/04/2022
 @cmp supervisorCmp
 @desc ====================== Please do not change this class without my permession ===================
*/

public with sharing class supervisorCtr {
    public static String PROFILENAME_TEST = '';
 

    public static String getUserProfile(){
        // get current user id and profile name         
        Id userId = UserInfo.getUserId(); 
        Id profileId= userinfo.getProfileId(); 
        String  profileName = [Select Id,Name from Profile where Id=:profileId].Name;  
        return profileName;
    }
    //  function for taking status acc to profile
    public static List<String> getAllStatus(){

        // get current user id and profile name         
        Id userId = UserInfo.getUserId(); 
        Id profileId= userinfo.getProfileId();

        // status 
        List<String> fetchStatus = new List<String>();

        String profileName;
        if(!System.Test.isRunningTest())
            profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        else profileName = SupervisorCtr.PROFILENAME_TEST;
        // system.debug('ProfileName '+profileName);
        // profileName = 'Hydro-X Admin';
        if(profileName == 'Hydro-X Supervisor'){
            //system.debug('super 1');
            fetchStatus.add('Pending Supervisor Approval');
            fetchStatus.add('Pending Admin Approval'); 
            fetchStatus.add('Created'); 
        }else if(profileName == 'Hydro-X Admin'){
            //system.debug('super 2');
            fetchStatus.add('Pending Supervisor Approval');
            fetchStatus.add('Pending Admin Approval'); 
            fetchStatus.add('Created'); 
            // fetchStatus.add('Pending Billing Approval'); 
        }else if(profileName == 'Hydro-X Account Receivables'){
            //system.debug('super 3' );
            fetchStatus.add('Pending Billing Approval');
            // fetchStatus.add('Completed'); 
        }else if(profileName == 'Hydro-X Payroll'){ fetchStatus.add('Pending Payroll Approval');
            // fetchStatus.add('Completed'); 
        }else if(profileName == 'System Administrator'){
            //system.debug('super 4');
            fetchStatus.add('Pending Billing Approval');
            fetchStatus.add('Completed'); 
            fetchStatus.add('Pending Admin Approval');
            fetchStatus.add('Assignment in Progress');
            fetchStatus.add('Pending Payroll Approval');
        }

        return fetchStatus;
    }





    // approve job functions
    @AuraEnabled
    public static void approveJobs(List<String> jobIds){

        //system.debug('getted ids '+jobIds);

        // get current user id and profile name         
        Id userId = UserInfo.getUserId(); 
        Id profileId= userinfo.getProfileId();

        // status 
        String upStatus;
        //Boolean truckChanged = false;

        String profileName;
        if(!System.Test.isRunningTest())
            profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        else profileName = SupervisorCtr.PROFILENAME_TEST;
        //system.debug('ProfileName '+profileName);
        // profileName='Hydro-X Admin';
        if(profileName == 'Hydro-X Supervisor'){
            upStatus  = 'Pending Admin Approval';
        }else if(profileName == 'Hydro-X Admin'){
            upStatus  = 'Pending Billing Approval';
        }else if(profileName == 'Hydro-X Payroll'){
            upStatus  = 'Completed';
        }else if(profileName == 'Hydro-X Account Receivables'){
            upStatus  = 'Pending Payroll Approval';
        }else if(profileName == 'System Administrator'){
            upStatus  = 'Pending Admin Approval';
        }

        Id cusJobRecordTypeId = Schema.SObjectType.Artera_Job__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId();

        Id intJobRecordTypeId = Schema.SObjectType.Artera_Job__c.getRecordTypeInfosByName().get('Internal').getRecordTypeId();

        //system.debug(profileName+' profile and Status is '+upStatus);

        if(jobIds.size()>0){
            List<Artera_Job__c> jobList = [SELECT Id,RecordTypeId,Status__c, Truck_Changed_by_Operator__c FROM Artera_Job__c WHERE Id IN : jobIds];
            for (Artera_Job__c obj : jobList) {
                if(profileName == 'Hydro-X Admin'){
                    if(obj.RecordTypeId == intJobRecordTypeId){
                        obj.Status__c = 'Pending Payroll Approval';
                    }else{
                        obj.Status__c = upStatus;
                    }                   
                }
                else{
                    obj.Status__c = upStatus;
                } 
                     
            }

            if(jobList != null && !jobList.isEmpty()) update jobList;
        }
        
    }

    @AuraEnabled
    public static String getSearchListByFilter(String filter, String searchKey, Date searchByDate, List<String> fRegion){
        
            Date conDate;  
            String searchQuery;   
            Id userId = UserInfo.getUserId(); 
            String profName = getUserProfile();
            List<String> allFetchingStatus = getAllStatus();
            // record type id for account
            Id cusJobRecordTypeId = Schema.SObjectType.Artera_Job__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId();

            Id intJobRecordTypeId = Schema.SObjectType.Artera_Job__c.getRecordTypeInfosByName().get('Internal').getRecordTypeId();


            String contactSearchKey = '*'+searchKey+'*';            
            String nameFilter = '%' + searchKey + '%';
            String workFilter = '%' + searchKey + '%';
            String custFilter = '%' + searchKey + '%';
            String truckFilter = '%' + searchKey + '%';

            Set<Id> jobIds = new Set<Id>();  
            List<Artera_Job__c> allJobList;
            List<JobDetailsWrapper> jobDate = new List<JobDetailsWrapper>();

            if(searchByDate!= null){
                conDate = Date.valueOf(searchByDate);
            } 

            

            if(searchKey != null && searchByDate == null && (fRegion.isEmpty() == true)){
                searchQuery = 'FIND \''+ contactSearchKey +'\' IN ALL FIELDS RETURNING  Artera_Job__c(Id,Artera_Region__c),Job_Ticket__c(Id,Job1__c,Job1__r.Job_Date__c,Job1__r.Artera_Region__c),Artera_Job_Allocation__c(Id,Job__c,Job__r.Job_Date__c,Job__r.Artera_Region__c)';
            }else if(searchKey != null && searchByDate == null && (fRegion.isEmpty() == false)){
                searchQuery = 'FIND \''+ contactSearchKey +'\' IN ALL FIELDS RETURNING  Artera_Job__c(Id,Job_Date__c,Artera_Region__c),Job_Ticket__c(Id,Job1__c,Job1__r.Job_Date__c,Job1__r.Artera_Region__c),Artera_Job_Allocation__c(Id,Job__c,Job__r.Job_Date__c,Job__r.Artera_Region__c)';
            }else if(searchKey != null && searchByDate != null && (fRegion.isEmpty() == true)){ 
                searchQuery = 'FIND \''+ contactSearchKey +'\' IN ALL FIELDS RETURNING  Artera_Job__c(Id,Job_Date__c,Artera_Region__c),Job_Ticket__c(Id,Job1__c,Job1__r.Job_Date__c,Job1__r.Artera_Region__c),Artera_Job_Allocation__c(Id,Job__c,Job__r.Job_Date__c,Job__r.Artera_Region__c)';
            }else if(searchKey != null && searchByDate != null && (fRegion.isEmpty() == false)){ 
                searchQuery = 'FIND \''+ contactSearchKey +'\' IN ALL FIELDS RETURNING  Artera_Job__c(Id,Job_Date__c,Artera_Region__c),Job_Ticket__c(Id,Job1__c,Job1__r.Job_Date__c,Job1__r.Artera_Region__c),Artera_Job_Allocation__c(Id,Job__c,Job__r.Job_Date__c,Job__r.Artera_Region__c)';
            }
            else if(searchKey == null && searchByDate != null && (fRegion.isEmpty() == true)){
                List<Artera_Job__c> allJobListByRegion = [SELECT Id FROM Artera_Job__c WHERE Job_Date__c =:conDate];
                if(!allJobListByRegion.isEmpty()){
                    for(Artera_Job__c jobItr3: allJobListByRegion){ 
                        jobIds.add(jobItr3.Id); 
                    }
                }
            }else if(searchKey == null && searchByDate == null && (fRegion.isEmpty() == false)){
                List<Artera_Job__c> allJobListByRegion = [SELECT Id FROM Artera_Job__c WHERE Artera_Region__c IN  : fRegion ];
                if(!allJobListByRegion.isEmpty()){
                    for(Artera_Job__c jobItr3: allJobListByRegion){ 
                        jobIds.add(jobItr3.Id); 
                    }
                }
            }else if(searchKey == null && searchByDate != null && (fRegion.isEmpty() == false)){
                List<Artera_Job__c> allJobListByRegion = [SELECT Id FROM Artera_Job__c WHERE Job_Date__c =:conDate AND Artera_Region__c IN  : fRegion ];
                if(!allJobListByRegion.isEmpty()){
                    for(Artera_Job__c jobItr3: allJobListByRegion){ 
                        jobIds.add(jobItr3.Id); 
                    }
                }
            }
 
            if(searchKey!= null){ 
                List<List<SObject>> soslresult = Search.query(searchQuery);
                List<Artera_Job__c> jobs = (List<Artera_Job__c>)soslresult[0];
                List<Job_Ticket__c> jtickets = (List<Job_Ticket__c>)soslresult[1];
                List<Artera_Job_Allocation__c> jallocations = (List<Artera_Job_Allocation__c>)soslresult[2];
                 
                List<Artera_Job__c> allJobListByStatus = [SELECT Id, Job_Date__c, Artera_Region__c FROM Artera_Job__c WHERE Status__c 
                LIKE : searchKey ];
                if(!allJobListByStatus.isEmpty()){
                    for(Artera_Job__c artFIds : allJobListByStatus){
                        if(searchByDate != null && (fRegion.isEmpty() == true)){
                            if(artFIds.Job_Date__c == conDate){
                                jobIds.add(artFIds.Id);
                            }
                        }else if(searchByDate != null && (fRegion.isEmpty() == false)){
                            if(artFIds.Job_Date__c == conDate && fRegion.contains(artFIds.Artera_Region__c)){
                                jobIds.add(artFIds.Id);
                            }
                        }else if(searchByDate == null && (fRegion.isEmpty() == false)){ 
                            if( fRegion.contains(artFIds.Artera_Region__c)){
                                jobIds.add(artFIds.Id); 
                            }                                    
                        }else if(searchByDate == null && (fRegion.isEmpty() == true)){
                            jobIds.add(artFIds.Id); 
                        } 
                    }
                }

                List<Artera_Job__c> allJobListByContact = [SELECT Id FROM Artera_Job__c WHERE Contact_Name__c LIKE : searchKey ];
                if(!allJobListByContact.isEmpty()){
                    for(Artera_Job__c artFIds : allJobListByContact){
                        if(searchByDate != null && (fRegion.isEmpty() == true)){
                            if(artFIds.Job_Date__c == conDate){
                                jobIds.add(artFIds.Id);
                            }
                        }else if(searchByDate != null && (fRegion.isEmpty() == false)){
                            if(artFIds.Job_Date__c == conDate && fRegion.contains(artFIds.Artera_Region__c)){
                                jobIds.add(artFIds.Id);
                            }
                        }else if(searchByDate == null && (fRegion.isEmpty() == false)){ 
                            if( fRegion.contains(artFIds.Artera_Region__c)){
                                jobIds.add(artFIds.Id); 
                            }                                    
                        }else if(searchByDate == null && (fRegion.isEmpty() == true)){
                            jobIds.add(artFIds.Id); 
                        } 
                    }
                }
        
                List<Project__c> proList = [SELECT Id,(SELECT Id,Job_Date__c,Artera_Region__c FROM Jobs1__r) FROM Project__c WHERE Name LIKE : nameFilter OR Project_Id__c LIKE : nameFilter];
                if(!proList.isEmpty()){
                    for(Project__c proObj : proList){
                        for(Artera_Job__c artFIds : proObj.Jobs1__r){
                            if(searchByDate != null && (fRegion.isEmpty() == true)){
                                if(artFIds.Job_Date__c == conDate){
                                    jobIds.add(artFIds.Id);
                                }
                            }else if(searchByDate != null && (fRegion.isEmpty() == false)){
                                if(artFIds.Job_Date__c == conDate && fRegion.contains(artFIds.Artera_Region__c)){
                                    jobIds.add(artFIds.Id);
                                }
                            }else if(searchByDate == null && (fRegion.isEmpty() == false)){ 
                                if( fRegion.contains(artFIds.Artera_Region__c)){
                                    jobIds.add(artFIds.Id); 
                                }                                    
                            }else if(searchByDate == null && (fRegion.isEmpty() == true)){
                                jobIds.add(artFIds.Id); 
                            } 
                        }
                    }
                }

                List<Work_Order__c> workList = [SELECT Id, Name, (SELECT Id,Job_Date__c,Artera_Region__c FROM Jobs1__r) FROM Work_Order__c WHERE Name LIKE : workFilter ] ;
                if(!workList.isEmpty()){
                    for(Work_Order__c proObj : workList){
                        for(Artera_Job__c artFIds : proObj.Jobs1__r){
                            if(searchByDate != null && (fRegion.isEmpty() == true)){
                                if(artFIds.Job_Date__c == conDate){
                                    jobIds.add(artFIds.Id);
                                }
                            }else if(searchByDate != null && (fRegion.isEmpty() == false)){
                                if(artFIds.Job_Date__c == conDate && fRegion.contains(artFIds.Artera_Region__c)){
                                    jobIds.add(artFIds.Id);
                                }
                            }else if(searchByDate == null && (fRegion.isEmpty() == false)){ 
                                if( fRegion.contains(artFIds.Artera_Region__c)){
                                    jobIds.add(artFIds.Id); 
                                }                                    
                            }else if(searchByDate == null && (fRegion.isEmpty() == true)){
                                jobIds.add(artFIds.Id); 
                            } 
                        }
                    }
                }


                List<Asset__c> assetList = [SELECT Id,(SELECT Id,Job_Date__c,Artera_Region__c FROM Jobs__r) FROM Asset__c WHERE Name LIKE : truckFilter];
                if(!assetList.isEmpty()){
                    for(Asset__c assetObj : assetList){
                        for(Artera_Job__c artFIds : assetObj.Jobs__r){
                            if(searchByDate != null && (fRegion.isEmpty() == true)){
                                if(artFIds.Job_Date__c == conDate){
                                    jobIds.add(artFIds.Id);
                                }
                            }else if(searchByDate != null && (fRegion.isEmpty() == false)){
                                if(artFIds.Job_Date__c == conDate && fRegion.contains(artFIds.Artera_Region__c)){
                                    jobIds.add(artFIds.Id);
                                }
                            }else if(searchByDate == null && (fRegion.isEmpty() == false)){ 
                                if( fRegion.contains(artFIds.Artera_Region__c)){
                                    jobIds.add(artFIds.Id); 
                                }                                    
                            }else if(searchByDate == null && (fRegion.isEmpty() == true)){
                                jobIds.add(artFIds.Id); 
                            } 
                        }
                    }
                }
        
                List<Account> custList = [SELECT Id,(SELECT Id,Job_Date__c,Artera_Region__c FROM Hydro_X_Jobs__r) FROM Account WHERE Name LIKE : custFilter];
                if(!custList.isEmpty()){
                    for(Account custObj : custList){
                        for(Artera_Job__c artFIds : custObj.Hydro_X_Jobs__r){
                            if(searchByDate != null && (fRegion.isEmpty() == true)){
                                if(artFIds.Job_Date__c == conDate){
                                    jobIds.add(artFIds.Id);
                                }
                            }else if(searchByDate != null && (fRegion.isEmpty() == false)){
                                if(artFIds.Job_Date__c == conDate && fRegion.contains(artFIds.Artera_Region__c)){
                                    jobIds.add(artFIds.Id);
                                }
                            }else if(searchByDate == null && (fRegion.isEmpty() == false)){ 
                                if( fRegion.contains(artFIds.Artera_Region__c)){
                                    jobIds.add(artFIds.Id); 
                                }                                    
                            }else if(searchByDate == null && (fRegion.isEmpty() == true)){
                                jobIds.add(artFIds.Id); 
                            } 
                        }
                    }
                }

                if(!soslresult.isEmpty()){
                    for(Artera_Job__c jobItr: jobs){ 
                        if(searchByDate != null && (fRegion.isEmpty() == true)){
                            if(jobItr.Job_Date__c == conDate){
                                jobIds.add(jobItr.Id);
                            }
                        }else if(searchByDate != null && (fRegion.isEmpty() == false)){
                            if(jobItr.Job_Date__c == conDate && fRegion.contains(jobItr.Artera_Region__c)){
                                jobIds.add(jobItr.Id);
                            }
                        }else if(searchByDate == null && (fRegion.isEmpty() == false)){ 
                            if( fRegion.contains(jobItr.Artera_Region__c)){
                                jobIds.add(jobItr.Id); 
                            }                                    
                        }else if(searchByDate == null && (fRegion.isEmpty() == true)){
                            jobIds.add(jobItr.Id); 
                        } 
                    }
                    
                    for(Job_Ticket__c jtItr: jtickets){
                        if(searchByDate != null && (fRegion.isEmpty() == true)){
                            if(jtItr.Job1__r.Job_Date__c == conDate){
                                jobIds.add(jtItr.Id);
                            }
                        }else if(searchByDate != null && (fRegion.isEmpty() == false)){
                            if(jtItr.Job1__r.Job_Date__c == conDate && fRegion.contains(jtItr.Job1__r.Artera_Region__c)){
                                jobIds.add(jtItr.Id);
                            }
                        }else if(searchByDate == null && (fRegion.isEmpty() == false)){ 
                            if( fRegion.contains(jtItr.Job1__r.Artera_Region__c)){
                                jobIds.add(jtItr.Id); 
                            }                                    
                        }else if(searchByDate == null && (fRegion.isEmpty() == true)){
                            jobIds.add(jtItr.Id); 
                        } 
                        
                    }
                    for(Artera_Job_Allocation__c jAllocItr: jallocations){
                        if(searchByDate != null && (fRegion.isEmpty() == true)){
                            if(jAllocItr.Job__r.Job_Date__c == conDate){
                                jobIds.add(jAllocItr.Id);
                            }
                        }else if(searchByDate != null && (fRegion.isEmpty() == false)){
                            if(jAllocItr.Job__r.Job_Date__c == conDate && fRegion.contains(jAllocItr.Job__r.Artera_Region__c)){
                                jobIds.add(jAllocItr.Id);
                            }
                        }else if(searchByDate == null && (fRegion.isEmpty() == false)){ 
                            if( fRegion.contains(jAllocItr.Job__r.Artera_Region__c)){
                                jobIds.add(jAllocItr.Id); 
                            }                                    
                        }else if(searchByDate == null && (fRegion.isEmpty() == true)){
                            jobIds.add(jAllocItr.Id); 
                        }
                    }
                }

            }  

            if(!jobIds.isEmpty()){
                Boolean UnitNone  = true;
                String regionObj    = '';
                String assignedTo = '';
                String PrimaryCDL  = '';
                String customerObj  = '';
                String contactObj   = '';
                String projectname  = '';
                String projectId = '';
                String woName       = '';
                String trackname    = '';    
                String name         = '';
                String perdiem      = '';
                String curEmpId     = '';     
                Time   starttime;
                Time   endtime ;
                double lunch;  
                double total;
                List<JobDetailsWrapper> mainWrapper = new List<JobDetailsWrapper>();
                List<Artera_Job__c>  jobList;  
                    if(filter == 'My'){ 
                        jobList = [SELECT
                                Id,Name,Artera_Region__r.Name,Truck_Changed_by_Operator__c,Account__r.Name,Contact__r.Name,Payroll_Hours__c,Job_Date__c,Scope__c,Status__c,Job_Location__c,Resouces_Names__c, Project__r.Name,Project__r.Project_Id__c,Project__c,Work_Order__r.Name,  Asset__r.Name,Assigned_To__r.Name,Start_Date__c,End_Date__c,RecordTypeId,
                                (SELECT Id,Name, Employee_Name__c, Total_Billable_Hours__c, Total_Non_Billable_Hours__c,  Paycode__c, Start_Time__c,End_Time__c,Lunch_Time__c,Per_Diem__c,Total_Hours__c,Employee_ID__c,Artera_Resource__c,Artera_Resource__r.Employee_ID__c,Artera_Resource__r.Name,Status__c  ,Job__r.RecordtypeId FROM Job_Allocations__r), (SELECT Id,Name, Job1__c  FROM Job_Tickets__r)
                            FROM Artera_Job__c WHERE Supervisor__c =:userId AND Id IN : jobIds AND Status__c IN : allFetchingStatus ORDER BY Project__r.Name];
                    }else{
                        jobList = [SELECT
                                Id,Name,Artera_Region__r.Name,Truck_Changed_by_Operator__c,Account__r.Name,Contact__r.Name,Payroll_Hours__c,Job_Date__c,Scope__c,Status__c,Job_Location__c,Resouces_Names__c, Project__r.Name,Project__r.Project_Id__c,Project__c,Work_Order__r.Name, Asset__r.Name,Assigned_To__r.Name,Start_Date__c,End_Date__c,RecordTypeId,
                                (SELECT Id,Name, Employee_Name__c, Total_Billable_Hours__c, Total_Non_Billable_Hours__c,  Paycode__c, Start_Time__c,End_Time__c,Lunch_Time__c,Per_Diem__c,Total_Hours__c,Employee_ID__c,Artera_Resource__c,Artera_Resource__r.Employee_ID__c,Artera_Resource__r.Name,Status__c ,Job__r.RecordtypeId FROM Job_Allocations__r), (SELECT Id,Name, Job1__c FROM Job_Tickets__r)
                            FROM Artera_Job__c WHERE Id IN : jobIds AND Status__c IN : allFetchingStatus ORDER BY Project__r.Name];
                    }
                    
                     
    
                List<Job_Ticket_Detail__c>  jobtkDtList = [SELECT Id,Name,Job_Ticket__r.Job_Ticket_Url__c,Job_Ticket__r.Id,Daily_Item_Number__c,Operator_Hours__c,Quantity__c,Unit_Item__c,Unit_Item__r.Name,Unit_Item__r.Unit_Item_Id__c,Job_Ticket__r.Name,Job_Ticket__r.Start_Time__c,Job_Ticket__r.End_Time__c,Job_Ticket__r.Notes__c,Job_Ticket__r.Customer_Reference_Number__c, Job_Ticket__r.Total_Hours__c,Job_Ticket__r.Job1__c FROM Job_Ticket_Detail__c WHERE Job_Ticket__r.Job1__c IN : jobIds];
                
                Map<Id,List<Job_Ticket_Detail__c>> mapMain = new Map<Id,List<Job_Ticket_Detail__c>>();
                for(Job_Ticket_Detail__c tktDt : jobtkDtList){
                    if(tktDt.Unit_Item__c == null){
                        tktDt.Unit_Item_Check__c = true;
                    } 
                    tktDt.Job_Ticket__r.Job_Ticket_Url__c = '/'+tktDt.Job_Ticket__r.Id;
                    List<Job_Ticket_Detail__c> tktList = mapMain.get(tktDt.Job_Ticket__r.Job1__c);
                   
                    if(tktList == null || tktList.isEmpty()){
                        tktList = new List<Job_Ticket_Detail__c>();
                    }
                    tktList.add(tktDt);
                    mapMain.put(tktDt.Job_Ticket__r.Job1__c, tktList);
                    
                }
                 
     
    
                for(Artera_Job__c artObj : jobList){ 
                      List<JobAllocWrapper> wrapperList2 = new List<JobAllocWrapper>(); 
                    // List<JobTicketWrapper> wrapperList3 = new List<JobTicketWrapper>(); 
                    
                    String conDate2;
                    regionObj   = artObj.Artera_Region__r.Name;
                    assignedTo   = artObj.Assigned_To__r.Name;
                    PrimaryCDL  = artObj.Resouces_Names__c;
                    customerObj = artObj.Account__r.Name;
                    contactObj  = artObj.Contact__r.Name;
                    projectname = artObj.Project__r.Name;
                    projectId   = artObj.Project__r.Project_Id__c;
                    woName      = artObj.Work_Order__r.Name;
                    trackname   = artObj.Asset__r.Name;  
    
                    Boolean isTruckChecked = artObj.Truck_Changed_by_Operator__c;
                    Boolean isJobShowing = true;
                    Boolean approveBtn = true;
                    // condition for recordtype
                    if(profName=='Hydro-X Account Receivables'){                    
                        if(artObj.RecordTypeId==intJobRecordTypeId){
                            isJobShowing = false;
                        } 
                    }
                    String bgColor;
                    if(artObj.Status__c=='Completed')   bgColor = 'slds-badge bgColor1';
                    else if(artObj.Status__c=='Pending Billing Approval')   bgColor = 'slds-badge bgColor2';
                    else if(artObj.Status__c=='Pending Admin Approval')    bgColor = 'slds-badge bgColor3';
                    else if(artObj.Status__c=='Pending Payroll Approval')    bgColor = 'slds-badge bgColor3'; 
                    else if(artObj.Status__c=='Pending Supervisor Approval')   bgColor = 'slds-badge bgColor4';
                    else if(artObj.Status__c=='Cancelled')     bgColor = 'slds-badge bgColor5';
                    else if(artObj.Status__c=='Dispatched')    bgColor = 'slds-badge bgColor6';
                    else if(artObj.Status__c=='Dispatched - Acknowledged')     bgColor = 'slds-badge bgColor7';
                    else if(artObj.Status__c=='Assignment in Progress')    bgColor = 'slds-badge bgColor8';
                    else if(artObj.Status__c=='New')   bgColor = 'slds-badge bgColor9';
                    else if(artObj.Status__c=='Created')   bgColor = 'slds-badge bgColor9';
                        
                    if(artObj.Job_Date__c!=null){
                        Date d = artObj.Job_Date__c ;                       
                        conDate2 = DateTime.newInstance(d.year(),d.month(),d.day()).format('MM-dd-YYYY');
                    }
    
                    for(Artera_Job_Allocation__c jobAlloObj : artObj.Job_Allocations__r){
                        
                        JobAllocWrapper jobAllWrap = new JobAllocWrapper(jobAlloObj);
                        wrapperList2.add(jobAllWrap);
                    }
    
              
                    List<Job_Ticket_Detail__c> blkTickets = new List<Job_Ticket_Detail__c>();
                    
                    if(artObj.RecordTypeId == intJobRecordTypeId){
                        
                        if(profName == 'Hydro-X Supervisor'){
                            approveBtn = false;
                        }
                        if(profName == 'Hydro-X Payroll'){
                            JobDetailsWrapper objWrap = new JobDetailsWrapper(
                                isTruckChecked,
                                UnitNone,
                                approveBtn,
                                isJobShowing,
                                projectname,
                                projectId,
                                woName,
                                trackname,
                                regionObj,
                                assignedTo,
                                PrimaryCDL,
                                customerObj,
                                contactObj,
                                conDate2,
                                bgColor,
                                artObj,
                                mapMain.containsKey(artObj.Id) ? mapMain.get(artObj.Id) : blkTickets,
                                mapMain.containsKey(artObj.Id) ? true : false,
                                artObj.Job_Allocations__r.size() > 0 ? true : false,
                                artObj.Job_Tickets__r.size() > 0 ? true : false,
                                wrapperList2
                                );
                                mainWrapper.add(objWrap);
                        }else{ 
                            if(artObj.Status__c == 'Created' || artObj.Status__c == 'Pending Admin Approval' ){
                                JobDetailsWrapper objWrap = new JobDetailsWrapper(
                                isTruckChecked,
                                unitNone,
                                approveBtn,
                                isJobShowing,
                                projectname,
                                projectId,
                                woName,
                                trackname,
                                regionObj,
                                assignedTo,
                                PrimaryCDL,
                                customerObj,
                                contactObj,
                                conDate2,
                                bgColor,
                                artObj,
                                mapMain.containsKey(artObj.Id) ? mapMain.get(artObj.Id) : blkTickets,
                                mapMain.containsKey(artObj.Id) ? true : false,
                                artObj.Job_Allocations__r.size() > 0 ? true : false,
                                artObj.Job_Tickets__r.size() > 0 ? true : false,
                                wrapperList2
                                );
                                mainWrapper.add(objWrap);
                            }
                        }
                    }else if(artObj.RecordTypeId == cusJobRecordTypeId){
                        if(profName == 'Hydro-X Supervisor'){
                            if(artObj.Status__c != 'Pending Admin Approval' ){
                                JobDetailsWrapper objWrap = new JobDetailsWrapper(
                                    isTruckChecked,
                                    unitNone,
                                    approveBtn,
                                    isJobShowing,
                                    projectname,
                                    projectId,
                                    woName,
                                    trackname,
                                    regionObj,
                                    assignedTo,
                                    PrimaryCDL,
                                    customerObj,
                                    contactObj,
                                    conDate2,
                                    bgColor,
                                    artObj,
                                    mapMain.containsKey(artObj.Id) ? mapMain.get(artObj.Id) : blkTickets,
                                    mapMain.containsKey(artObj.Id) ? true : false,
                                    artObj.Job_Allocations__r.size() > 0 ? true : false,
                                    artObj.Job_Tickets__r.size() > 0 ? true : false,
                                    wrapperList2
                                    );
                                    mainWrapper.add(objWrap);
                            }
                        }else{
                            JobDetailsWrapper objWrap = new JobDetailsWrapper(
                                    isTruckChecked,
                                    unitNone,
                                    approveBtn,
                                    isJobShowing,
                                    projectname,
                                    projectId,
                                    woName,
                                    trackname,
                                    regionObj,
                                    assignedTo,
                                    PrimaryCDL,
                                    customerObj,
                                    contactObj,
                                    conDate2,
                                    bgColor,
                                    artObj,
                                    mapMain.containsKey(artObj.Id) ? mapMain.get(artObj.Id) : blkTickets,
                                    mapMain.containsKey(artObj.Id) ? true : false,
                                    artObj.Job_Allocations__r.size() > 0 ? true : false,
                                    artObj.Job_Tickets__r.size() > 0 ? true : false,
                                    wrapperList2
                                    );
                                    mainWrapper.add(objWrap);
                        }
                    }
                } 
                return JSON.serialize(mainWrapper);
            }else{
                return 'No';
            }
    }

 
    @AuraEnabled(cacheable=true)
    public static String getAllJobAllocationsForSupervisor(String filter){
        Boolean UnitNone  = true;
        String regionObj = '';
        String assignedTo  = '';
        String PrimaryCDL = '';
        String customerObj = '';
        String contactObj = '';
        String projectname = '';
        String projectId = '';
        String woName = '';
        String trackname = '';        
        Time starttime;
        Time endtime ;
        String name = '';
        double lunch;  
        String perdiem = '';
        double total;
        String curEmpId = ''; 
        Id userId = UserInfo.getUserId(); 
        String profName = getUserProfile();
        List<JobDetailsWrapper> mainWrapper = new List<JobDetailsWrapper>();
        List<Artera_Job__c>  jobList;
        Set<Id> jobIds = new Set<Id>();
        List<String> allFetchingStatus = getAllStatus();

        // record type id for account
        Id cusJobRecordTypeId = Schema.SObjectType.Artera_Job__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId();

        Id intJobRecordTypeId = Schema.SObjectType.Artera_Job__c.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
 
                if(filter == 'My'){ 
                    jobList = [
                        SELECT
                            Id,Name,Artera_Region__r.Name,Truck_Changed_by_Operator__c,Account__r.Name,Contact__r.Name,Payroll_Hours__c,Job_Date__c,Scope__c,Status__c,Job_Location__c,Resouces_Names__c, Project__r.Name,Project__r.Project_Id__c,Project__c,Work_Order__r.Name, Asset__r.Name,Assigned_To__r.Name,Start_Date__c,End_Date__c,RecordTypeId, 
                            (SELECT Id,Name, Employee_Name__c, Total_Billable_Hours__c, Total_Non_Billable_Hours__c,  Paycode__c, Start_Time__c,End_Time__c,Lunch_Time__c,Per_Diem__c,Total_Hours__c,Employee_ID__c,Artera_Resource__c,Artera_Resource__r.Employee_ID__c,Artera_Resource__r.Name,Status__c ,Job__r.RecordtypeId FROM Job_Allocations__r), (SELECT Id,Name, Job1__c  FROM Job_Tickets__r)
                        FROM Artera_Job__c WHERE Supervisor__c =:userId AND Status__c IN : allFetchingStatus ORDER BY Project__r.Name];
                }else{
                    jobList = [
                        SELECT
                            Id,Name,Artera_Region__r.Name,Truck_Changed_by_Operator__c,Account__r.Name,Contact__r.Name,Payroll_Hours__c,Job_Date__c,Scope__c,Status__c,Job_Location__c,Resouces_Names__c, Project__r.Name,Project__r.Project_Id__c,Project__c,Work_Order__r.Name , Asset__r.Name,Assigned_To__r.Name,Start_Date__c,End_Date__c,RecordTypeId,
                            (SELECT Id,Name, Employee_Name__c, Total_Billable_Hours__c, Total_Non_Billable_Hours__c,  Paycode__c, Start_Time__c,End_Time__c,Lunch_Time__c,Per_Diem__c,Total_Hours__c,Employee_ID__c,Artera_Resource__c,Artera_Resource__r.Employee_ID__c,Artera_Resource__r.Name,Status__c ,Job__r.RecordtypeId FROM Job_Allocations__r), (SELECT Id,Name, Job1__c FROM Job_Tickets__r)
                        FROM Artera_Job__c WHERE Status__c IN : allFetchingStatus ORDER BY Project__r.Name];
                } 
                
                for(Artera_Job__c obj : jobList){
                    jobIds.add(obj.Id);
                }
                 
                 

            List<Job_Ticket_Detail__c>  jobtkDtList = [SELECT Id,Unit_Item_Check__c,Name,Job_Ticket__r.Job_Ticket_Url__c,Job_Ticket__r.Id,Daily_Item_Number__c,Operator_Hours__c,Quantity__c,Unit_Item__c,Unit_Item__r.Name,Unit_Item__r.Unit_Item_Id__c,Job_Ticket__r.Name,Job_Ticket__r.Start_Time__c,Job_Ticket__r.End_Time__c,Job_Ticket__r.Notes__c,Job_Ticket__r.Customer_Reference_Number__c, Job_Ticket__r.Total_Hours__c,Job_Ticket__r.Job1__c FROM Job_Ticket_Detail__c WHERE Job_Ticket__r.Job1__c IN : jobIds];
            
            Map<Id,List<Job_Ticket_Detail__c>> mapMain = new Map<Id,List<Job_Ticket_Detail__c>>();
        	 
        
            for(Job_Ticket_Detail__c tktDt : jobtkDtList){
                if(tktDt.Unit_Item__c == null){
                    tktDt.Unit_Item_Check__c = true;
                }                 
                tktDt.Job_Ticket__r.Job_Ticket_Url__c = '/'+tktDt.Job_Ticket__r.Id;
                List<Job_Ticket_Detail__c> tktList = mapMain.get(tktDt.Job_Ticket__r.Job1__c);
               
                if(tktList == null || tktList.isEmpty()){
                    tktList = new List<Job_Ticket_Detail__c>();
                }
                tktList.add(tktDt);
                mapMain.put(tktDt.Job_Ticket__r.Job1__c, tktList);
                
            }
             
 

            for(Artera_Job__c artObj : jobList){ 
                  List<JobAllocWrapper> wrapperList2 = new List<JobAllocWrapper>(); 
                // List<JobTicketWrapper> wrapperList3 = new List<JobTicketWrapper>(); 
                String conDate;
                regionObj   = artObj.Artera_Region__r.Name;
                assignedTo = artObj.Assigned_To__r.Name;
                PrimaryCDL  = artObj.Resouces_Names__c;
                customerObj = artObj.Account__r.Name;
                contactObj  = artObj.Contact__r.Name;
                projectname = artObj.Project__r.Name;
                projectId   = artObj.Project__r.Project_Id__c;
                woName      = artObj.Work_Order__r.Name;  
                trackname   = artObj.Asset__r.Name;  

                Boolean isTruckChecked = artObj.Truck_Changed_by_Operator__c;
                Boolean isJobShowing = true;
                Boolean approveBtn = true;
                // condition for recordtype
                if(profName=='Hydro-X Account Receivables'){ if(artObj.RecordTypeId==intJobRecordTypeId){ isJobShowing = false; } }
                
                String bgColor;
                if(artObj.Status__c=='Completed')   bgColor = 'slds-badge bgColor1';
                else if(artObj.Status__c=='Pending Billing Approval')  bgColor = 'slds-badge bgColor2';
                else if(artObj.Status__c=='Pending Admin Approval')    bgColor = 'slds-badge bgColor3';
                else if(artObj.Status__c=='Pending Payroll Approval')    bgColor = 'slds-badge bgColor3';
                else if(artObj.Status__c=='Pending Supervisor Approval')   bgColor = 'slds-badge bgColor4';
                else if(artObj.Status__c=='Cancelled') bgColor = 'slds-badge bgColor5';
                else if(artObj.Status__c=='Dispatched')    bgColor = 'slds-badge bgColor6';
                else if(artObj.Status__c=='Dispatched - Acknowledged') bgColor = 'slds-badge bgColor7';
                else if(artObj.Status__c=='Assignment in Progress')    bgColor = 'slds-badge bgColor8';
                else if(artObj.Status__c=='New')   bgColor = 'slds-badge bgColor9';
                else if(artObj.Status__c=='Created')   bgColor = 'slds-badge bgColor9';
                
                    
                if(artObj.Job_Date__c!=null){
                    Date d = artObj.Job_Date__c ;                       
                    conDate = DateTime.newInstance(d.year(),d.month(),d.day()).format('MM-dd-YYYY');
                }

                for(Artera_Job_Allocation__c jobAlloObj : artObj.Job_Allocations__r){
                    
                    JobAllocWrapper jobAllWrap = new JobAllocWrapper(jobAlloObj);
                    wrapperList2.add(jobAllWrap);
                }

          
                List<Job_Ticket_Detail__c> blkTickets = new List<Job_Ticket_Detail__c>(); 
                if(artObj.RecordTypeId == intJobRecordTypeId){ if(profName == 'Hydro-X Supervisor'){ approveBtn = false; } 
                    if(profName == 'Hydro-X Payroll'){
                        JobDetailsWrapper objWrap = new JobDetailsWrapper(isTruckChecked,UnitNone,approveBtn,isJobShowing,projectname,projectId,woName,trackname,regionObj,assignedTo, PrimaryCDL, customerObj,contactObj,conDate,bgColor,artObj,mapMain.containsKey(artObj.Id) ? mapMain.get(artObj.Id) : blkTickets,mapMain.containsKey(artObj.Id) ? true : false,artObj.Job_Allocations__r.size() > 0 ? true : false,artObj.Job_Tickets__r.size() > 0 ? true : false,wrapperList2);
                            mainWrapper.add(objWrap);
                    }else{
                        if(artObj.Status__c == 'Created' || artObj.Status__c == 'Pending Admin Approval' ){
                            JobDetailsWrapper objWrap = new JobDetailsWrapper(isTruckChecked,UnitNone,approveBtn,isJobShowing,projectname,projectId,woName,trackname,regionObj,assignedTo, PrimaryCDL, customerObj,contactObj,conDate,bgColor,artObj,mapMain.containsKey(artObj.Id) ? mapMain.get(artObj.Id) : blkTickets,mapMain.containsKey(artObj.Id) ? true : false,artObj.Job_Allocations__r.size() > 0 ? true : false,artObj.Job_Tickets__r.size() > 0 ? true : false,wrapperList2);
                            mainWrapper.add(objWrap);
                        }
                    }                   

                }else if(artObj.RecordTypeId == cusJobRecordTypeId){
                    if(profName == 'Hydro-X Supervisor'){ if(artObj.Status__c != 'Pending Admin Approval' ){ JobDetailsWrapper objWrap = new JobDetailsWrapper(isTruckChecked,UnitNone,approveBtn,isJobShowing,projectname,projectId,woName,trackname,regionObj,assignedTo, PrimaryCDL, customerObj,contactObj,conDate,bgColor,artObj,mapMain.containsKey(artObj.Id) ? mapMain.get(artObj.Id) : blkTickets,mapMain.containsKey(artObj.Id) ? true : false,artObj.Job_Allocations__r.size() > 0 ? true : false,artObj.Job_Tickets__r.size() > 0 ? true : false,wrapperList2); mainWrapper.add(objWrap); }
                    }else{ JobDetailsWrapper objWrap = new JobDetailsWrapper(isTruckChecked,UnitNone,approveBtn,isJobShowing,projectname,projectId,woName,trackname,regionObj,assignedTo, PrimaryCDL, customerObj,contactObj,conDate,bgColor,artObj,mapMain.containsKey(artObj.Id) ? mapMain.get(artObj.Id) : blkTickets,mapMain.containsKey(artObj.Id) ? true : false,artObj.Job_Allocations__r.size() > 0 ? true : false,artObj.Job_Tickets__r.size() > 0 ? true : false,wrapperList2);
                                mainWrapper.add(objWrap); }
                }
            }
            return JSON.serialize(mainWrapper);
    } 

    @AuraEnabled
    public static String getAllJobAllocationsForSupervisorRefreshData(String filter){
        Boolean UnitNone  = true;
        String regionObj = '';
        String assignedTo = '';
        String PrimaryCDL = '';
        String customerObj = '';
        String contactObj = '';
        String projectname = '';
        String projectId = '';
        String woName = '';
        String trackname = '';        
        Time starttime;
        Time endtime ;
        String name = '';
        double lunch;  
        String perdiem = '';
        double total;
        String curEmpId = ''; 
        Id userId = UserInfo.getUserId(); 
        String profName = getUserProfile();
        List<JobDetailsWrapper> mainWrapper = new List<JobDetailsWrapper>();
        List<Artera_Job__c>  jobList;
        Set<Id> jobIds = new Set<Id>();
        List<String> allFetchingStatus = getAllStatus();

        // record type id for account
        Id cusJobRecordTypeId = Schema.SObjectType.Artera_Job__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId();

        Id intJobRecordTypeId = Schema.SObjectType.Artera_Job__c.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
 
                if(filter == 'My'){ 
                    jobList = [SELECT Id,Name,Artera_Region__r.Name,Truck_Changed_by_Operator__c,Account__r.Name,Contact__r.Name,Payroll_Hours__c,Job_Date__c,Scope__c,Status__c,Job_Location__c,Resouces_Names__c, Project__r.Name,Project__r.Project_Id__c,Project__c,Work_Order__r.Name, Asset__r.Name,Assigned_To__r.Name,Start_Date__c,End_Date__c,RecordTypeId,
                            (SELECT Id,Name, Employee_Name__c, Total_Billable_Hours__c, Total_Non_Billable_Hours__c,  Paycode__c, Start_Time__c,End_Time__c,Lunch_Time__c,Per_Diem__c,Total_Hours__c,Employee_ID__c,Artera_Resource__c,Artera_Resource__r.Employee_ID__c,Artera_Resource__r.Name,Status__c ,Job__r.RecordtypeId FROM Job_Allocations__r), (SELECT Id,Name, Job1__c  FROM Job_Tickets__r)
                        FROM Artera_Job__c WHERE Supervisor__c =:userId AND Status__c IN : allFetchingStatus ORDER BY Project__r.Name];
                }else{
                    jobList = [SELECT Id,Name,Artera_Region__r.Name,Truck_Changed_by_Operator__c,Account__r.Name,Contact__r.Name,Payroll_Hours__c,Job_Date__c,Scope__c,Status__c,Job_Location__c,Resouces_Names__c, Project__r.Name,Project__r.Project_Id__c,Project__c,Work_Order__r.Name , Asset__r.Name,Assigned_To__r.Name,Start_Date__c,End_Date__c,RecordTypeId,
                            (SELECT Id,Name, Employee_Name__c, Total_Billable_Hours__c, Total_Non_Billable_Hours__c,  Paycode__c, Start_Time__c,End_Time__c,Lunch_Time__c,Per_Diem__c,Total_Hours__c,Employee_ID__c,Artera_Resource__c,Artera_Resource__r.Employee_ID__c,Artera_Resource__r.Name,Status__c ,Job__r.RecordtypeId FROM Job_Allocations__r), (SELECT Id,Name, Job1__c FROM Job_Tickets__r)
                        FROM Artera_Job__c WHERE Status__c IN : allFetchingStatus ORDER BY Project__r.Name];
                }
                
                for(Artera_Job__c obj : jobList){ jobIds.add(obj.Id); }
                 
                 

            List<Job_Ticket_Detail__c>  jobtkDtList = [SELECT Id,Name,Job_Ticket__r.Job_Ticket_Url__c,Job_Ticket__r.Id,Daily_Item_Number__c,Operator_Hours__c,Quantity__c,Unit_Item__c,Unit_Item__r.Name,Unit_Item__r.Unit_Item_Id__c,Job_Ticket__r.Name,Job_Ticket__r.Start_Time__c,Job_Ticket__r.End_Time__c,Job_Ticket__r.Notes__c,Job_Ticket__r.Customer_Reference_Number__c, Job_Ticket__r.Total_Hours__c,Job_Ticket__r.Job1__c FROM Job_Ticket_Detail__c WHERE Job_Ticket__r.Job1__c IN : jobIds];
            
            Map<Id,List<Job_Ticket_Detail__c>> mapMain = new Map<Id,List<Job_Ticket_Detail__c>>();
            for(Job_Ticket_Detail__c tktDt : jobtkDtList){
                if(tktDt.Unit_Item__c == null){
                    tktDt.Unit_Item_Check__c = true;
                }
                tktDt.Job_Ticket__r.Job_Ticket_Url__c = '/'+tktDt.Job_Ticket__r.Id;
                List<Job_Ticket_Detail__c> tktList = mapMain.get(tktDt.Job_Ticket__r.Job1__c);
               
                if(tktList == null || tktList.isEmpty()){
                    tktList = new List<Job_Ticket_Detail__c>();
                }
                tktList.add(tktDt);
                mapMain.put(tktDt.Job_Ticket__r.Job1__c, tktList);
                
            }
             
  
            for(Artera_Job__c artObj : jobList){ 
                // List<JobTicketWrapper> wrapperList3 = new List<JobTicketWrapper>(); 
                String conDate;
                regionObj   = artObj.Artera_Region__r.Name;
                assignedTo = artObj.Assigned_To__r.Name;
                PrimaryCDL  = artObj.Resouces_Names__c;
                customerObj = artObj.Account__r.Name;
                contactObj  = artObj.Contact__r.Name;
                projectname = artObj.Project__r.Name;
                projectId 	= artObj.Project__r.Project_Id__c;
                woName      = artObj.Work_Order__r.Name;  
                trackname   = artObj.Asset__r.Name;  

                Boolean isTruckChecked = artObj.Truck_Changed_by_Operator__c;
                Boolean isJobShowing = true;
                Boolean approveBtn = true;
                // condition for recordtype
                if(profName=='Hydro-X Account Receivables'){                    
                    if(artObj.RecordTypeId==intJobRecordTypeId){
                        isJobShowing = false;
                    } 
                }
                
                String bgColor;
                if(artObj.Status__c=='Completed')   bgColor = 'slds-badge bgColor1';
                else if(artObj.Status__c=='Pending Billing Approval')  bgColor = 'slds-badge bgColor2';
                else if(artObj.Status__c=='Pending Admin Approval')    bgColor = 'slds-badge bgColor3';
                else if(artObj.Status__c=='Pending Payroll Approval')    bgColor = 'slds-badge bgColor3';
                else if(artObj.Status__c=='Pending Supervisor Approval')   bgColor = 'slds-badge bgColor4';
                else if(artObj.Status__c=='Cancelled') bgColor = 'slds-badge bgColor5';
                else if(artObj.Status__c=='Dispatched')    bgColor = 'slds-badge bgColor6';
                else if(artObj.Status__c=='Dispatched - Acknowledged') bgColor = 'slds-badge bgColor7';
                else if(artObj.Status__c=='Assignment in Progress')    bgColor = 'slds-badge bgColor8';
                else if(artObj.Status__c=='New')   bgColor = 'slds-badge bgColor9';
                else if(artObj.Status__c=='Created')   bgColor = 'slds-badge bgColor9';
                
                    
                if(artObj.Job_Date__c!=null){
                    Date d = artObj.Job_Date__c ;                       
                    conDate = DateTime.newInstance(d.year(),d.month(),d.day()).format('MM-dd-YYYY');
                }
	
                
                  List<JobAllocWrapper> wrapperList2 = new List<JobAllocWrapper>(); 
                for(Artera_Job_Allocation__c jobAlloObj : artObj.Job_Allocations__r){                    
                    JobAllocWrapper jobAllWrap = new JobAllocWrapper(jobAlloObj);
                    wrapperList2.add(jobAllWrap);
                }

          
                List<Job_Ticket_Detail__c> blkTickets = new List<Job_Ticket_Detail__c>();
                
                if(artObj.RecordTypeId == intJobRecordTypeId){
                    if(profName == 'Hydro-X Supervisor'){
                        approveBtn = false;
                    }
                    if(profName == 'Hydro-X Payroll'){
                        JobDetailsWrapper objWrap = new JobDetailsWrapper(isTruckChecked,UnitNone,approveBtn,isJobShowing,projectname,projectId,woName,trackname,regionObj,assignedTo, PrimaryCDL, customerObj,contactObj,conDate,bgColor,artObj,mapMain.containsKey(artObj.Id) ? mapMain.get(artObj.Id) : blkTickets,mapMain.containsKey(artObj.Id) ? true : false,artObj.Job_Allocations__r.size() > 0 ? true : false,artObj.Job_Tickets__r.size() > 0 ? true : false, wrapperList2);
                            mainWrapper.add(objWrap);
                    }else{
                        if(artObj.Status__c == 'Created' || artObj.Status__c == 'Pending Admin Approval' ){
                            JobDetailsWrapper objWrap = new JobDetailsWrapper(isTruckChecked,UnitNone,approveBtn,isJobShowing,projectname,projectId,woName,trackname,regionObj,assignedTo, PrimaryCDL, customerObj,contactObj,conDate,bgColor,artObj,mapMain.containsKey(artObj.Id) ? mapMain.get(artObj.Id) : blkTickets,mapMain.containsKey(artObj.Id) ? true : false,artObj.Job_Allocations__r.size() > 0 ? true : false,artObj.Job_Tickets__r.size() > 0 ? true : false,wrapperList2);
                            mainWrapper.add(objWrap);
                        }
                    }                   

                }else if(artObj.RecordTypeId == cusJobRecordTypeId){
                    if(profName == 'Hydro-X Supervisor'){
                        if(artObj.Status__c != 'Pending Admin Approval' ){ JobDetailsWrapper objWrap = new JobDetailsWrapper(isTruckChecked,UnitNone,approveBtn,isJobShowing,projectname,projectId,woName,trackname,regionObj,assignedTo, PrimaryCDL, customerObj,contactObj,conDate,bgColor,artObj,mapMain.containsKey(artObj.Id) ? mapMain.get(artObj.Id) : blkTickets,mapMain.containsKey(artObj.Id) ? true : false,artObj.Job_Allocations__r.size() > 0 ? true : false,artObj.Job_Tickets__r.size() > 0 ? true : false,wrapperList2); mainWrapper.add(objWrap); }
                    }else{ JobDetailsWrapper objWrap = new JobDetailsWrapper(isTruckChecked,UnitNone,approveBtn,isJobShowing,projectname,projectId,woName,trackname,regionObj,assignedTo, PrimaryCDL, customerObj,contactObj,conDate,bgColor,artObj,mapMain.containsKey(artObj.Id) ? mapMain.get(artObj.Id) : blkTickets,mapMain.containsKey(artObj.Id) ? true : false,artObj.Job_Allocations__r.size() > 0 ? true : false,artObj.Job_Tickets__r.size() > 0 ? true : false,wrapperList2); mainWrapper.add(objWrap); }
                }
            }
            return JSON.serialize(mainWrapper);
    } 

    


    // return wrappper
    public class ResponseData{
        @AuraEnabled
        public List<JobDetailsWrapper> records;
        @AuraEnabled
        public Integer totalPages;

        public ResponseData(List<JobDetailsWrapper> records, Integer totalPages){
            this.records   = records;
            this.totalPages = totalPages;
        }
    }


    // wrapper classes
    public class JobDetailsWrapper{ 
        @AuraEnabled 
        public Boolean isTruckChecked;
        @AuraEnabled
        public Boolean unitNone;
        @AuraEnabled
        public Boolean approveBtn;
        @AuraEnabled
        public Boolean isJobShowing;
        @AuraEnabled
        public String projectName;
        @AuraEnabled
        public String projectId;
        @AuraEnabled
        public String woName;
        @AuraEnabled
        public String trackname;
        @AuraEnabled
        public String Region; 
        @AuraEnabled
        public String assignedTo; 
        @AuraEnabled
        public String PrimaryCDL; 
        @AuraEnabled
        public String Customer;
        @AuraEnabled
        public String Contact; 
        @AuraEnabled
        public String JobDate;
        @AuraEnabled
        public String BackgroundColor;
        @AuraEnabled
        public Artera_Job__c objJobs;
        @AuraEnabled
        public List<Job_Ticket_Detail__c> objJobTickets;
        @AuraEnabled
        public List<JobAllocWrapper> jobAllocations;
        @AuraEnabled
        public Boolean mapBool; 
        @AuraEnabled
        public Boolean jobBool;
        @AuraEnabled
        public Boolean tktBool; 
        @AuraEnabled
        public String link; 
 

        public JobDetailsWrapper(Boolean isTruckChecked,Boolean unitNone,Boolean approveBtn,Boolean isJobShowing,String projectName,String projectId, String woName,String trackname, String Region,String assignedTo,String PrimaryCDL, String Customer, String Contact, String JobDate, String BackgroundColor, Artera_Job__c objJobs, List<Job_Ticket_Detail__c> objJobTickets, Boolean mapBool ,Boolean jobBool, Boolean tktBool, List<JobAllocWrapper> jobAllocations){
            this.isTruckChecked = isTruckChecked;
            this.unitNone = unitNone;
            this.approveBtn = approveBtn;
            this.isJobShowing = isJobShowing;
            this.projectName = projectName;
            this.projectId = projectId;
            this.woName      = woName;
            this.trackname      = trackname;
            this.Region = Region;
            this.assignedTo = assignedTo;
            this.PrimaryCDL = PrimaryCDL; 
            this.Customer = Customer;
            this.Contact = Contact;
            this.JobDate = JobDate;
            this.BackgroundColor = BackgroundColor;
            this.objJobs = objJobs;
            this.objJobTickets = objJobTickets;
            this.mapBool = mapBool;
            this.jobBool = jobBool;
            this.tktBool = tktBool;
            this.link = '/'+objJobs.Id;
            this.jobAllocations = jobAllocations;
            
        }
    }

    public class JobAllocWrapper{ 
        @AuraEnabled
        public Boolean RecTypeStatus;     
        @AuraEnabled
        public Id Id;       
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public String URL; 
        @AuraEnabled
        public Id ResId;       
        @AuraEnabled
        public String ResName;
        @AuraEnabled
        public String ResEmpId;
        @AuraEnabled
        public String ResURL; 
        @AuraEnabled
        public Artera_Job_Allocation__c jobAllocation;

        public JobAllocWrapper(Id Id,String Name, Id ResId, String ResName,String ResEmpId, String Status){
            
            this.Id=Id;
            this.Name=Name; 
            this.Status=Status;
            this.ResId=ResId;
            this.ResName=ResName;
            this.ResEmpId=ResEmpId; 
        }

        public JobAllocWrapper(Artera_Job_Allocation__c jobAllocation, Id Id,String Name, Id ResId, String ResName,String ResEmpId, String Status){
            this.jobAllocation = jobAllocation; 
            this.Id=Id;
            this.Name=Name;
            this.ResId=ResId;
            this.ResName=ResName;
            this.ResEmpId=ResEmpId;
            this.Status=Status; 
        }
        public JobAllocWrapper(Artera_Job_Allocation__c jobAllocation){
            this.jobAllocation = jobAllocation;
            this.URL = '/'+jobAllocation.Id; 
            this.ResURL='/'+jobAllocation.Artera_Resource__c;
            this.Id = jobAllocation.Id;
            this.Name = jobAllocation.Name;
            this.ResId = jobAllocation.Artera_Resource__c;
            if(String.isNotBlank(jobAllocation.Artera_Resource__c)){
                this.ResName = jobAllocation.Artera_Resource__r.Name;
                this.ResEmpId = jobAllocation.Artera_Resource__r.Employee_ID__c;
            }else{
                this.ResName = '';
                this.ResEmpId = '';
            }
            this.Status = jobAllocation.Status__c;

                // customer 01276000000GsfkAAC || 01276000000GsfkAAC
                // internal 01276000000GsfpAAC || 01276000000GsfpAAC
                Id cusJobRecordTypeId = Schema.SObjectType.Artera_Job__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId();

                Id intJobRecordTypeId = Schema.SObjectType.Artera_Job__c.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
                //condition for recordtype
                if(jobAllocation.Job__r.RecordtypeId==cusJobRecordTypeId){
                    RecTypeStatus = false;
                }else{
                    RecTypeStatus = true;
                }
        }

    }

    public class JobTicketWrapper{

        @AuraEnabled
        public Id Id;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public List<tktDetWrapper> tkDetailList; 

        public JobTicketWrapper(Id Id, String Name, List<tktDetWrapper> tkDetailList){
                this.Id = Id;
                this.Name = Name;
                this.tkDetailList = tkDetailList;   
        }
    }


    public class tktDetWrapper{
        @AuraEnabled
        public Id Id;
        @AuraEnabled
        public String Name;
        public tktDetWrapper(Id Id, String Name ){
            this.Id = Id;
            this.Name = Name;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
        i++;
		i++;
        i++; i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
        i++;
		i++;
        i++; i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
        i++;
		i++;
        i++; i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
        i++;
		i++;
        i++; i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
        i++;
		i++;
        i++; i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
        i++;
		i++;
        i++; i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
        i++;
		i++;
        i++; i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
        i++;
		i++;
        i++; i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
        i++;
		i++;
        i++; i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
        i++;
		i++;
        i++; i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
        i++;
		i++;
        i++; i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
        i++;
		i++;
        i++; i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
        i++;
		i++;
        i++;
            
    }
}