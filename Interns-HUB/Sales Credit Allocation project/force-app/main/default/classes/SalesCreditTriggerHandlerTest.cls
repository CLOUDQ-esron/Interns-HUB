@isTest
public class SalesCreditTriggerHandlerTest{
    @testSetup
    static void setup() {  
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User u1 = [SELECT Id, Email FROM USER WHERE Email = 'nefingigi10@gmail.com'];
        User u = new User(
            FirstName='Test',
            LastName='User',
            Email='nefingigi10@gmail.com',
            Username='testuser839@test.com',
            Alias='Alias', 
            ManagerId = u1.id,
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            ProfileId=p.Id);
        insert u;
        
        Opportunity opp = new Opportunity(Name='Test Opp321', StageName='Prospecting', CloseDate=Date.today(), Region__c = 'Eastern Europe');
        insert opp;
        
        Sales_Credit__c sc = new Sales_Credit__c(Name = 'My TestSalesCredit',Opportunity__c = opp.Id, Sales_Rep__c = u.Id, CreditPercent__c = 81);
        insert sc;
        
        Sales_Credit__c sc2 = new Sales_Credit__c(Name = 'My TestSalesCredit2',Opportunity__c = opp.Id, Sales_Rep__c = u.Id, CreditPercent__c = 15);
        insert sc2;
        
    }
    @isTest
    static void beforeInsertTest() {     
        Sales_Credit__c sc = [SELECT Id, Region__c, OverCredited__c, Status__c FROM Sales_Credit__c WHERE Name = 'My TestSalesCredit' Limit 1];
        Sales_Credit__c sc2 = [SELECT Id, Region__c, OverCredited__c, Status__c FROM Sales_Credit__c WHERE Name = 'My TestSalesCredit2' Limit 1];
        Test.startTest();
        Assert.areEqual(true, sc.OverCredited__c);
        Assert.areEqual('Approved', sc2.Status__c);
        Test.stopTest();
    } 
    @isTest
    static void afterInsertTest() {
        User u = [SELECT Id FROM User WHERE FirstName='Test' AND LastName='User'];
        Opportunity opp1 = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp321'];
        Sales_Credit__c sc = [SELECT Id, Region__c, OverCredited__c, Status__c FROM Sales_Credit__c WHERE Name = 'My TestSalesCredit' Limit 1];
        Sales_Credit__c sc2 = [SELECT Id, Region__c, OverCredited__c, Status__c FROM Sales_Credit__c WHERE Name = 'My TestSalesCredit2' Limit 1];
        Commission_Alert__c ca = [SELECT Id FROM Commission_Alert__c WHERE Sales_Credit__c = :sc.Id];
        Sales_Credit__c sc3 = new Sales_Credit__c(Name = 'My TestSalesCredit3',Opportunity__c = opp1.Id, Sales_Rep__c = u.Id, CreditPercent__c = 20);
        
        Test.startTest();
        try{
            insert sc3;
        }catch (Exception e){
            Boolean exceptionThrown = (e.getMessage().contains('The total credit for the Opportunity has exceeded'))? true : false;
            Assert.areEqual(true, exceptionThrown, e.getMessage());
        }
        Test.stopTest();
        
        List<Commission_Alert__c> alerts = [SELECT Id FROM Commission_Alert__c WHERE Sales_Credit__c = :sc.Id];
        Assert.areEqual(1, alerts.size()); // Depends on actual threshold
    }
    @isTest
    static void beforeUpdateTest() {
        
        Sales_Credit__c sc = [SELECT Id, Region__c, OverCredited__c, Status__c FROM Sales_Credit__c WHERE Name = 'My TestSalesCredit' Limit 1];
        Sales_Credit__c sc4 = [SELECT Id, Region__c, OverCredited__c, Status__c FROM Sales_Credit__c WHERE Name = 'My TestSalesCredit' Limit 1];
        
        sc.Status__c = 'Approved';
        sc.CreditPercent__c = 82;
        
        Test.startTest();
        try {
            update sc;
        } catch (Exception e) {
            Boolean exceptionThrown = (e.getMessage().contains('The updated field cannot be changed when status has been approved')) ? true : false;
            Assert.areEqual(true, exceptionThrown, e.getMessage());
        }
        sc4.CreditPercent__c = 85;
        update sc4;
        Assert.areEqual(true, sc4.OverCredited__c);
        Test.stopTest();
    }
    @isTest
    static void afterUpdateTest() {
        
        Sales_Credit__c sc = [SELECT Id, Region__c, OverCredited__c, Status__c FROM Sales_Credit__c WHERE Name = 'My TestSalesCredit' Limit 1];
        Sales_Credit__c sc2 = [SELECT Id, Region__c, OverCredited__c, Status__c FROM Sales_Credit__c WHERE Name = 'My TestSalesCredit' Limit 1];
        sc.Eligible__c = true;
        sc.CreditPercent__c = 79;
        sc2.OverCredited__c = false;
        
        Test.startTest();
        update sc;
        update sc2;
        Test.stopTest();
        
        List<Commission_Alert__c> ac = [SELECT Id, Sales_Credit__c FROM Commission_Alert__c WHERE Sales_Credit__c = :sc.Id];
        Assert.areEqual(1, ac.size());
        List<Commission_Alert__c> alerts = [SELECT Id FROM Commission_Alert__c WHERE Sales_Credit__c = :sc2.Id];
        Assert.areEqual(1,alerts.size());
    }
    @isTest
    static void beforeDeleteTest() {
        
        Sales_Credit__c sc = [SELECT Id, Region__c, OverCredited__c, Status__c FROM Sales_Credit__c WHERE Name = 'My TestSalesCredit' Limit 1];
        sc.Status__c ='Approved';
        Test.startTest();
        update sc;
        try {
            delete sc;
        } catch (DmlException e) {
            Boolean exceptionThrown = (e.getMessage().contains('Cannot be deleted if Status is Approved or if Credit exceeds threshold')) ? true : false;
            Assert.areEqual(true, exceptionThrown, e.getMessage());
        }
        Test.stopTest();
    }
    @isTest
    static void afterDeleteTest() {
        
        Sales_Credit__c sc2 = [SELECT Id, Region__c, OverCredited__c, Status__c, Opportunity__c FROM Sales_Credit__c WHERE Name = 'My TestSalesCredit2' Limit 1];
        sc2.Status__c = 'Pending';
        update sc2;
        
        Test.startTest();
        delete sc2;
        Test.stopTest();
        
        Sales_Credit__c otherSC = [SELECT Id, Region__c, OverCredited__c, Status__c, Opportunity__c FROM Sales_Credit__c WHERE Opportunity__c = :sc2.Opportunity__c];
        Assert.areEqual(true, otherSC.OverCredited__c);
    }  
    @isTest
    static void afterUndeleteTest() {
        
        Sales_Credit__c sc2 = [SELECT Id, Region__c, OverCredited__c, Status__c, Opportunity__c FROM Sales_Credit__c WHERE Name = 'My TestSalesCredit2' Limit 1];
        sc2.Status__c = 'Pending';
        update sc2;
        delete sc2;
        Sales_Credit__c deletedsc2 = [SELECT Id, Region__c, OverCredited__c, Status__c, Opportunity__c FROM Sales_Credit__c WHERE Name = 'My TestSalesCredit2' Limit 1 ALL ROWS];
        
        Test.startTest();
        undelete deletedsc2;
        Test.stopTest();
        
        List<Commission_Alert__c> alerts = [SELECT Id FROM Commission_Alert__c WHERE Sales_Credit__c = :deletedsc2.Id];
        Assert.areEqual(1, alerts.size()); // Depends on thresholds
    }
}