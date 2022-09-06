public class JobStatusCancelledHandler {
    
    public static List<rsplus__SMS_Bucket__c> SmsToSend = new List<rsplus__SMS_Bucket__c>();
    public static rsplus__SMS_Bucket__c SendSMSToOperatorWithNotes (Artera_Job_Allocation__c ArtJobAlloc)
    {   
        rsplus__SMS_Bucket__c SMS = new rsplus__SMS_Bucket__c();
        
        SMS.rsplus__Number__c =ArtJobAlloc.Artera_Resource__r.Phone_Number__c;
        
        SMS.rsplus__Related_To__c =ArtJobAlloc.Id ;
        SMS.rsplus__Sender_ID__c = '14707305812';
        SMS.rsplus__Template_ID__c = 'T0005';
        
        return SMS ;
        
    }
    
    public static void onStatusChange(List<Artera_Job__c> jobList, Map<Id, Artera_Job__c> oldjobList){  
        List<Messaging.SingleEmailMessage> ListEmails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage SingleEmail = new Messaging.SingleEmailMessage();
        
        List<Artera_Job_Allocation__c> jobAllocationsToUpdate = new List<Artera_Job_Allocation__c>();
        List<rsplus__SMS_Bucket__c> ListSMS = new List<rsplus__SMS_Bucket__c>();
        rsplus__SMS_Bucket__c SingleMessage = new rsplus__SMS_Bucket__c();       
        
        List<Artera_Job_Allocation__c> JobAlls = new List<Artera_Job_Allocation__c> ();
        JobAlls = [SELECT Id , Name ,Status__c,Job__r.Name, Job__c ,Job__r.Asset__c,Job__r.RecordTypeId, Artera_Resource__c , Job__r.Dispatcher_Notes__c ,Job__r.Id, 
                   Artera_Resource__r.Phone_Number__c ,Artera_Resource__r.Name,Artera_Resource__r.Supervisor__r.Email,Job__r.supervisor__r.Name,
                   Job__r.Start_Date__c, Artera_Resource__r.Supervisor__r.Name,Job__r.Job_Date__c,Job__r.Job_Location__c,
                   Job__r.Owner_Name__c,Job__r.Project__r.Id,Job__r.Project__r.Name,Job__r.Contact__r.Name,Job__r.Contact__r.Phone,Job__r.Status__c,
                   Artera_Resource__r.Email__c,Artera_Resource__r.Supervisor__r.MobilePhone,Job__r.RecordTYPE.DEVELOPERName,
                   Artera_Resource__r.Salesforce_User__c,Artera_Resource__r.Supervisor__c
                   FROM Artera_Job_Allocation__c WHERE Job__c IN:jobList ];                
        
        
        for(Artera_Job_Allocation__c ja : JobAlls){
            Artera_Job__c oldJobs = oldjobList.get(ja.Job__r.Id);
                        System.debug('ja.Job__r.Id '+ja.Job__r.Id);
            System.debug('new job '+ja.Job__r.Status__c);
            System.debug('oldjobList' +oldjobList);
            System.debug('old job '+oldJobs.Status__c);
            
            if(ja.Job__r.Status__c == 'Cancelled' && (oldJobs.Status__c == 'Dispatched - Acknowledged' || oldJobs.Status__c == 'Dispatched')){
                System.debug('#################################Cancel Handler Running');
                EmailTemplate jobCancelledTemplate = [SELECT Id,Name,Subject,Markup FROM EmailTemplate WHERE Name = 'Job Cancelled'];
                List<string> toAddresses = new List<string>();
                toAddresses.add(ja.Artera_Resource__r.Email__c);
                Map<string ,string> toSubject = new Map<string , string>{                        
                };
                    Map<string ,string> toBody = new Map<string, string>{  
                        'JobAssignmentName'  => ja.Name, 
                            'ResourceName' => ja.Artera_Resource__r.Name ,
                            'ArteraJobName'  => ja.Job__r.Name ,
                            'ArterajobDate'  => String.valueOf(ja.Job__r.Job_Date__c) ,
                            'LocationJob'   => ja.Job__r.Job_Location__c,
                            'ArteraSupervisorName'   => ja.Job__r.Supervisor__r.Name	
                            };
                                
                                SingleEmail = EmailUtilities.getResultEmail(jobCancelledTemplate ,toAddresses ,toSubject,toBody );
                System.debug('SingleEmail'+SingleEmail);
                
                if (ja.Artera_Resource__r.Email__c != null){
                    //  SingleEmail = EmailUtilities.sendResultEmail('Job Cancelled',toAddresses,toSubject,toBody);
                    ListEmails.add(SingleEmail);  
                    System.debug('only email' + toAddresses);
                }
                if (ja.Artera_Resource__r.Phone_Number__c != null){
                    SingleMessage = SendSMSToOperatorWithNotes(ja);
                    ListSMS.add(SingleMessage);
                    System.debug('only sms'  );
                }
            }else for(Artera_Job_Allocation__c jobAlloc : JobAlls){
                jobAlloc.Status__c = 'Cancelled';
                // jobAllocationsToUpdate.add(jobAlloc); 
            }                    
        }
        Insert ListSMS;
        if(ListEmails != null && !ListEmails.isEmpty())
        {
            Messaging.sendEmail(ListEmails);
        }
    }
    
}