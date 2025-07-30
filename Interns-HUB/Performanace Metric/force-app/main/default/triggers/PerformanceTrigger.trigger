trigger PerformanceTrigger on Performance_Metric__c (after insert,after update,before delete,after delete,after undelete) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            PerformanceMetricHandler.afterInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            PerformanceMetricHandler.afterUpdate(Trigger.new);
        }
    }
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            PerformanceMetricHandler.beforeDelete(Trigger.old);
        }
        if(Trigger.isAfter){
            PerformanceMetricHandler.afterDelete(Trigger.old);
        }
    }
    if (Trigger.isUndelete) {
    	PerformanceMetricHandler.afterUndelete(Trigger.new); 
	}
}