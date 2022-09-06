public class dispatchJobsHandler {
    public static void onStatusChange(List<Artera_Job__c> jobList, Map<Id, Artera_Job__c> oldjobList){              
           
                List<string> JobIds = new List<String>();
        system.debug(joblist);
      
        for(Artera_Job__c j : jobList){  
            Artera_Job__c oldJobs = oldjobList.get(j.ID);
                if(j.Status__c == 'Dispatched' && oldJobs.Status__c == 'Assignment in Progress') {   
                      System.debug('kamil');
                    JobIds.add(j.Id);
                
                          
            }
        }
        if(JobIds != null){
             System.debug('kamil');
        DispatchJobsInBulk.DispatchJob(jobIds);
        }
        }
}