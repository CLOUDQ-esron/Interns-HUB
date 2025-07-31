public class ContractTriggerQueueable implements Queueable{
    
    public set<Id> vendorIds;
    public ContractTriggerQueueable(set<Id> vendorIds){
        this.vendorIds = vendorIds;
    }
    
    public void execute(QueueableContext context){
        List<Vendor__c> listVendors = new List<Vendor__c>();
        Map<Id, Decimal> mapOfVendorAgg = new Map<Id, Decimal>();
        for(AggregateResult agg : [SELECT Vendor__c, SUM(RiskScore__c) venSum FROM Contract__c GROUP by Vendor__c]){
            mapOfVendorAgg.put((Id)agg.get('Vendor__c'), (Decimal)agg.get('venSum'));
        }
        for(Id venId : vendorIds){
            Vendor__c ven = new Vendor__c();
            ven.Id = venId;
            ven.RiskScore__c = mapOfVendorAgg.get(venId);
            listVendors.add(ven);
        }
        if(!listVendors.isEmpty()){
            update listVendors;
        }
    }
}