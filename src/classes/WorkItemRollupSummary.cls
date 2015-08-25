/**********************************************************************************************
* @author       Yefim Shuster
* @date         2015-07-27
*
* @version      1.0
*
* @description  This class replaces DLRS and is used to calculate roll up summary fields on Work Item
*
* @revision     
**********************************************************************************************/
public without sharing class WorkItemRollupSummary {

  private class WorkItemRollupSummaryException extends Exception {}
  
  /**********************************************************************************************
  * @author       Yefim Shuster
  * @date         2015-07-24
  *
  * @version      1.1
  *
  * @description  recalculateChildtoParent() will be called on After Update and After Delete in Case Trigger to recalculate
  *                   Case.Children_WI_Count__c and Childer_s_Handle_Time__c value
  *
  * @revisions    Yefim Shuster on 2015-08-04 - recalculate on each After Update - new version is 1.1
  *     
  **********************************************************************************************/
  public static void recalculateChildtoParent(Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap, Boolean isUpdate, Boolean isDelete){
    Set<Id> parentIdSet = new Set<Id>();
    final Integer MAXSIZE = 1000;
    
    Diags.Enter('WorkItemRollupSummary.recalculateChildtoParent()');
    
    if (isUpdate && newCaseMap.size() <= 0) return;
    if (isDelete && oldCaseMap.size() <= 0) return;
    
    if (isUpdate){
      Map<Id, Case> retrCaseMap = new Map<Id, Case>([SELECT Id, ParentId
                                                   FROM Case
                                                   Where Id IN :newCaseMap.keySet()
                                                    and IsParent__c = false]);
      if (retrCaseMap.size() <= 0) return;
      
      for (Id cid : retrCaseMap.keySet()){
         Id nid = retrCaseMap.get(cid).ParentId;
         Id oid = (oldCaseMap.get(cid) == null ? null : oldCaseMap.get(cid).ParentId);
         
         if (nid != null) parentIdSet.add(nid);
         if (oid != null) parentIdSet.add(oid);     
      }
    }
    else if (isDelete){
      for (Id cid : oldCaseMap.keySet()){
         Id oid = oldCaseMap.get(cid).ParentId;
         
         if (oid != null){
            parentIdSet.add(oid);
         }     
      }
    }
    else return;
    
    if (parentIdSet.size() <= 0) return;
    
    List<Case> newcaseList = new List<Case>();
    
    Integer csize = 0;
    
    Map<Id, Case> parentsMap = new Map<Id, Case>([SELECT Id, Handle_Time__c
                                           FROM Case
                                           Where Id in :parentIdSet]);
                                           
    if (parentsMap.size() <= 0) return;
    
    Map<Id, Case> updateCaseMap = new Map<Id, Case>();
    
    for (List<AggregateResult> caseList : [SELECT ParentId, Count(Id) cnt0, Sum(Handle_Time__c) sum0
                                           FROM Case
                                           Where ParentId in :parentIdSet
                                           Group by ParentId]){
       
       if (csize + caseList.size() > MAXSIZE) break;
       
       csize += caseList.size();
       
       for (AggregateResult c : caseList){
         if (parentsMap.containsKey((Id)c.get('ParentId'))){
           Case cs = parentsMap.get((Id)c.get('ParentId'));
           Decimal cwic = ((Decimal)c.get('cnt0') == null ? 0 : (Decimal)c.get('cnt0'));
           Decimal chtime = ((Decimal)c.get('sum0') == null ? 0 : (Decimal)c.get('sum0'));
           cs.Average_Handle_Time_on_Parent__c = ((cs.Handle_Time__c == null ? 0 : cs.Handle_Time__c) + chtime) / (1 + cwic);
           cs.Children_WI_Count__c = cwic;
           updateCaseMap.put(cs.Id, cs);
         }
       }                
    }
    
    for (Id pid : parentIdSet) {
      if (!updateCaseMap.containsKey(pid)){
        if (parentsMap.containsKey(pid)){
          Case cs = parentsMap.get(pid);
          cs.Average_Handle_Time_on_Parent__c = 0;
          cs.Children_WI_Count__c = 0;
          updateCaseMap.put(cs.Id, cs);
        }
      }
    }
    
    if (updateCaseMap.size() <= 0) return;

    List<Database.SaveResult> results = Database.Update(updateCaseMap.values(), false); // allOrNothing = false - partial update will succeed
    
    List<Case> caseLockFailed = new List<Case>();
    List<Case> caseOtherFailed = new List<Case>();
    
    for (Integer i = 0; i < updateCaseMap.size(); i++){
       Database.SaveResult r = results[i];
       if (!r.isSuccess()){
          for (Database.Error er : r.getErrors()) {
             if (er.getStatusCode() == StatusCode.UNABLE_TO_LOCK_ROW){
                 caseLockFailed.add(updateCaseMap.get(r.getId()));
                 break;
             }
             else {
                caseOtherFailed.add(updateCaseMap.get(r.getId()));
                Diags.Info('Failed to update WI record Id = ' + r.getId() + ' Error = ' + er.getMessage());
                break;
             } 
          } 
       }
    }
    
    if (caseLockFailed.size() > 0) {
       Diags.Info('Locking errors in WorkItemRollupSummary.recalculateChildtoParent() detected. Failed records count = ' + caseLockFailed.size() + ' Attempting to recover');
       update caseLockFailed;
    }
    
    if (caseOtherFailed.size() > 0){
      throw new WorkItemRollupSummaryException('In WorkItemRollupSummary.recalculateChildtoParent(): Failed to update ' + caseOtherFailed.size() + ' WI records');
      //Diags.Info('In WorkItemRollupSummary.recalculateChildtoParent(): Failed to update ' + caseOtherFailed.size() + ' WI records');
    }
    
    Diags.Clear();
  }
  
  /**********************************************************************************************
  * @author       Yefim Shuster
  * @date         2015-07-27
  *
  * @version      1.0
  *
  * @description  recalculateHandleTime() will be called on After Update in Case Trigger to recalculate
  *                   Case.Handle_Time__c value
  *
  * @revisions
  *     
  **********************************************************************************************/
  public static void recalculateHandleTime(List<Case> updatedCaseList, Map<Id, Case> oldCaseMap, Boolean isUpdate){
    Set<Id> caseIdSet = new Set<Id>();
    final Integer MAXSIZE = 400;
    
    Diags.Enter('WorkItemRollupSummary.recalculateHandleTime()');
      
System.debug(logginglevel.info,'@@@@@@@@@WorkItemRollupSummary.recalculateHandleTime()');
    
    if (isUpdate && updatedCaseList.size() <= 0) return;
    
    if (isUpdate){
        
System.debug(logginglevel.info, '@@@@@@@@@ entering isUpdate if loop');
        
      for (Case c : updatedCaseList){
         String nstatus = c.Status;
         String ostatus = (oldCaseMap.get(c.Id) != null ? oldCaseMap.get(c.Id).Status : 'null');
          
System.debug(logginglevel.info, '@@@@@@@@@ work item new status: '+ nstatus);
System.debug(logginglevel.info, '@@@@@@@@@ work item old status: '+ ostatus);
          
         if ((nstatus != ostatus) && (((nstatus == 'Being Worked On') &&
                                       (ostatus != 'Being Worked On')) ||
                                       ((ostatus == 'Being Worked On') &&
                                       (nstatus != 'Being Worked On')))){
            caseIdSet.add(c.Id);
         }     
      }
    }
    else return;
    
    if (caseIdSet.size() <= 0) return;
      
System.debug(logginglevel.info, '@@@@@@@@@ work item caseIdSet size: '+ caseIdSet.size());  
      
    List<Case> newCaseList = new List<Case>();
    
    Integer csize = 0;
    
    for (List<AggregateResult> statusTimesList : [SELECT Work_Item__c, Sum(Time_Min__c) sum0
                                FROM Status_Times__c
                                WHERE Work_Item__c in :caseIdSet AND
                                   Last_Status__c = 'Being Worked On'
                                GROUP BY Work_Item__c]){
       
       if (csize + statusTimesList.size() > MAXSIZE) break;
       
       csize += statusTimesList.size();
       
       for (AggregateResult c : statusTimesList){
         newCaseList.add(new Case(Id = (Id)c.get('Work_Item__c'), Handle_Time__c = (Decimal)c.get('sum0')));
       }                
    }
    
    if (newCaseList.size() <= 0) return;
      
System.debug(logginglevel.info, '@@@@@@@@@ work item newCaseList size: '+ newCaseList.size());  
      
    List<Database.SaveResult> results = Database.Update(newCaseList, false); // allOrNothing = false - partial update will succeed
    
    List<Case> caseLockFailed = new List<Case>();
    List<Case> caseOtherFailed = new List<Case>();
      
System.debug(Logginglevel.info,'@@@@@@@@@What is new case list: WorkItemrollup' + newCaseList);//Tae
    
    for (Integer i = 0; i < newCaseList.size(); i++){
       Database.SaveResult r = results[i];
       if (!r.isSuccess()){
          for (Database.Error er : r.getErrors()) {
             if (er.getStatusCode() == StatusCode.UNABLE_TO_LOCK_ROW){
                 caseLockFailed.add(newCaseList[i]);
                 break;
             }
             else {
                caseOtherFailed.add(newCaseList[i]);
                Diags.Info('Failed to update Case record Id = ' + newCaseList[i].Id + ' Error = ' + er.getMessage());
                break;
             } 
          } 
       }
    }
    
    if (caseLockFailed.size() > 0) {
       Diags.Info('Locking errors in WorkItemRollupSummary.recalculateHandleTime() detected. Failed records count = ' + caseLockFailed.size() + ' Attempting to recover');
System.debug(logginglevel.info, '@@@@@@@@@ Locking errors in WorkItemRollupSummary.recalculateHandleTime() detected. Failed records count = ' + caseLockFailed.size() + ' Attempting to recover');
       
        update caseLockFailed;
    }
    
    if (caseOtherFailed.size() > 0){
      throw new WorkItemRollupSummaryException('In WorkItemRollupSummary.recalculateHandleTime(): Failed to update ' + caseOtherFailed.size() + ' Case records');
System.debug(logginglevel.info, '@@@@@@@@@ In WorkItemRollupSummary.recalculateHandleTime(): Failed to update ' + caseOtherFailed.size() + ' Case records');
        
    }
    
    Diags.Clear();
  }
  
  /**********************************************************************************************
  * @author       Yefim Shuster
  * @date         2015-07-30
  *
  * @version      1.0
  *
  * @description  recalculateFUREmailsSentCount() will be called on Before Update and After Insert and After Delete in Task Trigger to recalculate
  *                   Case.Number_of_FUR_Emails_Sent__c value
  *
  * @revisions
  *     
  **********************************************************************************************/
  public static void recalculateFUREmailsSentCount(Map<Id, Task> newTaskMap, Map<Id, Task> oldTaskMap, Boolean isBefore, Boolean isInsert, Boolean isUpdate, Boolean isDelete){
    
    if (isBefore && isInsert) return;
    
    if (isBefore && isDelete) return;
    
    if (!isBefore && isUpdate) return;
    
    if ((isUpdate || isInsert) && newTaskMap.size() <= 0) return;
    
    if (isDelete && oldTaskMap.size() <= 0) return;
    
    Set<Id> caseIdSet = new Set<Id>();
    final Integer MAXSIZE = 400;
    
    final Integer MAX_RECORDS_IN_TASKS_CUSTOM_SETTING = 20;
    
    String s1 = '',
           s2 = '',
           s3 = '',
           s4 = '',
           s5 = '',
           s6 = '',
           s7 = '',
           s8 = '',
           s9 = '',
           s10 = '',
           s11 = '',
           s12 = '',
           s13 = '',
           s14 = '',
           s15 = '',
           s16 = '',
           s17 = '',
           s18 = '',
           s19 = '',
           s20 = '';
    
    Diags.Enter('WorkItemRollupSummary.recalculateFUREmailsSentCount()');
    
    Map<String, Task__c> FUR_Email_Templates_custom_setting = Task__c.getAll();
    
    if (FUR_Email_Templates_custom_setting.size() <= 0) {
      return;
    }
    
    if (FUR_Email_Templates_custom_setting.size() > MAX_RECORDS_IN_TASKS_CUSTOM_SETTING) {
      throw new WorkItemRollupSummaryException('In WorkItemRollupSummary.recalculateFUREmailsSentCount(): FUR Email Templates Custom Setting must have maximum of 20 records');
    }
    
    Set<String> devNames = new Set<String>();
    
    for (String name : FUR_Email_Templates_custom_setting.keySet()){
      devNames.add(FUR_Email_Templates_custom_setting.get(name).Email_Template__c); 
    }
    
    final Map<Id, EmailTemplate> emailTemplateMap = new Map<Id, EmailTemplate>([select Id, Subject from EmailTemplate where DeveloperName IN :devNames]);
    
    if (emailTemplateMap.size() <= 0) return;
    
    Set<String> emailSubjectSet = new Set<String>();
    
    for (Id cid : emailTemplateMap.keySet()){
      if (emailTemplateMap.get(cid).Subject != null && !String.isEmpty(emailTemplateMap.get(cid).Subject)) emailSubjectSet.add(emailTemplateMap.get(cid).Subject); 
    }
    
    if (emailSubjectSet.size() <= 0) return;
    
    if (isInsert) {
      for (Id cid : newTaskMap.keySet()){
        Id nid = newTaskMap.get(cid).WhatId;
        if (nid == null) continue;
        String nstatus = newTaskMap.get(cid).Status;
        String nsubject = (newTaskMap.get(cid).Subject == null ? 'null' : newTaskMap.get(cid).Subject);
        if (nsubject == 'null') continue;
        if (nstatus == 'Completed') {
          for (String cs : emailSubjectSet){
            if (nsubject.contains(cs)){
                caseIdSet.add(nid);
                break;
            }
          }
        }
      }
    }
    else if (isUpdate){
      for (Id cid : newTaskMap.keySet()){
         Id nid = newTaskMap.get(cid).WhatId;
         Id oid = oldTaskMap.get(cid).WhatId;
         if (nid == null && oid == null) continue;
         String nstatus = newTaskMap.get(cid).Status;
         String ostatus = oldTaskMap.get(cid).Status;
         String nsubject = (newTaskMap.get(cid).Subject == null ? 'null' : newTaskMap.get(cid).Subject);
         String osubject = (oldTaskMap.get(cid).Subject == null ? 'null' : oldTaskMap.get(cid).Subject);
         if (nsubject == 'null' && osubject == 'null') continue;
         if ((nsubject != osubject) ||
            (nid != oid) || ((nstatus != ostatus) && (((nstatus == 'Completed') &&
                                                       (ostatus != 'Completed')) ||
                                                      ((ostatus == 'Completed') &&
                                                       (nstatus != 'Completed'))))){
            for (String cs : emailSubjectSet){
              if (nsubject.contains(cs) || osubject.contains(cs)){
                if (nid != null) caseIdSet.add(nid);
                if (oid != null) caseIdSet.add(oid);
                break;
              }
            }
         }     
      }
    }
    else if (isDelete){
      for (Id cid : oldTaskMap.keySet()){
         Id oid = oldTaskMap.get(cid).WhatId;
         if (oid == null) continue;
         String ostatus = oldTaskMap.get(cid).Status;
         String osubject = (oldTaskMap.get(cid).Subject == null ? 'null' : oldTaskMap.get(cid).Subject);
         if (osubject == 'null') continue;
         if (ostatus == 'Completed'){
            for (String cs : emailSubjectSet){
              if (osubject.contains(cs)){
                caseIdSet.add(oid);
                break;
              }
            }
         }     
      }
    }
    else return;
    
    if (caseIdSet.size() <= 0) return;
    
    String whereStr = '';
    
    for (String cs : emailSubjectSet) {
      if (String.isEmpty(s1)){
        s1 = '%' + cs + '%';
        whereStr += ' Or Subject like :s1'; 
      } 
      else if (String.isEmpty(s2)){
        s2 = '%' + cs + '%';
        whereStr += ' Or Subject like :s2'; 
      } 
      else if (String.isEmpty(s3)){
        s3 = '%' + cs + '%';
        whereStr += ' Or Subject like :s3'; 
      } 
      else if (String.isEmpty(s4)){
        s4 = '%' + cs + '%';
        whereStr += ' Or Subject like :s4'; 
      } 
      else if (String.isEmpty(s5)){
        s5 = '%' + cs + '%';
        whereStr += ' Or Subject like :s5'; 
      } 
      else if (String.isEmpty(s6)){
        s6 = '%' + cs + '%';
        whereStr += ' Or Subject like :s6'; 
      } 
      else if (String.isEmpty(s7)){
        s7 = '%' + cs + '%';
        whereStr += ' Or Subject like :s7'; 
      } 
      else if (String.isEmpty(s8)){
        s8 = '%' + cs + '%';
        whereStr += ' Or Subject like :s8'; 
      } 
      else if (String.isEmpty(s9)){
        s9 = '%' + cs + '%';
        whereStr += ' Or Subject like :s9'; 
      } 
      else if (String.isEmpty(s10)){
        s10 = '%' + cs + '%';
        whereStr += ' Or Subject like :s10'; 
      } 
      else if (String.isEmpty(s11)){
        s11 = '%' + cs + '%';
        whereStr += ' Or Subject like :s11'; 
      } 
      else if (String.isEmpty(s12)){
        s12 = '%' + cs + '%';
        whereStr += ' Or Subject like :s12'; 
      } 
      else if (String.isEmpty(s13)){
        s13 = '%' + cs + '%';
        whereStr += ' Or Subject like :s13'; 
      } 
      else if (String.isEmpty(s14)){
        s14 = '%' + cs + '%';
        whereStr += ' Or Subject like :s14'; 
      } 
      else if (String.isEmpty(s15)){
        s15 = '%' + cs + '%';
        whereStr += ' Or Subject like :s15'; 
      } 
      else if (String.isEmpty(s16)){
        s16 = '%' + cs + '%';
        whereStr += ' Or Subject like :s16'; 
      } 
      else if (String.isEmpty(s17)){
        s17 = '%' + cs + '%';
        whereStr += ' Or Subject like :s17'; 
      } 
      else if (String.isEmpty(s18)){
        s18 = '%' + cs + '%';
        whereStr += ' Or Subject like :s18'; 
      } 
      else if (String.isEmpty(s19)){
        s19 = '%' + cs + '%';
        whereStr += ' Or Subject like :s19'; 
      } 
      else if (String.isEmpty(s20)){
        s20 = '%' + cs + '%';
        whereStr += ' Or Subject like :s20'; 
      } 
    }
    
    if (!String.isEmpty(whereStr)) whereStr = whereStr.substring(3);
    
    List<Case> caseList = new List<Case>();
    
    Integer csize = 0;
    
    String soql = 'SELECT WhatId, Count(CreatedDate) cnt0' +
                  ' FROM Task' +
                  ' WHERE WhatId in :caseIdSet AND' +
                  '       Status = \'Completed\' AND' +
                  '       What.Type = \'Case\' AND' +
                  '       (' + whereStr + ')' +
                  ' GROUP BY WhatId';
    
    for (List<AggregateResult> taskList : Database.query(soql)){
       
       if (csize + taskList.size() > MAXSIZE) break;
       
       csize += taskList.size();
       
       for (AggregateResult c : taskList){
         caseList.add(new Case(Id = (Id)c.get('WhatId'), Number_of_FUR_Emails_Sent__c = (Decimal)c.get('cnt0')));
       }                
    }
    
    Boolean isRecalculated = false;
    
    for (Id cid : caseIdSet) {
      isRecalculated = false;
      for (Case cc : caseList) {
        if (cc.Id == cid) isRecalculated = true;
      }
      if (!isRecalculated){
        caseList.add(new Case(Id = cid, Number_of_FUR_Emails_Sent__c = 0));
      }
    }
    
    if (caseList.size() <= 0) return;

    List<Database.SaveResult> results = Database.Update(caseList, false); // allOrNothing = false - partial update will succeed
    
    List<Case> caseLockFailed = new List<Case>();
    List<Case> caseOtherFailed = new List<Case>();
    
    for (Integer i = 0; i < caseList.size(); i++){
       Database.SaveResult r = results[i];
       if (!r.isSuccess()){
          for (Database.Error er : r.getErrors()) {
             if (er.getStatusCode() == StatusCode.UNABLE_TO_LOCK_ROW){
                 caseLockFailed.add(caseList[i]);
                 break;
             }
             else {
                caseOtherFailed.add(caseList[i]);
                Diags.Info('Failed to update Case record Id = ' + caseList[i].Id + ' Error = ' + er.getMessage());
                break;
             } 
          } 
       }
    }
    
    if (caseLockFailed.size() > 0) {
       Diags.Info('Locking errors in WorkItemRollupSummary.recalculateFUREmailsSentCount() detected. Failed records count = ' + caseLockFailed.size() + ' Attempting to recover');
       update caseLockFailed;
    }
    
    if (caseOtherFailed.size() > 0){
      throw new WorkItemRollupSummaryException('In WorkItemRollupSummary.recalculateFUREmailsSentCount(): Failed to update ' + caseOtherFailed.size() + ' Case records');
    }
    
    Diags.Clear();
  }
}