global class QueueableApex implements Queueable, Schedulable {
    
    
    global void execute(QueueableContext context) {
        Account a = new Account(Name='Acme',Phone='(415) 555-1212');
        insert a;        
    }
     global void execute(SchedulableContext con) {
        Account a = new Account(Name='Acme',Phone='(415) 555-1212');
        insert a;        
    }
}