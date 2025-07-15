public class QuerySelector {
    public static list<CustomNotificationType> getInstance(){
       return [select Id, DeveloperName From CustomNotificationType Where DeveloperName ='Notify_approver_if_Status_is_Submitted'];
    }
            
}