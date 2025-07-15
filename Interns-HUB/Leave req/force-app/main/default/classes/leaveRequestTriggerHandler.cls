public class leaveRequestTriggerHandler {
    public static void beforeInsert(list<Leave_Request__c> newLeaveRequestList){
        for(Leave_Request__c req :newLeaveRequestList){
            if(req.Status__c == Null){
                req.Status__c = 'Draft';
            }
            if(req.StartDate__c< system.today()){
                req.addError('start date must be future dates');
            }
            
            
        }
    }
    public static void afterInsert(list<Leave_Request__c> newReqlist){
        system.debug(newReqlist);
        CustomNotificationType notificationType = [select Id, DeveloperName From CustomNotificationType Where DeveloperName ='Notify_approver_if_Status_is_Submitted'];
        list<leave_Audit__c> listAudit = new list<leave_Audit__c>();
        for(Leave_Request__c leave : newReqlist){
            leave_Audit__c newRec = new leave_Audit__c();
            newRec.Leave_Request__c = leave.Id;
            newRec.Notes__c = 'Iam not feeling well';
            newRec.Name = 'Trainig test';
            newRec.Action__c = 'Created';
            listAudit.add(newRec);
            if(leave.Status__c =='Submitted' && leave.Approver__c != null){
                Messaging.CustomNotification notification = New Messaging.CustomNotification();
                notification.setTitle('Aware the Status');
                notification.setBody('The notification help to aware approver where status is "Submitted"');
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(leave.Id);
                notification.setSenderId(UserInfo.getUserId());
                notification.send(new set<String>{leave.Approver__c});
            }
            System.debug(leave.Approver__c);
        }
        
        
        if(!listAudit.isEmpty()){
            Insert listAudit;
        }
    }
    
    public static void beforeUpdate(list<Leave_Request__c> newRequestleave,map<Id,Leave_Request__c> oldRequestMap){
        list<leave_Audit__c> listOfAuditField = new list<leave_Audit__c>();
        for(Leave_Request__c newUpdateRecc : newRequestleave){
            Leave_Request__c oldRecc = oldRequestMap.get(newUpdateRecc.Id);
            if(newUpdateRecc.Status__c != oldRecc.Status__c && oldRecc.Status__c == 'Approved'&& newUpdateRecc.Status__c == 'Draft'){
                newUpdateRecc.addError('Prevent status change from Approved back to Draft');
            }
            
        }
    }
    public static void afterUpdateTrigger( list<Leave_Request__c> updateList, Map<Id,Leave_Request__c> oldUpdatedMap){
        list<leave_Audit__c> listleave = new list<leave_Audit__c>();
        for(Leave_Request__c newRecc : updateList){
            Leave_Request__c oldRec = oldUpdatedMap.get(newRecc.Id);
            if(oldRec.Status__c != newRecc.Status__c && oldRec.Approver__c != newRecc.Approver__c && oldRec!=Null){
                leave_Audit__c newRec = new leave_Audit__c ();
                newRec.Leave_Request__c = newRecc.Id;
                newRec.Action__c ='Updated';
                newRec.Name = 'My Test';
                newRec.Notes__c= 'the field status is change from '+ oldRec.Status__c + 'to'+newRecc.Status__c+'And'+  ' The field approver change from '+oldRec.Approver__c +'to'+ newRecc.Approver__c; 
                newRec.Performed_By__c = newRecc.Approver__c;
                listleave.add(newRec);
                
            }
            if(!listleave.isEmpty()){
                Insert listleave;
            }
        }
    }
    public static void beforeDelete(list<Leave_Request__c> deleteLists){
        for(Leave_Request__c del : deleteLists ){
            if(del.Status__c == 'Approved'){
                del.addError('cannot delete an approved leave request');  
            }
        }
    }
    public static void afterUpdate(list<Leave_Request__c>newUpdateList,map<Id,Leave_Request__c> oldUpdateMap){
        list<leave_Audit__c> newAuditlist = new list<leave_Audit__c>();
        CustomNotificationType notificationType = [select Id, DeveloperName From CustomNotificationType Where DeveloperName ='Notify_approver_if_Status_is_Submitted'];
        for(Leave_Request__c leaveReq:newUpdateList){
            Leave_Request__c oldReq = oldUpdateMap.get(leaveReq.Id);
            leave_Audit__c newAudit = new leave_Audit__c(); 
            newAudit.Leave_Request__c = leaveReq.Id;
            newAudit.Notes__c = 'Iam not feeling well';
            newAudit.Name = 'Trainig test2';
            newAudit.Action__c= 'Updated';
            newAuditlist.add(newAudit);
            if((leaveReq.Status__c == 'Approved' ||leaveReq.Status__c =='Rejected') && leaveReq.Employee__c != Null){
                Messaging.CustomNotification notification = New Messaging.CustomNotification();
                notification.setTitle('Aware the status rejected or Updated');
                notification.setBody('The notification help to aware approver where status is "rejected or Updated"');
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(leaveReq.Id);
                notification.setSenderId(UserInfo.getUserId());
                notification.send(new set<String>{leaveReq.Employee__c});
            }
        }
        if(!newAuditlist.isEmpty()){
            Insert newAuditlist;
        }
    }
    public static void afterDelete(list<Leave_Request__c> oldList){
        Set<Id> LeaveRequest = new Set<Id>();
        CustomNotificationType notificationType = [select Id, DeveloperName From CustomNotificationType Where DeveloperName ='Notify_approver_if_Status_is_Submitted'];
        for(Leave_Request__c delList : oldList){
            LeaveRequest.add(delList.Employee__c);
        }
        Map<Id,User> managerIdList = new Map<Id,User>([SELECT Id,ManagerId, Manager.Name From User WHERE id In :LeaveRequest]);
        System.debug('managerIdList--->'+managerIdList);
        for(Leave_Request__c delList : oldList){
            if(managerIdList.get(delList.Employee__c).ManagerId != Null){
                Messaging.CustomNotification notification = New Messaging.CustomNotification();
                notification.setTitle('Aware the delete Record');
                notification.setBody(('The notification help to aware approver where status is "rejected or Updated"'));
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(delList.Id);
                notification.setSenderId(UserInfo.getUserId());
                notification.send(new set<String>{managerIdList.get(delList.Employee__c).ManagerId});
            }
        }
    }
    public static void afterUndelete(list<Leave_Request__c> unDeleteList){
        CustomNotificationType notificationType = [select Id, DeveloperName From CustomNotificationType Where DeveloperName ='Notify_approver_if_Status_is_Submitted'];
        for(Leave_Request__c unDel : unDeleteList){
            if(unDel.Status__c =='Submitted' && unDel.Employee__c != Null){
                Messaging.CustomNotification notification = New Messaging.CustomNotification();
                notification.setTitle('Aware the unDeleteRecord');
                notification.setBody('The notification help to aware the record is retrive from the recycle bin');
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(unDel.Id);
                notification.setSenderId(UserInfo.getUserId());
                notification.send(new set<String>{unDel.Employee__c});  
            }
            
        }
    } 
    
}