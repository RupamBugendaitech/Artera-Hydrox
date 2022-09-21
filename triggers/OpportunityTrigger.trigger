/* 
* handler/controller Class: SharePointOnlineWebserviceCallout
* Test Class: SharePointTest
* 06/01/2020: Abhishikth Chandra :
* 01/20/2021: Jawaun Mckelvey:
*/
trigger OpportunityTrigger on Opportunity (after insert, after update, after delete, before insert, before update) {
    try {
        if( Trigger.isAfter ) {
            if(Trigger.isInsert) {
                OpportunityCompetitorCounter.recalculate(Trigger.new, null);
                List<Opportunity> opps = SharepointOpportunityHandler.verifyOpportunitiesList(Trigger.new);
                SharepointOpportunityHandler.createFolder(opps);
            } else if(Trigger.isUpdate) {
                OpportunityCompetitorCounter.recalculate(Trigger.new, Trigger.oldMap);
                List<Opportunity> opps = SharepointOpportunityHandler.verifyOpportunitiesList(Trigger.new);
                SharepointOpportunityHandler.updateStages(opps, Trigger.oldMap);
            } else if(Trigger.isDelete){
                OpportunityCompetitorCounter.recalculate(Trigger.old, null);
            }
        }
        if(Trigger.isBefore) {
            if(Trigger.isInsert) OpportunityHandler.populateExistingMSA(Trigger.new, null);
            if(Trigger.isUpdate) OpportunityHandler.populateExistingMSA(Trigger.new, Trigger.oldMap);
        }
    } catch(Exception ex){
        System.debug('Exception in Opportunity Trigger : '+ex.getMessage()+ex.getLineNumber());
    }
}