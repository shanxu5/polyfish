global class ScheduleCreateWorkItems implements Schedulable{
    global void execute(SchedulableContext sc) {
      CreateWorkItems cwi = new CreateWorkItems(); 
      database.executebatch(cwi, 1000);
	}
}