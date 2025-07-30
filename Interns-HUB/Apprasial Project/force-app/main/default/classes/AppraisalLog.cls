public class AppraisalLog {
	public static void logChange(Set<Id> employeeIds, String action ,String description) {
        List<Appraisal_Log__c> logs = new List<Appraisal_Log__c>();
       	for (Id empId : employeeIds) {
            Appraisal_Log__c log = new Appraisal_Log__c();
            log.Employee__c = empId;
            log.Action__c = action;
            log.Action_On__c = System.now();
            log.Details__c = description;
            logs.add(log);
        }

        if (!logs.isEmpty()) {
            insert logs;
        }
    }
}