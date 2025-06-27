public class EmailHelper {
    @future
    public static void sendEscalationEmails(Set<Id> caseIds, Set<Id> ownerIds) {

        Map<Id, Case> caseMap = new Map<Id, Case>([
            SELECT Id, CaseNumber, Subject 
            FROM Case 
            WHERE Id IN :caseIds
        ]);

        Map<Id, User> userMap = new Map<Id, User>([
            SELECT Id, Email, Name 
            FROM User 
            WHERE Id IN :ownerIds AND Email != null
        ]);

        
        List<OrgWideEmailAddress> Owd = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'vinayashree2020@gmail.com'];
        Id orgWideEmailId = Owd.isEmpty() ? null : Owd[0].Id;

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Id caseId : caseIds) {
            Case c = caseMap.get(caseId);
            if (c != null) {
                for (Id ownerId : ownerIds) {
                    User u = userMap.get(ownerId);
                    if (u != null) {
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setToAddresses(new String[] { u.Email });
                        email.setSubject('Case Escalated: ' + c.CaseNumber);
                        email.setPlainTextBody('Dear ' + u.Name + ',\n\nA case has been escalated.\n\nSubject: ' + c.Subject + '\nCase Number: ' + c.CaseNumber + '\nCase Id: ' + c.Id + '\n\nRegards,\nSupport Team');

                        
                        if (orgWideEmailId != null) {
                            email.setOrgWideEmailAddressId(orgWideEmailId);
                        }

                        emails.add(email);
                    }
                }
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}