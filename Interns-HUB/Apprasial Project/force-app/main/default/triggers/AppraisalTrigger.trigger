trigger AppraisalTrigger on Appraisal__c (before insert,after insert,before update,after update,before delete,after delete) {
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            AppraisalHandler.beforeInsert(Trigger.new);
        }
        if(Trigger.isAfter){
            AppraisalHandler.afterInsert(Trigger.new);
        }
    }
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            AppraisalHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
        if(Trigger.isAfter){
            AppraisalHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }
    }
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            AppraisalHandler.beforeDelete(Trigger.old);
            
        }
        if(Trigger.isAfter){
            AppraisalHandler.afterDelete(Trigger.old);
        }
    }
     if (Trigger.isUndelete) {
    	AppraisalHandler.afterUndelete(Trigger.new); 
	}

}