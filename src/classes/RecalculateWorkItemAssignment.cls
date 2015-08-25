/**********************************************************************************************
* @author       Yefim Shuster
* @date         2015-07-10
*
* @version      1.0
*
* @description  This class replaces DLRS and is used to calculate WI_Assigned__c that is a "roll up summary field"
*               in Work_Item_Assignment__c object
*
* @revision     
**********************************************************************************************/
public without sharing class RecalculateWorkItemAssignment {

  private class RecalculateWorkItemAssignmentException extends Exception {}
  
  /**********************************************************************************************
  * @author       Yefim Shuster
  * @date         2015-07-10
  *
  * @version      1.1
  *
  * @description  recalculate() will be called on After Update and After Delete in Case Trigger to recalculate
  *                   Work_Item_Assignment__c.WI_Assigned__c value
  *
  * @revisions    Yefim Shuster on 2015-08-04 - fix After Delete logic - new version is 1.1
  *     
  **********************************************************************************************/
  public static void recalculate(Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap, Boolean isUpdate, Boolean isDelete){
    Set<Id> wiaSet = new Set<Id>();
    Set<Id> wiaUnassignedSet = new Set<Id>();
    final Integer maxsize = 400;
    
    Diags.Enter('RecalculateWorkItemAssignment.recalculate()');
    
    if (isUpdate && newCaseMap.size() <= 0) return;
    if (isDelete && oldCaseMap.size() <= 0) return;
    
    if (isUpdate){
      for (Id cid : newCaseMap.keySet()){
         Id nid = newCaseMap.get(cid).Work_Item_Assignment__c;
         Id oid = oldCaseMap.get(cid).Work_Item_Assignment__c;
         String nstatus = newCaseMap.get(cid).Status;
         String ostatus = oldCaseMap.get(cid).Status;
         if ((nid != oid) || ((nstatus != ostatus) && (((nstatus == 'Assigned' || nstatus == 'Being Worked On' || nstatus == 'Unavailable') &&
                                                       (ostatus != 'Assigned' && ostatus != 'Being Worked On' && ostatus != 'Unavailable')) ||
                                                      ((ostatus == 'Assigned' || ostatus == 'Being Worked On' || ostatus == 'Unavailable') &&
                                                       (nstatus != 'Assigned' && nstatus != 'Being Worked On' && nstatus != 'Unavailable'))))){
            if (nid != null) wiaSet.add(nid);
            if (oid != null) wiaSet.add(oid);
            
            // if new status is not Assigned, etc.
            if ((ostatus == 'Assigned' || ostatus == 'Being Worked On' || ostatus == 'Unavailable') &&
                (nstatus != 'Assigned' && nstatus != 'Being Worked On' && nstatus != 'Unavailable')){
                if (nid != null) wiaUnassignedSet.add(nid);
                if (oid != null) wiaUnassignedSet.add(oid);
            }
         }     
      }
    }
    else if (isDelete){
      for (Id cid : oldCaseMap.keySet()){
         Id oid = oldCaseMap.get(cid).Work_Item_Assignment__c;
         String ostatus = oldCaseMap.get(cid).Status;
         if (oid != null && (ostatus == 'Assigned' || ostatus == 'Being Worked On' || ostatus == 'Unavailable')){
            wiaSet.add(oid);
         }     
      }
    }
    else return;
    
    if (wiaSet.size() <= 0) return;
    
    List<Work_Item_Assignment__c> wiaList = new List<Work_Item_Assignment__c>();
    
    Integer csize = 0;
    
    for (List<AggregateResult> caseList : [SELECT Work_Item_Assignment__c, Count(Id) cnt0
                                FROM Case
                                WHERE Work_Item_Assignment__c in :wiaSet AND
                                   Status IN ('Assigned', 'Being Worked On', 'Unavailable')
                                GROUP BY Work_Item_Assignment__c]){
       
       if (csize + caseList.size() > maxsize) break;
       
       csize += caseList.size();
       
       for (AggregateResult c : caseList){
         wiaList.add(new Work_Item_Assignment__c(Id = (Id)c.get('Work_Item_Assignment__c'), WI_Assigned__c = (Decimal)c.get('cnt0')));
       }                
    }
    
    Boolean isRecalculated = false;
    
    if (isDelete){
      wiaUnassignedSet.addAll(wiaSet);
    }
    
    for (Id wiaid : wiaUnassignedSet) {
      isRecalculated = false;
      for (Work_Item_Assignment__c cwia : wiaList) {
        if (cwia.Id == wiaid) isRecalculated = true;
      }
      if (!isRecalculated){
        wiaList.add(new Work_Item_Assignment__c(Id = wiaid, WI_Assigned__c = 0));
      }
    }
    
    if (wiaList.size() <= 0) return;

    List<Database.SaveResult> results = Database.Update(wiaList, false); // allOrNothing = false - partial update will succeed
    
    List<Work_Item_Assignment__c> wiaLockFailed = new List<Work_Item_Assignment__c>();
    List<Work_Item_Assignment__c> wiaOtherFailed = new List<Work_Item_Assignment__c>();
    
    for (Integer i = 0; i < wiaList.size(); i++){
       Database.SaveResult r = results[i];
       if (!r.isSuccess()){
          for (Database.Error er : r.getErrors()) {
             if (er.getStatusCode() == StatusCode.UNABLE_TO_LOCK_ROW){
                 wiaLockFailed.add(wiaList[i]);
                 break;
             }
             else {
                wiaOtherFailed.add(wiaList[i]);
                Diags.Info('Failed to update WIA record Id = ' + wiaList[i].Id + ' Error = ' + er.getMessage());
                break;
             } 
          } 
       }
    }
    
    if (wiaLockFailed.size() > 0) {
       Diags.Info('Locking errors in RecalculateWorkItemAssignment.recalculate() detected. Failed records count = ' + wiaLockFailed.size() + ' Attempting to recover');
       update wiaLockFailed;
    }
    
    if (wiaOtherFailed.size() > 0){
      throw new RecalculateWorkItemAssignmentException('Failed to update ' + wiaOtherFailed.size() + ' WIA records');
    }
    
    Diags.Clear();
  }
}