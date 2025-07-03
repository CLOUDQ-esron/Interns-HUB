trigger ContactTrigger on Contact (before insert, before update,after insert,after update, after delete, before delete) {
    
    if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate){
       	ContactTriggerHandler.beforeInsertUpdateContact(Trigger.new,Trigger.oldMap);
            //ContactTriggerHandler.beforeUpdateContactSales(Trigger.new ,Trigger.oldMap);
            
        }
        
        
        
        
    }
}