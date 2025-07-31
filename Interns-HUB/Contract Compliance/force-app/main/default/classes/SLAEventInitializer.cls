public class SLAEventInitializer implements Queueable {
    
    public List<Contract__c> contracts;
    
    public SLAEventInitializer(List<Contract__c> contracts) {
        this.contracts = contracts;
    }
    
    public void execute(QueueableContext context) {
        List<SLA_Event__c> slaEvents = new List<SLA_Event__c>();
        Map<Id, Vendor__c> maoOfVendors = QuerySelector.createVendorMap(contracts);
        for (Contract__c c : contracts) {
            SLA_Event__c sla = new SLA_Event__c();
            String tierValue = maoOfVendors.get(c.Vendor__c).Tier__c;
            if(tierValue == 'Bronze'){
                sla.ImpactLevel__c = 'Minor';
                sla.Name = 'Bronze SLA Event';}
            if(tierValue == 'Silver'){
                sla.ImpactLevel__c = 'Medium';
                sla.Name = 'Silver SLA Event';}
            if(tierValue == 'Gold'){
                sla.ImpactLevel__c = 'Critical';
                sla.Name = 'Silver SLA Event';}
            sla.Contract__c = c.Id;
            sla.Status__c = 'Investigating';
            slaEvents.add(sla);
        }
        
        if (!slaEvents.isEmpty()) {
            insert slaEvents;
        }
    }
}