@isTest
public class LeaveReq2TestClass {

    @testSetup
    static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        // Create Manager
        User manager = new User(Alias = 'mgr',Email = 'manager@testorg.com',EmailEncodingKey = 'UTF-8',
            LastName = 'Manager',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',ProfileId = p.Id,TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'manager' + System.currentTimeMillis() + '@testorg.com');
        	insert manager;

        // Create Employee
        User employee = new User(Alias = 'emp', Email = 'employee@testorg.com',EmailEncodingKey = 'UTF-8',LastName = 'Employee',LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',ProfileId = p.Id,TimeZoneSidKey = 'America/Los_Angeles',UserName = 'employee' + System.currentTimeMillis() + '@testorg.com',
            ManagerId = manager.Id);
        insert employee;

        // Create Employee Record
        Employee__c emp = new Employee__c(Name = 'Test Employee',Department__c = 'IT',Manager__c = manager.Id);
        insert emp;

        //  Leave Request
        Leave_Request__c pendingReq = new Leave_Request__c(Name = 'PendingReq',Employee__c = emp.Id,Leave_Type__c = 'Sick',StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(5),Violates_Policy__c = true);

        // Create Approved Leave Request
        Leave_Request__c approvedReq = new Leave_Request__c(Name = 'ApprovedReq',Employee__c = emp.Id,Leave_Type__c = 'Sick',StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(5),Violates_Policy__c = true,Status__c = System.Label.Status_approved);

        insert pendingReq; 
        insert approvedReq;
    }

    @isTest
    static void testBeforeInsert() {
        Employee__c emp = [SELECT Id FROM Employee__c LIMIT 1];
        Leave_Request__c req = new Leave_Request__c(Employee__c = emp.Id,Leave_Type__c = 'Sick',StartDate__c = Date.today(),EndDate__c = Date.today().addDays(10));
		String errMsg = null;
        Test.startTest();
        try {
            insert req;
        } catch (Exception e) {
            errMsg = e.getMessage();
        }
        Test.stopTest();
        System.assertNotEquals(null, errMsg, 'Expected validation error on insert');
    }

    @isTest
    static void testAfterInsert() {
        Leave_Request__c req = [SELECT Id FROM Leave_Request__c WHERE Name = 'PendingReq' LIMIT 1];
        List<Leave_Violation_Log__c> logs = [SELECT Id FROM Leave_Violation_Log__c WHERE Leave_Request__c = :req.Id];
        System.assertEquals(1, logs.size(), 'Violation log should be created after insert');
    }

    @isTest
    static void testBeforeUpdate() {
        Leave_Request__c req = [SELECT Id, StartDate__c FROM Leave_Request__c WHERE Name = 'ApprovedReq' LIMIT 1];
        req.StartDate__c = req.StartDate__c.addDays(1);
        Test.startTest();
        try {
            update req;
            System.assert(false, 'Expected error when modifying approved leave');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Approved leave cannot be modified'), 'Expected modification error');
        }
        Test.stopTest();
    }

    @isTest
    static void testAfterUpdate() {
        Leave_Request__c req = [SELECT Id, Status__c FROM Leave_Request__c WHERE Name = 'ApprovedReq' LIMIT 1];
		Test.startTest();
        update req; 
        Test.stopTest();

        System.assert(true, 'Update on approved leave passed without exception');
    }

    @isTest
    static void testBeforeDelete() {
        Leave_Request__c req = [SELECT Id, Status__c FROM Leave_Request__c WHERE Name = 'ApprovedReq' LIMIT 1];
        String errorMsg = null;

        Test.startTest();
        try {
            delete req;
            System.assert(false, 'Expected error not thrown when deleting approved leave');
        } catch (DmlException e) {
            errorMsg = e.getMessage();
        }
        Test.stopTest();

        System.assertNotEquals(null, errorMsg, 'Expected an error when deleting approved leave');
        System.assert(errorMsg.contains('cannot be deleted'), 'Expected deletion error message to mention prohibition');
    }

    @isTest
    static void testAfterUndelete() {
        Leave_Request__c req = [SELECT Id FROM Leave_Request__c WHERE Name = 'PendingReq' LIMIT 1];
        delete req;

        Test.startTest();
        undelete req;
        Test.stopTest();

        List<Leave_Violation_Log__c> logs = [SELECT Id FROM Leave_Violation_Log__c WHERE Leave_Request__c = :req.Id];
        System.assert(logs.size() > 0, 'Violation should be re-logged after undelete');
    }
}