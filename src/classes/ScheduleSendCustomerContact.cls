global class ScheduleSendCustomerContact implements Schedulable {
    global void execute(SchedulableContext sc) {
      SendCustomerContact scc = new SendCustomerContact(); 
      database.executebatch(scc, 50);
   }
}