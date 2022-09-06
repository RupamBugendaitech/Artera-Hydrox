/**
 @author Kamil 
 @date 17/03/2022
 @group Artera_Job__c
 @description Apex Email handler class for handling inbound email messages from resource/ Operators for acknowledging the jobs 
 they have been assigned
 Name : UpdateJobAllocationStatus .
 @lastModifiedOn 09/04/2022 
 @lastModifiedBy Kamil
*/

public with sharing class  UpdateJobAllocationStatus implements  Messaging.InboundEmailHandler  {


    public static  Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                    Messaging.InboundEnvelope env){

                                        
                                        
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();


    string myPlainText = email.plainTextBody;
    string content = email.subject ;
    
    System.debug('###########' + content  + '#######');   
    System.debug('###########' + email.subject + '###########'); 

    List<string> jnames =  content.split(' ');
    string jnumber = jnames[1];
    System.debug('##### ' + jnumber + '####');

    Artera_Job_Allocation__c obj = [SELECT ID ,Job__c, Name , Status__c FROM Artera_Job_Allocation__c  WHERE name  =: jnumber  LIMIT 1];
    obj.Status__c = 'Acknowledged' ;  

    update obj;

    Id RelatedJob =  obj.Job__c ;
   
   
    Artera_Job__c Artjob  = new Artera_Job__c ();
    ArtJob = [SELECT Id ,Status__c, Name ,(SELECT ID,Name , Status__c FROM Job_Allocations__r) FROM Artera_Job__c WHERE ID =: RelatedJob LIMIT 1];

    system.debug('Related Job :' +ArtJob);
    Boolean flag = true ;
   
     for(Artera_Job_Allocation__c JobAlloc : ArtJob.Job_Allocations__r )
     {
        
         if( JobAlloc.status__c != 'Acknowledged')
         {
             flag = false; 

         }
     }
     
     if(flag == true )
     {
         ArtJob.Status__c = 'Dispatched - Acknowledged' ;
     }
     update ArtJob ;

    
                                
    result.success = true;

    return result;                                                       
                                    
    }
    }