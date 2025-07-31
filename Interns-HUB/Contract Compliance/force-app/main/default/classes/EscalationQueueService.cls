public class EscalationQueueService implements Queueable {
    public String address;
    public String subject;
	public string body;
    public EscalationQueueService(String address,String subject, string body) {
        this.address= address;
        this.subject = subject;
        this.body = body;
    }

    public void execute(QueueableContext context) {
        System.debug(address);
        System.debug(this.address);
        System.debug(subject);
        System.debug(body);
        Messaging.SingleEmailMessage em = new Messaging.SingleEmailMessage();
        em.setToAddresses(new List<String>{address });
        em.setSubject(subject);
        em.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ em });
    }
}