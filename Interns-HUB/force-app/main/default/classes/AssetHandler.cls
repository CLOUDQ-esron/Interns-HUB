public with sharing class AssetHandler {

    public static void beforeInsert(List<Asset__c> newAssets) {
        for (Asset__c asset : newAssets) {
            if (String.isBlank(asset.Status__c)) {
                asset.Status__c = 'Active';
            }
        }
    }
    public static void afterInsert(List<Asset__c> newAssets) {
        AssetLogger.logChange(newAssets, 'Created', 'Asset created.');
        AssetNotifier.notify(newAssets, null, 'AFTER INSERT','Asset__c');
        
    }

    public static void beforeUpdate(List<Asset__c> newList, Map<Id, Asset__c> oldMap) {
        for (Asset__c newRec : newList) {
            Asset__c oldRec = oldMap.get(newRec.Id);
            if (
                newRec.Status__c == 'Retired' &&
                oldRec.Status__c != 'Retired' &&
                newRec.Next_Inspection_Date__c != null &&
                newRec.Next_Inspection_Date__c > Date.today()
            ) {
                newRec.addError('Cannot retire asset with upcoming inspection.');
            }
        }
    }

    public static void afterUpdate(List<Asset__c> newList, Map<Id, Asset__c> oldMap) {
        AssetLogger.logFieldDifferences(newList, oldMap);
        AssetNotifier.notify(newList, oldMap,'AFTER UPDATE','Asset__c');
    }
   public static void beforeDelete(List<Asset__c> assetList) {
        Set<Id> assetIds = new Set<Id>();
        for (Asset__c asset : assetList) {
            assetIds.add(asset.Id);
        }
        Date oneYearAgo = Date.today().addYears(-1);
        Map<Id, List<Asset_Inspection__c>> inspectionMap = new Map<Id, List<Asset_Inspection__c>>();
        for (Asset_Inspection__c insp : [
            SELECT Asset__c, Inspection_Date__c 
            FROM Asset_Inspection__c 
            WHERE Asset__c IN :assetIds AND Inspection_Date__c >= :oneYearAgo
        ]) {
            if (!inspectionMap.containsKey(insp.Asset__c)) {
                inspectionMap.put(insp.Asset__c, new List<Asset_Inspection__c>());
            }
            inspectionMap.get(insp.Asset__c).add(insp);
        }
        for (Asset__c asset : assetList) {
            if (inspectionMap.containsKey(asset.Id)) {
                asset.addError('Cannot delete Asset: Inspections exist within the last year.');
            }
        }
    }
    public static void afterDelete(List<Asset__c> deletedAssets) {
        AssetLogger.logChange(deletedAssets, 'Deleted', null);
        AssetNotifier.notify(deletedAssets, null, 'AFTER DELETE','Asset__c');
    }

    public static void afterUndelete(List<Asset__c> undeletedAssets) {
        AssetLogger.logChange(undeletedAssets, 'Undeleted', null);
        AssetNotifier.notify(undeletedAssets, null, 'AFTER UNDELETE','Asset__c');
    }
}
