trigger LeaveRequestTrigger on Leave_Request__c (before insert,after insert,before Update,after update,before delete,After delete,After undelete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            LeaveRequestTriggerHandler2.beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){            
        LeaveRequestTriggerHandler2.handlerBeforeUpdate(Trigger.new, Trigger.oldMap);   
        }
    	if(Trigger.isDelete){
//        leaveRequestTriggerHandler.beforeDelete(trigger.old); 
          LeaveRequestTriggerHandler2.handlerBeforeDelete(Trigger.old);
    }
    }
    
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
//            leaveRequestTriggerHandler.afterInsert(Trigger.new);
           	  LeaveRequestTriggerHandler2.handlerAfterInsert(Trigger.new);
        }if(Trigger.isUpdate){
//            leaveRequestTriggerHandler.afterUpdateTrigger(Trigger.new,Trigger.oldMap);
//            leaveRequestTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
              LeaveRequestTriggerHandler2.handlerAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isDelete){
//            leaveRequestTriggerHandler.afterDelete(Trigger.old); 
        }
        if( Trigger.isUndelete){
//            leaveRequestTriggerHandler.afterUndelete(Trigger.new);  
			  LeaveRequestTriggerHandler2.handlerAfterUndelete(Trigger.new);           
        }
        
        
    }
}