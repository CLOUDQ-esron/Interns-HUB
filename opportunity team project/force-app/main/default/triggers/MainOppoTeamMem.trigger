trigger MainOppoTeamMem on Opportunity (After insert, After Update) {
    If(Trigger.isInsert){
    	MainOppoTeamMemClass.InsertOppo(Trigger.New);
    }
    If(Trigger.isUpdate){
        MainOppoTeamMemClass.UpdateOrInsertOppo(Trigger.New, Trigger.oldMap);
    }
}