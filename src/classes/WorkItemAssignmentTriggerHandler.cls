/**********************************************************************************************
* @author       Janella Espiritu
* @date         08/26/2014
* @description  This class holds all the processes for WorkItemAssignmentTrigger
* @version      1.6
* @revision(s)  01.16.2015 J1EU R1 Stabilisation - updated query to look for Parent and added order
                    for CaseNumber
                Yefim Shuster on 2015-02-18 - PCR 140278 - MBT Reassignment - remove User_Skill_Rule__r.RecordType.Name !=: USR_RECORDTYPE_MBT
                                     query criteria - new version is 1.1
                Yefim Shuster on 2015-02-19 - Defect 139 - Auto assignment does not work if Parent has open bill cycle and child is
                                      canceled or completed - new version is 1.2
        Joe Kowalsky on 2015-04-06 - Defect 154 - Cannot complete WIs in production.
        Yefim Shuster on 2015-05-06 - added handle() method - new version is 1.3
        Yefim Shuster on 2015-05-13 - R2 - refactor Work Item Assignment - new version is 1.4
        Yefim Shuster on 2015-06-03 - R2 - refactor Work Item Assignment - removed updateHighestPriorityCase() - new version is 1.5
        Yefim Shuster on 2015-07-11 - added isRunning to prevent recursion in After Update - new version is 1.6
**********************************************************************************************/
public class WorkItemAssignmentTriggerHandler {

    private static Boolean isRunning = false;  // prevent recursion in After Update
    
    /*************************************************************************
    * @author         Yefim Shuster (refactored updateHighestPriorityCase by Janella Espiritu)
    * @date           2015-05-06
    * @version        1.0
    * @description    This method checks for unassigned cases, looks for the 
    *           one with the highest priority and assigns to the Work 
    *           Item Assignment records that are updated based on their 
    *           User Skill
    * @parameters    None
    * @revision      Original version
    **************************************************************************/
    public static void assignWIs(){
    
        Diags.Enter('WorkItemAssignmentTriggerHandler.assignWIs()');
        
        List<Case> casesToUpdate = new List<Case>();
        
        List<Case> highestPriorityWIs = WorkItemAssignmentUtility.getHighestPriorityWIs();
        
        if (highestPriorityWIs == null || highestPriorityWIs.size() == 0) return;
        
        Set<Id> parentIds = new Set<Id>();
        
        for(Case c : highestPriorityWIs){
            if(c.ParentId != null){
                parentIds.add(c.ParentId);
            }
            else{
              parentIds.add(c.Id);    
            }
        }
       
        // Query Unassigned Work Items
        Map<Id, Case> allRelatedCasesMap = WorkItemAssignmentUtility.getAssignedOrUnassignedWIsRelatedTo(parentIds);
        
        Map<Id, List<Case>> caseGroupMap = new Map<Id, List<Case>>();
         
        if(allRelatedCasesMap.size() > 0){
          for(Id cid : allRelatedCasesMap.keySet()){
                Case c = allRelatedCasesMap.get(cid);
                if(c.ParentId != null){
                    if(caseGroupMap.containsKey(c.ParentId)){
                        List<Case> temp = caseGroupMap.get(c.ParentId);
                        temp.add(c);
                        caseGroupMap.put(c.ParentId, temp);
                    }
                    else{
                        caseGroupMap.put(c.ParentId, new List<Case>{c});
                    }
                }
                else{
                    if(caseGroupMap.containsKey(c.Id)){
                        List<Case> temp = caseGroupMap.get(c.Id);
                        temp.add(c);
                        caseGroupMap.put(c.Id, temp);
                    }
                    else{
                        caseGroupMap.put(c.Id, new List<Case>{c});
                    }
                } 
          }    
        }
        
        WorkItemAssignmentUtility.performWIAssignment(highestPriorityWIs, caseGroupMap, casesToUpdate);
        
        // If there are highest priority cases to be updated
        if(casesToUpdate.size() > 0){
           Diags.Info('In assignWIs(): update casesToUpdate. size() = ' + casesToUpdate.size());
           update casesToUpdate;
        }
        
        Diags.Clear();
    }
    
    /*************************************************************************
    * @author         Yefim Shuster
    * @date           05/05/2015
    * @description    This method is called from WorkItemAssignment Trigger and handles all trigger processing
    * @version        1.6
    *
    * @parameters    newWIAList - Trigger.new
    *                newWIAMap - Trigger.newMap
    *                oldWIAList - Trigger.old
    *                oldWIAMap - Trigger.oldMap
    *                isBefore - Trigger.isBefore
    *                isUpdate - Trigger.isUpdate
    *                isInsert - Trigger.isInsert
    *
    * @revision(s)  added isRunning to prevent recursion in After Update - new version is 1.6
    **************************************************************************/
    public static void handle(List<Work_item_Assignment__c> newWIAList,
                              Map<Id, Work_item_Assignment__c> newWIAMap,
                              List<Work_item_Assignment__c> oldWIAList,
                              Map<Id, Work_item_Assignment__c> oldWIAMap,
                              Boolean isBefore,
                              Boolean isUpdate,
                              Boolean isInsert){
           
      try {
      
        Diags.Enter('WorkItemAssignmentTriggerHandler.handle():IsBefore=' + isBefore + ':IsUpdate=' + isUpdate + ' - newWIAList size = ' + (newWIAList == null ? 0 : newWIAList.size()));
                           
        List<Work_item_Assignment__c> wiaUpdated = new List<Work_item_Assignment__c>();
        
        // Modified by YXS7 on 2015-05-06 - R2 - no longer using Assignment Enabled Custom Settings - commented out below - new version is 1.3
        //Set<String> assignmentEnabledWITypes = UserSkillRuleUtility.assignmentEnabled();
        //assignmentEnabledWITypes = UserSkillRuleUtility.getPicklistValues(new Case(), 'Work_Item_Type__c', assignmentEnabledWITypes);
        
        // Before DML
        if(isBefore){
            
        }
        // After DML
        if(!isBefore){
            // If trigger is Insert, pass created list to the trigger handler
            if(isInsert){
                // Modified by YXS7 on 2015-05-06 - R2 - refactor Work Item Assignment - commented out and replaced below - new version is 1.3
                //WorkItemAssignmentTriggerHandler.updateHighestPriorityCase(newWIAList,assignmentEnabledWITypes);
                WorkItemAssignmentTriggerHandler.assignWIs();
            }
            // If trigger is Update
            if(isUpdate){
                if(!isRunning){
                    
                    isRunning = true;
                    
                    // Loop updated Work Item Assignments
                    for(Work_item_Assignment__c wia : newWIAList){
                        // If current work item assignment load score is less than 100
                        if(wia.Load_Score__c < 100){
                            // Check if Availability, Load Score, Limit or WI Assigned are changed
                            if((wia.Availability__c && !oldWIAMap.get(wia.Id).Availability__c) 
                               || (wia.Load_Score__c != oldWIAMap.get(wia.Id).Load_Score__c)){
                                   // Add current work item assignment to list
                                   wiaUpdated.add(wia);
                               }
                        }
                    }
                    // If wiaUpdated list is not empty, pass the list to the trigger handler
                    if(wiaUpdated.size() > 0){
                        // Modified by YXS7 on 2015-05-06 - R2 - refactor Work Item Assignment - commented out and replaced below - new version is 1.3
                        //WorkItemAssignmentTriggerHandler.updateHighestPriorityCase(wiaUpdated,assignmentEnabledWITypes);
                        WorkItemAssignmentTriggerHandler.assignWIs();
                    }
                }
            }  
        }
        
        isRunning = false;
        
        Diags.Save();
        Diags.Clear();
      }
      catch(Exception e){
        System.debug('***Error in WorkItemAssignmentTriggerHandler.handle(): ' + e.getMessage());
        Diags.SaveException(e);
        Diags.ClearAll();
        throw e;
      }                      
    }
}