public class CaseManager {
    public static void processCases(Map<Id, Case> caseMap) {
        List<Case> cases = caseMap.values();
        Set<Id> caseIds = caseMap.keySet();
        List<Entitlement> ents = [
            SELECT Id, EndDate, StartDate, RemainingCases, Type, CaseId__c
            FROM Entitlement 
            WHERE CaseId__c IN :caseIds
        ];

        
        Map<Id, Entitlement> entMap = new Map<Id, Entitlement>();
        for (Entitlement e : ents) {
            entMap.put(e.CaseId__c, e);
        }

        List<Entitlement> entitlementsToUpdate = new List<Entitlement>();
        List<Case> casesToUpdate = new List<Case>();
        Set<Id> escalatedCaseIds = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();

        
        for (Case c : caseMap.values()) {
            if (!entMap.containsKey(c.Id)) {
                Case cToUpdate = new Case(
                    Id = c.Id,
                    Priority = 'High',
                    Status = 'Escalated'
                );
                casesToUpdate.add(cToUpdate);
                escalatedCaseIds.add(c.Id);
                ownerIds.add(c.OwnerId);
            } else {
              	Entitlement e = entMap.get(c.Id);
                e.StartDate = Date.today();
                e.EndDate = Date.today().addDays(2);
                e.Type = (e.RemainingCases > 3) ? 'Premium' : 'Standard';
                entitlementsToUpdate.add(e);
            }
        }

        
        if (!entitlementsToUpdate.isEmpty()) {
            update entitlementsToUpdate;
        }

        
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }

        
        if (!escalatedCaseIds.isEmpty() && !ownerIds.isEmpty()) {
            EmailHelper.sendEscalationEmails(escalatedCaseIds, ownerIds);
        }
    }
}