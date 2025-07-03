trigger AccountTrigger on Account (before update,After Update) {
    /* Map<Id, Account> nMap = Trigger.newMap;
List<Contact> cList = [SELECT LastName,Accountid FROM Contact WHERE AccountId IN: nMap.keySet()];

for (Contact c : cList) {
Account a = nMap.get(c.AccountId);
c.MailingCity = a.BillingState;
}
update cList;*/
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            AccountTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
            AccountTriggerHandler.beforeAccUpdate(Trigger.new,Trigger.oldMap);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            AccountTriggerHandler.afterAccUpdate(Trigger.new,Trigger.oldMap); 
        }
    }
}