/**
 * Created by Tyler.Brandenburg on 25/09/2019.
 */

@IsTest
private class EmailUtilitiesTest {

    @IsTest
    static void sendResultEmailTest() {
       // TriggerControlService.disableAllTriggers();

        String templateName = 'Send Leave Status if approved';
        List<String> toAddresses = new List<String>{UserInfo.getUserEmail()};
        Map<String,String> toReplaceSubject = new Map<String,String>{'submissionRecordName' => 'replacementSubjectText'};
        Map<String,String> toReplaceBody = new Map<String,String>{'submissionRecordName' => 'replacementBodyText'};

        Test.startTest();
        Messaging.SingleEmailMessage result = EmailUtilities.sendResultEmail(templateName,toAddresses,toReplaceSubject,toReplaceBody);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
    }

    @isTest
    static  void testIncrement() {
        Test.startTest();
      EmailUtilities.justIncrement();
        Test.stopTest();
    }


}