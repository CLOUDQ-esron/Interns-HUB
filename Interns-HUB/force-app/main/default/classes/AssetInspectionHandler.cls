public with sharing class AssetInspectionHandler {
    
    public static List<Asset_Notification_Criteria__mdt> assetCriteria = new List<Asset_Notification_Criteria__mdt>();
    
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
        	if ( AssetNotifier.processFormula(String.valueOf(newFieldVal), operator, value)) {
                    return true;
                }
            }
        }
        return false;
    }
    
	public static void afterInsert(List<Asset_Inspection__c> newAssets) {
            Set<Id> assetIds = new Set<Id>();
            for (Asset_Inspection__c insp : newAssets) {
            if (insp.Asset__c != null) 
                assetIds.add(insp.Asset__c);
        }
    
        Map<Id, Asset__c> assetMap = new Map<Id, Asset__c>(
            [SELECT Id, Name, Last_Inspection_Date__c, Next_Inspection_Date__c, OwnerId, Category__c 
             FROM Asset__c WHERE Id IN :assetIds]
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
        acl.Change_Type__c = ' Inspection ';
        acl.Changed_By__c = UserInfo.getUserId();
        acl.Changed_On__c = System.now();
        acl.Field_Changes__c = ' Inspection done on This Date ';
        logs.add(acl);
    
            
            
    
        if (!updates.isEmpty()) 
            update updates;
         if (!logs.isEmpty()) 
        	insert logs;
        
        }
    
     AssetInspectionHandler.notify(newAssets,null,'AFTER INSERT','Asset_Inspection__c');
    }
    
    public static void notify(List<SObject> newList, Map<Id, SObject> oldMap,  String eventName, String objectName ) {
        
        assetCriteria = [SELECT Object_Name__c, Event__c, Field_To_Validate__c, Operator_To_Validate__c, Value_To_Validate__c, Notification_Title__c, Notification_Body__c, NotificationTypeDevName__c, Is_Active__c FROM Asset_Notification_Criteria__mdt  WHERE Event__c = :eventName AND Object_Name__c = :objectName AND Is_Active__c = true LIMIT 100];

        Map<String, Id> notificationTypeMap = new Map<String, Id>();
        CustomNotificationType cnt = [SELECT Id, DeveloperName FROM CustomNotificationType LIMIT 1];
    
   
                                
        

        for (CustomNotificationType nt : [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'customnotification' LIMIT 100] ) {
            notificationTypeMap.put(nt.DeveloperName, nt.Id);
        }

       
        for (SObject asset : newList) {
        SObject oldAsset = (oldMap != null) ? oldMap.get(asset.Id) : null;
		if( evaluate( asset,oldAsset )){
               		AssetNotifier.sendNotification(
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
    
}
