public class ContractTriggerHandler {
    public static void handlerBeforeInsert(List<Contract__c> newList){
        
        Map<Id, Vendor__c> mapOfVendors = QuerySelector.createVendorMap(newList);
        Map<String, Risk_Threshold__mdt> mapOfThresholds = QuerySelector.getMapOfRiskThresholdmdt();
        for(Contract__c con:newList){
            if(con.Vendor__c != null){
                String vendorTier = mapOfVendors.get(con.Vendor__c).Tier__c;
                con.Assigned_Legal_Rep__c = mapOfThresholds.get(vendorTier).User__c;
            }
            if(con.Status__c == null){
                con.Status__c = 'Draft';
            }
            if(con.EndDate__c<con.StartDate__c){
            con.addError('End date must be future dates');
			}
            con.IsFrozen__c = false;
        }
    }
    
    public static void handleAfterInsert(List<Contract__c> newContracts) {
        List<Contract__c> contractWithVendors = new List<Contract__c>();
        for(Contract__c con:newContracts){
            if(con.Vendor__c != null){
                contractWithVendors.add(con);
            }
        }
        SLAEventInitializer slaRecords = new SLAEventInitializer(contractWithVendors);
        System.enqueueJob(slaRecords);

    }
    
	public static void handlerBeforeUpdate(List<Contract__c > newList,Map<Id,Contract__c > oldMap) {
        
        Map<Id,Vendor__c> venMap = QuerySelector.createVendorMap(newList);
        Map<String, Risk_Threshold__mdt> mapOfThresholds = QuerySelector.getMapOfRiskThresholdmdt();

        for (Contract__c con :newList){
         Contract__c oldCon = oldMap.get(con.Id); 
			if ((oldCon.Status__c == 'Active' && con.Status__c == 'Active') && oldCon.Vendor__c != con.Vendor__c) {
                con.addError('Cannot change Vendor when the contract is Active.');
            }
            String vendorTier = venMap.get(con.Vendor__c).Tier__c;
            if(con.ViolationCount__c > oldCon.ViolationCount__c && con.ViolationCount__c > mapOfThresholds.get(vendorTier).Max_Violations_c__c){
                con.EscalationFlag__c = true;
            }
            if(oldCon.IsFrozen__c == true && con.IsFrozen__c == true) {
                con.addError('This contract is frozen and cannot be modified.');
            }
        }
    }
    
    
    public static void handlerAfterUpdate(List<Contract__c> newList, Map<Id,Contract__c> oldMap) {
        
        List<Compliance_Escalation_Log__c> escalationLogs = new List<Compliance_Escalation_Log__c>();
        Map<String, Risk_Threshold__mdt> mapOfThresholds = QuerySelector.getMapOfRiskThresholdmdt();
        Map<Id, Vendor__c> vendorMap = QuerySelector.createVendorMap(newList);
        set<Id> conIds = new set<Id>();
        for (Contract__c con : newList) {
            Contract__c oldCon = oldMap.get(con.Id);
            if(con.SLABreach__c != oldCon.SLABreach__c && con.SLABreach__c == True) {
//                con.ViolationCount__c = (oldCon.ViolationCount__c == null ? 0 : oldCon.ViolationCount__c) + 1;
            }
            String vendorTier = vendorMap.get(con.Vendor__c).Tier__c;
            if(con.RiskScore__c > mapOfThresholds.get(vendorTier).Max_Risk__c){
                conIds.add(con.Id);
            }
            Id userId = UserInfo.getUserId();
                InAppNotification.customNotification(con.Id, userId, null);
        }
        QuerySelector.createComplianceEscalationLog(conIds);
    }
    
    public static void handlerBeforeDelete(List<Contract__c> oldList){
        Set<Id> userId = new Set<Id>{UserInfo.getUserId()};
        List<PermissionSetAssignment> perId =[Select Id From PermissionSetAssignment Where AssigneeId In :userId AND PermissionSet.Name = 'Manager_Permission'];
        for(Contract__c old :oldList){
            if(old.Status__c == 'Active' || old.IsFrozen__c == true || perId.isEmpty()){
               old.addError('Something went to wrong');
            }
        }
    }
    public static void handlerAfterDelete(List<Contract__c> delList){
        set<Id> vendorIds = new set<Id>();
        for(Contract__c del :delList){
            QuerySelector.createComplianceEscalationLogWhenDeleted();
            if(del.Vendor__c != null)
                vendorIds.add(del.Vendor__c);
        }
        ContractTriggerQueueable recalculateRisk = new ContractTriggerQueueable(vendorIds);
        system.enqueueJob(recalculateRisk);
    }
                                               
    public static void afterUndelete(List<Contract__c> newList) {
        for (Contract__c con : newList) {
            InAppNotification.customUndeleteNotification(con.Id, null, null);
        }
    }
}