public class InventoryItemsQueueable implements Queueable{
    
    public Id recordId;
    public Id userId;
    public CustomNotificationType cnType;
    
    public InventoryItemsQueueable(String customNotificationName, Id recordId, Id userId){
        this.recordId = recordId;
        this.userId = userId;
        this.cnType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = :customNotificationName];
    }
    
    public void execute(QueueableContext context){        
        Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();
        customNotificationObj.setBody('A Procurement Request has been created since the stock is below the threshold');
        customNotificationObj.setTitle('A Procurement Request has been created !!!');
        customNotificationObj.setNotificationTypeId(cnType.id);
        customNotificationObj.setSenderId(userId);
        customNotificationObj.setTargetId(recordId);
        customNotificationObj.send(new Set<String> {userId});
    }
}