public class MainOppoTeamMemClass {
    List<Opportunity> ListOppo = new List<Opportunity>(); 
    private string PROPOSAL_PRICEQUOTE = 'Proposal/Price Quote';
    
    Public static void InsertOppo(List<Opportunity> NewOppoList){
        List<OpportunityTeamMember> ListOppoTeamMem = new List<OpportunityTeamMember>();
        For(Opportunity oppo : NewOppoList){
            if(oppo != Null && oppo.StageName == 'Prospecting'){
                System.debug('The prospecting gets triggered');
                OpportunityTeamMember NewMember = new OpportunityTeamMember();
                NewMember.OpportunityId = oppo.Id;
                NewMember.UserId = OppoHelperClass.CheckSOQL();
                NewMember.TeamMemberRole = 'Business Analyst';
                NewMember.OpportunityAccessLevel = 'Read';
                ListOppoTeamMem.add(NewMember);
            }
        }
        If(!ListOppoTeamMem.isEmpty()){
      		Insert ListOppoTeamMem;
        }
}
    Public static void UpdateOrInsertOppo(List<Opportunity> NewOppoList, Map<Id, Opportunity> OldOppoMap){
        List<OpportunityTeamMember> ListOppoTeamMem2 = new List<OpportunityTeamMember>();
        AggregateResult UserWithLessOppo2 = [SELECT UserId FROM OpportunityTeamMember GROUP BY UserId ORDER BY Count(Opportunity.Id) LIMIT 1];
        For(Opportunity oppo : NewOppoList){
            if(oppo != Null && oppo.StageName == 'Proposal/Price Quote' && OldOppoMap.get(oppo.Id).StageName != 'Proposal/Price Quote' ){
                System.debug(OldOppoMap.get(oppo.Id).StageName);
                System.debug('The Proposal gets triggered');
                OpportunityTeamMember NewMember2 = new OpportunityTeamMember();
                NewMember2.OpportunityId = oppo.Id;
                NewMember2.UserId = OppoHelperClass.CheckSOQL();
                NewMember2.TeamMemberRole = 'Sales Manager';
                NewMember2.OpportunityAccessLevel = 'All';
                ListOppoTeamMem2.add(NewMember2);
    
            }
        }
        If(!ListOppoTeamMem2.isEmpty()){
            Insert ListOppoTeamMem2;
        }
    }
}