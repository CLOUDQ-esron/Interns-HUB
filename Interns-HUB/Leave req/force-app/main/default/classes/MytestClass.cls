@isTest
public class MytestClass{
    
    @testSetup
    static void leaveRequestTriggerTestClass() {
        //Insert User
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u1 = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles',
                           UserName='uniqueUserName123'+System.now().second()+'@gmail.com');
        insert u1;
        
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles',
                           UserName='uniqueUserName'+System.now().second()+'@gmail.com',ManagerId = u1.Id);
        Insert u2;
        User u3 = new User(Alias = 'standt3', Email='standarduser3@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles',
                           UserName='uniqueUserName1234'+System.now().second()+'@gmail.com');
        Insert u3;
        //Insert Leave_Request__c records 
        Leave_Request__c newReccord1 = new Leave_Request__c(Name= 'My test12',Status__c='Submitted',Employee__c=u2.Id,Approver__c=u1.id,StartDate__c=Date.newInstance(2025,7,11));
        Leave_Request__c newReccord2 = new Leave_Request__c(Name='My test123',Status__c='Approved');
        Leave_Request__c newReccord3 = new Leave_Request__c(Name='My test1234',Status__c='Approved',Employee__c = u2.Id);
        Leave_Request__c newReccord4 = new Leave_Request__c(Name='My test12345',Status__c='Rejected',Employee__c =u3.Id);
        Leave_Request__c newReccord5 = new Leave_Request__c(Name='My test123456',Status__c='Draft',Employee__c =u2.Id,Approver__c = u2.ManagerId);
        
        
        insert newReccord1; 
        insert newReccord2;
        insert newReccord3;
        insert newReccord4;
        insert newReccord5;
        
        
    }
    //beforeInsertTriggerTestClass
    @isTest
    public static void beforeInsertTriggerTestClass (){
        Leave_Request__c newReccord = new Leave_Request__c(Name= 'My test',Status__c='',StartDate__c=Date.newInstance(2025,7,9));
        string str;
        Test.startTest();
        try{
            Insert newReccord ;   
        }
        Catch(Exception e){
            str =e.getMessage();  
        }
        System.assertNotEquals(null,str);
        Test.stopTest();
        
    }
    
    //afterInsertTriggerTest Class
    
    @isTest
    static void afterInsertTestClass(){
        Leave_Request__c result1 = [SELECT Id,Approver__c,Status__c,StartDate__c FROM Leave_Request__c Where Name= 'My test12'LIMIT 1];
        list<Leave_Audit__c> newleaveAudit = [SELECT Id, Leave_Request__c FROM Leave_Audit__c WHERE Leave_Request__c = : result1.Id];
        System.assertEquals(1,newleaveAudit.size());
        
    }
    
    //beforeUpdate TriggerClass
    @isTest
    static void beforeUpdateTestClass(){
        Leave_Request__c result2 = [Select Id,Name,Status__c From Leave_Request__c Where Name ='My test123'];
        result2.Status__c ='Draft';
        string str1;
        Test.startTest();
        
        try{
            Update result2;
            
        }
        catch(Exception e){
            str1 =e.getMessage();  
        }
        System.assertNotEquals(null,str1);
        Test.stopTest();
        
    }
    
    
    //afterUpdate Trigger TestClass
    @isTest
    static void afterUpdateTestClass(){
        User updateUsers = [select Id,Email,LastName From User Where LastName='Testing3'];
        Leave_Request__c result3 = [Select Id,Name,Approver__c, Status__c From Leave_Request__c Where Name ='My test1234' Limit 1];
        result3.Employee__c = updateUsers.Id;
        result3.Approver__c = updateUsers.Id;
        result3.Status__c ='Rejected';
        Update result3;
        List<Leave_Audit__c> newleaveAudit = [SELECT Id, Leave_Request__c FROM Leave_Audit__c WHERE Leave_Request__c = :result3.Id];
        System.assertEquals(3,newleaveAudit.size());
    }
    //beforeDelete Trigger Testclass
    @isTest
    static void beforeDeleteTestClass(){
        Leave_Request__c result4 = [Select Name,Status__c From Leave_Request__c where Name ='My test123'];
        String str;
        Test.startTest();
        
        try{
            Delete result4;
        }Catch(Exception e){
            str = e.getMessage();
        }
        System.assertNotEquals(null,str);
        Test.stopTest();
        
    }
    //afterUpdateTriggerTrigger testClass
    @isTest
    static void afterUpdateTriggerTestClass(){
        Leave_Request__c result5 = [Select Name,Status__c,Employee__c From Leave_Request__c Where Name='My test1234'];
        Leave_Request__c result6 = [Select Name,Status__c,Employee__c From Leave_Request__c Where Name='My test12345'];
        list<Leave_Request__c> listReq = [select Id From Leave_Request__c];
        List<Leave_Audit__c> newleaveAudit = [SELECT Id, Leave_Request__c FROM Leave_Audit__c WHERE Leave_Request__c In:listReq];
        System.assertNotEquals(2,newleaveAudit.size());
    }
    //afterDelete Trigger
    @isTest
    static void afterDeleteTestClass(){
        Leave_Request__c result7 = [Select Name,Status__c,Employee__c,Approver__c From Leave_Request__c Where Name='My test12345'];
        Test.startTest();
        Delete result7;
        Test.stopTest();
    }
    //Undelete Trigger
    @isTest
    Static Void afterUndeleteTestClass(){
        Leave_Request__c deleteReccord = [Select Id,Name,Status__c,Employee__c From Leave_Request__c where Name ='My test12'];
        Delete deleteReccord;
        Leave_Request__c unDeleteRecord = [Select Id,Name,Status__c,Employee__c From Leave_Request__c where Name ='My test12' ALL ROWS];
        Test.startTest();
        undelete unDeleteRecord;
        Test.stopTest();
        
        
    }
}