public class InventoryItemsFuture {
    @future
    public static void logUrgentInventoryItems(List<Id> urgentITs) {
        
        List<Inventory_Item__c> itemIT = [SELECT Id, Name, Stock_On_Hand__c, Minimum_Threshold__c FROM Inventory_Item__c WHERE Id IN :urgentITs ];
        for (Inventory_Item__c tempIT : itemIT) {
            System.debug('Sent Email for urgent inventory: ' + tempIT.Name);
            String body = 'The '+tempIT.Name+' item need urgent inventory';
            InventoryItemsHelper.sendMail('nefingigi10@gmail.com', 'Urgent Inventory!!!!!!!', body);
        }
    }


}