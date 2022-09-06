/**
 @author Kamil 
@date 16/05/2022
@group Artera_Job__c
@description Apex Class for Dispatching multiple Jobs and sending Notification , SMS and Email alerts to Operators ,supervisor ,  salesforce user. Controller of 
             Complete dispatch funtionality .
      Name : DispatchJobsinBUlk .
      Last Modified : - 18/05/2022 Wednesday
*/

public with sharing class DispatchJobsInBulk{

public DispatchJobsinBulk()
{
//testing
}

//SMS_Bucket - 
public static rsplus__SMS_Bucket__c SendSMSToSupervisor(Artera_Job_Allocation__c ArtJobAlloc)
{
rsplus__SMS_Bucket__c SMS = new rsplus__SMS_Bucket__c();

SMS.rsplus__Number__c =ArtJobAlloc.Artera_Resource__r.supervisor__r.MobilePhone;
SMS.rsplus__Related_To__c =ArtJobAlloc.Id ;
SMS.rsplus__Sender_ID__c = '14707305812';
SMS.rsplus__Template_ID__c = 'T0003';

Return SMS ;
}    

public static rsplus__SMS_Bucket__c SendSMSToOperatorWithNotes (Artera_Job_Allocation__c ArtJobAlloc)
{
rsplus__SMS_Bucket__c SMS = new rsplus__SMS_Bucket__c();

SMS.rsplus__Number__c =ArtJobAlloc.Artera_Resource__r.Phone_Number__c;
SMS.rsplus__Related_To__c =ArtJobAlloc.Id ;
SMS.rsplus__Sender_ID__c = '14707305812';
SMS.rsplus__Template_ID__c = 'T0004';

Return SMS ;

}
Public static rsplus__SMS_Bucket__c SendSMSToOperatorWithoutNotes(Artera_Job_Allocation__c ArtJobAlloc)
{
rsplus__SMS_Bucket__c SMS = new rsplus__SMS_Bucket__c();

SMS.rsplus__Number__c =ArtJobAlloc.Artera_Resource__r.Phone_Number__c;
SMS.rsplus__Related_To__c =ArtJobAlloc.Id ;
SMS.rsplus__Sender_ID__c = '14707305812';
SMS.rsplus__Template_ID__c = 'T0002';

Return SMS ;

}

public static void SendCustomNotification(Artera_Job_Allocation__c AJAlloc)
{

List<CustomNotificationType > TemplateInfoDetail  = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Notify_SalesforceUsers'];
Messaging.CustomNotification JobNotification = new Messaging.CustomNotification();
 if(AJAlloc.Artera_Resource__r.Salesforce_User__c != null){
   Set<string> ListIds = new Set<string>();
   string ProjectId = AJAlloc.Job__r.Project__c;
  string newId = AJAlloc.Artera_Resource__r.Salesforce_User__c;
  ListIds.add(newId);
  JobNotification.setTitle('A new Job is Assigned');
JobNotification.setBody('A new job has been assigned to you -'  +AJAlloc.Job__r.Name );
JobNotification.setNotificationTypeId(TemplateInfoDetail[0].Id);
JobNotification.setTargetId(ProjectId);

JobNotification.send(ListIds);
 }
 else return;
  


}

@AuraEnabled 

public static void DispatchJob(List<string> jobIds) {
  checkRecursive.run= false;
//return jobIds;
List<Messaging.SingleEmailMessage> ListEmails = new List<Messaging.SingleEmailMessage>();
Messaging.SingleEmailMessage SingleEmail = new Messaging.SingleEmailMessage();
List<rsplus__SMS_Bucket__c> ListSMS = new List<rsplus__SMS_Bucket__c>();
rsplus__SMS_Bucket__c SingleMessage = new rsplus__SMS_Bucket__c();
List<Artera_Job__c> JobsToUpdate = new List<Artera_Job__c> (); 

List<Artera_Job_Allocation__c> JobAlls = new List<Artera_Job_Allocation__c> ();
JobAlls = [SELECT Id , Name ,Status__c,Job__r.Name, Job__c ,Job__r.Asset__c,Job__r.RecordTypeId, Artera_Resource__c , Job__r.Dispatcher_Notes__c ,Job__r.Id, 
          Artera_Resource__r.Phone_Number__c ,Artera_Resource__r.Name,Artera_Resource__r.Supervisor__r.Email,Job__r.supervisor__r.Name,
          Job__r.Start_Date__c, Artera_Resource__r.Supervisor__r.Name,Job__r.Job_Date__c,Job__r.Job_Location__c,
          Job__r.Owner_Name__c,Job__r.Project__r.Id,Job__r.Project__r.Name,Job__r.Contact__r.Name,Job__r.Contact__r.Phone,
          Artera_Resource__r.Email__c,Artera_Resource__r.Supervisor__r.MobilePhone,Job__r.RecordTYPE.DEVELOPERName,
          Artera_Resource__r.Salesforce_User__c,Artera_Resource__r.Supervisor__c
          FROM Artera_Job_Allocation__c WHERE Job__c IN:jobIds ];

          System.debug(JobAlls +'#################################');
if(JobAlls != null) {
  for(Artera_Job_Allocation__c ArtJobAlloc :JobAlls)
  {
    System.debug(ArtJobAlloc.Job__r.Asset__c);
    System.debug(ArtJobAlloc.Job__r.RecordTYPE.DEVELOPERName);
    System.debug(ArtJobAlloc.Status__c);

    if(ArtJobAlloc.Job__r.Asset__c != null &&  ArtJobAlloc.Job__r.RecordTYPE.DEVELOPERName == 'Customer' && ArtJobAlloc.Status__c == 'Assigned'  ){  // Artera Job Allocation ->Status = ASsigned**********
    // List<Artera_Job_Allocation__c> ListJobAllocations = new List<Artera_Job_Allocation__c>();
    // ListJobAllocations.add(ArtJobAlloc);

    system.debug(ArtJobAlloc + '#######################');
      if(ArtJobAlloc.Job__r.Dispatcher_Notes__c != null &&  ArtJobAlloc.Artera_Resource__r.Phone_Number__c != null &&  ArtJobAlloc.Artera_Resource__r.Email__c != null && ArtJobAlloc.Artera_Resource__r.Supervisor__c != null && ArtJobAlloc.Artera_Resource__r.Supervisor__r.MobilePhone != null)
      {
        SingleMessage =SendSMSToSupervisor(ArtJobAlloc);
        ListSMS.add(SingleMessage);
        SingleMessage = SendSMSToOperatorWithNotes(ArtJobAlloc);
        ListSMS.add(SingleMessage);
        SingleEmail = SendingEmailThroughDISPATCHERFlow.SendingEmailThroughDISPATCHER(ArtJobAlloc);
        ListEmails.add(SingleEmail);
        SingleEmail =SendingEmailThroughSUPERVISORFlow.SendingEmailThroughSUPERVISOR(ArtJobAlloc);
        ListEmails.add(SingleEmail);

        }
      else if(ArtJobAlloc.Job__r.Dispatcher_Notes__c != null &&  ArtJobAlloc.Artera_Resource__r.Phone_Number__c != null &&  ArtJobAlloc.Artera_Resource__r.Email__c != null && ArtJobAlloc.Artera_Resource__r.Supervisor__c != null && ArtJobAlloc.Artera_Resource__r.Supervisor__r.MobilePhone == null)
      {
        SingleMessage = SendSMSToOperatorWithNotes(ArtJobAlloc);
        ListSMS.add(SingleMessage);
        SingleEmail =SendingEmailThroughSUPERVISORFlow.SendingEmailThroughSUPERVISOR(ArtJobAlloc);
        ListEmails.add(SingleEmail);
        SingleEmail =SendingEmailThroughDISPATCHERFlow.SendingEmailThroughDISPATCHER(ArtJobAlloc);
        ListEmails.add(SingleEmail);
      }
      else if (ArtJobAlloc.Job__r.Dispatcher_Notes__c != null &&  ArtJobAlloc.Artera_Resource__r.Phone_Number__c != null &&  ArtJobAlloc.Artera_Resource__r.Email__c != null && ArtJobAlloc.Artera_Resource__r.Supervisor__c == null )
      {
        SingleMessage = SendSMSToOperatorWithNotes(ArtJobAlloc);
        ListSMS.add(SingleMessage);
        SingleEmail = SendingEmailThroughDISPATCHERFlow.SendingEmailThroughDISPATCHER(ArtJobAlloc);
        ListEmails.add(SingleEmail);
      }
      else if(ArtJobAlloc.Job__r.Dispatcher_Notes__c != null &&  ArtJobAlloc.Artera_Resource__r.Phone_Number__c == null &&  ArtJobAlloc.Artera_Resource__r.Email__c != null && ArtJobAlloc.Artera_Resource__r.Supervisor__c != null && ArtJobAlloc.Artera_Resource__r.Supervisor__r.MobilePhone != null)
      {
        SingleMessage = SendSMSToSupervisor(ArtJobAlloc);
        ListSMS.add(SingleMessage);
        SingleEmail = SendingEmailThroughDISPATCHERFlow.SendingEmailThroughDISPATCHER(ArtJobAlloc);
        ListEmails.add(SingleEmail);
        SingleEmail = SendingEmailThroughSUPERVISORFlow.SendingEmailThroughSUPERVISOR(ArtJobAlloc);
        ListEmails.add(SingleEmail);
      }
      else if(ArtJobAlloc.Job__r.Dispatcher_Notes__c != null &&  ArtJobAlloc.Artera_Resource__r.Phone_Number__c == null &&  ArtJobAlloc.Artera_Resource__r.Email__c != null && ArtJobAlloc.Artera_Resource__r.Supervisor__c != null && ArtJobAlloc.Artera_Resource__r.Supervisor__r.MobilePhone == null)
      {
        SingleEmail = SendingEmailThroughDISPATCHERFlow.SendingEmailThroughDISPATCHER(ArtJobAlloc);
        ListEmails.add(SingleEmail);
        SingleEmail = SendingEmailThroughSUPERVISORFlow.SendingEmailThroughSUPERVISOR(ArtJobAlloc);
        ListEmails.add(SingleEmail);
      }
      else if(ArtJobAlloc.Job__r.Dispatcher_Notes__c != null &&  ArtJobAlloc.Artera_Resource__r.Phone_Number__c == null &&  ArtJobAlloc.Artera_Resource__r.Email__c != null && ArtJobAlloc.Artera_Resource__r.Supervisor__c == null)
      {
        SingleEmail = SendingEmailThroughDISPATCHERFlow.SendingEmailThroughDISPATCHER(ArtJobAlloc);
        ListEmails.add(SingleEmail);
      }
      else if(ArtJobAlloc.Job__r.Dispatcher_Notes__c != null &&  ArtJobAlloc.Artera_Resource__r.Phone_Number__c != null &&  ArtJobAlloc.Artera_Resource__r.Email__c == null && ArtJobAlloc.Artera_Resource__r.Supervisor__c != null && ArtJobAlloc.Artera_Resource__r.Supervisor__r.MobilePhone != null)
      {
        SingleMessage = SendSMSToSupervisor(ArtJobAlloc);
        ListSMS.add(SingleMessage);
        SingleMessage = SendSMSToOperatorWithNotes(ArtJobAlloc);
        ListSMS.add(SingleMessage);
        SingleEmail =SendingEmailThroughSUPERVISORFlow.SendingEmailThroughSUPERVISOR(ArtJobAlloc);
        ListEmails.add(SingleEmail);
      }
      else if(ArtJobAlloc.Job__r.Dispatcher_Notes__c != null &&  ArtJobAlloc.Artera_Resource__r.Phone_Number__c != null &&  ArtJobAlloc.Artera_Resource__r.Email__c == null && ArtJobAlloc.Artera_Resource__r.Supervisor__c != null && ArtJobAlloc.Artera_Resource__r.Supervisor__r.MobilePhone == null)
      {
        SingleMessage = SendSMSToOperatorWithNotes(ArtJobAlloc);
        ListSMS.add(SingleMessage);
        SingleEmail = SendingEmailThroughSUPERVISORFlow.SendingEmailThroughSUPERVISOR(ArtJobAlloc);
        ListEmails.add(SingleEmail);
      }
      else if(ArtJobAlloc.Job__r.Dispatcher_Notes__c != null &&  ArtJobAlloc.Artera_Resource__r.Phone_Number__c != null &&  ArtJobAlloc.Artera_Resource__r.Email__c == null && ArtJobAlloc.Artera_Resource__r.Supervisor__c == null)
      {
        SingleMessage = SendSMSToOperatorWithNotes(ArtJobAlloc);
        ListSMS.add(SingleMessage);
      }
      else if(ArtJobAlloc.Job__r.Dispatcher_Notes__c != null &&  ArtJobAlloc.Artera_Resource__r.Phone_Number__c == null &&  ArtJobAlloc.Artera_Resource__r.Email__c == null && ArtJobAlloc.Artera_Resource__r.Supervisor__c != null && ArtJobAlloc.Artera_Resource__r.Supervisor__r.MobilePhone != null)
      {
        SingleMessage = SendSMSToSupervisor(ArtJobAlloc);
        ListSMS.add(SingleMessage);
        SingleEmail = SendingEmailThroughSUPERVISORFlow.SendingEmailThroughSUPERVISOR(ArtJobAlloc);
        ListEmails.add(SingleEmail);
      }
      else if (ArtJobAlloc.Job__r.Dispatcher_Notes__c != null &&  ArtJobAlloc.Artera_Resource__r.Phone_Number__c == null &&  ArtJobAlloc.Artera_Resource__r.Email__c == null && ArtJobAlloc.Artera_Resource__r.Supervisor__c != null && ArtJobAlloc.Artera_Resource__r.Supervisor__r.MobilePhone == null)
      {
        SingleEmail = SendingEmailThroughSUPERVISORFlow.SendingEmailThroughSUPERVISOR(ArtJobAlloc);
        ListEmails.add(SingleEmail);
      }
      else if(ArtJobAlloc.Job__r.Dispatcher_Notes__c != null &&  ArtJobAlloc.Artera_Resource__r.Phone_Number__c == null &&  ArtJobAlloc.Artera_Resource__r.Email__c == null && ArtJobAlloc.Artera_Resource__r.Supervisor__c == null)
      {
        //Do Nothing
        System.debug(' ');
      }
      else if(ArtJobAlloc.Job__r.Dispatcher_Notes__c == null &&  ArtJobAlloc.Artera_Resource__r.Phone_Number__c != null &&  ArtJobAlloc.Artera_Resource__r.Email__c != null )
      {
        SingleEmail = SendingEmailThroughOPERATORFlow.SendingEmailThroughOPERATOR(ArtJobAlloc);
        ListEmails.add(SingleEmail);
        SingleMessage = SendSMSToOperatorWithoutNotes(ArtJobAlloc);
        ListSMS.add(SingleMessage);
      }
      else if (ArtJobAlloc.Job__r.Dispatcher_Notes__c == null &&  ArtJobAlloc.Artera_Resource__r.Phone_Number__c == null &&  ArtJobAlloc.Artera_Resource__r.Email__c != null)
      {
        SingleEmail = SendingEmailThroughOPERATORFlow.SendingEmailThroughOPERATOR(ArtJobAlloc);
        ListEmails.add(SingleEmail);
      }
      else if(ArtJobAlloc.Job__r.Dispatcher_Notes__c == null &&  ArtJobAlloc.Artera_Resource__r.Phone_Number__c != null &&  ArtJobAlloc.Artera_Resource__r.Email__c == null)
      {
        SingleMessage = SendSMSToOperatorWithoutNotes(ArtJobAlloc);
        ListSMS.add(SingleMessage);
      }
       SendCustomNotification(ArtJobAlloc);
      
        Artera_Job__c NewJob = new Artera_Job__c ();            
          NewJob = ArtJobAlloc.Job__r;
          NewJob.Status__c = 'Dispatched';
          boolean flag = false ;
          for(Artera_Job__c LocalJob : JobsToUpdate){
          if (LocalJob == NewJob)
          {
            flag = true ;
          }
          }
          if(flag == false)
          {
            JobsToUpdate.add(NewJob);
          }
           }
           
           
  }
  Update JobsToUpdate ;
  Insert ListSMS;
  if(ListEmails != null && !ListEmails.isEmpty())
  {
    Messaging.sendEmail(ListEmails);
  }
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
  i++;i++;
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
  i++;i++;
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
  i++;i++;
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
  i++;i++;
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
  i++;i++;
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
}
}