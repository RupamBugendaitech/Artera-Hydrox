/**
 @author Kamil 
 @date 22/04/2022
 @group Artera_Job__c
 @description Apex invocable class for sending mail to resource for Job being Cancelled being called by a running flow.
 they have been assigned
 Name :  SendingEmailUponJobCancellatiion.
 @lastModifiedOn 22/04/2022 
 @lastModifiedBy Kamil
*/

public class SendingEmailUponJobCancellation {
    @InvocableMethod(Label='Sending Email Through Resource' Description = 'Sending email through Resource')

    public static void InformResource(List<Artera_Job_Allocation__c> ArtJobAlloc) {

        
        string jobId = ArtJobAlloc[0].id ;
        List<string> toAddresses = new List<string>();
          
         

         Artera_Job_Allocation__c arteraJobAllocation = [SELECT Artera_Resource__r.Name, Artera_Resource__r.Email__c ,Job__r.Name, 
                                                         Job__r.Job_Date__c , Job__r.Supervisor__r.Name,
                                                 Job__r.Job_Location__c,Job__r.Dispatcher_Notes__c,Job__r.Owner_Name__c ,
                                                 Id,Name FROM Artera_Job_Allocation__c WHERE ID =: jobId];

        toAddresses.add(arteraJoballocation.Artera_Resource__r.Email__c);
        Map<string ,string> toSubject = new Map<string , string>();
           
        Map<string ,string> toBody = new Map<string, string>
        {
            'ResourceName' => arteraJobAllocation.Artera_Resource__r.Name ,
            'ArteraJobName'  => arteraJobAllocation.Job__r.Name ,
            'ArterajobDate'       => String.valueOf(arteraJobAllocation.Job__r.Job_Date__c) ,
            'LocationJob'   => arteraJobAllocation.Job__r.Job_Location__c ,
            'ArtJobId'        => arteraJobAllocation.Id,
            'JobOwner'   => arteraJobAllocation.Job__r.Owner_Name__c,
            'ArteraJobAllocationId' => arteraJobAllocation.Id ,
            'JobAssignmentName' => arteraJobAllocation.Name ,
            'ArteraSupervisorName ' => arteraJobAllocation.Job__r.Supervisor__r.Name
                
        };

        EmailUtilities.sendResultEmail('Job Cancelled' ,toAddresses ,toSubject,toBody );


    }

}