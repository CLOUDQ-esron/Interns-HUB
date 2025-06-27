trigger CaseTrigger on Case (after insert, after update) {
    if ((Trigger.isInsert || Trigger.isUpdate) && TriggerControl.isFirstRun) {
        TriggerControl.isFirstRun = false; 
        CaseManager.processCases(Trigger.newMap);
    }
}