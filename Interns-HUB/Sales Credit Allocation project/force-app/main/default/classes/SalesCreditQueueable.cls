public class SalesCreditQueueable implements Queueable{
    public String address;
    public String subject;
    public String body;
    
    // Constructor to pass arguments
    public SalesCreditQueueable(String address, String subject, String body) {
        this.address = address;
        this.subject = subject;
        this.body = body;
    }
    public void execute(QueueableContext context){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();       // Create an email message object
        String[] toAddresses = new String[] {address};
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    
}