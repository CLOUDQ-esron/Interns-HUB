/**
 * @description AssetNotifier handles the evaluation and sending of custom notifications 
 * based on defined metadata criteria for Asset__c records.
 */
public with sharing class AssetNotifier {

    /**
     * @description List of notification criteria fetched from custom metadata.
     */
    public static List<Asset_Notification_Criteria__mdt> assetCriteria = new List<Asset_Notification_Criteria__mdt>();

    /**
     * @description Evaluates whether the asset record change meets any criteria for notification.
     * @param newValue New version of the asset SObject.
     * @param oldValue Old version of the asset SObject.
     * @return Boolean true if criteria match, else false.
     */
    public static Boolean evaluate(SObject newValue, SObject oldValue) {
        if (assetCriteria == null || assetCriteria.isEmpty()) {
            return false;
        }

        for (Asset_Notification_Criteria__mdt criteria : assetCriteria) {
            String field = criteria.Field_To_Validate__c;
            String value = criteria.Value_To_Validate__c;
            String operator = criteria.Operator_To_Validate__c;

            Object newFieldVal = newValue.get(field);
            Object oldFieldVal = oldValue != null ? oldValue.get(field) : null;

            if (newFieldVal != oldFieldVal && newFieldVal != null) {
                if (processFormula(String.valueOf(newFieldVal), operator, value)) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * @description Processes the formula logic used in the criteria to validate field changes.
     * @param existingValue The current value of the field.
     * @param Operator The logical operator (e.g., IN, CHANGED, >, <).
     * @param valueToEvaluate The expected value or condition to compare with.
     * @return Boolean true if the condition is met.
     */
    public static Boolean processFormula(String existingValue, String Operator, String valueToEvaluate) {
        if (existingValue == null || Operator == null || valueToEvaluate == null ||
            String.isBlank(existingValue) || String.isBlank(Operator) || String.isBlank(valueToEvaluate)) {
            return false;
        }

        switch on operator {
            when 'IN' {
                List<String> values = valueToEvaluate.split(',');
                for (String val : values) {
                    if (existingValue.equalsIgnoreCase(val.trim())) {
                        return true;
                    }
                }
                return false;
            }
            when 'CHANGED' {
                return existingValue.equalsIgnoreCase(valueToEvaluate);
            }
            when '>' {
                if (valueToEvaluate.equalsIgnoreCase('TODAY()')) {
                    Date existingDate = Date.valueOf(existingValue);
                    return existingDate > Date.today();
                } 
                return false;
            }
            when '<' {
                if (valueToEvaluate.equalsIgnoreCase('TODAY() - 30')) {
                    Date existingDate = Date.valueOf(existingValue);
                    return existingDate < Date.today().addDays(-30);
                } 
                return false;
            }
            when else {
                return false;
            }
        }
    }

    /**
     * @description Main notification logic triggered during asset changes.
     * It fetches metadata, evaluates criteria, and sends notifications if matched.
     * @param newList List of new Asset__c records.
     * @param oldMap Map of old Asset__c records (if any).
     * @param eventName The event triggering the evaluation (e.g., 'after update').
     * @param objectName The name of the object (usually 'Asset__c').
     */
    public static void notify(List<Asset__c> newList, Map<Id, Asset__c> oldMap, String eventName, String objectName) {
        assetCriteria = [ SELECT Object_Name__c, Event__c, Field_To_Validate__c, Operator_To_Validate__c,Value_To_Validate__c, Notification_Title__c, Notification_Body__c, NotificationTypeDevName__c, Is_Active__c  FROM Asset_Notification_Criteria__mdt  
            WHERE Event__c = :eventName AND Object_Name__c = :objectName AND Is_Active__c = true  LIMIT 100];

        Map<String, Id> notificationTypeMap = new Map<String, Id>();
        List<CustomNotificationType> cntList = [ SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'customnotification' LIMIT 100 ];

        for (CustomNotificationType nt : cntList) {
            notificationTypeMap.put(nt.DeveloperName, nt.Id);
        }

        for (Asset__c asset : newList) {
            Asset__c oldAsset = (oldMap != null) ? oldMap.get(asset.Id) : null;

            if (evaluate(asset, oldAsset)) {
                sendNotification(
                    asset.Id,
                    assetCriteria[0].Notification_Title__c,
                    assetCriteria[0].Notification_Body__c,
                    new Set<String>{UserInfo.getUserId()}, 
                    cntList[0].Id,
                    UserInfo.getUserId()
                );
            }
        }
    }

    /**
     * @description Sends the custom notification using Messaging.CustomNotification.
     * @param recordId,typeId,title,body,senderId,recipients used in the notification
     */
    public static void sendNotification(Id recordId, String title, String body, Set<String> recipients, Id typeId, Id senderId) {
        Messaging.CustomNotification cn = new Messaging.CustomNotification();
        cn.setNotificationTypeId(typeId);
        cn.setTitle(title);
        cn.setBody(body);
        cn.setTargetId(recordId);
        cn.setSenderId(senderId);
        cn.send(recipients);
    }
}
