public class AppraisalBatch implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Department__c FROM Employ__c WHERE Department__c != NULL]);
    }

  public void execute(Database.BatchableContext bc, List<Employ__c> scope) {
        Set<Id> eid = new Set<Id>();
        for (Employ__c emp : scope) {
            eid.add(emp.Id);
        }

     
        Map<Id, Decimal> avgVal = new Map<Id, Decimal>();
      List<AggregateResult> res =  [SELECT Employ__c, AVG(Final_Score__c) avgScore FROM Appraisal__c WHERE Employ__c IN :eid AND Final_Score__c != null GROUP BY Employ__c ];
       for (AggregateResult ar : res) {
            Id empId = (Id)ar.get('Employ__c');
            Decimal avg = (Decimal) ar.get('avgScore');
            avgVal.put(empId, avg);
        }

       List<Employ__c> score = new List<Employ__c>();
        for (Employ__c emp : scope) {
            if (avgVal.containsKey(emp.Id)) {
                emp.Average_Score__c = avgVal.get(emp.Id);
                score.add(emp);
            }
        }

        if (!score.isEmpty()) {
            update score;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Average scores updated for employees.');
    }
}