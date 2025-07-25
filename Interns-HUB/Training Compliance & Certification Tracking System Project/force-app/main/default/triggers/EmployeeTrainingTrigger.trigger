trigger EmployeeTrainingTrigger on Employee_Training__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    if(Trigger.isBefore){        
        if(Trigger.isInsert){
            EmployeeTraininghandler.BeforeInsert(Trigger.new);
        }   
        If(Trigger.isUpdate){
            EmployeeTraininghandler.BeforeUpdate(Trigger.new, Trigger.oldMap);
        }
        If(Trigger.isDelete){
            EmployeeTraininghandler.BeforeDelete(Trigger.old);
        }
    }
    If(Trigger.isAfter){
        If(Trigger.isInsert){
            EmployeeTraininghandler.AfterInsert(Trigger.new);
        }
        If(Trigger.isUpdate){
            EmployeeTraininghandler.AfterUpdate(Trigger.new, Trigger.oldMap);
        }
        If(Trigger.isDelete){
            System.debug(Trigger.old);
            EmployeeTraininghandler.AfterDelete(Trigger.old);
        }
        If(Trigger.isUndelete){
            EmployeeTraininghandler.afterUndelete(Trigger.new);
        }
  }
}