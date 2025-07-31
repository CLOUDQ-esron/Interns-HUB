public class QuerySelector {
    public static list<CustomNotificationType> getInstance(){
       return [select Id, DeveloperName From CustomNotificationType Where DeveloperName ='Notify_approver_if_Status_is_Submitted'];
    }
     
    public static Map<String, Risk_Threshold__mdt> getMapOfRiskThresholdmdt(){
        Map<String, Risk_Threshold__mdt> mapOfThresholds = new Map<String, Risk_Threshold__mdt>();
        List<Risk_Threshold__mdt> listOfThresholds = [SELECT Auto_Freeze__c, Auto_Terminate__c, Max_Violations_c__c, Max_Risk__c, Tier__c, User__c FROM Risk_Threshold__mdt];
        for(Risk_Threshold__mdt threshold : listOfThresholds){
            mapOfThresholds.put(threshold.Tier__c, threshold);
        }
        return mapOfThresholds;
    }
    
    public static Map<Id, Vendor__c> createVendorMap(List<Contract__c> newList){
        
        set<Id> vendorIds = new set<Id>();
        for(Contract__c con : newList){
            if(con.Vendor__c != null){
            vendorIds.add(con.Vendor__c);
            }
        } 
        Map<Id, Vendor__c> mapOfVendors = new Map<Id, Vendor__c>([SELECT Id,Name, Tier__c, RiskScore__c, ActiveContracts__c FROM Vendor__c WHERE Id IN :vendorIds]);
        return mapOfVendors;
    }
    
    public static void createComplianceEscalationLog(set<Id> conIds){
        List<Compliance_Escalation_Log__c> listEscalation = new List<Compliance_Escalation_Log__c>();
        for(Id con : conIds){
            Compliance_Escalation_Log__c com = new Compliance_Escalation_Log__c(); 
            com.Name = 'Risk is greater than max risk';
            com.Contract__c = con;
            com.Timestamp__c = Datetime.now();
            com.Action__c = 'Flag';
            com.EscalatedTo__c = 'Manager';
            listEscalation.add(com);
        }
        if(!listEscalation.isEmpty()){
            insert listEscalation;
        }
    }
    
    public static void createComplianceEscalationLogWhenDeleted(){
        Compliance_Escalation_Log__c com = new Compliance_Escalation_Log__c(); 
        com.Name = 'Contract has been deleted';
        com.Timestamp__c = Datetime.now();
        com.Action__c = 'Flag';
        com.EscalatedTo__c = 'Manager';
    } 
}