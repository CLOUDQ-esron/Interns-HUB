public class AccountTriggerHandler {
    public static void beforeUpdate(List<Account> newAccountList, Map<Id, Account> oldAccountMap){
        System.debug('New Updated List--->'+newAccountList);
        System.debug('Old Updated Map--->'+oldAccountMap);
        
        for(Account newAccount : newAccountList){
            Account oldAccount = oldAccountMap.get(newAccount.Id);
            if(newAccount.Name != oldAccount.Name){
                System.debug('new Name-->'+newAccount.Name);
                System.debug('old Name-->'+oldAccount.Name);
                newAccount.addError('Cannot Update');
            }
        }
        
        
        /*for(Account newAccount : newAccountList){
for(Account oldAccount : oldAccountList){
if(newAccount.Name != oldAccount.Name){
newAccount.addError('Cannot Update');
}
}
}*/
    }
    public static void beforeAccUpdate(List<Account> newAccountlist,Map<Id, Account> oldAccountReccMap){
        for(Account newAccountReccMap : newAccountlist){
            Account oldRecords= oldAccountReccMap.get(newAccountReccMap.Id);
            if(oldRecords.Industry != 'Finance' && newAccountReccMap.Industry == 'Finance' && newAccountReccMap.Type != 'Prospect' ){
                newAccountReccMap.Type = 'Prospect';
            }
        }
        
    }
  
    public static void afterAccUpdate(List<Account> updateAccountList ,Map<Id, Account> oldAccountMap){
        set<Id> accId = new set<Id>();
        for(Account updateAcc :updateAccountList){
            Account oldRecc = oldAccountMap.get(updateAcc.Id);
            if(updateAcc.Industry != oldRecc.Industry && updateAcc.Industry =='Banking'){
                accId.add(updateAcc.Id);
            }
        }
        list<Task> newTaskList = new list<Task>();
        list<Contact> listContact = [Select Id,Name,AccountId,Department,OwnerId From Contact Where AccountId In: accId AND Department ='Finance'];
        for(Contact Con :listContact)
        {
            Task newTask = new Task();
            newTask.WhoId = Con.Id;
            newTask.Subject = 'user to validate KYC document';
            newTask.Priority = 'Normal';
            newTask.Status = 'Completed';
            newTask.OwnerId = Con.OwnerId;
            newTaskList.add(newTask);  
        }
        if(!newTaskList.IsEmpty()){
            System.debug('task-->'+newTaskList);
            Insert newTaskList;
        }
        
    }
}