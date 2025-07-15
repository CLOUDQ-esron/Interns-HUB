public class NotificationQuery {
    Public Static CustomNotificationType getNotificationType(){
        return [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Notification_to_Employee_from_Employee_Training' LIMIT 1];
    }
    Public Static List<Training_Module__c> getMapOfTrainingModule(String fieldName, Set<Id> temp){
       //Map<Id, Training_Module__c> returnMap = new Map<Id, Training_Module__c>(Database.query('SELECT Id, Mandatory__c FROM Training_Module__c WHERE Id IN :'TMIds);
       //return returnMap;
       return Database.query('SELECT Id, ' + fieldName + ' FROM Training_Module__c WHERE Id = :temp');
    }
}