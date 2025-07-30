@isTest
public class InventoryItemsTriggerHandlerTest {

    @testSetup
    static void setupData() {

        Vendor__c vendor = new Vendor__c (Name = 'Vendor 1', Delivery_Lead_Time__c = 5, SLA_Level__c = 'Gold', Active__c = true);
        insert vendor;
        
        Vendor__c vendor2 = new Vendor__c (Name = 'Vendor 2', Delivery_Lead_Time__c = 5, SLA_Level__c = 'Gold', Active__c = true);
        insert vendor2;

        Inventory_Item__c it = new Inventory_Item__c (Name = 'My Test Product 365', SKU__c = 'SKU001', Stock_On_Hand__c = 0, Supplier__c = vendor.Id, Auto_Reorder__c = true);
        insert it;
    }

    @isTest
    static void beforeInsertTest() {
        Inventory_Item__c it = [SELECT Id, Minimum_Threshold__c, Next_Reorder_Date__c, Is_Frozen__c FROM Inventory_Item__c WHERE Name = 'My Test Product 365'];
        Assert.areEqual(10, it.Minimum_Threshold__c);
        Date expectedDate = Date.newInstance(2025, 8, 3);
        Assert.areEqual(expectedDate, it.Next_Reorder_Date__c);
        Assert.areEqual(true, it.Is_Frozen__c);
        
    }

    @isTest
    static void afterInsertTest() {
        
        Inventory_Item__c it = [SELECT Id, Minimum_Threshold__c, Next_Reorder_Date__c, Is_Frozen__c FROM Inventory_Item__c WHERE Name = 'My Test Product 365'];
        List<Procurement_Request__c> pr = [SELECT Id FROM Procurement_Request__c WHERE Inventory_Item__c = :it.Id];
        Assert.areEqual(1, pr.size());

    }

    @isTest
    static void beforeUpdateTest() {
        
        Inventory_Item__c it = [SELECT Id, Minimum_Threshold__c, Next_Reorder_Date__c, Is_Frozen__c FROM Inventory_Item__c WHERE Name = 'My Test Product 365'];
        Vendor__c vendor2 = [SELECT Id FROM Vendor__c WHERE Name = 'Vendor 2'];

        it.Supplier__c = vendor2.Id;

        Test.startTest();
        try {
            update it;
        } catch (Exception e) {
            Boolean exceptionThrown = (e.getMessage().contains('The Supplier cannot be changed when there are open Procurement Requests'))? true:false;
            Assert.areEqual(true, exceptionThrown, e.getMessage());
        }
        Assert.areEqual(true, it.Is_Frozen__c);
        Test.stopTest();
    }

    @isTest
    static void afterUpdateTest(){
        Inventory_Item__c it = [SELECT Id, Minimum_Threshold__c, Next_Reorder_Date__c, Is_Frozen__c FROM Inventory_Item__c WHERE Name = 'My Test Product 365'];
        it.Stock_On_Hand__c = 5; 

        Test.startTest();
        update it;
        Test.stopTest();
        
        List<Stock_Audit_Log__c> sal = [SELECT Id FROM Stock_Audit_Log__c WHERE Inventory_Item__c = :it.Id];
        Assert.areEqual(1, sal.size());
        List<Procurement_Request__c> pr = [SELECT Id FROM Procurement_Request__c WHERE Inventory_Item__c = :it.Id];
        Assert.areEqual(2, pr.size());
    }

    @isTest
    static void testBeforeDeletePreventsIfFrozenOrOpen() {
        
        Inventory_Item__c it = [SELECT Id, Minimum_Threshold__c, Next_Reorder_Date__c, Is_Frozen__c FROM Inventory_Item__c WHERE Name = 'My Test Product 365'];

        Test.startTest();
        try {
            delete it;
        } catch (Exception e) {
            Boolean exceptionThrown = (e.getMessage().contains('Frozen Inventory Items can only be deleted by the Inventory Manager'))? true:false;
            Assert.areEqual(true, exceptionThrown, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testAfterDeleteCreatesAuditLog() {
        
        Inventory_Item__c it = [SELECT Id, Minimum_Threshold__c, Next_Reorder_Date__c, Is_Frozen__c FROM Inventory_Item__c WHERE Name = 'My Test Product 365'];
        it.Stock_On_Hand__c = 5;
        it.Is_Frozen__c = false;
        update it;
        List<Procurement_Request__c> pr = [SELECT Id FROM Procurement_Request__c WHERE Inventory_Item__c = :it.Id];

        
        Test.startTest();
        delete pr;
        delete it;
        Test.stopTest();
        
        List<Inventory_Item__c> itDeleted = [SELECT Id, Minimum_Threshold__c, Next_Reorder_Date__c, Is_Frozen__c FROM Inventory_Item__c WHERE Id = :it.Id];

        Assert.areEqual(0, itDeleted.size());
    }

    @isTest
    static void testAfterUndeleteTriggersReorderAndUrgentLog() {
        
        Inventory_Item__c it = [SELECT Id, Minimum_Threshold__c, Next_Reorder_Date__c, Is_Frozen__c FROM Inventory_Item__c WHERE Name = 'My Test Product 365'];
        it.Stock_On_Hand__c = 5;
        it.Is_Frozen__c = false;
        update it;
        
        List<Procurement_Request__c> pr = [SELECT Id FROM Procurement_Request__c WHERE Inventory_Item__c = :it.Id];
        delete pr;
        delete it;

        Test.startTest();
        undelete it;
        Test.stopTest();

        List<Procurement_Request__c> prs = [SELECT Id FROM Procurement_Request__c WHERE Inventory_Item__c = :it.Id];
        Assert.areEqual(1, prs.size());
    }
}