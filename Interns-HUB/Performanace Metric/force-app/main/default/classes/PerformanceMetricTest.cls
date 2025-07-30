@isTest
public class PerformanceMetricTest {
    @isTest
    static void testAfterInsert(){
        Employee__c emp = new Employee__c();
        emp.Name ='Vinaya';
        insert emp;
        
        Performance_Metric__c pm = new Performance_Metric__c();
        pm.Name = 'Performance - Vinaya';
        pm.Employee__c = emp.Id;
        pm.Score__c = 85;
        pm.Evaluation_Month__c = Date.newInstance(2025, 7, 26);
        insert pm ;
        
        Employee__c E1 = [SELECT Id, Current_Score__c FROM Employee__c LIMIT 1];
        System.assertEquals(85,E1.Current_Score__c,'Equal');
        
        List<Appraisal_Log__c> log = [SELECT Id FROM Appraisal_Log__c WHERE Action__c = 'Score Updated'];
		System.assertEquals(1,log.Size(), 'equal');

     }
    @isTest
    static void testAfterUpdate(){
        User manager = new User();
        manager.FirstName = 'Test';
        manager.LastName = 'Manager';
        manager.Email = 'manager@example.com';
        manager.Username = 'manager' + DateTime.now().getTime() + '@test.com';
        manager.Alias = 'tman';
        manager.TimeZoneSidKey = 'Asia/Kolkata';
        manager.LocaleSidKey = 'en_US';
        manager.EmailEncodingKey = 'UTF-8';
        manager.LanguageLocaleKey = 'en_US';
        manager.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
        insert manager;
        
        Employee__c emp = new Employee__c();
        emp.Name ='Vinaya';
        emp.Department__c='HR';
        emp.Manager__c = manager.Id;
        
        insert emp;
       
        Performance_Metric__c pm = new Performance_Metric__c();
        pm.Name = 'Performance - Vinaya';
        pm.Employee__c = emp.Id;
        pm.Score__c = 85;
        pm.Evaluation_Month__c = Date.newInstance(2025, 7, 26);
        insert pm ;
        
        Performance_Metric__c ppm = [SELECT Id, Name , Score__c From Performance_Metric__c WHERE Name ='Performance - Vinaya'];
       	ppm.Score__c = 25;
        update ppm;
        
        
        Employee__c app = [SELECT Id, Appraisal_Ready__c FROM Employee__c];
        System.assertEquals(false,app.Appraisal_Ready__c,'TRUE');
        
        List<Appraisal_Log__c> log = [SELECT Id FROM Appraisal_Log__c WHERE Action__c = 'Threshold Met'];
		System.assertEquals(1,log.Size(), 'equal');
    }
    @isTest
    static void testBeforeDelete() {
        Employee__c emp = new Employee__c();
        emp.Name ='Vinaya';
        emp.Department__c='HR';
        insert emp;
       
        Performance_Metric__c pm = new Performance_Metric__c();
        pm.Name = 'Performance - Vinaya';
        pm.Employee__c = emp.Id;
        pm.Source__c = 'System';
        pm.Evaluation_Month__c = Date.newInstance(2025, 7, 26);
        insert pm ;
        
        Test.startTest();
        try {
            delete pm;
            System.assert(false, 'System-generated metrics should not be deletable');
        } catch (DmlException ec) {
            System.assert(ec.getMessage().contains('Cannot delete system-generated metrics'),
                'Expected deletion to be blocked with custom error');
        }
        Test.stopTest();
	}
    @isTest
    static void testAfterDelete() {
        
        Employee__c emp = new Employee__c();
        emp.Name ='Vinaya';
        emp.Department__c='HR';
        insert emp;
        
        
        Performance_Metric__c pm = new Performance_Metric__c();
        pm.Name = 'Performance - Vinaya';
        pm.Employee__c = emp.Id;
        pm.Source__c = 'Manager';
        pm.Evaluation_Month__c = Date.newInstance(2025, 7, 26);
        pm.Score__c = 80;
        insert pm;
        
        Test.startTest();
        delete pm;
        Test.stopTest();
        
        Employee__c sc = [SELECT Id, Current_Score__c FROM Employee__c WHERE Id = :emp.Id];
        System.assertNotEquals(80, emp.Current_Score__c, 'Score should be recalculated after delete');
        
        List<Appraisal_Log__c> logs = [SELECT Id FROM Appraisal_Log__c WHERE Employee__c = :emp.Id AND Action__c = 'Score Updated'];
        System.assertEquals(2, logs.size(), 'One Score Updated log should be created');
    }
     @isTest
    static void testAfterUndelete() {
        Employee__c emp = new Employee__c();
        emp.Name ='Vinaya';
        emp.Department__c='HR';
        insert emp;
        
        
        Performance_Metric__c pm = new Performance_Metric__c();
        pm.Name = 'Performance - Vinaya';
        pm.Employee__c = emp.Id;
        pm.Source__c = 'Manager';
        pm.Evaluation_Month__c = Date.newInstance(2025, 7, 26);
        pm.Score__c = 99;
        insert pm;
        
        delete pm;
        
        List<Performance_Metric__c> ppmm = [SELECT Id FROM Performance_Metric__c  WHERE Employee__c = :emp.Id ALL ROWS ];
        undelete ppmm;

        Employee__c sc = [SELECT Id, Current_Score__c FROM Employee__c WHERE Id = :emp.Id];
        System.assertNotEquals(99, emp.Current_Score__c, 'Score should be recalculated after delete');
    }

    

    

}