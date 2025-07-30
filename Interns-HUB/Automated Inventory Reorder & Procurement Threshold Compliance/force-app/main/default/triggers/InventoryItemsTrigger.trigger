trigger InventoryItemsTrigger on Inventory_Item__c (before insert, after insert, after update, before update, before delete, after delete, after undelete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            InventoryItemsTriggerHandler.beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            InventoryItemsTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            InventoryItemsTriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
           InventoryItemsTriggerHandler.afterInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            InventoryItemsTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            InventoryItemsTriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
        }
        if(Trigger.isUndelete){
            InventoryItemsTriggerHandler.afterUndelete(Trigger.new);
        }
    }
}