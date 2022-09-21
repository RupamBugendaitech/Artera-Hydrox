trigger DispatchJobs on Artera_Job__c (after update) {
    if(checkRecursive.run == true){
if(trigger.isUpdate){
dispatchJobsHandler.onStatusChange(Trigger.New, Trigger.oldMap);
   
}
}
}