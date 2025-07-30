trigger SalesCreditTrigger on Sales_Credit__c (before insert, after insert, before update, after update, before delete, after delete, after undelete){
    if(Trigger.isBefore){
        if(Trigger.isInsert){
        SalesCreditTriggerHandler.beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            SalesCreditTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            SalesCreditTriggerHandler.beforeDelete(Trigger.old, Trigger.oldMap);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            SalesCreditTriggerHandler.afterInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            SalesCreditTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            SalesCreditTriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
        }
        if(Trigger.isUndelete){
            SalesCreditTriggerHandler.afterUndelete(Trigger.new, Trigger.newMap);
        }
    }
}