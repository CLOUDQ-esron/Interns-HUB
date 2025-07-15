/**
 * @description Handler class for Asset_Inspection__c trigger logic.
 * Includes logic for updating Asset fields based on inspections and sending notifications based on CMDT criteria.
 */
public with sharing class AssetInspectionHandler {

    /**
     * @description List of Asset_Notification_Criteria__mdt records used to determine when to send notifications.
     */
    public static List<Asset_Notification_Criteria__mdt> assetCriteria = new List<Asset_Notification_Criteria__mdt>();

    /**
     * @description Evaluates whether the notification condition is met by comparing new and old field values.
     * @param newValue New record value (SObject).
     * @param oldValue Old record value (SObject), can be null.
     * @return Boolean indicating whether the condition is satisfied.
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
                if (AssetNotifier.processFormula(String.valueOf(newFieldVal), operator, value)) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * @description Logic to execute after Asset_Inspection__c insert. 
     * Updates related Asset__c records, logs changes, and triggers notifications.
     * @param newAssets List of newly inserted Asset_Inspection__c records.
     */
    public static void afterInsert(List<Asset_Inspection__c> newAssets) {
        Set<Id> assetIds = new Set<Id>();
        for (Asset_Inspection__c insp : newAssets) {
            if (insp.Asset__c != null) {
                assetIds.add(insp.Asset__c);
            }
        }

        Map<Id, Asset__c> assetMap = new Map<Id, Asset__c>(
            [SELECT Id, Name, Last_Inspection_Date__c, Next_Inspection_Date__c, OwnerId, Category__c 
             FROM Asset__c WHERE Id IN :assetIds WITH SECURITY_ENFORCED]
        );

        List<Asset__c> updates = new List<Asset__c>();
        List<Asset_Change_Log__c> logs = new List<Asset_Change_Log__c>();
        Date today = System.today();

        for (Asset_Inspection__c insp : newAssets) {
            Asset__c asset = assetMap.get(insp.Asset__c);
            if (insp.Inspection_Date__c != null) {
                if (insp.Inspection_Date__c > today) {
                    asset.Next_Inspection_Date__c = insp.Inspection_Date__c;
                } else {
                    asset.Last_Inspection_Date__c = insp.Inspection_Date__c;
                }
                updates.add(asset);
            }

            Asset_Change_Log__c acl = new Asset_Change_Log__c();
            acl.Asset__c = asset.Id;
            acl.Change_Type__c = 'Inspection';
            acl.Changed_By__c = UserInfo.getUserId();
            acl.Changed_On__c = System.now();
            acl.Field_Changes__c = 'Inspection done on this date';
            logs.add(acl);
        }

        if (!updates.isEmpty() && Schema.sObjectType.Asset__c.isUpdateable()) {
            Database.update(updates, true);
        }

        if (!logs.isEmpty() && Schema.sObjectType.Asset_Change_Log__c.isCreateable()) {
            Database.insert(logs, true);
        }

        AssetInspectionHandler.notify(newAssets, null, 'AFTER INSERT', 'Asset_Inspection__c');
    }

    /**
     * @description Sends a custom notification based on CMDT rules.
     * @param newList List of new SObject records.
     * @param oldMap Map of old SObject records.
     * @param eventName Name of the DML event ('AFTER INSERT', etc).
     * @param objectName API name of the SObject being processed.
     */
    public static void notify(List<SObject> newList, Map<Id, SObject> oldMap, String eventName, String objectName) {
        assetCriteria = [
            SELECT Object_Name__c, Event__c, Field_To_Validate__c, Operator_To_Validate__c, 
                   Value_To_Validate__c, Notification_Title__c, Notification_Body__c, 
                   NotificationTypeDevName__c, Is_Active__c 
            FROM Asset_Notification_Criteria__mdt  
            WHERE Event__c = :eventName AND Object_Name__c = :objectName AND Is_Active__c = true 
            LIMIT 100
        ];

        Map<String, Id> notificationTypeMap = new Map<String, Id>();

        // Enforce user permissions for CustomNotificationType
        if (!Schema.sObjectType.CustomNotificationType.isAccessible()) {
            return;
        }

        List<CustomNotificationType> notificationTypes = [
            SELECT Id, DeveloperName FROM CustomNotificationType 
            WHERE DeveloperName = 'customnotification' LIMIT 100
        ];

        for (CustomNotificationType nt : notificationTypes) {
            notificationTypeMap.put(nt.DeveloperName, nt.Id);
        }

        Id notificationTypeId = notificationTypeMap.containsKey('customnotification')
            ? notificationTypeMap.get('customnotification') : null;

        if (notificationTypeId == null) {
            return;
        }

        for (SObject asset : newList) {
            SObject oldAsset = (oldMap != null) ? oldMap.get(asset.Id) : null;
            if (evaluate(asset, oldAsset)) {
                AssetNotifier.sendNotification(
                    asset.Id,
                    assetCriteria[0].Notification_Title__c,
                    assetCriteria[0].Notification_Body__c,
                    new Set<String>{UserInfo.getUserId()}, 
                    notificationTypeId,
                    UserInfo.getUserId()
                );

                System.debug('asset.Id: ' + asset.Id);
                System.debug('Notification_Body__c: ' + assetCriteria[0].Notification_Body__c);
            }
        }
    }
}
