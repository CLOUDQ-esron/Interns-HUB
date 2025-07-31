public class CreationViolationLog {
    public static void logViolation(Leave_Request__c req) {
        Leave_Violation_Log__c vio = new Leave_Violation_Log__c();
        vio.Leave_Request__c = req.Id;
        vio.Employee__c = req.Employee__c;
        vio.ActionTaken__c = 'Logged';
        insert vio ;
    }
    
    public static void resolveViolation(Id leaveRequestId) {
        Leave_Violation_Log__c res = [SELECT Id FROM Leave_Violation_Log__c WHERE Leave_Request__c = :leaveRequestId LIMIT 1];
        res.ActionTaken__c = 'Resolved';
        update res;
    }
    public static Map<String, Map<String,Leave_Policy__mdt>> createMapOFMDT(){
       
        Map<String, Map<String,Leave_Policy__mdt>>  mapOfMapDep = new Map<String, Map<String,Leave_Policy__mdt>>();
        for(Leave_Policy__mdt lpm : [SELECT Department__c, Leave_Type__c, Max_Days__c, Manager_Approval__c, Notify_On_Violation__c, Escalate_To__c FROM Leave_Policy__mdt]){
            
            String dept = lpm.Department__c;
            String leave = lpm.Leave_Type__c;
            
            if (!mapOfMapDep.containsKey(dept)) {
                mapOfMapDep.put(dept, new Map<String, Leave_Policy__mdt>());
            }
            if (mapOfMapDep.containsKey(dept)){
                mapOfMapDep.get(dept).put(leave, lpm);
            }
        }
        return mapOfMapDep;
    }
    public static Map<Id,Employee__c> createMapOFMDT(list<Leave_Request__c> listOfLR){

        Set<Id> empId = new Set<Id>();
        for(Leave_Request__c lea : listOfLR){
            if(lea.Employee__c !=Null){
                empId.add(lea.Employee__c); 
            }
        }
        Map<Id,Employee__c> emMap = New Map<Id,Employee__c>([Select Id, Department__c, Manager__r.Email fROM Employee__c Where Id in :empId]);
        return emMap;
}
}