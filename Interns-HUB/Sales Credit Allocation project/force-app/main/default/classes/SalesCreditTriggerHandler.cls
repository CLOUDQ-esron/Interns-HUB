public class SalesCreditTriggerHandler {
    public static void beforeInsert(List<Sales_Credit__c> newSCList){
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id, Name from Profile where Id = :profileId].Name;
        
        Map<String,Commission_Threshold__mdt> mapOfCT = SalesCreditSelector.createMapOfCommissionThreshold();
        for(Sales_Credit__c sc : newSCList){
            if(sc.Opportunity__c != null){
                sc.OverCredited__c = (sc.CreditPercent__c > mapOfCT.get(sc.Region__c).Max_Credit__c) ? true:false; 
                system.debug(sc.OverCredited__c);
                if(sc.CreditPercent__c < mapOfCT.get(sc.Region__c).Auto_Approve__c){
                    sc.Status__c = 'Approved';
                }
            }
            if(profileName == 'System Administrator'){
                sc.Eligible__c = false;
            }
        }
    }
    public static void afterInsert(List<Sales_Credit__c> newSCList){
        
        Map<String,Commission_Threshold__mdt> mapOfCT = SalesCreditSelector.createMapOfCommissionThreshold();
        Map<String, Integer> oppoAggregate = SalesCreditSelector.createMapOfOppoTotalCredit(newSCList);
        Map<Id,User> mapOfUsers = SalesCreditSelector.createMapOfSalesReps(newSCList);
        List<Commission_Alert__c> listOfCA = new List<Commission_Alert__c>();

        
        for(Sales_Credit__c tempSC : newSCList){
            if( 100 < oppoAggregate.get(tempSC.Opportunity__c)){
                SalesCreditNotificationService.sendMail(mapOfUsers.get(tempSC.Sales_Rep__c).Email,'The Total credit has exceeded','The Total credit for the mentioned opportunnity has exceeded');
              tempSC.addError('The total credit for the Opportunity has exceeded');
            }
            if(tempSC.OverCredited__c == true && mapOfCT.get(tempSC.Region__c).Notify_Manager__c == true){
                System.debug('Trigger enters the if statement');
                Commission_Alert__c alertCA = new Commission_Alert__c();
                alertCA.Sales_Rep__c = tempSC.Sales_Rep__c;
                alertCA.Sales_Credit__c = tempSC.Id;
                alertCA.AlertType__c = 'Over-Credit';
                alertCA.Message__c = 'The Sales Credit record has been over credited';
                alertCA.CreatedOn__c = Datetime.now();
                alertCA.Status__c = 'Notified';
                listOfCA.add(alertCA);
                System.debug('Trigger enters the email statement'+ mapOfUsers.get(tempSC.Sales_Rep__c).Manager.Email);
                SalesCreditNotificationService.sendMail(mapOfUsers.get(tempSC.Sales_Rep__c).Manager.Email,'The Credit Threshold has exceeded',alertCA.Message__c);
                System.debug('Trigger enters the custom notification statement'+ tempSC.Id);
                SalesCreditNotificationService.sendCustomNotification('Notification_for_over_credited_Sales_Credit_records', tempSC.Id, mapOfUsers.get(tempSC.Sales_Rep__c).ManagerId);
            }
            if(mapOfCT.get(tempSC.Region__c).Escalate_To__c != null){
                SalesCreditQueueable escalateJob = new SalesCreditQueueable(mapOfUsers.get(tempSC.Sales_Rep__c).Manager.Email,'The Credit Threshold has exceeded','this was sent with queueable');
                system.enqueueJob(escalateJob);
            }

        }
        if(!listOfCA.isEmpty()){
            Insert listOfCA;
        }
    }
    public static void beforeUpdate(List<Sales_Credit__c> newSCList, Map<Id,Sales_Credit__c> oldSCMap){
        
        Map<String, Integer> oppoAggregate = SalesCreditSelector.createMapOfOppoTotalCredit(newSCList);
        Map<String, Commission_Threshold__mdt> mapOfThreshold = SalesCreditSelector.createMapOfCommissionThreshold();

        for(Sales_Credit__c tempSC : newSCList){
            if(tempSC.Status__c == 'Approved' && (oldSCMap.get(tempSC.Id).CreditPercent__c != tempSC.CreditPercent__c || oldSCMap.get(tempSC.Id).Opportunity__c != tempSC.Opportunity__c || oldSCMap.get(tempSC.Id).Sales_Rep__c != tempSC.Sales_Rep__c)){
                tempSC.addError('The updated field cannot be changed when status has been approved');
            }  
            decimal difference = (tempSC.CreditPercent__c - oldSCMap.get(tempSC.Id).CreditPercent__c);
            tempSC.OverCredited__c = (tempSC.CreditPercent__c > mapOfThreshold.get(tempSC.Region__c).Max_Credit__c) ? true:false;
        }
    }
    public static void afterUpdate(List<Sales_Credit__c> newSCList, Map<Id,Sales_Credit__c> oldSCMap){
        
        List<Commission_Alert__c> listOfCA = new List<Commission_Alert__c>();
        Map<String, Integer> oppoAggregate = SalesCreditSelector.createMapOfOppoTotalCredit(newSCList);
        Map<String, Commission_Threshold__mdt> mapOfThreshold = SalesCreditSelector.createMapOfCommissionThreshold();
        Map<Id,User> mapOfUsers = SalesCreditSelector.createMapOfSalesReps(newSCList);
        Map<Id,Commission_Alert__c> mapOfCA = SalesCreditSelector.createMapOfCommissionAlerts(newSCList);

        for(Sales_Credit__c tempSC : newSCList){
            
            if(tempSC.OverCredited__c){
                Commission_Alert__c alertCA = new Commission_Alert__c();
                alertCA.Sales_Rep__c = tempSC.Sales_Rep__c;
                alertCA.Sales_Credit__c = tempSC.Id;
                alertCA.AlertType__c = 'Over-Credit';
                alertCA.Message__c = 'The update action on the Sales Credit record has been over credited';
                alertCA.CreatedOn__c = Datetime.now();
                alertCA.Status__c = 'Notified';
                listOfCA.add(alertCA);
                SalesCreditNotificationService.sendMail(mapOfUsers.get(tempSC.Sales_Rep__c).Manager.Email,'The Credit Threshold has exceeded',alertCA.Message__c);
            }
            if(oldSCMap.get(tempSC.Id).OverCredited__c == true && tempSC.OverCredited__c == false){
                Commission_Alert__c updateCA = new Commission_Alert__c();
                updateCA.Id = mapOfCA.get(tempSC.Id).Id;
                updateCA.Message__c = 'Resolved';
                listOfCA.add(updateCA);
            }
        }
        if(!listOfCA.isEmpty()){
        Upsert listOfCA;
        }
    }
    public static void beforeDelete(List<Sales_Credit__c> oldSCList, Map<Id,Sales_Credit__c> oldSCMap){
        for(Sales_Credit__c tempSC : oldSCList){
            if(tempSC.Status__c != null && tempSC.OverCredited__c != null){
            if(tempSC.Status__c == 'Approved' || tempSC.OverCredited__c == true  || UserInfo.getUserId() != tempSC.CreatedById){
                tempSC.addError('Cannot be deleted if Status is Approved or if Credit exceeds threshold');
            }
            }
        }
    }
    public static void afterDelete(List<Sales_Credit__c> oldSCList, Map<Id,Sales_Credit__c> oldSCMap){
        
        List<Id> listOfSCOppos = new List<Id>();
        Map<String, Integer> oppoAggregate = SalesCreditSelector.createMapOfOppoTotalCredit(oldSCList);
        Map<String, Commission_Threshold__mdt> mapOfThreshold = SalesCreditSelector.createMapOfCommissionThreshold();
        
        for(Sales_Credit__c tempSC : oldSCList){
            listOfSCOppos.add(tempSC.Opportunity__c);
        }
        for(Sales_Credit__c tempSC : [SELECT Id, OverCredited__c, Opportunity__c, Region__c FROM Sales_Credit__c WHERE Opportunity__c IN :listOfSCOppos]){
            tempSC.OverCredited__c = (oppoAggregate.get(tempSC.Opportunity__c) > mapOfThreshold.get(tempSC.Region__c).Max_Credit__c) ? true:false;
        }
    }
    public static void afterUndelete(List<Sales_Credit__c> oldSCList, Map<Id,Sales_Credit__c> oldSCMap){
        
        List<Commission_Alert__c> listOfCA = new List<Commission_Alert__c>();
        Map<String, Integer> oppoAggregate = SalesCreditSelector.createMapOfOppoTotalCredit(oldSCList);
        Map<String, Commission_Threshold__mdt> mapOfThreshold = SalesCreditSelector.createMapOfCommissionThreshold();
        for(Sales_Credit__c tempSC : oldSCList){
            if(oppoAggregate.get(tempSC.Opportunity__c) > mapOfThreshold.get(tempSC.Region__c).Max_Credit__c){
                Commission_Alert__c alertCA = new Commission_Alert__c();
                alertCA.Sales_Rep__c = tempSC.Sales_Rep__c;
                alertCA.Sales_Credit__c = tempSC.Id;
                alertCA.AlertType__c = 'Over-Credit';
                alertCA.Message__c = 'The Sales Credit still violates the credit thresholds';
                alertCA.CreatedOn__c = Datetime.now();
                alertCA.Status__c = 'Pending';
                listOfCA.add(alertCA);
            }
        }
        if(!listOfCA.isEmpty()){
        insert listOfCA;
        }
    }    
}