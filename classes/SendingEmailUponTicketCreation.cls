/**
@author Simran
@date 21/04/2022
@group Artera_Job__c
@description Apex invocable class for sending mail to resource Upon New Job-ticket creation.
Name :  SendingEmailUponTicketCreation.
@lastModifiedOn 15/04/2022 
@lastModifiedBy simran
*/

public class SendingEmailUponTicketCreation {
    @InvocableMethod(Label='Sending Email On Ticket Creation' Description = 'Sending email on ticket creation')
    public static void SendingEmailToResources(List<Artera_Job__c> ArteraJob ) {
        string jobId = ArteraJOb[0].id ;
        List<string> toAddresses = new List<string>();
        System.debug(jobId+' Id');
        string Operator_Resource_Name ='';
        string Ticket_Id ='';
        string Ticket_Name ='';
        string Ticket_Location = '';
        string Resource_Email ='';
        Artera_Job__c JOB = [SELECT Id ,Name ,Job_Date__c,Owner_Name__c,(SELECT Artera_Resource__r.Name,Artera_Resource__r.Email__c ,ID , Name FROM Job_Allocations__r ),
                             (SELECT Id ,Location__c, Name FROM Job_Tickets__r) 
                             FROM Artera_Job__c WHERE ID =: jobId];
        
        For(Artera_Job_Allocation__c ArtJobAlloc : JOB.Job_Allocations__r)
        {
            if(ArtJobAlloc.Artera_Resource__r.Email__c != Null)
            {
            Operator_Resource_Name = ArtJobAlloc.Artera_Resource__r.Name ;
             Resource_Email =ArtJobAlloc.Artera_Resource__r.Email__c;
            toAddresses.add(Resource_Email);
            }
            else 
                return;
            }
        
        For(Job_Ticket__c Ticket : JOB.Job_Tickets__r ){
		    Ticket_Id = Ticket.Id;
            Ticket_Name =Ticket.Name;
            Ticket_Location =Ticket.Location__c;
            }
        
        Map<string ,string> toSubject = new Map<string , string>();
        Map<string ,string> toBody = new Map<string, string>
        {
            'OperatorResourceName' =>Operator_Resource_Name ,
                'TicketId'  => Ticket_Id,
                'TicketName'       => Ticket_Name ,
                'ArteraJobName'   => JOB.Name ,
                'JobDate'        =>String.valueOf( JOB.Job_Date__c),
                'TicketLocation' => Ticket_Location,
                'JobOwner'   => JOB.Owner_Name__c
                };
             
        EmailUtilities.sendResultEmail('Send email notification to resource' ,toAddresses ,toSubject,toBody );
    }
    
}