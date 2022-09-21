trigger JobStatusCancelled on Artera_Job__c (after update) {
    if(trigger.isUpdate){
        
        JobStatusCancelledHandler.onStatusChange(Trigger.New, Trigger.oldMap);
       
    }
}