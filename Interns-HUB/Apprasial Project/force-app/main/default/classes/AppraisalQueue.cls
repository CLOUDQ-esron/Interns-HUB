public class AppraisalQueue implements Queueable {
     private Set<Id> aid;
    public AppraisalQueue(List<Appraisal__c> app){
        aid =new set<id>();
        for(Appraisal__c ap : app){
            aid.add(ap.id);
        }
    }
    public void execute(QueueableContext context){
       List<Appraisal__c> val =[SELECT Id,Goal_Achievement__c, Team_Feedback_Score__c FROM Appraisal__c WHERE Id IN :aid ];
       List<Appraisal__c> app = new List<Appraisal__c>(); 
        for(Appraisal__c a : val){
            if(a.Goal_Achievement__c != null || a.Team_Feedback_Score__c != null){
                a.Final_Score__c =( (a.Goal_Achievement__c + a.Team_Feedback_Score__c) / 2);
            }
            
        }
        update app;
        
    }

}