public class PerformanceMetricHandler {
	//after insert
    public static void afterInsert(List<Performance_Metric__c> performance) {
       Set<Id> empIds = new Set<Id>();
       for (Performance_Metric__c per : performance) {
            if (per.Employee__c!=null && per.Evaluation_Month__c != null) {
                empIds.add(per.Employee__c);
                
            }
       }
        Map<Id, Decimal> avgScore = NotificationEmail.avgScore(empIds);
        
        List<Employee__c> emp = new List<Employee__c>();
        for(Id empId : avgScore.keySet()){
           Employee__c employee = new Employee__c();
            employee.Id = empId;
            employee.Current_Score__c = avgScore.get(empId);
            emp.add(employee);
        }
	AppraisalLog.logChange(empIds,'Score Updated','The Score is Updated');
         if (!emp.isEmpty()) {
            update emp;
        }
      }
    
    
   //after update
  public static void afterUpdate(List<Performance_Metric__c> perform) {
       Date threemnth = Date.today().addMonths(-3);
       Set<Id> eId = new Set<Id>();
       
       for (Performance_Metric__c per : perform) {
			if (per.Evaluation_Month__c >= threemnth) {
               eId.add(per.Employee__c);
           }
       }
       
      Map<Id, Decimal> avgSc = NotificationEmail.avgScore(eId);
      Map<Id, Employee__c> mapOfEM = new Map<Id, Employee__c>([SELECT Id,Department__c,Manager__r.Email FROM Employee__c WHERE Id IN :eId]);
      Map<Id,Performance_Metric__c> pm = new Map<Id,Performance_Metric__c> ([SELECT Score__c FROM Performance_Metric__c WHERE Employee__c in :eId ]);
      Map<String, Performance_Threshold__mdt> perThresold = QuerySelector.metadata();
       List<Employee__c> emplist = new List<Employee__c>();
      
      for(Performance_Metric__c tempPM : perform){
         string empDepartment = mapOfEM.get(tempPM.Employee__c).Department__c;
          String managerEmail = mapOfEM.get(tempPM.Employee__c).Manager__r.Email;
			if(tempPM.Score__c  != null && perThresold.get(empDepartment).Maximum_Threshold__c != null  && perThresold.get(empDepartment).Minimum_Threshold__c != null && 
            ((tempPM.Score__c  > perThresold.get(empDepartment).Maximum_Threshold__c) || (tempPM.Score__c  < perThresold.get(empDepartment).Minimum_Threshold__c)) ){
              Employee__c emp = new Employee__c();
              emp.Id = tempPM.Employee__c;
              emp.Appraisal_Ready__c = false ;
              emplist.add(emp);
              NotificationEmail.sendNotifications(new List<Performance_Metric__c>{ tempPM });
              NotificationEmail.sendMail(managerEmail, 'Updated Score', 'Updated Score Exceed the Maximum and Minimum Threshold');
                system.debug('-->' + managerEmail);
              AppraisalLog.logChange(eId,'Threshold Met','it meets the thresold');  
         }	
      }
      
  }
    //before delete
  public static void beforeDelete(List<Performance_Metric__c> perform){
    for (Performance_Metric__c per : perform) {
            if(per.Source__c == System.label.Source_value_is_system){
                per.addError('Cannot delete system-generated metrics');
            }
                
    }
   }
    //after delete
   public static void afterDelete(List<Performance_Metric__c> perform){
        Set<Id> eIds = new Set<Id>();
       for(Performance_Metric__c pm : perform){
            if(pm.Employee__c != null){
                eIds.add(pm.Employee__c);
            }
        }
       
        Map<Id, Decimal> avgScore = NotificationEmail.avgScore(eIds);
        List<Employee__c> em = new List<Employee__c>();
        for(Id emp : eIds ){
            Employee__c emply = new Employee__c();
            emply.Id = emp;
            System.debug(emply.Id);
            emply.Current_Score__c = avgScore.get(emp);
            em.add(emply);
        }
        update em;
       
      AppraisalLog.logChange(eIds,'Score Updated','Score is Updated');
        
    }
    //after undelete
    public static void afterUnDelete(List<Performance_Metric__c> perform) {
        Set<Id> eIds = new Set<Id>();
        for (Performance_Metric__c pm :perform ){
            if (pm.Employee__c != null) {
                eIds.add(pm.Employee__c);
            }
        }
        Map<Id, Decimal> avgScore = NotificationEmail.avgScore(eIds);
		List<Employee__c> emp = new List<Employee__c>();
        for(Id empId : avgScore.keySet()){
           Employee__c employee = new Employee__c();
            employee.Id = empId;
            employee.Current_Score__c = avgScore.get(empId);
            emp.add(employee);
        }
        
        List<Employee__c> emplist = new List<Employee__c>();
         Map<Id, Employee__c> mapOfEM = new Map<Id, Employee__c>([SELECT Id, Department__c FROM Employee__c WHERE Id IN :eIds]);
        
        Map<String, Performance_Threshold__mdt> perThresold = QuerySelector.metadata();
         for(Performance_Metric__c tempPM : perform){
         string empDepartment = mapOfEM.get(tempPM.Employee__c).Department__c;
          	if(tempPM.Score__c  != null && perThresold.get(empDepartment).Maximum_Threshold__c != null  && perThresold.get(empDepartment).Minimum_Threshold__c != null && 
            	((tempPM.Score__c  > perThresold.get(empDepartment).Maximum_Threshold__c) || (tempPM.Score__c  < perThresold.get(empDepartment).Minimum_Threshold__c)) ){
                      Employee__c emply = new Employee__c();
                      emply.Id = tempPM.Employee__c;
                      emply.Appraisal_Ready__c = false;
                      emplist.add(emply);
                      NotificationEmail.sendNotifications(new List<Performance_Metric__c>{ tempPM });
                      
                }
         }
        
        if (!emp.isEmpty()) {
            update emp;
        }
    }
        
    
          
}