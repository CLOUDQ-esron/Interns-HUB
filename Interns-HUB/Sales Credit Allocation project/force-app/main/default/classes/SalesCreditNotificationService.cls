public class SalesCreditNotificationService {
    public static void sendMail(String address, String subject, String body) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();       // Create an email message object
        String[] toAddresses = new String[] {address};
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        System.debug(results);
    }
    public static void sendCustomNotification(String customNotificationName, Id recordId, Id userId){
        CustomNotificationType cnType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = :customNotificationName];
        Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();
        customNotificationObj.setBody('This Sales Credit Id has exceeded the limit');
        customNotificationObj.setTitle('Sales Credit Record exceeds the threshold !!');
        customNotificationObj.setNotificationTypeId(cnType.id);
        customNotificationObj.setSenderId(userId);
        customNotificationObj.setTargetId(recordId);
        customNotificationObj.send(new Set<String> {userId});
    }
}