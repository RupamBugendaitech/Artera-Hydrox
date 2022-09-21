/**
 * Created on 11.11.21.
 */

trigger OpportunityCompetitorsTrigger on Opportunity_Competitors__c (before insert, before update, before delete,
        after insert, after update, after delete, after undelete) {
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        OpportunityCompetitorCounter.recalculate(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isDelete){
        OpportunityCompetitorCounter.recalculate(Trigger.old);
    }
}