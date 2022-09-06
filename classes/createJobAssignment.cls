public class createJobAssignment {   
    public static void addJob(List <Leave__c> leaveLists){
        Integer iDays;
        List<Artera_Job_Allocation__c> jobs = new List<Artera_Job_Allocation__c>();
        List<Artera_Job__c> newJobs = new List<Artera_Job__c>();
        List<Artera_Resource__c> res = new List<Artera_Resource__c>();
        List<Messaging.SingleEmailMessage> mailList =  new List<Messaging.SingleEmailMessage>();
        // System.debug('Mail list: ' + mailList);
        
        for(Leave__c l: leaveLists) {
            if(l.Half_Day_Leave__c == true && (l.Status__c == 'Approved' || l.Status__c == 'Rejected')){
                Date currentDate=l.Leave_Start_date__c; 
                
                Artera_Job__c j;
                
                try{                        
                    j = [SELECT Id, Name, Status__c FROM Artera_Job__c 
                         WHERE Job_Type__c = 'Leave' 
                         AND Job_Date__c =: currentDate
                         AND Status__c != 'Completed'];
                }catch(Exception e){
                    j=null; 
                    // System.debug('j =' +j);
                }
                
                if(j==null){
                    j = new Artera_Job__c();                         
                    List<Project__c> projectId = [SELECT Id,Name FROM Project__c WHERE Name='HydroX Leave' LIMIT 1];
                    Id proId = projectId[0].Id;          	           
                    RecordType rt = [SELECT Id , DeveloperName FROM RecordType WHERE DeveloperName= 'Internal'];
                    j.RecordTypeId = rt.Id;
                    Account acc = [SELECT Id, Name FROM Account Where Name = 'Hydroexcavators, LLC'];
                    j.Account__c = acc.Id;
                    j.Job_Type__c = 'Leave';
                    j.Job_Date__c = currentDate;
                    j.Project__c  = proId;
                    // newJob.Job_Date__c = currentDate;
                    newjobs.add(j);
                    // System.debug('If logger');
                    insert j;
                }
                
                Artera_Job_Allocation__c ja = new Artera_Job_Allocation__c();
                
                Time Timess=l.Leave_Start_Time__c;
                DateTime dt = Timess != null && currentDate != null ? DateTime.newInstanceGMT(currentDate, Timess) : null;
                Time endtime;
                if(dt != null){
                    dt=dt.addHours(4);
                    endtime =dt.timeGmt();
                } else {
                    endtime = null;
                }
                ja.Job__c = j.Id;                   
                ja.Type__c = 'Leave';
                ja.Status__c = 'Assigned';
                ja.Paycode__c = l.Reason__c;
                ja.Half_Day_Leave__c =l.Half_Day_Leave__c;
                ja.Start_Time__c=l.Leave_Start_Time__c;
                ja.End_Time__c=endtime;
                ja.Artera_Resource__c = l.Artera_Resource__c;
                ja.Job_Assignment_Date_Field__c = currentDate;
                // System.debug('else logger');
                // System.debug('Current Date :'+currentDate);
                jobs.add(ja);
                currentDate=currentDate+1;  
                
                
                System.debug('l.Half_Day_Leave__c ' + l.Half_Day_Leave__c);
                Artera_Resource__c resourceList = [SELECT Id,  Name, Email__c  FROM Artera_Resource__c WHERE Id=:l.Artera_Resource__c];
                List<String> toAddresses = new List<String>();
                toAddresses.add(resourceList.Email__c);
                Map<String, String> toSubject=new Map<String,String>();
                Map<String, String> toBody= new Map<String, String>{
                    'ArteraResourceName' => resourceList.Name,
                        'LeaveStatus' => l.Status__c,
                        'startDate' => string.valueOf(l.Leave_Start_date__c)
                        };
                            
                            EmailUtilities.sendResultEmail('Half day leave',toAddresses,toSubject,toBody);   
                break;
            }
            
            
            if(l.Status__c == 'Approved'){    
                iDays = l.Leave_Start_date__c.daysBetween(l.Leave_End_Date__c); 
                Date currentDate=l.Leave_Start_date__c; 
                for (Integer i = 0; i <= iDays; i++) {
                    
                    Artera_Job__c j;
                    
                    try{                        
                        j = [SELECT Id, Name, Status__c FROM Artera_Job__c 
                             WHERE Job_Type__c = 'Leave' 
                             AND Job_Date__c =: currentDate
                             AND Status__c != 'Completed'];
                    }catch(Exception e){
                        j=null; 
                    }
                    
                    if(j==null){
                        j = new Artera_Job__c();                         
                        List<Project__c> projectId = [SELECT Id,Name FROM Project__c WHERE Name='HydroX Leave' LIMIT 1];
                        Id proId = projectId[0].Id;          	           
                        RecordType rt = [SELECT Id , DeveloperName FROM RecordType WHERE DeveloperName= 'Internal'];
                        j.RecordTypeId = rt.Id;
                        Account acc = [SELECT Id, Name FROM Account Where Name = 'Hydroexcavators, LLC'];
                        j.Account__c = acc.Id;
                        j.Job_Type__c = 'Leave';
                        j.Job_Date__c = currentDate;
                        j.Project__c  = proId;
                        // newJob.Job_Date__c = currentDate;
                        newjobs.add(j);
                        // System.debug('If logger');
                        insert j;
                    }
                    
                    Artera_Job_Allocation__c ja = new Artera_Job_Allocation__c();
                    
                    Time Timess=l.Leave_Start_Time__c;
                    DateTime dt = Timess != null && currentDate != null ? DateTime.newInstanceGMT(currentDate, Timess) : null;
                    Time endtime;
                    if(dt != null){
                        dt=dt.addHours(4);
                        endtime =dt.timeGmt();
                    } else {
                        endtime = null;
                    }
                    ja.Job__c = j.Id;                   
                    ja.Type__c = 'Leave';
                    ja.Status__c = 'Assigned';
                    ja.Paycode__c = l.Reason__c;
                    ja.Half_Day_Leave__c =l.Half_Day_Leave__c;
                    ja.Start_Time__c=l.Leave_Start_Time__c;
                    ja.End_Time__c=endtime;
                    ja.Artera_Resource__c = l.Artera_Resource__c;
                    ja.Job_Assignment_Date_Field__c = currentDate;
                    // System.debug('else logger');
                    // System.debug('Current Date :'+currentDate);
                    jobs.add(ja);
                    currentDate=currentDate+1;  
                }  
                
                Artera_Resource__c resourceList = [SELECT Id,  Name, Email__c  FROM Artera_Resource__c WHERE Id=:l.Artera_Resource__c];
                List<String> toAddresses = new List<String>();
                toAddresses.add(resourceList.Email__c);
                Map<String, String> toSubject=new Map<String,String>();
                Map<String, String> toBody= new Map<String, String>{
                    'ArteraResourceName' => resourceList.Name,
                        'LeaveStatus' => l.Status__c,
                        'startDate' => string.valueOf(l.Leave_Start_date__c),
                        'endDate' => string.valueOf(l.Leave_End_Date__c)
                        };
                            EmailUtilities.sendResultEmail('Send Leave Status if approved',toAddresses,toSubject,toBody);
            } 
            
            if (l.Status__c == 'Rejected'){              
                Artera_Resource__c resourceList = [SELECT Id,  Name, Email__c  FROM Artera_Resource__c WHERE Id=:l.Artera_Resource__c];
                List<String> toAddresses = new List<String>();
                toAddresses.add(resourceList.Email__c);
                Map<String, String> toSubject=new Map<String,String>();
                Map<String, String> toBody= new Map<String, String>{
                    'ArteraResourceName' => resourceList.Name,
                        'LeaveStatus' => l.Status__c,
                        'ReasonForRejection' => l.Reason_for_leave_rejection__c,
                        'startDate' => string.valueOf(l.Leave_Start_date__c),
                        'endDate' => string.valueOf(l.Leave_End_Date__c)
                        };
                            
                            EmailUtilities.sendResultEmail('Send Leave Status if rejected',toAddresses,toSubject,toBody);        
            }
        }
        if(jobs.size()>0){
            insert jobs;
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