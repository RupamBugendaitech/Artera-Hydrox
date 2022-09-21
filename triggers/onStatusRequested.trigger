trigger onStatusRequested on Leave__c (before insert, before update) {
if(trigger.isInsert || trigger.isUpdate){
OnLeaveStatusRequest.statusRequest(Trigger.new);
}
}