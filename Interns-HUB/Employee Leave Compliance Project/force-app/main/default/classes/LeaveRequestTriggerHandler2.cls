public class LeaveRequestTriggerHandler2 {
    public static void beforeInsert(list<Leave_Request__c> newLeavelist){
        Map<Id,Employee__c> emMap = CreationViolationLog.createMapOFMDT(newLeavelist);
        Map<String, Map<String,Leave_Policy__mdt>>  mapOfMapDep = CreationViolationLog.createMapOFMDT();
        for(Leave_Request__c lea : newLeavelist){
            if(lea.Employee__c != null && lea.Leave_Type__c != null){
               String emDepartment = emMap.get(lea.Employee__c).Department__c;
               Leave_Policy__mdt tempLeave = mapOfMapDep.get(emDepartment).get(lea.Leave_Type__c);
               	if(lea.Leave_Days__c > tempLeave.Max_Days__c){
                    lea.Violates_Policy__c = true;
                    lea.Violation_Reason__c = 'Exceeds max of '+tempLeave.Max_Days__c+' days for '+tempLeave.Leave_Type__c+' Leave';
                }
                if(lea.Manager__c == null && tempLeave.Manager_Approval__c == true){
                    lea.addError('Manager approval is required.');
                }            
            }        
        }
    }
    public static void handlerAfterInsert(List<Leave_Request__c> leaveRequests) {
        Map<Id,Employee__c> emMap = CreationViolationLog.createMapOFMDT(leaveRequests);
        Map<String, Map<String,Leave_Policy__mdt>> mapOfMapDep = CreationViolationLog.createMapOFMDT();
        for (Leave_Request__c req : leaveRequests) {
            if(req.Employee__c != null && req.Leave_Type__c != null){
                if (req.Violates_Policy__c == true) {
                    CreationViolationLog.logViolation(req);
                }
                
                Employee__c emRecord = emMap.get(req.Employee__c);
                Leave_Policy__mdt tempLeave = mapOfMapDep.get(emRecord.Department__c).get(req.Leave_Type__c);
                if(tempLeave.Notify_On_Violation__c == true){
                    NotificationService.sendEmailToManager(emRecord.Manager__r.Email, 'Violation of the Rule !!', 'The Rule has been violated');
                    NotificationService.sendInAppNotification(req.Id);
                }
                if(tempLeave.Escalate_To__c != Null){
                   EscalationQueueService esclate = new EscalationQueueService(emRecord.Manager__r.Email, 'Violation of the Rule !!', 'The Rule has been violated');
                    system.enqueueJob (esclate);
                }
                
            }
        }
    }
    
    public static void handlerBeforeUpdate(List<Leave_Request__c> newList, Map<Id, Leave_Request__c> oldMap) {
        for (Leave_Request__c req : newList) {
            Leave_Request__c old = oldMap.get(req.Id);
            if (old.Status__c == System.Label.Status_approved && (req.StartDate__c != old.StartDate__c || req.EndDate__c != old.EndDate__c || req.Leave_Type__c != old.Leave_Type__c)) {
                req.addError('Approved leave cannot be modified.');
            }
           if (req.Status__c == System.Label.Status_approved && req.Manager__c != null && UserInfo.getUserId() != req.Manager__c) {
                req.addError('Only the assigned manager can approve this leave.');
            }
        }
    }
    
    public static void handlerAfterUpdate(List<Leave_Request__c> newList, Map<Id, Leave_Request__c> oldMap) {
         Map<Id,Employee__c> emMap = CreationViolationLog.createMapOFMDT(newList);
			for (Leave_Request__c req : newList) {
            Leave_Request__c old = oldMap.get(req.Id);
        	Employee__c emRecord = emMap.get(req.Employee__c);
			if (req.Status__c == System.Label.Status_approved && req.Violates_Policy__c == true) {
               system.debug('entered the queueable job');
                system.debug(emRecord.Manager__r.Email);
              EscalationQueueService esclate = new EscalationQueueService(emRecord.Manager__r.Email, 'Violation of the Rule !!', 'The Rule has been violated');
				system.enqueueJob(esclate);

            }
            
            if (req.Status__c == System.Label.Status_cancelled && req.Violates_Policy__c == false && old.Violates_Policy__c == true) {
                CreationViolationLog.resolveViolation(req.Id);
            }
        }
    }
    public static void handlerBeforeDelete(List<Leave_Request__c> oldList) {
        Set<Id> userId = new Set<Id>{UserInfo.getUserId()};
        List<PermissionSetAssignment> perId =[Select Id From PermissionSetAssignment Where AssigneeId In :userId AND PermissionSet.Name = 'Manager_Permission'];
		for (Leave_Request__c req : oldList) {
            if (perId.isEmpty() && req.Status__c == System.Label.Status_approved) {
                req.addError('Approved leave cannot be deleted.');
            }
        }
    }
    public static void handlerAfterUndelete(List<Leave_Request__c> unList) {
        Map<Id,Employee__c> emMap = CreationViolationLog.createMapOFMDT(unList);
        Map<String, Map<String,Leave_Policy__mdt>>  mapOfMapDep = CreationViolationLog.createMapOFMDT();
        for(Leave_Request__c lea : unList){
            if(lea.Employee__c != null && lea.Leave_Type__c != null){
                String emDepartment = emMap.get(lea.Employee__c).Department__c;
                Leave_Policy__mdt tempLeave = mapOfMapDep.get(emDepartment).get(lea.Leave_Type__c);
                if(lea.Leave_Days__c > tempLeave.Max_Days__c){
                    CreationViolationLog.logViolation(lea);
                    
                }
            }
            
        }
    }
}