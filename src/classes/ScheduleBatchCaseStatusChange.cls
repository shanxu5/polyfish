/**********************************************************************************************
* @author       Melody Yang
* @date         08/17/2015
* @description  This method calls BatchCaseStatusChange
* @version      1.0
* @revision(s)  Original Version
**********************************************************************************************/

global class ScheduleBatchCaseStatusChange implements Schedulable{
    global void execute(SchedulableContext sc) {
    BatchCaseStatusChange b = new BatchCaseStatusChange(); 
      database.executebatch(b, 200);
   }
    //System.schedule('Process at On the Hour','0 0 * 0 * ?n',new ScheduleBatchCaseStatusChange());
}