trigger ContractTrigger on Contract__c (before insert,after insert,before update,after update, before delete, after delete, after undelete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            ContractTriggerHandler.handlerBeforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            ContractTriggerHandler.handlerBeforeUpdate(Trigger.new,Trigger.oldMap);
        }
        if(Trigger.isDelete){
            ContractTriggerHandler.handlerBeforeDelete(Trigger.old);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            ContractTriggerHandler.handleAfterInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            ContractTriggerHandler.handlerAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            ContractTriggerHandler.handlerAfterDelete(Trigger.old);
        }
        if(Trigger.isUndelete){
            ContractTriggerHandler.afterUndelete(Trigger.new);
        }
    }
}