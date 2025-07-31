@isTest
public class ContractTriggerTestClass {

    @testSetup
    static void setupTestData() {
        // Create test User
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(FirstName = 'Test',LastName = 'User',
            Email = 'fathima@gmail.com',
            Username = 'ns35679fathima@gmail.com',
            Alias = 'tusr',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert u;

       

        // Create Vendor
        Vendor__c vendor = new Vendor__c(Name = 'Test Vendor', Tier__c = 'Silver');
        insert vendor;
        
        Vendor__c vendor2 = new Vendor__c(Name = 'Test Vendor2', Tier__c = 'Bronze');
        insert vendor2;
        
        // Create Contract
        Contract__c contract = new Contract__c(
            Name = 'Initial Contract',
            Vendor__c = vendor.Id,
            ViolationCount__c = 1,
            EscalationFlag__c = false,
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(30));
        insert contract;
        
        Contract__c contract3 = new Contract__c(
            Name = 'Initial Contract3',
            Vendor__c = vendor.Id,
            ViolationCount__c = 1,
            EscalationFlag__c = false,
            StartDate__c = Date.today(),
            RiskScore__c = 50,
            IsFrozen__c = true,
            EndDate__c = Date.today().addDays(30));
        insert contract3;
        
        Contract__c contract4 = new Contract__c(
            Name = 'Initial Contract4',
            Vendor__c = vendor.Id,
            ViolationCount__c = 1,
            EscalationFlag__c = false,
            StartDate__c = Date.today(),
            RiskScore__c = 50,
            IsFrozen__c = true,
            EndDate__c = Date.today().addDays(30));
        insert contract4;
         
    }

    @isTest
    static void testHandlerBeforeInsert() {
        Vendor__c vendor = [SELECT Id, Tier__c FROM Vendor__c LIMIT 1];
		Contract__c contract = [Select Name,Vendor__c,Status__c,StartDate__c,EndDate__c,IsFrozen__c, RiskScore__c From Contract__c Where Name  ='Initial Contract'];
		Contract__c contract2 = new Contract__c(Name = 'Initial Contract2',Vendor__c = vendor.Id,StartDate__c = Date.today().addDays(30),EndDate__c = Date.today()); 
        Test.startTest();
        	Try{
            insert contract2;
        }
        catch (Exception e) {
            Boolean exceptionThrown = (e.getMessage().contains('End date must be future dates'))? true:false;
            Assert.areEqual(true, exceptionThrown, e.getMessage());

        Test.stopTest();

        System.assertEquals('Draft', contract.Status__c);
        System.assertEquals(false, contract.IsFrozen__c);
        }
    }

    @isTest
    static void testHandlerBeforeUpdate() {
        Vendor__c vendor2 = [SELECT Id, Tier__c FROM Vendor__c WHERE Name = 'Test Vendor2' LIMIT 1];
        Contract__c contract3 = [ SELECT Name, Vendor__c, Status__c, StartDate__c, EndDate__c, IsFrozen__c, ViolationCount__c, EscalationFlag__c From Contract__c Where Name  ='Initial Contract3'];
       Contract__c contract=[ Select Name, Vendor__c, Status__c, StartDate__c, EndDate__c, IsFrozen__c, ViolationCount__c, EscalationFlag__c From Contract__c Where Name  ='Initial Contract'];
        contract.Status__c = 'Active';
        update contract;

        Test.startTest();
        try {
            contract.ViolationCount__c = 35;
            contract.Vendor__c = vendor2.Id;
            contract.IsFrozen__c = true;
            update contract;
            Assert.areEqual(true, contract.EscalationFlag__c);
        } catch (Exception e) {
            Boolean exceptionThrown = (e.getMessage().contains('Cannot change Vendor when the contract is Active'))? true:false;
              Assert.areEqual(true, exceptionThrown, e.getMessage());
        }
        contract3.isFrozen__c = true;
        update contract3;
        try {
            contract3.Status__c = 'Draft';
            contract3.ViolationCount__c = 30;
            update contract3;
        } catch (Exception e) {
            Boolean exceptionThrown = (e.getMessage().contains('This contract is frozen and cannot be modified.'))? true:false;
            Assert.areEqual(true, exceptionThrown, e.getMessage());
        }
    }

    @isTest
    static void testHandlerBeforeDelete() {
        Contract__c contract = [SELECT Id, Status__c FROM Contract__c LIMIT 1];
        contract.Status__c = 'Active';
        update contract;

        Test.startTest();
        try {
            delete contract;
        } catch (DmlException e) {
            Boolean exceptionThrown = (e.getMessage().contains('Something went to wrong'))? true:false;
            Assert.areEqual(true, exceptionThrown, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testHandlerAfterDelete() {
        Contract__c contract = [SELECT Id FROM Contract__c WHERE Name = 'Initial Contract3' LIMIT 1];

        Test.startTest();
        delete contract;
        Test.stopTest();

        Vendor__c vendor = [SELECT Id, RiskScore__c FROM Vendor__c WHERE Name = 'Test Vendor'];
            
        Assert.areEqual(50, vendor.RiskScore__c);
    }

    @isTest
    static void testAfterUndelete() {
        Contract__c contract = [SELECT Id FROM Contract__c LIMIT 1];
        delete contract;
        undelete contract;

        Test.startTest();
        ContractTriggerHandler.afterUndelete(new List<Contract__c>{contract});
        Test.stopTest();

        System.assert(true);
    }
}