public class AssetNotifier {
    
    public static List<Asset_Notification_Criteria__mdt> assetCriteria = new List<Asset_Notification_Criteria__mdt>();
    
    public static Boolean evaluate(SObject newValue, SObject oldValue) {
        if (assetCriteria == null || assetCriteria.isEmpty()) {
            return false;
        }
    
        for (Asset_Notification_Criteria__mdt criteria : assetCriteria) {
            if (criteria == null || !criteria.Is_Active__c || criteria.Field_To_Validate__c == null) continue;
            
            String field = criteria.Field_To_Validate__c;
            String value = criteria.Value_To_Validate__c;
            String Operator = criteria.Operator_To_Validate__c;
             System.debug(field+'----'+value+'-----'+Operator);
            if (field == null || value == null || Operator == null) continue;

            Object newFieldVal = newValue.get(field);
            Object oldFieldVal = oldValue != null ? oldValue.get(field) : null;

            if (newFieldVal != oldFieldVal && newFieldVal != null) {
                System.debug('123');
                if (processFormula(String.valueOf(newFieldVal), Operator, value)) {
                    System.debug('12345');
                    return true;
                }
            }
        }
        return false;
    }

    public static Boolean processFormula(String existingValue, String Operator, String valueToEvaluate) {
        if (existingValue == null || Operator == null || valueToEvaluate == null ||
            String.isBlank(existingValue) || String.isBlank(Operator) || String.isBlank(valueToEvaluate)) {
            return false;
        }
        
        switch on Operator {
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
                } else if (existingValue.isNumeric() && valueToEvaluate.isNumeric()) {
                    Decimal existing = Decimal.valueOf(existingValue);
                    Decimal expected = Decimal.valueOf(valueToEvaluate);
                    return existing > expected;
                }
                return false;
            }
            when '<' {
                if (valueToEvaluate.equalsIgnoreCase('TODAY() - 30')) {
                    Date existingDate = Date.valueOf(existingValue);
                    return existingDate < Date.today().addDays(-30);
                } else if (existingValue.isNumeric() && valueToEvaluate.isNumeric()) {
                    Decimal existing = Decimal.valueOf(existingValue);
                    Decimal expected = Decimal.valueOf(valueToEvaluate);
                    return existing < expected;
                }
                return false;
            }
            when else {
                return false;
            }
        }
    }
    
    public static void notify(List<Asset__c> newList, Map<Id, Asset__c> oldMap,  String eventName, String objectName ) {
        
        assetCriteria = [SELECT Object_Name__c, Event__c, Field_To_Validate__c, Operator_To_Validate__c, Value_To_Validate__c, Notification_Title__c, Notification_Body__c, NotificationTypeDevName__c, Is_Active__c FROM Asset_Notification_Criteria__mdt  WHERE Event__c = :eventName AND Object_Name__c = :objectName AND Is_Active__c = true LIMIT 100];
        
        Map<String, Id> notificationTypeMap = new Map<String, Id>();
        CustomNotificationType cnt = [SELECT Id, DeveloperName FROM CustomNotificationType LIMIT 1];
    
   
                                
        System.debug('Searching ');
        System.debug('Object: ' + objectName);
        System.debug('Event: ' + eventName);
        System.debug('Current user: ' + UserInfo.getUserId());

        for (CustomNotificationType nt : [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'customnotification' LIMIT 100] ) {
            notificationTypeMap.put(nt.DeveloperName, nt.Id);
        }

       
        for (Asset__c asset : newList) {
        Asset__c oldAsset = (oldMap != null) ? oldMap.get(asset.Id) : null;
			
            if( evaluate( asset,oldAsset )){
                    sendNotification(
                        asset.Id,
                        assetCriteria[0].Notification_Title__c,
                        assetCriteria[0].Notification_Body__c,
                        new Set<String>{UserInfo.getUserId()}, 
                        cnt.id,
                        UserInfo.getUserId()
                    );
                    
                    System.debug ('asset.Id' + asset.Id);
                    System.debug ('Notification_Body__c' + assetCriteria[0].Notification_Body__c);
                
            }
            
        }
    }

    public static void sendNotification(Id recordId,String title,String body,Set<String> recipients,Id typeId,Id senderId) {
        Messaging.CustomNotification cn = new Messaging.CustomNotification();
        cn.setNotificationTypeId(typeId);
        cn.setTitle(title);
        cn.setBody(body);
        cn.setTargetId(recordId); 
        cn.setSenderId(senderId);
        cn.send(recipients);
    }
       
}