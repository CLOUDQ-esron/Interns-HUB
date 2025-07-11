trigger AsseTrigger on Asset__c (before insert,after insert,before update,after update,before delete,after delete,after undelete ) {
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            AssetHandler.beforeInsert(Trigger.new);
        }
        if(Trigger.isAfter){
            AssetHandler.afterInsert(Trigger.new);
        }
    }
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            AssetHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
        if(Trigger.isAfter){
            AssetHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            AssetHandler.beforeDelete(Trigger.old);
        }
        if (Trigger.isAfter) {
            AssetHandler.afterDelete(Trigger.old);
        }

    }
    if (Trigger.isUndelete) {
    	AssetHandler.afterUndelete(Trigger.new); 
	}

    
    
}