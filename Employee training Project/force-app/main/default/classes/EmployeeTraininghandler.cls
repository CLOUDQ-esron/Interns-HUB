public class EmployeeTraininghandler {
    Public Static void BeforeInsert(List<Employee_Training__c> NewListET){
        System.debug(NewListET);
        Set<id> ListofTMId = new Set<Id>();
        for(Employee_Training__c et : NewListET){
            if(et.Completion_Date__c != Null){
                et.status__c = System.Label.Employee_Training_Status_Completed;
                ListofTMId.add(et.Training_Module__c);
            }
        }
        Map<Id, Training_Module__c> TrigRelatedTM = new Map<Id, Training_Module__c>(NotificationQuery.getMapOfTrainingModule('Mandatory__c, Validity_Period__c', ListofTMId));
        System.debug(TrigRelatedTM);
        for(Employee_Training__c et2 : NewListET){
            if(TrigRelatedTM.ContainsKey(et2.Training_Module__c) && et2.Training_Module__c != Null){                
            	Training_Module__c temp = TrigRelatedTM.get(et2.Training_Module__c);
            	et2.Expiry_Date__c = et2.Completion_Date__c.addDays(Integer.valueOf(temp.Validity_Period__c));
            }
        }
	}
    Public Static void AfterInsert(List<Employee_Training__c> NewListET){
        CustomNotificationType notificationType = NotificationQuery.getNotificationType();
        List<Training_Change_Log__c> ListofTC = new List<Training_Change_Log__c>();
        Set<id> ListofTMId = new Set<Id>();
        For(Employee_Training__c ET : NewListET){
            If(ET.Training_Module__c != Null){
                
            }
            ListofTMId.add(ET.Training_Module__c); 
            Training_Change_Log__c NewTCL = new Training_Change_Log__c();
            NewTCL.Name = 'Just for fun';
            NewTCL.Employee_Training__c = ET.Id;
            NewTCL.Change_Type__c = 'Created';
            ListofTC.add(NewTCL);
        }
        Insert ListofTC;
        Map<Id, Training_Module__c> TrigRelatedTM = new Map<Id, Training_Module__c>(NotificationQuery.getMapOfTrainingModule('Mandatory__c', ListofTMId));
        For(Employee_Training__c ET : NewListET){
            If(ET.Training_Module__c != Null && TrigRelatedTM.get(ET.Training_Module__c).Mandatory__c != False && notificationType != Null && ET.Employee__c != Null){
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
        		notification.setBody('The Module is Marked as mandatory');
        		notification.setTitle('Module is mandatory');
        		notification.setNotificationTypeId(notificationType.Id);
        		notification.setTargetId(ET.Training_Module__c); // Record associated with the notification
        		notification.setSenderId(UserInfo.getUserId()); // The user sending the notification
        		notification.send(new Set<String>{ET.Employee__c});
            }
        }        
	}
    Public Static void BeforeUpdate(List<Employee_Training__c> NewList, Map<Id, Employee_Training__c> OldMap){
        List<Training_Change_Log__c> ListofTC = new List<Training_Change_Log__c>();
        For(Employee_Training__c ET : NewList){
            If(ET.Expiry_Date__c < System.Today()){                
                ET.addError('Cannot Update this record as it has finished its Expiry Date');
            }
            Training_Change_Log__c NewTCL = new Training_Change_Log__c();
            NewTCL.Name = 'Old Field Values for auditing';
            NewTCL.Employee_Training__c = ET.Id; 
            NewTCL.Field_Changes__c = 'Old Expiry Date: ' + OldMap.get(ET.Id).Expiry_Date__c + '\n Old Status Value: ' + OldMap.get(ET.Id).Status__c;
            NewTCL.Change_Type__c = 'deleted';
            NewTCL.Changed_On__c = System.Today(); 
            NewTCL.Changed_By__c = UserInfo.getUserId();
            ListofTC.add(NewTCL);
            }
        If(!ListofTC.isEmpty()){
            Insert ListofTC;            
        }         
    }
    Public Static void AfterUpdate(List<Employee_Training__c> NewList, Map<Id, Employee_Training__c> OldMap){
        CustomNotificationType notificationType = NotificationQuery.getNotificationType();
        List<Training_Change_Log__c> ListofTC = new List<Training_Change_Log__c>();
        for(Employee_Training__c ET : NewList){
            If(ET.Status__c != OldMap.get(ET.Id).Status__c && ET.Employee__c != Null && (ET.Status__c == System.Label.Employee_Training_Status_Expired || ET.Status__c == System.Label.Employee_Training_Status_Upcoming)){
                System.debug('Inside the create notification statement');
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
        		notification.setBody('The Employee Training Status has been changed');
        		notification.setTitle('Status has been chnaged');
        		notification.setNotificationTypeId(notificationType.Id);
        		notification.setTargetId(ET.Id);
        		notification.setSenderId(UserInfo.getUserId());
        		notification.send(new Set<String>{ET.Employee__c});
            }
            If(ET.Expiry_Date__c != OldMap.get(ET.Id).Expiry_Date__c || ET.Status__c != OldMap.get(ET.Id).Status__c){ 
                System.debug('Inside the create TCL statement');
                Training_Change_Log__c NewTCL = new Training_Change_Log__c();          
                NewTCL.Name = 'Field Change';
                NewTCL.Changed_On__c = System.Today(); 
                NewTCL.Changed_By__c = UserInfo.getUserId();
                NewTCL.Employee_Training__c = ET.Id;
                If(ET.Expiry_Date__c != OldMap.get(ET.Id).Expiry_Date__c){                    
                	NewTCL.Field_Changes__c = 'The Expiry Date field was updated from ' + OldMap.get(ET.Id).Expiry_Date__c + ' To ' + ET.Expiry_Date__c;
                }
                If(ET.Status__c != OldMap.get(ET.Id).Status__c){
                    NewTCL.Field_Changes__c = 'The Status field was updated from ' + OldMap.get(ET.Id).Status__c + ' To ' + ET.Status__c;
                }   
                NewTCL.Change_Type__c = 'Field Updated';
            	ListofTC.add(NewTCL);
            }
        }
        System.debug(ListofTC);
        If(!ListofTC.isEmpty()){
            Insert ListofTC;
        }
    }
    Public Static void BeforeDelete(List<Employee_Training__c> NewList){
        System.debug('Enters the method');
        System.debug(NewList);
        Set<id> ListofTMId = new Set<Id>();
        For(Employee_Training__c ET : NewList){
            If(ET.Training_Module__c != Null){
            ListofTMId.add(ET.Training_Module__c);
            }
        }
        Map<Id, Training_Module__c> TrigRelatedTM = new Map<Id, Training_Module__c>(NotificationQuery.getMapOfTrainingModule('Mandatory__c', ListofTMId));
        System.debug(TrigRelatedTM);
        System.debug(TrigRelatedTM.values());
        For(Employee_Training__c ET : NewList){   
            System.debug('Inside the for loop ==>' + NewList);
            If(TrigRelatedTM.ContainsKey(ET.Training_Module__c) && ET.Training_Module__c != Null && TrigRelatedTM.get(ET.Training_Module__c).Mandatory__c == True){
                ET.addError('Cannot Delete this record as its related training module is mandatory');
            }
       }
    }
    Public Static void AfterDelete(List<Employee_Training__c> OldList){
        List<Training_Change_Log__c> ListofTC = new List<Training_Change_Log__c>();
        System.debug('Entered the Method ==>' + OldList);
        CustomNotificationType notificationType = NotificationQuery.getNotificationType();
        For(Employee_Training__c ET : OldList){ 
            If(ET.Status__c == System.Label.Employee_Training_Status_Completed && ET.Employee__c != Null){
                System.debug('Inside the create notification statement');
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setBody('A Employee Training that has been completed was deleted');
                notification.setTitle('Completed Employee Training was deleted');
        		notification.setNotificationTypeId(notificationType.Id);
        		notification.setTargetId(ET.Id);
        		notification.setSenderId(UserInfo.getUserId());
        		notification.send(new Set<String>{ET.Employee__c});
            }
            System.debug('Inside the create TCL statement');
            Training_Change_Log__c NewTCL = new Training_Change_Log__c();
                NewTCL.Name = 'Employee Training Record is deleted';
                NewTCL.Field_Changes__c = 'The Record was deleted';
                NewTCL.Change_Type__c = 'deleted';
                NewTCL.Changed_On__c = System.Today(); 
                NewTCL.Changed_By__c = UserInfo.getUserId();
            	ListofTC.add(NewTCL);
            }
        If(!ListofTC.isEmpty()){
            Insert ListofTC;
        }
	}
    Public static void afterUndelete(List<Employee_Training__c> NewList){
        List<Training_Change_Log__c> ListofTC = new List<Training_Change_Log__c>();
        System.debug('Entered the Method ==>' + NewList);
        CustomNotificationType notificationType = NotificationQuery.getNotificationType();
        For(Employee_Training__c ET : NewList){ 
            If(ET.Status__c == 'Completed' && ET.Employee__c != Null){
                System.debug('Inside the create notification statement');
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setBody('A Employee Training that has been completed was Undeleted');
                notification.setTitle('Completed Employee Training was Undeleted');
        		notification.setNotificationTypeId(notificationType.Id);
        		notification.setTargetId(ET.Id);
        		notification.setSenderId(UserInfo.getUserId());
        		notification.send(new Set<String>{ET.Employee__c});
            }
            System.debug('Inside the create TCL statement');
            Training_Change_Log__c NewTCL = new Training_Change_Log__c();
            NewTCL.Name = 'Employee Training Record is undeleted';
            NewTCL.Field_Changes__c = 'The Record was Undeleted';
            NewTCL.Change_Type__c = 'Undeleted';
            NewTCL.Changed_On__c = System.Today(); 
            NewTCL.Changed_By__c = UserInfo.getUserId();
            NewTCL.Employee_Training__c = ET.Id;
            ListofTC.add(NewTCL);
        }
        If(!ListofTC.isEmpty()){
            Insert ListofTC;
        }
    }
}