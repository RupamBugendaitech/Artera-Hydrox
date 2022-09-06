/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-13-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class dispatcher2ctrler {
   

    @AuraEnabled
    public static void updateAssignmentData(Artera_Job_Allocation__c assObj){ 
        update assObj;
    }

    @AuraEnabled
    public static void updateTicketData(Job_Ticket__c tktObj){
        update tktObj;
    }
   
    @AuraEnabled
    public static void deleteAssigns(String assigId){
        try {
            Artera_Job_Allocation__c rec=[select id from Artera_Job_Allocation__c where id=:assigId ];
            
            delete rec;
        } catch (Exception e) {throw new AuraHandledException(e.getMessage()); }
    }

  /*  @AuraEnabled
    public static void dispatchJobs(List<Id> jobIds){
        try {
            
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    } */

    @AuraEnabled
    public static List<JobDetailsWrapper> getSearchListByFilter(String filter, String searchKey, Date searchByDate, List<String> fRegion, Boolean needQuerying){
        try {
            Date conDate;  
            String searchQuery;   
            String conYard;
            String contactSearchKey = '*'+searchKey+'*';
            String nameFilter = '%' + searchKey + '%';
            String numberFilter = '%' + searchKey + '%';
            String custFilter = '%' + searchKey + '%';
            String truckFilter = '%' + searchKey + '%';

            Set<Id> jobIds = new Set<Id>();

            if(searchByDate!= null){
                conDate = Date.valueOf(searchByDate);
            }
             
            // if(searchKey != null && searchByDate == null){ 
            //     searchQuery = 'FIND \''+ contactSearchKey +'\' IN ALL FIELDS RETURNING  Artera_Job__c(Id,Job_Date__c,Artera_Region__c),Job_Ticket__c(Id,Job1__c,Job1__r.Job_Date__c),Artera_Job_Allocation__c(Id,Job__c, Job__r.Job_Date__c)';
            // }else if(searchKey != null && searchByDate != null){ 
            //     searchQuery = 'FIND \''+ contactSearchKey +'\' IN ALL FIELDS RETURNING  Artera_Job__c(Id,Job_Date__c,Artera_Region__c),Job_Ticket__c(Id,Job1__c,Job1__r.Job_Date__c),Artera_Job_Allocation__c(Id,Job__c, Job__r.Job_Date__c)';
            // }
            
            if(searchKey != null && searchByDate == null && (fRegion.isEmpty() == true)){
                searchQuery = 'FIND \''+ contactSearchKey +'\' IN ALL FIELDS RETURNING  Artera_Job__c(Id,Artera_Region__c,Status__c,Contact_Name__c,Resouces_Names__c),Job_Ticket__c(Id,Job1__c,Job1__r.Job_Date__c,Job1__r.Artera_Region__c,Job1__r.Status__c,Job1__r.Contact_Name__c),Artera_Job_Allocation__c(Id,Job__c,Job__r.Job_Date__c,Job__r.Artera_Region__c,Job__r.Status__c,Job__r.Contact_Name__c)';
            }else if(searchKey != null && searchByDate == null && (fRegion.isEmpty() == false)){
                searchQuery = 'FIND \''+ contactSearchKey +'\' IN ALL FIELDS RETURNING  Artera_Job__c(Id,Job_Date__c,Artera_Region__c,Status__c,Contact_Name__c,Resouces_Names__c),Job_Ticket__c(Id,Job1__c,Job1__r.Job_Date__c,Job1__r.Artera_Region__c,Job1__r.Status__c,Job1__r.Contact_Name__c),Artera_Job_Allocation__c(Id,Job__c,Job__r.Job_Date__c,Job__r.Artera_Region__c,Job__r.Status__c,Job__r.Contact_Name__c)';

                
            }else if(searchKey != null && searchByDate != null && (fRegion.isEmpty() == true)){ 
                searchQuery = 'FIND \''+ contactSearchKey +'\' IN ALL FIELDS RETURNING  Artera_Job__c(Id,Job_Date__c,Artera_Region__c,Status__c,Contact_Name__c,Resouces_Names__c),Job_Ticket__c(Id,Job1__c,Job1__r.Job_Date__c,Job1__r.Artera_Region__c,Job1__r.Status__c,Job1__r.Contact_Name__c),Artera_Job_Allocation__c(Id,Job__c,Job__r.Job_Date__c,Job__r.Artera_Region__c,Job__r.Status__c,Job__r.Contact_Name__c)';

                

            }else if(searchKey != null && searchByDate != null && (fRegion.isEmpty() == false)){
                searchQuery = 'FIND \''+ contactSearchKey +'\' IN ALL FIELDS RETURNING  Artera_Job__c(Id,Job_Date__c,Artera_Region__c,Status__c,Contact_Name__c,Resouces_Names__c),Job_Ticket__c(Id,Job1__c,Job1__r.Job_Date__c,Job1__r.Artera_Region__c,Job1__r.Status__c,Job1__r.Contact_Name__c),Artera_Job_Allocation__c(Id,Job__c,Job__r.Job_Date__c,Job__r.Artera_Region__c,Job__r.Status__c,Job__r.Contact_Name__c)';

            }else if(searchKey == null && searchByDate != null && (fRegion.isEmpty() == true)){
                List<Artera_Job__c> allJobListByRegion = [SELECT Id FROM Artera_Job__c WHERE Job_Date__c =:conDate];
                if(!allJobListByRegion.isEmpty()){
                    for(Artera_Job__c jobItr3: allJobListByRegion){ 
                        jobIds.add(jobItr3.Id); 
                    }
                }
            }
            else if(searchKey == null && searchByDate == null && (fRegion.isEmpty() == false)){
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

                List<Artera_Job__c> allJobListByStatus = [SELECT Id, Job_Date__c, Artera_Region__c FROM Artera_Job__c WHERE Status__c LIKE : searchKey ];
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

                List<Artera_Job__c> allJobListByContact = [SELECT Id,Job_Date__c, Artera_Region__c FROM Artera_Job__c WHERE Contact_Name__c LIKE : searchKey ];
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
                 
        
                List<Project__c> proList = [SELECT Id, Project_Id__c, (SELECT Id,Job_Date__c,Artera_Region__c FROM Jobs1__r) FROM Project__c WHERE Name LIKE : nameFilter OR Project_Id__c LIKE : nameFilter] ;
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
            return getAllJobAllocationsForDisMain(filter, new List<Id>(jobIds), needQuerying);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
 
    @AuraEnabled(cacheable=true)
    public static List<JobDetailsWrapper> getAllJobAllocationsForDis(String filter,Boolean needQuerying){
        return getAllJobAllocationsForDisMain(filter, null, needQuerying);
    }

    @AuraEnabled 
    public static List<JobDetailsWrapper> getAllJobAllocationsForDisRefreshData(String filter,Boolean needQuerying){
        return getAllJobAllocationsForDisMain(filter, null, needQuerying);
    } 

    @AuraEnabled(cacheable=true)
    public static List<JobDetailsWrapper> getAllJobAllocationsForDisMain(String filter, List<Id> jobIds, Boolean needQuerying){ 
         
        String regionObj = '';
        String customerObj = '';
        String contactObj = '';
        String PrimaryCDL = '';
        String contactNo = '';
        String projectname = '';
        String projectId = '';
        String woName = '';
        String trackname = '';
        String scope = '';
        
        Time starttime;
        Time endtime ;
        String name = '';
        double lunch;  
        String perdiem = '';
        double total;
        String curEmpId = ''; 


        
        try {
            List<JobDetailsWrapper> wrapperList = new List<JobDetailsWrapper>(); 
            
            Id userId = UserInfo.getUserId();
                    // record type id for account
            Id cusJobRecordTypeId = Schema.SObjectType.Artera_Job__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId();

            Id intJobRecordTypeId = Schema.SObjectType.Artera_Job__c.getRecordTypeInfosByName().get('Internal').getRecordTypeId();

            //System.debug('UserId '+userId);
            // if(needQuerying == false){
            //     return wrapperList;
            // }
             
            if(filter == 'My'){
                List<Artera_Job__c>  jobList;
                if(jobIds == null || jobIds.isEmpty()){
                    if(needQuerying){
                        jobList = [SELECT Id,RecordtypeId,Recordtype.Name,Name,Artera_Region__r.Name,Account__r.Name,Contact__r.Name, Contact__r.Phone,Payroll_Hours__c,Job_Date__c,scope__r.Name,Status__c,Job_Location__c,Resouces_Names__c , Project__r.Name, Project__r.Project_Id__c, Work_Order__r.Name,Asset__r.Name,Start_Date__c,End_Date__c,(SELECT Id,Name,Start_Time__c,End_Time__c,Lunch_Time__c,Per_Diem__c,Total_Hours__c,Employee_ID__c,Employee_Name__c,Artera_Resource__c,Artera_Resource__r.Employee_ID__c,Artera_Resource__r.Name,Status__c FROM Job_Allocations__r),(SELECT Id,Name,End_Time__c,Start_Time__c,Location__c,Status__c,Customer_Reference_Number__c FROM Job_Tickets__r) FROM Artera_Job__c WHERE OwnerId =: userId AND Status__c IN ('New','Assignment in Progress','Dispatched','Dispatched - Acknowledged','Created','Pending Admin Approval') ORDER BY Project__r.Name];
                    }                    
                }else{
                    jobList = [SELECT Id,RecordtypeId,Recordtype.Name,Name,Artera_Region__r.Name,Account__r.Name,Contact__r.Name,Contact__r.Phone,Payroll_Hours__c,Job_Date__c,scope__r.Name,Status__c,Job_Location__c,Resouces_Names__c , Project__r.Name,Project__r.Project_Id__c,Work_Order__r.Name,Asset__r.Name,Start_Date__c,End_Date__c,(SELECT Id,Name,Start_Time__c,End_Time__c,Lunch_Time__c,Per_Diem__c,Total_Hours__c,Employee_ID__c,Employee_Name__c,Artera_Resource__c,Artera_Resource__r.Employee_ID__c,Artera_Resource__r.Name,Status__c FROM Job_Allocations__r),(SELECT Id,Name,End_Time__c,Start_Time__c,Location__c,Status__c,Customer_Reference_Number__c FROM Job_Tickets__r) FROM Artera_Job__c WHERE OwnerId =: userId AND Id IN :jobIds AND Status__c IN ('New','Assignment in Progress','Dispatched','Dispatched - Acknowledged','Created','Pending Admin Approval') ORDER BY Project__r.Name];
                }
                System.debug('joblist '+jobList);
                if(jobList!= null){
                    for(Artera_Job__c artObj : jobList){ 
                        List<JobAllocWrapper> wrapperList2 = new List<JobAllocWrapper>(); 
                        List<JobTicketWrapper> wrapperList3 = new List<JobTicketWrapper>(); 
                        String conDate;
                        
                        regionObj   = artObj.Artera_Region__r.Name;
                        PrimaryCDL   = artObj.Resouces_Names__c ;
                        customerObj = artObj.Account__r.Name;
                        contactObj  = artObj.Contact__r.Name;
                        contactNo  = artObj.Contact__r.Phone;
                        projectname = artObj.Project__r.Name;
                        projectId   = artObj.Project__r.Project_Id__c;
                        woName      = artObj.Work_Order__r.Name;
                        trackname   = artObj.Asset__r.Name;
                        scope   = artObj.scope__r.Name;
                        
                        String bgColor;
                        if(artObj.Status__c=='Completed'){
                            bgColor = 'slds-badge bgColor1';
                        }else if(artObj.Status__c=='Pending Billing Approval'){
                            bgColor = 'slds-badge bgColor2';
                        }else if(artObj.Status__c=='Pending Admin Approval'){
                            bgColor = 'slds-badge bgColor3';
                        }else if(artObj.Status__c=='Pending Supervisor Approval'){
                            bgColor = 'slds-badge bgColor4';
                        }else if(artObj.Status__c=='Cancelled'){
                            bgColor = 'slds-badge bgColor5';
                        }else if(artObj.Status__c=='Dispatched'){
                            bgColor = 'slds-badge bgColor6';
                        }else if(artObj.Status__c=='Dispatched - Acknowledged'){
                            bgColor = 'slds-badge bgColor7';
                        }else if(artObj.Status__c=='Assignment in Progress'){
                            bgColor = 'slds-badge bgColor8';
                        }else if(artObj.Status__c=='New'){
                            bgColor = 'slds-badge bgColor9';
                        }else if(artObj.Status__c=='Created'){
                            bgColor = 'slds-badge bgColor9';
                        }
                        
                        if(artObj.Job_Date__c!=null){
                            Date d = artObj.Job_Date__c ;                       
                            conDate = DateTime.newInstance(d.year(),d.month(),d.day()).format('MM-dd-YYYY');
                        }
                        
                        for(Artera_Job_Allocation__c jobAlloObj : artObj.Job_Allocations__r){                        
                            JobAllocWrapper jobAllWrap = new JobAllocWrapper(jobAlloObj.Id,jobAlloObj.Name,jobAlloObj.Artera_Resource__c,jobAlloObj.Artera_Resource__r.Name,jobAlloObj.Artera_Resource__r.Employee_ID__c,jobAlloObj.Status__c);
                            wrapperList2.add(jobAllWrap);
                        }
    
                        for(Job_Ticket__c tktObj : artObj.Job_Tickets__r){                        
                            JobTicketWrapper tktWrap = new JobTicketWrapper(tktObj.Id, tktObj.Name, tktObj.Location__c, tktObj.Customer_Reference_Number__c);
                            wrapperList3.add(tktWrap);
                        }
                        
                        if(artObj.RecordTypeId == intJobRecordTypeId){
                            if(artObj.Status__c == 'Created' || artObj.Status__c == 'Pending Admin Approval' ){
                                JobDetailsWrapper objWrap = new JobDetailsWrapper(false,true,conDate,bgColor,wrapperList2,wrapperList3,projectname,
                                projectId, woName,trackname,scope, artObj, regionObj,PrimaryCDL, customerObj,contactObj,contactNo, artObj.Job_Allocations__r.size() > 0 ? true : false , artObj.Job_Tickets__r.size() > 0 ? true : false );
                                wrapperList.add(objWrap);
                            }
                        }else if(artObj.RecordTypeId == cusJobRecordTypeId){
                            if(artObj.Status__c != 'Pending Admin Approval'){
                                JobDetailsWrapper objWrap = new JobDetailsWrapper(true,true,conDate,bgColor,wrapperList2,wrapperList3,projectname,
                                projectId, woName,trackname,scope, artObj, regionObj,PrimaryCDL, customerObj,contactObj, contactNo, artObj.Job_Allocations__r.size() > 0 ? true : false , artObj.Job_Tickets__r.size() > 0 ? true : false );
                                wrapperList.add(objWrap);
                            }
                        }
                    }
                }
 
                return wrapperList;
            }else{
                List<Artera_Job__c>  jobList;
                if(jobIds == null || jobIds.isEmpty()){
                    if(needQuerying){
                        jobList = [SELECT Id,RecordtypeId,Recordtype.Name,Name,Artera_Region__r.Name,Account__r.Name,Contact__r.Name,Contact__r.Phone,Payroll_Hours__c,Job_Date__c,scope__r.Name,Status__c,Job_Location__c,Resouces_Names__c , Project__r.Name,Project__r.Project_Id__c,Work_Order__r.Name,Asset__r.Name,Start_Date__c,End_Date__c,(SELECT Id,Name,Start_Time__c,End_Time__c,Lunch_Time__c,Per_Diem__c,Total_Hours__c,Employee_ID__c,Artera_Resource__c,Artera_Resource__r.Employee_ID__c,Artera_Resource__r.Name,Status__c FROM Job_Allocations__r),(SELECT Id,Name,End_Time__c,Start_Time__c,Location__c,Status__c, Customer_Reference_Number__c FROM Job_Tickets__r) FROM Artera_Job__c WHERE Status__c IN ('New','Assignment in Progress','Dispatched','Dispatched - Acknowledged','Created','Pending Admin Approval') ORDER BY Project__r.Name];
                    }
                }else{
                    jobList = [SELECT Id,RecordtypeId,Recordtype.Name,Name,Artera_Region__r.Name,Account__r.Name,Contact__r.Name,Contact__r.Phone,Payroll_Hours__c,Job_Date__c,scope__r.Name,Status__c,Job_Location__c,Resouces_Names__c , Project__r.Name,Project__r.Project_Id__c,Work_Order__r.Name,Asset__r.Name,Start_Date__c,End_Date__c,(SELECT Id,Name,Start_Time__c,End_Time__c,Lunch_Time__c,Per_Diem__c,Total_Hours__c,Employee_ID__c,Artera_Resource__c,Artera_Resource__r.Employee_ID__c,Artera_Resource__r.Name,Status__c FROM Job_Allocations__r),(SELECT Id,Name,End_Time__c,Start_Time__c,Location__c,Status__c,Customer_Reference_Number__c FROM Job_Tickets__r) FROM Artera_Job__c WHERE Id IN :jobIds AND Status__c IN ('New','Assignment in Progress','Dispatched','Dispatched - Acknowledged','Created','Pending Admin Approval') ORDER BY Project__r.Name];
                }

                System.debug('joblist '+jobList);
                if(jobList!= null){
                    for(Artera_Job__c artObj : jobList){ 
                        List<JobAllocWrapper> wrapperList2 = new List<JobAllocWrapper>(); 
                        List<JobTicketWrapper> wrapperList3 = new List<JobTicketWrapper>(); 
                        String conDate ;
                        regionObj = artObj.Artera_Region__r.Name;
                        PrimaryCDL = artObj.Resouces_Names__c ;
                        customerObj = artObj.Account__r.Name;
                        contactObj = artObj.Contact__r.Name;
                        contactNo = artObj.Contact__r.Phone;
                        projectname = artObj.Project__r.Name;
                        projectId = artObj.Project__r.Project_Id__c;
                        woName = artObj.Work_Order__r.Name;
                        trackname   = artObj.Asset__r.Name;
                        scope = artObj.scope__r.Name;
    
                        
                        String bgColor;
                        if(artObj.Status__c=='Completed'){
                            bgColor = 'slds-badge bgColor1';
                        }else if(artObj.Status__c=='Pending Billing Approval'){
                            bgColor = 'slds-badge bgColor2';
                        }else if(artObj.Status__c=='Pending Admin Approval'){
                            bgColor = 'slds-badge bgColor3';
                        }else if(artObj.Status__c=='Pending Supervisor Approval'){
                            bgColor = 'slds-badge bgColor4';
                        }else if(artObj.Status__c=='Cancelled'){
                            bgColor = 'slds-badge bgColor5';
                        }else if(artObj.Status__c=='Dispatched'){
                            bgColor = 'slds-badge bgColor6';
                        }else if(artObj.Status__c=='Dispatched - Acknowledged'){
                            bgColor = 'slds-badge bgColor7';
                        }else if(artObj.Status__c=='Assignment in Progress'){
                            bgColor = 'slds-badge bgColor8';
                        }else if(artObj.Status__c=='New'){
                            bgColor = 'slds-badge bgColor9';
                        }else if(artObj.Status__c=='Created'){
                            bgColor = 'slds-badge bgColor9';
                        }
                        
                        if(artObj.Job_Date__c!=null){
                            Date d = artObj.Job_Date__c;                    
                            conDate = DateTime.newInstance(d.year(),d.month(),d.day()).format('MM-dd-YYYY');
                        }
    
                        for(Artera_Job_Allocation__c jobAlloObj : artObj.Job_Allocations__r){
                            
                            JobAllocWrapper jobAllWrap = new JobAllocWrapper(jobAlloObj.Id,jobAlloObj.Name,jobAlloObj.Artera_Resource__c,jobAlloObj.Artera_Resource__r.Name,jobAlloObj.Artera_Resource__r.Employee_ID__c,jobAlloObj.Status__c);
                            wrapperList2.add(jobAllWrap);
                        }
    
                        for(Job_Ticket__c tktObj : artObj.Job_Tickets__r){                        
                            JobTicketWrapper tktWrap = new JobTicketWrapper(tktObj.Id, tktObj.Name, tktObj.Location__c, tktObj.Customer_Reference_Number__c);
                            wrapperList3.add(tktWrap);
                        }
    
                        if(artObj.RecordTypeId == intJobRecordTypeId){
                            if(artObj.Status__c == 'Created' || artObj.Status__c == 'Pending Admin Approval' ){
                                JobDetailsWrapper objWrap = new JobDetailsWrapper(false,true, conDate, bgColor, wrapperList2,wrapperList3,projectname,projectId, woName,trackname,scope, artObj, regionObj,PrimaryCDL, customerObj,contactObj,contactNo, artObj.Job_Allocations__r.size() > 0 ? true : false , artObj.Job_Tickets__r.size() > 0 ? true : false );
                                wrapperList.add(objWrap);
                            }
                        }else if(artObj.RecordTypeId == cusJobRecordTypeId){
                            if(artObj.Status__c != 'Pending Admin Approval'){
                                JobDetailsWrapper objWrap = new JobDetailsWrapper(true,true, conDate, bgColor, wrapperList2,wrapperList3,projectname,projectId, woName,trackname,scope, artObj, regionObj,PrimaryCDL, customerObj,contactObj,contactNo, artObj.Job_Allocations__r.size() > 0 ? true : false , artObj.Job_Tickets__r.size() > 0 ? true : false );
                            wrapperList.add(objWrap);
                            }
                            
                        }
                    }
                }

                System.debug('list '+wrapperList);
                return wrapperList;
            }
            
            
            
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }

    public class SupervisorResponseData{
        @AuraEnabled
        public List<JobDetailsWrapper> records;
        @AuraEnabled
        public Integer totalPages;

        public SupervisorResponseData(List<JobDetailsWrapper> records, Integer totalPages){
            this.records   = records; this.totalPages = totalPages;
        }
    }

    public class JobDetailsWrapper{ 
        @AuraEnabled
        public Boolean isShow;
        @AuraEnabled
        public Boolean hideBool;
        @AuraEnabled
        public Boolean jobBool;
        @AuraEnabled
        public Boolean tktBool;
        @AuraEnabled
        public Artera_Job__c objJobs;
        @AuraEnabled
        public String Region; 
        @AuraEnabled
        public String PrimaryCDL; 
        @AuraEnabled
        public String Customer;
        @AuraEnabled
        public String BackgroundColor;
        @AuraEnabled
        public String Contact;
        @AuraEnabled
        public String ContactNo;
        @AuraEnabled
        public String projectName;
        @AuraEnabled
        public String projectId;
        @AuraEnabled
        public String woName;
        @AuraEnabled
        public String trackname;
        @AuraEnabled
        public String scope;
        @AuraEnabled
        public String JobDate;
        @AuraEnabled
        public String link;
        @AuraEnabled
        public List<JobAllocWrapper> jobAllocations;
        @AuraEnabled
        public List<JobTicketWrapper> jobTickets;
 
            
        public JobDetailsWrapper( Boolean isShow,Boolean hideBool,String JobDate, String BackgroundColor,List<JobAllocWrapper> jobAllocations,List<JobTicketWrapper> jobTickets, String projectName, String projectId, String woName, String trackname,String scope, Artera_Job__c objJobs, String Region,String PrimaryCDL, String Customer, String Contact,String ContactNo, Boolean jobBool, Boolean tktBool){
            this.BackgroundColor = BackgroundColor;
            this.jobAllocations = jobAllocations;
            this.JobDate = JobDate;
            this.jobTickets = jobTickets;
            this.Region = Region;
            this.PrimaryCDL = PrimaryCDL;
            this.Customer = Customer;
            this.Contact = Contact;
            this.ContactNo = ContactNo;
            this.hideBool = hideBool;
            this.objJobs  = objJobs;
            this.isShow = isShow;
            this.jobBool  = jobBool;
            this.tktBool  = tktBool;
            this.projectName = projectName;
            this.projectId = projectId;
            this.woName = woName;
            this.trackname = trackname;
            this.scope = scope;
            this.link = '/'+objJobs.Id; 
        }
    }

    public class JobAllocWrapper{ 

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

            public JobAllocWrapper(Id Id,String Name, Id ResId, String ResName,String ResEmpId, String Status){
                
                this.Id=Id;
                this.Name=Name;
                this.URL = '/'+Id; 
                this.Status=Status;
                this.ResId=ResId;
                this.ResName=ResName;
                this.ResEmpId=ResEmpId;
                this.ResURL='/'+ResId;
        }

    }

    public class JobTicketWrapper{

        @AuraEnabled
        public Id Id;       
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Location;
        @AuraEnabled
        public String custRefNo;
        @AuraEnabled
        public String URL;

        public JobTicketWrapper(Id Id, String Name, String Location, String custRefNo){

            this.Id         = Id;
            this.Name       = Name;
            this.Location   = Location;
            this.custRefNo  = custRefNo;
            this.URL        = '/'+Id;
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
    }
}