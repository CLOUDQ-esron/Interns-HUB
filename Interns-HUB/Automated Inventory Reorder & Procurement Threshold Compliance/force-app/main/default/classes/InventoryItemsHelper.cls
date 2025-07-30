public class InventoryItemsHelper {
    public static Map<String,Inventory_Reorder_Config__mdt> createMapOfInventoryReorderConfigmdt(){
        Map<String,Inventory_Reorder_Config__mdt> mapOfMDT = new Map<String, Inventory_Reorder_Config__mdt>();
        for (Inventory_Reorder_Config__mdt tempMDT : [SELECT SKU__c, Enable_Auto_Reorder__c, Reorder_If_Below__c, Reorder_Quantity__c, Escalate_If_Urgent__c, Force_Freezing_If_Zero__c FROM Inventory_Reorder_Config__mdt ]) {
            mapOfMDT.put(tempMDT.SKU__c, tempMDT);
        }
        return mapOfMDT;
    }
    
    public static  Map<Id, Vendor__c> createMapOfVendors(List<Inventory_Item__c> newITList){
        Set<Id> supplierIds = new Set<Id>();
        for(Inventory_Item__c tempIT : newITList){
            supplierIds.add(tempIT.Supplier__c);
        }
        Map<Id, Vendor__c> mapOfVendor = new Map<Id, Vendor__c>([SELECT Id, Delivery_Lead_Time__c FROM Vendor__c WHERE Id IN :supplierIds]);       
        return mapOfVendor;
    }
    
    public static void createProcurementRequest (Inventory_Item__c newITitem, String procName, Integer quant){
        Procurement_Request__c procRequest = new Procurement_Request__c();
        procRequest.Name = procName;
        procRequest.Inventory_Item__c = newITitem.Id;
        procRequest.Quantity__c = quant;
        procRequest.Raised_By__c = UserInfo.getUserId();
        procRequest.Requested_On__c = datetime.now();
        procRequest.Status__c = 'new';
        procRequest.Urgency_Level__c = 'Normal';
        insert procRequest;
    }
    public static Boolean checkOpenProcurementResults(Id newITitem){
        List<Procurement_Request__c> listOfProc = [SELECT Id, Inventory_Item__c FROM Procurement_Request__c WHERE Inventory_Item__c = :newITitem AND (Status__c = 'New' OR Status__c = 'Submitted')];
        Boolean openProc = listOfProc.isEmpty() ? false:true;
        return openProc;
    }
    
    public static void createStockAuditLog (Id itemId, Decimal oldStock, Decimal newStock, String notes){
        Stock_Audit_Log__c stockAudit = new Stock_Audit_Log__c();
        if(itemId != null)
            stockAudit.Inventory_Item__c = itemId;
        if((oldStock - newStock) < 0)
            stockAudit.Name = 'Restocked';
            stockAudit.Change_Type__c = 'Restock';
        if((oldStock - newStock) > 0)
            stockAudit.Name = 'Depleted';
            stockAudit.Change_Type__c = 'Deplete';
        if((oldStock - newStock) == 0)
            stockAudit.Name = 'Frozen';
            stockAudit.Change_Type__c = 'Freeze';
        stockAudit.Changed_On__c = datetime.now();
        stockAudit.Changed_By__c = UserInfo.getUserId();
        stockAudit.NotesC__c = notes;
        insert stockAudit;
    }
    
    public static Boolean getPermissionOfUser(){
        Boolean userHasPermission = false;
        for (PermissionSetAssignment psa : [SELECT AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()]){
            if (psa.PermissionSet.Name == 'Inventory_Manager') {
                userHasPermission = true;
            }
        }
        System.debug(userHasPermission);
        return userHasPermission;
    }
    
    public static void sendMail(String address, String subject, String body) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();       // Create an email message object
        String[] toAddresses = new String[] {address};
            mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        System.debug(results);
    }
}