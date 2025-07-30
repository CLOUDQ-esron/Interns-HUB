public class NotificationEmail {
    //Notification method
	public static void sendNotifications(List<Performance_Metric__c > pm) {
        CustomNotificationType cnType = QuerySelector.noti();
    	String currentUserId = UserInfo.getUserId();
        List<Messaging.CustomNotification> notifications = new List<Messaging.CustomNotification>();
        for(Performance_Metric__c ppmm : pm){
          	Messaging.CustomNotification cn = new Messaging.CustomNotification();
            cn.setNotificationTypeId(cnType.Id);
            cn.setTitle('Employee Score Threshold Update');
            cn.setBody('Employee score has met the threshold conditions.');
            cn.setTargetId(ppmm.Id); 
            cn.setSenderId(currentUserId);
            cn.send(new Set<String>{currentUserId});
            notifications.add(cn);   
        }
        
     }
    
    //Email method
    public static void sendMail(String address, String subject, String body) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {address};
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        system.debug(results);
    }
    
    //Method that Calculate Average Score
    public static Map<Id,Decimal> avgScore(Set<Id> employiIds){
        
        Date today = Date.today();
        Integer mnth = (Integer)((Math.floor((today.month() - 1) / 3)) * 3) + 1;
        Date startq= Date.newInstance(today.year(), mnth, 1);
        Date endq = startq.addMonths(3).addDays(-1);
        Map<Id, Decimal> average = new Map<Id, Decimal>();
        
        List<AggregateResult> avg = [SELECT Employee__c empId,AVG(Score__c) avgScore FROM Performance_Metric__c WHERE Employee__c IN : employiIds  GROUP BY Employee__c ];
		 for (AggregateResult agg : avg) {
           Id empId = (Id) agg.get('empId');
           Decimal avgS = (Decimal) agg.get('avgScore');
           average.put(empId, avgS);
        }
        
        return average;
    }
           
            
}