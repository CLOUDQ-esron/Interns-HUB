/**
 * @description The AssetLogger class is responsible for logging changes made to Asset__c records.
 * It supports logging general change events as well as field-level differences.
 */
public with sharing class AssetLogger {

    /**
     * @description Logs a general asset change (e.g., creation, deletion) with optional field change summary.
     * @param assets List of Asset__c records involved in the change.
     * @param changeType Type of change (e.g., 'Created', 'Updated', 'Deleted').
     * @param fieldChanges Optional string describing the field-level changes.
     */
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

    /**
     * @description Compares new and old versions of Asset__c records and logs any field-level differences.
     * @param newList List of new Asset__c records (typically from trigger.new).
     * @param oldMap Map of old Asset__c records keyed by Id (typically from trigger.oldMap).
     */
    public static void logFieldDifferences(List<Asset__c> newList, Map<Id, Asset__c> oldMap) {
        List<Asset_Change_Log__c> logs = new List<Asset_Change_Log__c>();
        for (Asset__c newRec : newList) {
            Asset__c oldRec = oldMap.get(newRec.Id);
            String diffs = '';

            if (newRec.Status__c != oldRec.Status__c){
                diffs += 'Status: ' + oldRec.Status__c + ' → ' + newRec.Status__c + '\n';
            }
            if (newRec.Location__c != oldRec.Location__c){
                diffs += 'Location: ' + oldRec.Location__c + ' → ' + newRec.Location__c + '\n';
            }
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
