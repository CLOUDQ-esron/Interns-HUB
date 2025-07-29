trigger LeaveRequestTrigger on Leave_Request__c (before insert,after insert,before Update,after update,before delete,After delete,After undelete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            leaveRequestTriggerHandler.beforeInsert(Trigger.new);
        }
        else if(Trigger.isUpdate){
            leaveRequestTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
            
        }
    	else if(Trigger.isDelete){
        leaveRequestTriggerHandler.beforeDelete(trigger.old); 
    }
    }
    
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            leaveRequestTriggerHandler.afterInsert(Trigger.new);
        }else if(Trigger.isUpdate){
            leaveRequestTriggerHandler.afterUpdateTrigger(Trigger.new,Trigger.oldMap);
            leaveRequestTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }
        else if(Trigger.isDelete){
            leaveRequestTriggerHandler.afterDelete(Trigger.old); 
        }
        else if( Trigger.isUndelete){
            leaveRequestTriggerHandler.afterUndelete(Trigger.new);  
        }
        
        
    }
}