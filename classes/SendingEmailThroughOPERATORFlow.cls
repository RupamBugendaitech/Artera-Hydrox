/**
 @author Kamil 
 @date 12/04/2022
 @group Artera_Job__c
 @description Apex invocable class for sending mail to resource without dispatcher notes upon being called by a running flow.
 they have been assigned
 Name :  SendingEmailThroughOPERATORFlow.
 @lastModifiedOn 15/04/2022 
 @lastModifiedBy Kamil
*/
public with sharing class SendingEmailThroughOPERATORFlow {
    

    public static Messaging.SingleEmailMessage SendingEmailThroughOPERATOR(Artera_Job_Allocation__c arteraJobAllocation) {

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        EmailTemplate OperatorWithoutNotesTemplate = [SELECT Id,Name,Subject,Markup FROM EmailTemplate WHERE Name = 'User Acknowledgement'];
        
        // string jobId = ArtJobAlloc[0].id ;
         List<string> toAddresses = new List<string>();
          
         

        //  Artera_Job_Allocation__c arteraJobAllocation = [SELECT Artera_Resource__r.Supervisor__r.Name,Artera_Resource__r.Name, Artera_Resource__r.Email__c , Job__r.Job_Date__c , 
        //                                                 Job__r.Job_Location__c,Job__r.Start_Date__c,Job__r.Dispatcher_Notes__c,Job__r.Owner_Name__c ,
        //                                                 Job__r.Contact__r.Name ,Job__r.Contact__r.Phone,Job__r.Project__r.Name,Job__r.Project__r.Id,
        //                                                 Id,Name FROM Artera_Job_Allocation__c WHERE ID =: jobId];

        toAddresses.add(arteraJoballocation.Artera_Resource__r.Email__c);
        Map<string ,string> toSubject = new Map<string , string>
        {
            'JobAssignmentName'  => arteraJobAllocation.Name 
        };
        Map<string ,string> toBody = new Map<string, string>
        {
            'ArteraResourceSupervisor' => arteraJobAllocation.Artera_Resource__r.Supervisor__r.Name,
             'OperatorResourceName' => arteraJobAllocation.Artera_Resource__r.Name ,
            'JobAssignmentName'  => arteraJobAllocation.Name ,
            'ArteraJobDate'       => String.valueOf(arteraJobAllocation.Job__r.Job_Date__c) ,
            'ArteraJobContactName' => arteraJobAllocation.Job__r.Contact__r.Name,
            'ArteraJobContactNumber' => arteraJobAllocation.Job__r.Contact__r.Phone,
            'ArteraJobLocation'   => arteraJobAllocation.Job__r.Job_Location__c ,
            'ArteraJobStartTime' => String.valueOf(arteraJobAllocation.Job__r.Start_Date__c),
            'ProjectName'       => arteraJobAllocation.Job__r.Project__r.Name ,
           'ProjectId'          => arteraJobAllocation.Job__r.Project__r.Id,
            'ArteraJobDispatcherNotes' => arteraJobAllocation.Job__r.Dispatcher_Notes__c ,
            'ArteraJobOwnerName'   => arteraJobAllocation.Job__r.Owner_Name__c,
            'ArteraSupervisorName' => arteraJobAllocation.Job__r.supervisor__r.Name
        };

        email =  EmailUtilities.getResultEmail(OperatorWithoutNotesTemplate ,toAddresses ,toSubject,toBody );
        return email ;


    }
}