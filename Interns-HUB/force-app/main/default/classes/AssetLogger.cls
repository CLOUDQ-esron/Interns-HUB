public with sharing class AssetLogger {
    
    public static void logChange(List<Asset__c> assets, String changeType, String fieldChanges) {
        List<Asset_Change_Log__c> logs = new List<Asset_Change_Log__c>();
        for (Asset__c asset : assets) {
            Asset_Change_Log__c acl = new Asset_Change_Log__c();
            
            if (changeType != 'Deleted') {
                acl.Asset__c = asset.Id; 
            } 
            
            acl.Change_Type__c = changeType;
            acl.Changed_By__c = UserInfo.getUserId();
            acl.Changed_On__c = System.now();
            acl.Field_Changes__c = fieldChanges != null ? fieldChanges : 'N/A';
            logs.add(acl);
        }
        if (!logs.isEmpty()) {
            insert logs;
        }
    }

    public static void logFieldDifferences(List<Asset__c> newList, Map<Id, Asset__c> oldMap) {
        List<Asset_Change_Log__c> logs = new List<Asset_Change_Log__c>();
        for (Asset__c newRec : newList) {
            Asset__c oldRec = oldMap.get(newRec.Id);
            String diffs = '';

            if (newRec.Status__c != oldRec.Status__c)
                diffs += 'Status: ' + oldRec.Status__c + ' → ' + newRec.Status__c;
            
            if (newRec.Location__c != oldRec.Location__c)
                diffs += 'Location: ' + oldRec.Location__c + ' → ' + newRec.Location__c;

            if (!String.isBlank(diffs)) {
                Asset_Change_Log__c aclu = new Asset_Change_Log__c();
                aclu.Asset__c = newRec.Id;
               	aclu.Change_Type__c = 'Updated';
                aclu.Changed_By__c = UserInfo.getUserId();
                aclu.Changed_On__c = System.now();
                aclu.Field_Changes__c = diffs;
                logs.add(aclu);
            }
        }
        if (!logs.isEmpty()) {
             insert logs;
        }
           
    }
}
