global class ScheduleSendSLANotification implements Schedulable {
    global void execute(SchedulableContext sc) {
      SendSLANotification scc = new SendSLANotification(); 
      database.executebatch(scc, 50);
   }
}