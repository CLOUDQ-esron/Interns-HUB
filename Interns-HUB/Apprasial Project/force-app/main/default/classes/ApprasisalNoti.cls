public class ApprasisalNoti {
	public static void sendNotifications(List<Appraisal__c> app) {
        CustomNotificationType cnType = QuerySelector.noti();
    	String currentUserId = UserInfo.getUserId();
        List<Messaging.CustomNotification> notifications = new List<Messaging.CustomNotification>();
        for(Appraisal__c appr: app){
          	Messaging.CustomNotification cn = new Messaging.CustomNotification();
            cn.setNotificationTypeId(cnType.Id);
            cn.setTitle('Employee Score Threshold Update');
            cn.setBody('Employee score has met the threshold conditions.');
            cn.setTargetId(appr.Id); 
            cn.setSenderId(currentUserId);
            cn.send(new Set<String>{currentUserId});
            notifications.add(cn);   
        }
        
     }
}