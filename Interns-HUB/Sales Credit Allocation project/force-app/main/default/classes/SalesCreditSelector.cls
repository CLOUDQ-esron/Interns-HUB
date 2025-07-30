public class SalesCreditSelector {
    
    public static Map<String, Integer> createMapOfOppoTotalCredit(List<Sales_Credit__c> listOfSC){
        set<Id> opportunityIds = new set<Id>();
        for(Sales_Credit__c creditRecord : listOfSC){
            opportunityIds.add(creditRecord.Opportunity__c);
        }
        Map<String, Integer> oppoAggregate = new Map<String, Integer>();
        for(AggregateResult sumOfCPOppo : [SELECT SUM(CreditPercent__c) TotalCredit, Opportunity__c FROM Sales_Credit__c WHERE Opportunity__c IN :opportunityIds GROUP BY Opportunity__c]){
            oppoAggregate.put(String.valueOf(sumOfCPOppo.get('Opportunity__c')),Integer.valueOf(sumOfCPOppo.get('TotalCredit')));
        }
        return oppoAggregate;
    }
    
    public static Map<String, Commission_Threshold__mdt> createMapOfCommissionThreshold(){
        Map<String,Commission_Threshold__mdt> mapOfCT = new Map<String,Commission_Threshold__mdt>();
        for(Commission_Threshold__mdt ct : [SELECT Region__c, Auto_Approve__c, Escalate_To__c, Max_Credit__c, Notify_Manager__c FROM Commission_Threshold__mdt]){
            mapOfCT.put(ct.Region__c, ct);
        }
        return mapOfCT;
    }
    
    public static Map<Id,User> createMapOfSalesReps(List<Sales_Credit__c> newSCList){
        set<Id> salesRepIds = new set<Id>();
        for(Sales_Credit__c creditRecord : newSCList){
            salesRepIds.add(creditRecord.Sales_Rep__c);
        }
        Map<Id,User> mapOfUsers = new Map<Id,User>([SELECT Id, Email, ManagerId, Manager.Email FROM User WHERE Id IN :salesRepIds]);
        return mapOfUsers;
    }    
    
    public static Map<Id,Commission_Alert__c> createMapOfCommissionAlerts(List<Sales_Credit__c> newSCList){
        Map<Id,Commission_Alert__c> mapOfCA = new Map<Id,Commission_Alert__c>();
        for(Commission_Alert__c alert : [SELECT Id, Sales_Credit__c FROM Commission_Alert__c WHERE Sales_Credit__c IN :newSCList ORDER BY CreatedOn__c]){
            mapOfCA.put(alert.Sales_Credit__c, alert);
        }
        return mapOfCA;
    }
}