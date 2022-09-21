trigger addJobAssignment on Leave__c (after insert , after update, before update, before insert) {
if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
createJobAssignment.addJob(Trigger.New);
}
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        createJobAssignment.onLeaveRequested(Trigger.New);
    }
}