public class ContactTriggerHandler {
     public static void beforeInsert(List<Contact> newContactList){
        System.debug('before insert'+newContactList);
        for(Contact con : newContactList){
            String rollNumber = con.LastName+'Reg'+con.Class__c;
            if(rollNumber.length() == 10 && con.Class__c!=null){
                con.Roll_Number__c = rollNumber;
                
            }
            
        }
    }
    /* public static void afterInsert(List<Contact> newContactList){
System.debug('after insert'+newContactList);
Set<Id> accIdSet = new Set<Id>();
for(Contact con : newContactList){
if(con.AccountId != null){
accIdSet.add(con.AccountId);
}
}
List<AggregateResult> contactCount = [SELECT COUNT(Id) conCount, AccountId FROM Contact WHERE AccountId IN: accIdSet GROUP BY AccountId];
List<Account> accToUpdateList = new List<Account>();
for(AggregateResult agg : contactCount){
Account acc = new Account();
acc.Id = (Id)agg.get('AccountId');
acc.Total_Contacts__c = (Integer)agg.get('conCount');
accToUpdateList.add(acc);
}

if(!accToUpdateList.isEmpty()){
update accToUpdateList;
}

}*/
    
    public static void afterInsert(List<Contact> newContactList, Map<Id,Contact> oldUpdateConMap){
        System.debug('after insert'+newContactList);
        System.debug('after insert checking old Map-->'+oldUpdateConMap);
        Set<Id> accIdSet = new Set<Id>();
        for(Contact con : newContactList){
            //null point exception
            Contact oldConRecord = oldUpdateConMap != null? oldUpdateConMap.get(con.Id) : null;
            //insert                                               update
            if((con != null && oldConRecord == null && con.AccountId != null) || (oldConRecord != null && con.AccountId != oldConRecord.AccountId))
                accIdSet.add(con.AccountId);
            //To take old records
            if(oldConRecord != null && oldConRecord.AccountId != null){
                accIdSet.add(oldConRecord.AccountId);
            }
        }
        totalContactCount(accIdSet);
        
        /*   List<AggregateResult> contactCount = [SELECT COUNT(Id) conCount, AccountId FROM Contact WHERE AccountId IN: accIdSet GROUP BY AccountId];
List<Account> accToUpdateList = new List<Account>();
for(AggregateResult agg : contactCount){
Account acc = new Account();
acc.Id = (Id)agg.get('AccountId');
acc.Total_Contacts__c = (Integer)agg.get('conCount');
accToUpdateList.add(acc);
}

if(!accToUpdateList.isEmpty()){
update accToUpdateList;
}*/
        
    }
    
    public static void afterDelete(List<Contact> newContactList, List<Contact> oldContactList){
        System.debug('after delete new list-->'+newContactList);
        System.debug('after delete old list-->'+oldContactList);
        Set<Id> accIdSet = new Set<Id>();
        for(Contact con : newContactList){
            if(con.AccountId != null){
                accIdSet.add(con.AccountId);
            }
        }
        if(!accIdSet.isEmpty())
            totalContactCount(accIdSet);
        
        /*  List<AggregateResult> contactCount = [SELECT COUNT(Id) conCount, AccountId FROM Contact WHERE AccountId IN: accIdSet GROUP BY AccountId];
List<Account> accToUpdateList = new List<Account>();
for(AggregateResult agg : contactCount){
Account acc = new Account();
acc.Id = (Id)agg.get('AccountId');
acc.Total_Contacts__c = (Integer)agg.get('conCount');
accToUpdateList.add(acc);
}

if(!accToUpdateList.isEmpty()){
update accToUpdateList;
} */
        
        
    }
    
    public static void totalContactCount(Set<Id> accountIds){
        List<AggregateResult> contactCount = [SELECT COUNT(Id) conCount, AccountId FROM Contact WHERE AccountId IN: accountIds GROUP BY AccountId];
        List<Account> accToUpdateList = new List<Account>();
        for(AggregateResult agg : contactCount){
            Account acc = new Account();
            acc.Id = (Id)agg.get('AccountId');
            acc.Total_Contacts__c = (Integer)agg.get('conCount');
            accToUpdateList.add(acc);
        }
        
        
        
        if(!accToUpdateList.isEmpty()){
            update accToUpdateList;
        }
    }
    
    public static void beforeDelete(List<Contact> newContactList, List<Contact> oldContactList){
        System.debug('before delete new list-->'+newContactList);
        System.debug('before delete old list-->'+oldContactList);
    }
    
    public static void createTaskafterInsert(List<Contact> newContactList){
        System.debug('After -->'+newContactList);
        list<task> listTask = new list<task>();
        for(contact conList : newContactList){
            task newTask = new task();
            newTask.WhoId = conList.Id;
            newTask.ActivityDate = system.Today()+ 3;
            listTask.add(newTask);
        }
        if(!listTask.isEmpty()){
            insert listTask;
        }
    }
    
    
    
    public static void createCase(List<Contact> newConList){
        list<Case> listCaselistCase = new list<Case>();
        for(contact newCon:newConList){
            Case newCase = new Case();
            newCase.ContactId = newCon.Id;
            newCase.Status='Escalated';
            newCase.Origin ='Email';
            newCase.Subject	= newCon.LastName;
            listCaselistCase.add(newCase);
        }
        if(!listCaselistCase.isEmpty()){
            Insert listCaselistCase;
            
        }
    }
    public static void beforeupdate(List<Contact> newContactLists,map<Id,Contact> oldContactMap){
        for(Contact newUpdateCon : newContactLists ){
            Contact oldRecords = oldContactMap.get(newUpdateCon.Id);
            if(newUpdateCon.DoNotCall== True && oldRecords.Email != newUpdateCon.Email){
                newUpdateCon.Email.addError('Email cannot be changed');
                
            }
        }
    }
    
  
    public static void beforeInsertUpdateContact(List<Contact> listOfContacts, Map<Id,Contact> oldUpContacts){
        set<Id> accIdies = new set<Id>();
        for(Contact newCon : listOfContacts){
            if(newCon.AccountId != Null && string.isBlank(newCon.Phone)){
                accIdies.Add(newCon.AccountId);
            }
        }
        Map<Id,Account> accMap = new Map<Id,Account>([Select Id,Phone,Parent.Id,Parent.phone From Account Where Id IN: accIdies]);
        List<Contact> contactList = new List<Contact>();
        for(Contact newCon :listOfContacts){
            if(newCon.AccountId != Null && string.isBlank(newCon.Phone) ){
                Account acc = accMap.get(newCon.AccountId);
                System.debug('acc--->'+acc.Parent.Phone);
                if(acc != Null){
                    if(!string.isBlank(acc.Phone)){
                        newCon.Phone = acc.Phone;
                        newCon.Id = newCon.Id;
                    }
                    else if(acc.ParentId != Null && !string.isBlank(acc.Parent.Phone)){
                        //Account parentAccount = accMap.get(acc.ParentId);
                        //if(parentAccount != Null && !string.isBlank(parentAccount.Phone)){'
                        System.debug('acc11--->'+acc.Parent.Phone);
                        newCon.Phone = acc.Parent.Phone;
                        newCon.Id = newCon.Id;
                        //}
                    } 
                }
            }
        }
       
        
    }
    public static void beforeUpdateContactSales(list<Contact> newUpadateContact, Map<Id, Contact> oldUpdateMap){
        set<Id> accIdies = new set<Id>();
        for(Contact newCon :newUpadateContact){
            if(newCon.AccountId != Null && newCon.Department != oldUpdateMap.get(newCon.Id).Department && newCon.Department =='Sales'){
                accIdies.add(newCon.AccountId) ;
            }
        }
        
        //System.debug('??==>'+ accIdies);
        Map<Id,Account> accMap = New Map<Id,Account>([Select Id,AnnualRevenue From Account Where Id In :accIdies]);
        //System.debug('??'+ accMap);
        for(Contact newCon :newUpadateContact){
            Account acc = accMap.containsKey(newCon.AccountId)? accMap.get(newCon.AccountId): null;
            //System.debug('??'+ acc);
            if(acc != null && acc.AnnualRevenue>1000000 && newCon.Department == 'Sales'){
                newCon.Is_Key_Account__c = True;
            }
            else{
                newCon.Is_Key_Account__c = False;
            }
        }
        
    }
}