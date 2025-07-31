public class InAppNotification {
    public static void customNotification(Id violationId,Id sender,Id send){
        CustomNotificationType notificationType = [select Id, DeveloperName From CustomNotificationType Where DeveloperName ='Notify_approver_if_Status_is_Submitted'];
        Messaging.CustomNotification notification = New Messaging.CustomNotification();
        notification.setTitle('Aware about the upadtion');
        notification.setBody('The notification help to aware about updation action is done');
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(violationId);
        notification.setSenderId(sender);
        notification.send(new set<String>{UserInfo.getUserId()});
        
    }
    public static void customUndeleteNotification(Id undelId,Id sender,Id send){
        CustomNotificationType notificationType = [select Id, DeveloperName From CustomNotificationType Where DeveloperName ='Notify_approver_if_Status_is_Submitted'];
        Messaging.CustomNotification notification = New Messaging.CustomNotification();
        notification.setTitle('Aware about the undelete');
        notification.setBody('Sending recovery notice about undelete operation');
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(undelId);
        notification.setSenderId(UserInfo.getUserId());
        notification.send(new set<String>{UserInfo.getUserId()});
        
    }
    
}