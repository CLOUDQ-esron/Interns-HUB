public class NotificationService {
    public static void sendEmailToManager(String managerEmail, String subject, String body) {
        Messaging.SingleEmailMessage em = new Messaging.SingleEmailMessage();
        em.setToAddresses(new List<String>{ managerEmail });
        em.setSubject(subject);
        em.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ em });
    }
    public static void sendInAppNotification(Id violation) {
        CustomNotificationType notificationType = [select Id, DeveloperName From CustomNotificationType Where DeveloperName ='Notify_approver_if_Status_is_Submitted'];
        Messaging.CustomNotification notification = New Messaging.CustomNotification();
        notification.setTitle('Aware about the upadtion');
        notification.setBody('The notification help to aware about updation action is done');
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(violation);
        notification.setSenderId(UserInfo.getUserId());
        notification.send(new set<String>{UserInfo.getUserId()});
    }
}