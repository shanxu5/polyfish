/**********************************************************************************************
* @author       Janella Espiritu
* @date         08/29/2014
* @description  This class holds all the processes for UserSkillTrigger
* @version      1.5
* @revision(s)  01.16.2015 J1EU R1 Stabilisation - updated query to look for Parent and added 
                          order for CaseNumber
                Yefim Shuster on 2015-02-18 - PCR 140278 - MBT Reassignment - remove User_Skill_Rule__r.RecordType.Name !=: USR_RECORDTYPE_MBT
                                     query criteria - new version is 1.1
                Yefim Shuster on 2015-02-19 - Defect 139 - Auto assignment does not work if Parent has open bill cycle and child is
                                      canceled or completed - new version is 1.2
                Yefim Shuster on 2015-04-06 - Defect 154 - cannot complete WIs - new version is 1.3
                Yefim Shuster on 2015-05-13 - R2 - refactor Work Item Assignment - new version is 1.4
                Yefim Shuster on 2015-06-03 - R2 - refactor Work Item Assignment - removed assignCases() - new version is 1.5
                Bharghavi Nekkanti on 2015-10-08 -Adding logic for user skill history
**********************************************************************************************/
public class UserSkillTriggerHandler {
    
    /*************************************************************************
    * @author         Yefim Shuster (refactored assignCases by Janella Espiritu)
    * @date           2015-05-13
    * @version        1.0
    * @description    This method checks for unassigned cases, looks for the 
    *           one with the highest priority and assigns to the Work 
    *           Item Assignment records that are updated based on their 
    *           User Skill
    * @parameters    None
    * @revision      Original version
    **************************************************************************/
    public static void assignWIs(){
    
        Diags.Enter('UserSkillTriggerHandler.assignWIs()');
        
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
    * @description    This method is called from UserSkill Trigger and handles all trigger processing
    * @parameters    newUSList - Trigger.new
    *                newUSMap - Trigger.newMap
    *                oldUSList - Trigger.old
    *                oldUSMap - Trigger.oldMap
    *                isBefore - Trigger.isBefore
    *                isUpdate - Trigger.isUpdate
    *                isInsert - Trigger.isInsert
    *                isInsert - Trigger.isDelete
    **************************************************************************/
    public static void handle(List<User_Skill__c> newUSList,
                              Map<Id, User_Skill__c> newUSMap,
                              List<User_Skill__c> oldUSList,
                              Map<Id, User_Skill__c> oldUSMap,
                              Boolean isBefore,
                              Boolean isUpdate,
                              Boolean isInsert,
                              Boolean isDelete){
                              
      try {
      
        Diags.Enter('UserSkillTriggerHandler.handle():IsBefore=' + isBefore + ':IsUpdate=' + isUpdate + ' - newUSList size = ' + (newUSList == null ? 0 : newUSList.size()));
        
        //Set<String> assignmentEnabledWITypes = UserSkillRuleUtility.assignmentEnabled();
        //assignmentEnabledWITypes = UserSkillRuleUtility.getPicklistValues(new Case(), 'Work_Item_Type__c', assignmentEnabledWITypes);
        
        // After DML
        if(!isBefore){
            // On Insert of Record
            if(isInsert){
                // Modified by YXS7 on 2015-05-13 - R2 - refactor Work Item Assignment - commented out and replaced below - new version is 1.4
                //UserSkillTriggerHandler.assignCases(newUSList, assignmentEnabledWITypes);
                UserSkillTriggerHandler.assignWIs();
                UserSkillTriggerHandler.createHistoryTracking(newUSList, 'Insert');
                
            }
            if(isUpdate){
                UserSkillTriggerHandler.createHistoryTracking(newUSList, 'Update');
            }
             if(isDelete){
                UserSkillTriggerHandler.createHistoryTracking(oldUSList, 'Delete');
            }
        }
        
        Diags.Save();
        Diags.Clear();
      }
      catch(Exception e){
        System.debug('***Error in UserSkillTriggerHandler.handle(): ' + e.getMessage());
        Diags.SaveException(e);
        Diags.ClearAll();
        throw e;
      }                     
    }
    /**********************************************************************************************
    * @author       Bhargavi
    * @date         06/16/2015
    * @description  User Skill Trigger handler class for history tracking
    **********************************************************************************************/
    
    public static void createHistoryTracking(List<User_Skill__c> userSkills, String operation){
        Diags.Enter('Inside History Handler----->');
        List<User_Skill_History__c> skillHistories = new List<User_Skill_History__c>();
        User_Skill_History__c skillHistory;
        for(User_Skill__c userSkill:userSkills){
            Diags.Info('userSkill---->'+userSkill);
            skillHistory = new User_Skill_History__c ();
            skillHistory.Logged_in_User__c = UserInfo.getUserId() ;
            skillHistory.Modified_Date__c = System.Now() ;
            skillHistory.Operation__c = operation ;
            skillHistory.User_Skill_Rule__c = userSkill.User_Skill_Rule__c ;
            skillHistory.Work_Item_Assignment__c = userSkill.Work_Item_Assignment__c ;
            Diags.Info('skillHistory---->'+skillHistory);
            skillHistories.add(skillHistory);
        }
        insert skillHistories;
        Diags.Clear();
    }
}