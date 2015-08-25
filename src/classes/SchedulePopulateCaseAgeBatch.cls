/**********************************************************************************************
* @author       Tae Tran
* @date         07/22/2015
*
* @version      1.0
*
* @description  schedule class to schedule populate case age batch class
*               
* @revision     
*               
**********************************************************************************************/
global class SchedulePopulateCaseAgeBatch implements Schedulable {
    global void execute(SchedulableContext sc) {
	  PopulateCaseAgeBatch pcab = new PopulateCaseAgeBatch(); 
      database.executebatch(pcab, 50);
   }
}