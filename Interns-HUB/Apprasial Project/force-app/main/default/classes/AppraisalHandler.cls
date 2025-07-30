public class AppraisalHandler {
    //before insert
    public static void beforeInsert(List<Appraisal__c> appraisal) {
      Set<Id> eid = new Set<Id>();
	for (Appraisal__c ap : appraisal) {
          if (ap.Employ__c != null) {
               eid.add(ap.Employ__c);
           }
       }
	 List<Appraisal__c> val = [SELECT Id, Employ__c, Quarter__c, Year__c FROM Appraisal__c WHERE Employ__c IN :eid];
        for (Appraisal__c app : appraisal) {
           for (Appraisal__c ap : val) {
                if (ap.Employ__c == app.Employ__c && ap.Quarter__c == app.Quarter__c && ap.Year__c == app.Year__c) {
                    app.addError('An appraisal already exists for this employee, quarter, and year.');
                 }
            }
        }
        for(Appraisal__c a : appraisal){
           if(String.isBlank(a.Status__c)){
                a.Status__c = 'In Review';
            }
           if(String.isBlank(a.Reviewer__c)){
                a.Reviewer__c = UserInfo.getUserId();
                    
            }
         }
     }
    //after insert
    public static void afterInsert(List<Appraisal__c> appraisal){
        System.enqueueJob(new AppraisalQueue(appraisal));
        Set<Id> eid = new Set<Id>();
		for (Appraisal__c ap : appraisal) {
            if (ap.Employ__c != null) {
                eid.add(ap.Employ__c);
            }
        }
        Map<Id,Employ__c> emp = new Map<Id,Employ__c>([SELECT Id, Department__c FROM Employ__c WHERE Id IN :eid]);
        Map<String,Performance_Config__mdt> pc = new Map<String,Performance_Config__mdt>();
        List<Performance_Config__mdt> metadata = [SELECT Department__c, Escalate_Below__c, Bonus_Above__c FROM Performance_Config__mdt WHERE Department__c != null];
        for (Performance_Config__mdt pcong : metadata){
            pc.put(pcong.Department__c, pcong);  
            
        }
        List<Reward__c> rewards = new List<Reward__c>();

        for (Appraisal__c appr : appraisal) {
            Employ__c empl = emp.get(appr.Employ__c);
            if (empl != null && empl.Department__c != null) {
                Performance_Config__mdt pcc = pc.get(empl.Department__c);
       		 System.debug('--- Employee: ' + empl);
             System.debug('---  ' + pcc);
        		if (pcc != null) {
                    if (pcc.Escalate_Below__c != null && appr.Goal_Achievement__c < pcc.Escalate_Below__c) {
                        Escalation.escalate(appr.Id); 
                    }
        
                    if (pcc.Bonus_Above__c != null && appr.Goal_Achievement__c >= pcc.Bonus_Above__c) {
                        Reward__c r = new Reward__c();
                        r.Employ__c = appr.Employ__c;
                        r.Type__c = 'Bonus';
                        r.Score__c = appr.Goal_Achievement__c;
                        r.Generated_On__c = System.now();
                        r.Issued_By__c = UserInfo.getUserId();
                        rewards.add(r);
                    }
                }
            }
        }

        if (!rewards.isEmpty()) {
            insert rewards;
        }

    }


    //before update
    public static void beforeUpdate(List<Appraisal__c> appraisal,Map<id,Appraisal__c> oldApp){
        set<id>  eid = new set<id>();
        for(Appraisal__c ap : appraisal){
            eid.add(ap.Employ__c);
        }
        
        List<Appraisal__c> appr = [SELECT Employ__c,Status__c FROM Appraisal__c WHERE Id IN: eid];
        Map<Id, Appraisal__c> vals = new Map<Id, Appraisal__c>();
        
        for(Appraisal__c app : appraisal){
           Appraisal__c oldappp = oldApp.get(app.Id);
            system.debug('--->' + oldApp.get(app.Id));
            if(app.Employ__c != oldappp.Employ__c && app.Status__c == System.Label.Prevent_Deletion ){
                app.addError('Not');
            }
            if(app.Final_Score__c<oldappp.Final_Score__c){
               vals.put(app.Id,app);
            }
            if(app.Reviewer__c == UserInfo.getUserId() ){
                app.addError('Cannot Modify');
            }
            
        }
        
        
        
    }
    //after update
    public static void afterUpdate(List<Appraisal__c> appraisal,Map<Id,Appraisal__c> oldApp){
        set<id>  eid = new set<id>();
        for(Appraisal__c ap : appraisal){
            eid.add(ap.Employ__c);
        }
        Map<Id,Employ__c> emp = new Map<Id,Employ__c>([SELECT Id, Department__c FROM Employ__c WHERE Id IN :eid]);
        list<Appraisal__c> app = new List<Appraisal__c>();
       Map<String,Performance_Config__mdt> pc = new Map<String,Performance_Config__mdt>();
        List<Performance_Config__mdt> metadata = [SELECT Department__c, Escalate_Below__c, Bonus_Above__c FROM Performance_Config__mdt];
        for (Performance_Config__mdt pcc : metadata){
            if (pcc.Department__c != null){
               pc.put(pcc.Department__c, pcc);  
            }
            
        }
        List<Reward__c> rewards = new List<Reward__c>();
        List<Employ__c> emply = new List<Employ__c>();
        
        for (Appraisal__c a : appraisal) {
            Appraisal__c old = oldApp.get(a.Id);
            Employ__c empl = emp.get(a.Employ__c);
            Performance_Config__mdt p = pc.get(empl.Department__c);
            if(a.Final_Score__c != old.Final_Score__c){
              app.add(a); 
           
            }
           if(a.Final_Score__c > p.Bonus_Above__c ){
               system.debug('--->' + a.Final_Score__c + '---<' +p.Bonus_Above__c );
                Reward__c r = new Reward__c();
               r.Employ__c = a.Employ__c;
               r.Type__c = 'Bonus';
               r.Score__c = a.Final_Score__c;
               r.Generated_On__c = System.now();
               r.Issued_By__c = UserInfo.getUserId();
               	rewards.add(r);
           }
               
           if (p != null && a.Final_Score__c != null && p.Escalate_Below__c != null && a.Employ__c != null) {
            if (a.Final_Score__c < p.Escalate_Below__c) {
                Employ__c empp = new Employ__c();
                empp.Id = a.Employ__c;
                empp.Is_On_Probation__c = true;
                emply.add(empp);
            }
        }
            
         ApprasisalNoti.sendNotifications(new List<Appraisal__c>{a});
        
    	}
        if(!rewards.isEmpty()){
            insert rewards;
        }
        if(!emply.isEmpty()){
            update  emply;
        }
        
        Database.executeBatch(new AppraisalBatch());

        
    	}
    


    //before delete
    public static void beforeDelete(List<Appraisal__c> appraisals) {
    	Set<Id> currentUserId = new Set<Id>{UserInfo.getUserId()};
        List<PermissionSetAssignment> permissionId = [SELECT Id  FROM PermissionSetAssignment WHERE AssigneeId IN :currentUserId AND PermissionSet.Name = 'HR_Admin'];
        for (Appraisal__c a : appraisals) {
           if (permissionId.isEmpty() && a.Status__c == System.Label.Prevent_Deletion) {
                a.addError('You cannot delete an approved appraisal unless you have HR Admin permission.');
            }
        }
	}
    
    //after delete
    public static void afterDelete(List<Appraisal__c> appraisal) {
        Set<Id> eid = new Set<Id>();
        Set<String> dep = new Set<String>();
        set<Id> aid = new set<id>();

        for (Appraisal__c app : appraisal) {
            if (app.Employ__c != null) {
                eid.add(app.Employ__c);
            }
            aid.add(app.Id);
        }

        List<Employ__c> val = new List<Employ__c>();
        List<Employ__c>  e =[SELECT Id, Active_Appraisal__c, Department__c FROM Employ__c WHERE Id IN :eid];
        for (Employ__c emp : e ) {
            if (aid.contains(emp.Active_Appraisal__c)) {
                emp.Active_Appraisal__c = null;
                val.add(emp);
            }
            if (emp.Department__c != null) {
                dep.add(emp.Department__c);
            }
        }

        if (!val.isEmpty()) {
            update val;
        }

    
        Database.executeBatch(new AppraisalBatch());
    }



    
    //after undelete
    public static void afterUndelete(List<Appraisal__c> appraisal){
        set<id>  eid = new set<id>();
        Map<Id, Appraisal__c> app = new Map<Id, Appraisal__c>();
        for(Appraisal__c ap : appraisal){
            eid.add(ap.Employ__c);
            app.put(ap.Employ__c,ap);
        }
        List<Employ__c> emppActive = new List<Employ__c>();
        for (Id e : eid) {
            Appraisal__c a = app.get(e);
            Employ__c em =new Employ__c();
            em.Id = e;
            em.Active_Appraisal__c = a.Id;
            emppActive.add(em);
        }
        if(!emppActive.isEmpty()){
            update emppActive;
        }
        
         List<Employee__c> empProbation = new List<Employee__c>();
         Map<Id,Employ__c> emp = new Map<Id,Employ__c>([SELECT Id, Department__c FROM Employ__c WHERE Id IN :eid]);
        Map<String,Performance_Config__mdt> pc = new Map<String,Performance_Config__mdt>();
        List<Performance_Config__mdt> metadata = [SELECT Department__c, Escalate_Below__c, Bonus_Above__c FROM Performance_Config__mdt];
        for (Performance_Config__mdt pcc : metadata){
            pc.put(pcc.Department__c, pcc);
        }
        for(Appraisal__c appr : appraisal){
            Employ__c empl = emp.get(appr.Employ__c);
            System.debug('---->' + emp.get(appr.Employ__c));
            Performance_Config__mdt pcc = pc.get(empl.Department__c);
            system.debug('---->' + pc.get(empl.Department__c));
        	if (appr.Final_Score__c != null && appr.Final_Score__c < pcc.Escalate_Below__c) { 
                Escalation.escalate(appr.Id);
            }
        }
        
    }
}