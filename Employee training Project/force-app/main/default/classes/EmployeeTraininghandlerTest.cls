@isTest
public class EmployeeTraininghandlerTest {
    @testSetup
    static void setup(){
        Id systemAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

        User userExample = new User();
        userExample.Username = 'emailtest198@test.com';
        userExample.FirstName = 'First';
        userExample.LastName = 'Last';
        userExample.Alias = 'Alias';
        userExample.Email = 'emailtest@test.com';
        userExample.TimeZoneSidKey = 'America/New_York';
        userExample.LocaleSidKey = 'en_US';
        userExample.EmailEncodingKey = 'ISO-8859-1';
        userExample.ProfileId = systemAdminProfileId;
        userExample.LanguageLocaleKey = 'en_US';
        insert userExample;

        Training_Module__c testTms = new Training_Module__c(Name = 'Test Class Training Module', Mandatory__c = True, Validity_Period__c = 50);
        Insert testTms;
        
        Employee_Training__c testETs = new Employee_Training__c(Name = 'Test Class Employee Training', Completion_Date__c = Date.newInstance(2025, 7, 8), Employee__c = userExample.Id, Training_Module__c = testTms.Id, Status__c = 'Revoked');
        insert testETs;
        
        Employee_Training__c testETs2 = new Employee_Training__c(Name = 'Test Class Employee Training2', Completion_Date__c = Date.newInstance(2025, 7, 8), Employee__c = userExample.Id, Status__c = 'Completed');
        insert testETs2;
    }
    @isTest
    Public static void beforeInsertTest(){
        Employee_Training__c eT = [SELECT Id, Completion_Date__c, Expiry_Date__c, Training_Module__c FROM Employee_Training__c WHERE Name = 'Test Class Employee Training' Limit 1];
        Training_Module__c tM = [SELECT Id, Validity_Period__c FROM Training_Module__c WHERE Id = :eT.Training_Module__c];
        Assert.areEqual(eT.Completion_Date__c.addDays(Integer.valueOf(tM.Validity_Period__c)), eT.Expiry_Date__c);
    }
    @isTest 
    Public static void afterInsertTest(){
        Employee_Training__c eT = [SELECT Id, Completion_Date__c, Expiry_Date__c, Training_Module__c FROM Employee_Training__c WHERE Name = 'Test Class Employee Training' Limit 1];
        List<Training_Change_Log__c> tCL = [SELECT Id FROM Training_Change_Log__c WHERE Employee_Training__c = :eT.Id];
        Assert.areEqual(1,tCL.size());
    }
    @isTest
    Public static void beforeUpdateTest(){
        Employee_Training__c listOfETs = [SELECT Id, Completion_Date__c, Expiry_Date__c FROM Employee_Training__c WHERE Name = 'Test Class Employee Training' Limit 1];
        
        Test.startTest();
        try{
        listOfETs.Expiry_Date__c = Date.newInstance(2025, 07, 08);
        update listOfETs;
        }catch (Exception e){
            Boolean exceptionThrown = (e.getMessage().contains('Cannot Update this record as it has finished its Expiry Date'))? true:false;
            Assert.areEqual(true, exceptionThrown, e.getMessage());
        }
        Test.stopTest();
        
        List<Training_Change_Log__c> tCL = [SELECT Id FROM Training_Change_Log__c WHERE Employee_Training__c = :listOfETs.Id];
        Assert.areEqual(1,tCL.size());
    }
    @isTest
    Public static void afterUpdateTest(){
        Employee_Training__c listOfETs = [SELECT Id, Completion_Date__c, Expiry_Date__c, Status__c FROM Employee_Training__c WHERE Name = 'Test Class Employee Training' Limit 1];
        
        Test.startTest();
        listOfETs.Status__c = 'Expired';
        listOfETs.Expiry_Date__c = Date.newInstance(2025, 07, 12);
        Update listOfETs;
        Test.stopTest();
        
        List<Training_Change_Log__c> tCL = [SELECT Id FROM Training_Change_Log__c WHERE Employee_Training__c = :listOfETs.Id];
        Assert.areEqual(3,tCL.size());
    }
    @isTest
    Public static void beforeDeleteTest(){
        Employee_Training__c listOfETs = [SELECT Id, Completion_Date__c, Expiry_Date__c, Status__c, Training_Module__c FROM Employee_Training__c WHERE Name = 'Test Class Employee Training' Limit 1];
        Test.startTest();
        try{
        Delete listOfETs;
        }catch (Exception e){
            Boolean exceptionThrown = (e.getMessage().contains('Cannot Delete this record as its related training module is mandatory'))? true : false;
            Assert.areEqual(true, exceptionThrown, e.getMessage());
        }
        Test.stopTest();

    }
    @isTest
    Public static void afterDeleteTest(){
        Employee_Training__c listOfETs = [SELECT Id, Completion_Date__c, Expiry_Date__c, Status__c, Training_Module__c FROM Employee_Training__c WHERE Name = 'Test Class Employee Training2' Limit 1];
        
        Test.startTest();
        delete listOfETs;
        Test.stopTest();
        
        List<Training_Change_Log__c> tCL = [SELECT Id FROM Training_Change_Log__c WHERE Employee_Training__c = :listOfETs.Id];
        Assert.areEqual(0,tCL.size());
    }
    @isTest
    Public static void afterUndeleteTest(){
        Training_Module__c listOfTMs = [SELECT Id, Mandatory__c FROM Training_Module__c WHERE Name = 'Test Class Training Module'];
        listOfTMs.Mandatory__c = False;
        Update listOfTMs;
        Employee_Training__c listOfETs = [SELECT Id, Completion_Date__c, Expiry_Date__c, Status__c FROM Employee_Training__c WHERE Name = 'Test Class Employee Training' Limit 1];
        Delete listOfETs;
        Employee_Training__c listOfETs2 = [SELECT Id, Completion_Date__c, Expiry_Date__c, Status__c FROM Employee_Training__c WHERE Name = 'Test Class Employee Training' ALL ROWS];
        Undelete listOfETs2;
        List<Training_Change_Log__c> tCL = [SELECT Id FROM Training_Change_Log__c WHERE Employee_Training__c = :listOfETs2.Id];
        Assert.areEqual(2,tCL.size());
    }
}