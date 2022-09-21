trigger JobShareTrigger on Artera_Job__c (after insert, after update) {
 if(trigger.isInsert || trigger.isUpdate){


    List<Artera_Job__Share> jobShares = new List<Artera_Job__Share>();

    for(Artera_Job__c j : trigger.new){
        Artera_Job__Share jobRecord = new Artera_Job__Share();
        jobRecord.ParentId = j.Id;
     
        jobRecord.UserOrGroupId = j.supervisor__c;
        jobRecord.AccessLevel = 'edit';
        jobRecord.RowCause = Schema.Artera_Job__Share.RowCause.Share_jobs_without_region_restriction__c;
        jobShares.add(jobRecord);
    }
    Database.SaveResult[] jobShareInsertResult = Database.insert(jobShares,false);
    }
}