@isTest
public class AppraisalHandlerTest {
    @isTest
    static void testBeforeInsert(){
        Employ__c emp = new Employ__c();
        emp.Name = 'John Doe';
        emp.Department__c = 'HR';
        insert emp;
        
		Appraisal__c app = new Appraisal__c ();
        app.Employ__c=emp.Id;
        app.Quarter__c='Q2';
        app.Year__c =2025;
        app.Goal_Achievement__c= 80;
        app.Team_Feedback_Score__c = 50;
        
        insert app;
        
        Appraisal__c duliapp = new Appraisal__c();
        duliapp.Employ__c=emp.Id;
        duliapp.Quarter__c='Q2';
        duliapp.Year__c =2025;
        duliapp.Goal_Achievement__c= 80;
        duliapp.Team_Feedback_Score__c = 50;
        
       
        
        Test.startTest();
        try {
            insert duliapp;
            System.assert(false, 'Expected errror.');
        } catch (DmlException ec) {
            System.assert(ec.getMessage().contains('An appraisal already exists'), 'Validation error should mention duplicate appraisal.');
        }
        Test.stopTest();
        
        
        Appraisal__c a = [SELECT Id,Status__c,Reviewer__c,Employ__c  FROM Appraisal__c  WHERE Id =:app.Id];
        System.assertEquals('In Review', a.Status__c, 'Status is In Review');
        System.assertEquals(UserInfo.getUserId(), a.Reviewer__c, 'Reviewer is the current user.');
    }
    
    @isTest
    static void testAfterInsert() {
        Employ__c emp = new Employ__c();
        emp.Name = 'John Doe';
        emp.Department__c = 'HR';
        insert emp;
        Employ__c e = [SELECT Id FROM Employ__c WHERE Name = 'John Doe' LIMIT 1];

        Appraisal__c app = new Appraisal__c();
        app.Employ__c = e.Id;
        app.Goal_Achievement__c = 90;
        app.Team_Feedback_Score__c = 85;
        app.Quarter__c = 'Q1';
        app.Year__c = 2025;
        insert app;
        List<Reward__c> rewards = [SELECT Id, Employ__c, Type__c, Score__c FROM Reward__c WHERE Employ__c = :emp.Id];
        System.assertEquals(1, rewards.size());
        System.assertEquals('Bonus', rewards[0].Type__c);
        System.assertEquals(90, rewards[0].Score__c);

        Appraisal__c appr = [SELECT Final_Score__c FROM Appraisal__c WHERE Id = :app.Id];
        
        System.assertEquals(null, app.Final_Score__c, 'Final value');
    }


    @isTest
    static void testBeforeUpdate(){
        
        Employ__c emp = new Employ__c();
        emp.Name = 'Test Emp';
        emp.Department__c = 'HR';
        insert emp;

        
        Appraisal__c app = new Appraisal__c();
         app.Employ__c = emp.Id;
        app.Goal_Achievement__c = 90;
        app.Team_Feedback_Score__c = 80;
         app.Final_Score__c = 85;
         app.Quarter__c = 'Q1';
         app.Year__c = 2025;
         app.Reviewer__c = UserInfo.getUserId();
          app.Status__c = System.Label.Prevent_Deletion ;
       
        insert app;

        Appraisal__c a = new Appraisal__c();
        a.Id = app.Id;
         a.Employ__c = emp.Id;
        a.Goal_Achievement__c = 10;
        a.Status__c = System.Label.Prevent_Deletion ;
        

        Test.startTest();
        try {
            update a;
            System.assert(false, 'Expected reviewer restriction error.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Cannot Modify'), 'Should fail');
        }
        Test.stopTest();
    }
    
    
     @isTest
    static void testAfterUpdate() {
       Employ__c emp = new Employ__c(Name = 'Test User', Department__c = 'HR');
        insert emp; 
        
        Employ__c ep = [SELECT Id, Department__c FROM Employ__c LIMIT 1];
        User reviewer = [SELECT Id FROM User WHERE Name = 'Vinaya S' LIMIT 1];

		Appraisal__c app = new Appraisal__c();
         app.Employ__c = ep.Id;
         app.Final_Score__c = 85;
         app.Quarter__c = 'Q1';
         app.Year__c = 2022;
         app.Status__c = 'Completed';
        app.Reviewer__c = reviewer.Id;

        insert app;

        app.Final_Score__c = 97; 
        Test.startTest();
        update app;
        Test.stopTest();
        
		 List<Reward__c> rewards = [SELECT Id, Employ__c, Type__c, Score__c FROM Reward__c WHERE Employ__c = :emp.Id];
        System.assertEquals(1, rewards.size());

       	app.Final_Score__c = 30; 
        update app;

        Employ__c pro = [SELECT Is_On_Probation__c FROM Employ__c WHERE Id = :emp.Id];
        System.assertEquals(true, pro.Is_On_Probation__c);
    }

	@isTest
    static void testBeforeDelete() {
        
        Employ__c emp = new Employ__c(Name = 'Test Employee', Department__c = 'HR');
        insert emp;
		Appraisal__c app = new Appraisal__c();
        app.Employ__c = emp.Id;
        app.Final_Score__c = 80;
        app.Quarter__c = 'Q1';
        app.Year__c = 2023;
        app.Status__c = 'Completed';
        
        insert app;

        Test.startTest();
        delete app;
        Test.stopTest();

        
        List<Appraisal__c> check = [SELECT Id FROM Appraisal__c WHERE Id = :app.Id];
        System.assertEquals(0, check.size(), 'delete');
    }
    

    @isTest
    static void testAfterDelete() {
        Employ__c emp = new Employ__c(Name = 'Test Employee', Department__c = 'HR');
        insert emp;
		Appraisal__c app = new Appraisal__c();
        app.Employ__c = emp.Id;
        app.Final_Score__c = 80;
        app.Quarter__c = 'Q1';
        app.Year__c = 2023;
        app.Status__c = 'Completed';
        insert app;

       emp.Active_Appraisal__c = app.Id;
        update emp;

        Test.startTest();
        delete app;
        Test.stopTest();

		Employ__c e = [SELECT Active_Appraisal__c FROM Employ__c WHERE Id = :emp.Id];
        System.assertEquals(null, e.Active_Appraisal__c, 'null');
    }
	@isTest
	static void testAfterUndelete() {
        
        Employ__c emp = new Employ__c(Name = 'Test Employee', Department__c = 'HR');
        insert emp; 
		List<Appraisal__c> appList = new List<Appraisal__c>();

        for (Integer i = 0; i < 3; i++) {
            Appraisal__c app = new Appraisal__c();
            app.Employ__c = emp.Id;
            app.Final_Score__c = 80;
            app.Quarter__c = 'Q1';
            app.Year__c = 2023;
            app.Status__c = 'Completed';
            appList.add(app);
        }
        
        insert appList;

        
       /* emp.Active_Appraisal__c = app.Id;
        update emp;

        delete app;*/

        Test.startTest();
        AppraisalHandler.afterUndelete(appList);
        Test.stopTest();

        
        Employ__c e = [SELECT Active_Appraisal__c FROM Employ__c WHERE Id = :emp.Id];
        System.assertEquals(appList[1].Id, e.Active_Appraisal__c);
    }
    


}