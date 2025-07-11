trigger AssetInspectionTrigger on Asset_Inspection__c (after insert) {
    if (Trigger.isAfter) {
        AssetInspectionHandler.afterInsert(Trigger.new);
    }
}