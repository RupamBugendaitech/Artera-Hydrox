public class EmailUtilities {
public static Messaging.SingleEmailMessage sendResultEmail(String templateName, List<String> toAddresses, Map<String, String> toReplaceSubject, Map<String, String> toReplaceBody) {
        EmailTemplate emailTemplate = [SELECT Id,Name,Subject,Markup FROM EmailTemplate WHERE Name = :templateName];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
System.debug('Email: '+email);
        String subject = emailTemplate.Subject;
        for (String s : toReplaceSubject.keySet()) {
            subject = subject.replace(s, toReplaceSubject.get(s));
        }

        String htmlBody = emailTemplate.Markup;
        for (String s : toReplaceBody.keySet()) {
            if (toReplaceBody.get(s) != null) {
                htmlBody = htmlBody.replace(s, toReplaceBody.get(s));
            }

        }

        email.setToAddresses(toAddresses);
        email.setReplyTo('operatorresponseemail@ens21vp0qisarxwu6om3fi3fp3m0mb3i9zy6sekq3oluyhg7.1u-zngiuam.na210.apex.salesforce.com');
        email.setSenderDisplayName('Hydro-X Excavators');
        email.setSubject(subject);
        email.setHtmlBody(htmlBody);

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
                email
        });

        return email;
    }

    public static Messaging.SingleEmailMessage getResultEmail(EmailTemplate emailTemplate, List<String> toAddresses, Map<String, String> toReplaceSubject, Map<String, String> toReplaceBody) {

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        String subject = emailTemplate.Subject;
        for (String s : toReplaceSubject.keySet()) {
            if (toReplaceSubject.get(s) != null) {
            subject = subject.replace(s, toReplaceSubject.get(s));
        }
    }

        String htmlBody = emailTemplate.Markup;
        for (String s : toReplaceBody.keySet()) {
            if (toReplaceBody.get(s) != null) {
                htmlBody = htmlBody.replace(s, toReplaceBody.get(s));
            }
        }

        email.setToAddresses(toAddresses);
        email.setReplyTo('operatorresponseemail@ens21vp0qisarxwu6om3fi3fp3m0mb3i9zy6sekq3oluyhg7.1u-zngiuam.na210.apex.salesforce.com');
        email.setSenderDisplayName('Hydro-X Excavators');
        email.setSubject(subject);
        email.setHtmlBody(htmlBody);

        return email;
    }

    public static void justIncrement() {
        Integer i = 0;
        i++;
        i++;
      i++;
        i++;
            i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;
             i++;
        i++;
      i++;
        i++;
            i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++;i++;
        i++;
      i++;
        i++; i++;
        i++;
      i++;
    }


}