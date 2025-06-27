public class OppoHelperClass {   
    Static Integer minValue = 0;
    Static Id userIdWithTheLeastNumberOfOpportunity;
    Public Static Id CheckSOQL(){
        Map<Id, Integer> MapofOppoteammember = new Map<Id, Integer>();
        List<AggregateResult> IdofUserWithLessOppo = [SELECT UserId, Count(Opportunity.Id) oppoagg FROM OpportunityTeamMember GROUP BY UserId ORDER BY Count(Opportunity.Id)];
        For(AggregateResult agg : IdofUserWithLessOppo){
            Id UserId = (Id)agg.get('UserId');
     		Integer oppocount = (Integer)agg.get('oppoagg');
            MapofOppoteammember.put(UserId,oppocount);
        }
        system.debug('??'+MapofOppoteammember);
        For(Id eachMapId : MapofOppoteammember.Keyset()){
            System.debug('ENTER'+eachMapId);
          Id firstKey = (Id)(MapofOppoteammember.keySet().iterator().next());
          Integer countTemp = MapofOppoteammember.get(firstKey);

            Integer count = MapofOppoteammember.get(eachMapId);
             

            If(countTemp>= count){
                minValue = count;
                userIdWithTheLeastNumberOfOpportunity = eachMapId;
                System.debug('eachMapId'+eachMapId);
            }
        }
        return userIdWithTheLeastNumberOfOpportunity;
    }
}