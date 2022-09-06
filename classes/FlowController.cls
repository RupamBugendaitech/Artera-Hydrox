/**
 @author Kamil 
 @date 02/04/2022
 @group Artera_Job__c
 @description Apex Controller class for Calling Autolaunched flow "Dispatch Job in Bulks" for running multiple 
              jobs Dispatchment by Dispatcher Profile through Dispacther Homescreen. 
 Name : FlowController .
*/

public with sharing class FlowController {
    public FlowController()
    {
        //testing
    }
   
    @AuraEnabled 
   // public static void callingFlow(List<ID> jobIds) {
 /* List<String> jobName = new List<string> ();
    jobname.add('Mini Excavator');
    jobname.add('AGL Excavation');
    //jobname.add('Final Test Rupam');
    //jobname.add('Rupam Final Test Operator'); */

    public static void callingFlow(List<string> jobIds) {
        
    

        //return jobIds;
        system.debug('All job ids '+jobIds);

        for(string obj : jobIds){
           system.debug('Current Id is '+obj);
        Flow.Interview flowInstance = new Flow.Interview.Dispatch_Jobs_In_Bulk(new map<string,object> {'recordId' => obj});
        flowInstance.start();
                Boolean isSuccess = (Boolean) flowInstance.getVariableValue('isSuccess');
                system.debug('result: ' +isSuccess);
        }

        



       /* List<string> jobIds = new List<string>();
        jobIds.add('a1f760000009ONIAA2');
        jobIds.add('a1f760000009PeUAAU');
        jobIds.add('a1f760000009OJyAAM');
        
        Flow.Interview flowInstance = new Flow.Interview.Dispatch_Jobs_In_Bulk(new map<string,object> {'recordId' => 'a1f760000009PeUAAU'});
        flowInstance.start();
                Boolean isSuccess = (Boolean) flowInstance.getVariableValue('isSuccess');
                system.debug('result: ' +isSuccess);*/
        


    }

}