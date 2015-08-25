/**********************************************************************************************
* @author       Yefim Shuster
* @date         02/18/2015
* @description  This class holds all utility methods and cached queries for Work Item Assignment Engine
* @revision(s)  Original
* @version      1.9
*
*               Modified by YXS7 on 2015-04-06 - Defect 154 - added new getOpenBillCycleUSRIds method - new version is 1.1
*               Modified by YXS7 on 2015-04-30 - R2 - added getUnassignedHighestPriorityWIs() - new version is 1.2
*               Modified by YXS7 on 2015-05-04 - R2 - updated getUnassignedHighestPriorityWIs() - new version is 1.3
*               Modified by YXS7 on 2015-05-12 - R2 - added WIA refactoring methods - new version is 1.4
*       Modified by J1EU on 2015-05-21 - R2 - added new getCSRProfileId method - new version is 1.5
*               Modified by YXS7 on 2015-05-26 - R2 - added cache for getHighestPriorityWIs() and updated performWIAssignment() - new version is 1.6
*               Modified by YXS7 on 2015-05-28 - added User_Skill_Rule__r.AssignmentEnabled__c = true
*                    to where clause - Parent WIs must have AssignmentEnabled__c = true on their USR records - new version is 1.7
*               Modified by YXS7 on 2015-06-01 - added getBillCycleWindowNotAssignedRecordTypeId() and getBillCycleWindowDefaultRecordTypeId()
*                    new version is 1.8
*               Modified by YXS7 on 2015-07-01 - removed RecordTypeId IN :recordTypeIdSet filter criteria in getHighestPriorityWIs() 
*                    and in getAssignedOrUnassignedWIsRelatedTo() - no longer needed in R2 - new version is 1.9
**********************************************************************************************/
public without sharing class WorkItemAssignmentUtility {
    
    // Cached values initialized lazily
    private static Boolean MBTQueueIdCached = false;
    private static Id MBTQueueId = null;
    
    private static Boolean BillingExceptionQueueIdCached = false;
    private static Id BillingExceptionQueueId = null;
    
    private static Boolean DuplicateExceptionQueueIdCached = false;
    private static Id DuplicateExceptionQueueId = null;
    
  //Janella Espiritu 5/21/2015
  private static Boolean CSRProfileIdCached = false;
    private static Id CSRProfileId = null;
  //Janella Espiritu 6/17/2015
  private static Boolean SSRProfileIdCached = false;
    private static Id SSRProfileId = null;
  //Janella Espiritu 07/09/2015
  private static Boolean IntegrationProfileIdCached = false;
    private static Id IntegrationProfileId = null;
    
    //Tae 8/10/2015 add system admin
    private static Boolean SysAdminProfileIdCached = false;
    private static Id SysAdminProfileId = null;
    
    private static Set<String> openBillCycleUSRS = new Set<String>();
    private static Boolean openBillCycleUSRSCached = false;
    
    private static Set<String> openBillCycles = new Set<String>();
    private static Boolean openBillCyclesCached = false;
    
    private static Set<Id> openBillCycleUSRIds = new Set<Id>();
    private static Boolean openBillCycleUSRSIdsCached = false;
    
    private static Boolean FastSlowToDoQueueIdCached = false; // J1EU 05/08/2015 - added 
    private static Id FastSlowToDoQueueId = null; // J1EU 05/08/2015 - added 
    
  private static Boolean FastSlowToDoGasUSRIdCached = false; // J1EU 05/08/2015 - added 
    private static Id FastSlowToDoGasUSRId = null; // J1EU 05/08/2015 - added
  
    private static Boolean FloorSupportQueueIdCached = false; // J1EU 05/29/2015 - added 
    private static Id FloorSupportQueueId = null; // J1EU 05/29/2015 - added 
    
    private static Map<Id, Work_Item_Assignment__c> availableCSRsMap = new Map<Id, Work_Item_Assignment__c>();
    private static Boolean availableCSRsCached = false;
    
    private static Map<Id, User_Skill__c> userSkillsForAvailableCSRsMap = new Map<Id, User_Skill__c>();
    private static Boolean userSkillsForAvailableCSRsCached = false;
    
    private static List<Case> highestPriorityWIsList = new List<Case>();
    private static Boolean highestPriorityWIsCached = false;
    
    private static Map<Id, Case> WIsRelatedToOpenBillCyclesMap = new Map<Id, Case>();
    private static Boolean WIsRelatedToOpenBillCyclesCached = false;
    
    private static Map<Id, Case> assignedOrUnassignedWIsRelatedToMap = new Map<Id, Case>();
    private static Boolean assignedOrUnassignedWIsRelatedToCached = false;
    
    private static final String RECORDTYPE_BCW_NOT_ASSIGNED = 'Not Assigned User Skill Rule';
    private static final String RECORDTYPE_BCW_DEFAULT = 'Bill Cycle Windows';
    private static final String RECORDTYPE_CCB_CASES = 'CC&B Billing Ops Cases';
    
    private static Boolean CPUTimeCached = false; // J1EU 07/20/2015 - added 
    private static Integer CPUTime = 0; // J1EU 07/20/2015 - added 
    private static Integer CPUTimeOld = 0; // J1EU 07/20/2015 - added 
    
    public static Integer getCPUTime(Integer CPUTimeNew){
        if (CPUTimeCached){
            CPUTime = CPUTimeNew - CPUTimeOld;
            CPUTimeOld = CPUTimeNew;
        }
        else{
            CPUTime = CPUTimeNew - CPUTime;
            CPUTimeOld = CPUTimeNew;
            CPUTimeCached = true;
        } 
     return CPUTime;
  }
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           05/08/2015
    * @description    This method obtains MBT Queue Id from cache or from SObject
    * @parameters    None
    **************************************************************************/
  public static Id getFastSlowToDoQueueId(){
     if (FastSlowToDoQueueIdCached) return FastSlowToDoQueueId;
       
     FastSlowToDoQueueId = [select Id from Group where Name = 'Fast Slow To Dos' and Type = 'Queue'].Id;
       
     FastSlowToDoQueueIdCached = true;
       
     return FastSlowToDoQueueId;
  }
  /*************************************************************************
    * @author         Janella Espiritu
    * @date           05/08/2015
    * @description    This method obtains MBT Queue Id from cache or from SObject
    * @parameters    None
    **************************************************************************/
  public static Id getFastSlowToDoGasUSRId(){
     if (FastSlowToDoGasUSRIdCached) return FastSlowToDoGasUSRId;
       
     FastSlowToDoGasUSRId = [select Id from User_Skill_Rule__c where Name = 'Fast/Slow Meter Adj - Gas'].Id;
       
     FastSlowToDoGasUSRIdCached = true;
       
     return FastSlowToDoGasUSRId;
  }
  /*************************************************************************
    * @author         Janella Espiritu
    * @date           05/08/2015
    * @description    This method obtains the CSR Profile from cache or from SObject
    * @parameters    None
    **************************************************************************/
  public static Id getCSRProfileId(){
     if (CSRProfileIdCached) return CSRProfileId;
       
     CSRProfileId = [select id from Profile where Name='CSR'].Id;
       
     CSRProfileIdCached = true;
       
     return CSRProfileId;
  }
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           07/09/2015
    * @description    This method obtains the Integration Profile from cache or from SObject
    * @parameters    None
    **************************************************************************/
  public static Id getIntegrationProfileId(){
     if (IntegrationProfileIdCached) return IntegrationProfileId;
       
     IntegrationProfileId = [select id from Profile where Name='Integration'].Id;
       
     IntegrationProfileIdCached = true;
       
     return IntegrationProfileId;
  }
    
    /*************************************************************************
    * @author         Tae Tran
    * @date           8/10/2015
    * @description    This method obtains the Sys Admin Profile from cache or from SObject
    * @parameters    None
    **************************************************************************/
  public static Id getSysAdminProfileId(){
     if (SysAdminProfileIdCached) return SysAdminProfileId;
       
     SysAdminProfileId = [select id from Profile where Name='System Administrator'].Id;
       
     SysAdminProfileIdCached = true;
       
     return SysAdminProfileId;
  }
    
  /*************************************************************************
    * @author         Janella Espiritu
    * @date           05/08/2015
    * @description    This method obtains the SSR Profile from cache or from SObject
    * @parameters    None
    **************************************************************************/
  public static Id getSSRProfileId(){
     if (SSRProfileIdCached) return SSRProfileId;
       
     SSRProfileId = [select id from Profile where Name='SSR'].Id;
       
     SSRProfileIdCached = true;
       
     return SSRProfileId;
  }
    /*************************************************************************
    * @author         Yefim Shuster
    * @date           02/18/2015
    * @description    This method obtains MBT Queue Id from cache or from SObject
    * @parameters    None
    **************************************************************************/
  public static Id getMBTQueueId(){
     if (MBTQueueIdCached) return MBTQueueId;
     
     MBTQueueId = [select Id from Group where Name = 'BSEG MBT Elec SM30 SM40' and Type = 'Queue'].Id;
     
     MBTQueueIdCached = true;
     
     return MBTQueueId;
  }
  /*************************************************************************
    * @author         Janella Espiritu
    * @date           05/29/2015
    * @description    This method obtains Floor Support Queue Id from cache or from SObject
    * @parameters    None
    **************************************************************************/
  public static Id getFloorSupportQueueId(){
     if (FloorSupportQueueIdCached) return FloorSupportQueueId;
     
     FloorSupportQueueId = [select Id from Group where Name = 'BSEG MBT Elec SM30 SM40' and Type = 'Queue'].Id;
     
     FloorSupportQueueIdCached = true;
     
     return FloorSupportQueueId;
  }
  /*************************************************************************
    * @author         Yefim Shuster
    * @date           02/18/2015
    * @description    This method obtains Billing Exceptions Queue Id from cache or from SObject
    * @parameters    None
    **************************************************************************/
  public static Id getBillingExceptionQueueId(){
     if (BillingExceptionQueueIdCached) return BillingExceptionQueueId;
     
     BillingExceptionQueueId = [select Id from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
     
     BillingExceptionQueueIdCached = true;
     
     return BillingExceptionQueueId;
  }
  
  /*************************************************************************
    * @author         Yefim Shuster
    * @date           02/18/2015
    * @description    This method obtains Duplicate Exceptions Queue Id from cache or from SObject
    * @parameters    None
    **************************************************************************/
  public static Id getDuplicateExceptionQueueId(){
     if (DuplicateExceptionQueueIdCached) return DuplicateExceptionQueueId;
     
     DuplicateExceptionQueueId = [select Id from Group where Name = 'Duplicate Exceptions' and Type = 'Queue'].Id;
     
     DuplicateExceptionQueueIdCached = true;
     
     return DuplicateExceptionQueueId;
  }
  
  /*************************************************************************
   * @author         Yefim Shuster
   * @date           06/01/2015
   * @description    This method will return Record Type Id for Bill Cycle Window Not Assigned Bill Cycles record type
   * @parameters    None
   **************************************************************************/
    public static Id getBillCycleWindowNotAssignedRecordTypeId(){
       return Schema.SObjectType.Bill_Cycle_Window__c.getRecordTypeInfosByName().get(RECORDTYPE_BCW_NOT_ASSIGNED).getRecordTypeId();
    }
    
    /*************************************************************************
   * @author         Yefim Shuster
   * @date           06/01/2015
   * @description    This method will return Record Type Id for Bill Cycle Window Default record type
   * @parameters    None
   **************************************************************************/
    public static Id getBillCycleWindowDefaultRecordTypeId(){
       return Schema.SObjectType.Bill_Cycle_Window__c.getRecordTypeInfosByName().get(RECORDTYPE_BCW_DEFAULT).getRecordTypeId();
    }

    /*************************************************************************
   * @author         Janella Espiritu
   * @date           07/29/2015
   * @description    This method will return Record Type Id for CC&B Billing Ops Cases record type
   * @parameters    None
   **************************************************************************/
    public static Id getCCBCasesRecordTypeId(){
       return Schema.SObjectType.Case.getRecordTypeInfosByName().get(RECORDTYPE_CCB_CASES).getRecordTypeId();
    }
    
  /*************************************************************************
    * @author         Yefim Shuster
    * @date           02/19/2015
    * @description    This method will query User Skill Rules that will not be assigned if Bill Cycle is open - or get the list from cache
    * @parameters    None
    **************************************************************************/
  public static Set<String> getOpenBillCycleUSRs(){
     if (openBillCycleUSRSCached) return openBillCycleUSRS;
       
      for(Bill_Cycle_Window__c bcw : [select User_Skill_Rule__r.Name from Bill_Cycle_Window__c where RecordType.DeveloperName = 'Not_Assigned_User_Skill_Rule']){
          openBillCycleUSRS.add(bcw.User_Skill_Rule__r.Name);
      }
      
      openBillCycleUSRSCached = true;
      
      return openBillCycleUSRS;
   }
   
   /*************************************************************************
    * @author         Yefim Shuster
    * @date           02/19/2015
    * @description    This method will query Open Bill Cycle Windows and collect Primary Bill Cycle Names - or get the list from cache
    * @parameters    None
    **************************************************************************/
  public static Set<String> getOpenBillCycles(){
     if (openBillCyclesCached) return openBillCycles;
       
      for(Bill_Cycle_Window__c bcw : [select Primary_Bill_Cycle__c 
                        from Bill_Cycle_Window__c
                       where Window_Start_Date__c <=: date.today()
                       and Window_Close_Date__c >=: date.today()]){
            openBillCycles.add(bcw.Primary_Bill_Cycle__c);
        }
      
      openBillCyclesCached = true;
      
      return openBillCycles;
   }
   
   /*************************************************************************
    * @author         Yefim Shuster
    * @date           04/06/2015
    * @description    This method will query User Skill Rules that will not be assigned if Bill Cycle is open - or get the list from cache
    * @parameters    None
    **************************************************************************/
    public static Set<Id> getOpenBillCycleUSRIds(){
     if (openBillCycleUSRSIdsCached) return openBillCycleUSRIds;
       
      for(Bill_Cycle_Window__c bcw : [select User_Skill_Rule__c from Bill_Cycle_Window__c where RecordType.DeveloperName = 'Not_Assigned_User_Skill_Rule']){
          openBillCycleUSRIds.add(bcw.User_Skill_Rule__c);
      }
      
      openBillCycleUSRSIdsCached = true;
      
      return openBillCycleUSRIds;
   }
   
    /*************************************************************************
    * @author         Yefim Shuster
    * @date           04/06/2015
    * @description    This method will return Record Type Id for Case Billing Exceptions Record Type
    * @parameters    None
    **************************************************************************/
    public static Id getCaseBillingExceptionsRecordTypeId(){
       return Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.RECORDTYPE_BILLING_EXCEPTIONS).getRecordTypeId();
    }
   
   /*************************************************************************
    * @author         Yefim Shuster
    * @date           04/06/2015
    * @description    This method will return Record Type Id for Case Mailbox Record Type
    * @parameters    None
    **************************************************************************/
    public static Id getCaseMailboxRecordTypeId(){
     return Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.RECORDTYPE_MAILBOX).getRecordTypeId();
    }
    
        /*************************************************************************
    * @author         Yefim Shuster
    * @date           04/30/2015
    * @description    This method will return a Map of Available CSRs - map keys are
    *                   Work_Item_Assignment__c Ids and values are Work_Item_Assignment__c records
    * @parameters     none  
    *  
    **************************************************************************/
    public static Map<Id, Work_Item_Assignment__c> getAvailableCSRs(){
        if (availableCSRsCached) return availableCSRsMap;
        
        availableCSRsMap = new Map<Id, Work_Item_Assignment__c>([select Id, 
                                             Load_Score__c, 
                                             WI_Assigned__c, 
                                             Limit__c, 
                                             User__c, 
                                             User__r.Supervisor__c, 
                                             User__r.Supervisor__r.Email 
                                            from Work_Item_Assignment__c 
                                            where Load_Score__c < 100
                                            and Availability__c = true
                                            order by Load_Score__c ASC]);
                                            
       availableCSRsCached = true;
       
       return availableCSRsMap;
    }

   /*************************************************************************
    * @author         Yefim Shuster
    * @date           05/06/2015
    * @description    This method will return a Map of User Skills for available CSRs - map keys are
    *                   User_Skill__c Ids and values are User_Skill__c records
    * @parameters     workItemAssignmentIds - Set<Id> containing Ids of Work_Item_Assignment__c  
    * @revisions      Modified by YXS7 on 2015-05-26 - removed User_Skill_Rule__r.AssignmentEnabled__c = true
    *                    from where clause - this check will be done in performWIAssignment
    *                 Modified by YXS7 on 2015-05-28 - added User_Skill_Rule__r.AssignmentEnabled__c = true
    *                    to where clause - Parent WIs must have AssignmentEnabled__c = true on their USR records
    **************************************************************************/
    public static Map<Id, User_Skill__c> getUserSkillsForAvailableCSRs(Set<Id> workItemAssignmentIds){
        if (userSkillsForAvailableCSRsCached) return userSkillsForAvailableCSRsMap;
        
        userSkillsForAvailableCSRsMap = new Map<Id, User_Skill__c>([Select Id, 
                      Work_Item_Assignment__r.User__c,
                      Work_Item_Assignment__r.User__r.Supervisor__c,
                      Work_Item_Assignment__r.User__r.Supervisor__r.Email, 
                      Work_Item_Assignment__c,
                      User_Skill_Rule__c,
                      User_Skill_Rule__r.AssignmentEnabled__c,
                      Work_Item_Assignment__r.Load_Score__c,
                      Work_Item_Assignment__r.WI_Assigned__c,
                      Work_Item_Assignment__r.Limit__c
                      from User_Skill__c 
                      where Work_Item_Assignment__c IN :workItemAssignmentIds
                        and User_Skill_Rule__r.AssignmentEnabled__c = true
                      order by Work_Item_Assignment__r.Load_Score__c ASC]);
                      
       userSkillsForAvailableCSRsCached = true;
       
       return userSkillsForAvailableCSRsMap;
    }
    
    /*************************************************************************
    * @author         Yefim Shuster
    * @date           04/30/2015
    * @description    This method will return a Map of WIs related to Open Bill Cycles - map keys are
    *                   WI Ids and values are Case records
    * @parameters     none  
    * @revisions      YXS7 on 2015-05-26 - cache query results
    **************************************************************************/
    public static Map<Id, Case> getWIsRelatedToOpenBillCycles(){
    
        if (WIsRelatedToOpenBillCyclesCached) return WIsRelatedToOpenBillCyclesMap;
        
        Set<Id> l_openBillCycleUSRIds = WorkItemAssignmentUtility.getOpenBillCycleUSRIds();
        
        Set<String> l_openBillCycles = WorkItemAssignmentUtility.getOpenBillCycles();
        
        Id l_billingExceptionsQueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        
        WIsRelatedToOpenBillCyclesMap = new Map<Id, Case>([select Id, ParentId, Bill_Cycle__c, User_Skill_Rule__r.Name
                                 from Case 
                                 where ((IsParent__c = false
                                         and Parent.Bill_Cycle__c IN :l_openBillCycles
                                         and Parent.User_Skill_Rule__c IN :l_openBillCycleUSRIds
                                         and Parent.Hold__c = false
                                         ) 
                                         OR (IsParent__c = true
                                             and Bill_Cycle__c IN :l_openBillCycles
                                             and User_Skill_Rule__c IN :l_openBillCycleUSRIds
                                             and Hold__c = false
                                        )) 
                                        and Hold__c = false
                                        and IsClosed = false
                                        and OwnerId = :l_billingExceptionsQueueId 
                                   ]);
                                   
        WIsRelatedToOpenBillCyclesCached = true;
        
        return WIsRelatedToOpenBillCyclesMap;
    }
    
    /*************************************************************************
    * @author         Yefim Shuster
    * @date           05/08/2015
    * @description    This method will return a Map of Assigned or Unassigned WIs related to WIs in relatedWIs Set - map keys are
    *                   WI Ids and values are Case records
    * @parameters     relatedWIs - set of WIs IDs to lookup  
    * @revisions      YXS7 on 2015-05-26 - cache query results
    * @revisions      YXS7 on 2015-05-26 - added User_Skill_Rule__r.AssignmentEnabled__c
    *                 YXS7 on 2015-07-01 - removed RecordTypeId IN :recordTypeIdSet filter criteria - no longer needed in R2
    **************************************************************************/
    public static Map<Id, Case> getAssignedOrUnassignedWIsRelatedTo(Set<Id> relatedWIs){
    
        if (assignedOrUnassignedWIsRelatedToCached) return assignedOrUnassignedWIsRelatedToMap;
        
        // Modified by YXS7 on 2015-07-01 - removed RecordTypeId IN :recordTypeIdSet filter criteria - no longer needed in R2 - commented out below
        //Set<Id> recordTypeIdSet = new Set<Id>{WorkItemAssignmentUtility.getCaseBillingExceptionsRecordTypeId(),WorkItemAssignmentUtility.getCaseMailboxRecordTypeId()};
        
        Id billingExceptionsQueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        
        assignedOrUnassignedWIsRelatedToMap = new Map<Id, Case>([select Id, 
                                          Priority_Score__c, 
                                          User_Skill_Rule__c,
                                          User_Skill_Rule__r.Name,
                                          User_Skill_Rule__r.AssignmentEnabled__c, 
                                          Work_Item_Type__c,
                                          ParentId,
                                          Parent.User_Skill_Rule__c,
                                          Parent.Work_Item_Type__c,
                                          Bill_Cycle__c,
                                          Age__c,
                                          SA_Type__c
                                      from Case 
                                      where Status IN (:System.Label.STATUS_UNASSIGNED, :System.Label.STATUS_ASSIGNED)
                                      and ((IsParent__c = false AND ParentId IN :relatedWIs) OR (IsParent__c = true AND Id IN :relatedWIs))
                                      and Hold__c = false
                                      and OwnerId = :billingExceptionsQueueId
                                      order by Priority_Score__c DESC, CaseNumber ASC]);
                                      
        assignedOrUnassignedWIsRelatedToCached = true;
        
        return assignedOrUnassignedWIsRelatedToMap;
    } 
    
    /*************************************************************************
    * @author         Yefim Shuster
    * @date           04/30/2015
    * @description    This method will return Unassigned Highest Priority WIs based on passed in criteria
    * @parameters     
    *                 WIStatus - WI Status of WIs to include
    *                 userSkillRuleIds - set of Parent WI's USR Ids to include
    *                 assignmentEnabledWITypes - set of WI Types that are enabled for Assignment
    *                 recordTypeIdSet - set of WI Record Type Ids to include
    *                 excludeWIsIdset - set of WI Ids to exclude from the result set - these could be WI with Open Bill Cycles or others to disregard
    *                 billingExceptionsQueueId - ID of Billing Exceptions Queue
    *                 limitSize - maximum number of WIs to include into result set
    *
    * @revisions      YXS7 on 2015-05-26 - cache query results
    *                 YXS7 on 2015-07-01 - removed RecordTypeId IN :recordTypeIdSet filter criteria - no longer needed in R2
    **************************************************************************/
    public static List<Case> getHighestPriorityWIs(){
    
      Diags.Enter('WorkItemAssignmentUtility.getHighestPriorityWIs()');
      
      if (highestPriorityWIsCached) return highestPriorityWIsList;
      
      //set of WI Ids to exclude from the result set - these could be WI with Open Bill Cycles or others to disregard
      Set<Id> excludeWIsIdset = new Set<Id>();
      
      //set of Parent WI's USR Ids to include
      Set<Id> userSkillRuleIds = new Set<Id>();
      
      // Modified by YXS7 on 2015-07-01 - removed RecordTypeId IN :recordTypeIdSet filter criteria - no longer needed in R2 - commented out below
      //Set<Id> recordTypeIdSet = new Set<Id>{WorkItemAssignmentUtility.getCaseBillingExceptionsRecordTypeId(),WorkItemAssignmentUtility.getCaseMailboxRecordTypeId()};
      
      Id billingExceptionsQueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
      
      //maximum number of WIs to include into result set
      Integer limitSize = 0;
      
      Map<Id, Work_Item_Assignment__c> l_availableCSRsMap = WorkItemAssignmentUtility.getAvailableCSRs();
      
      if (l_availableCSRsMap.size() <= 0) return new List<Case>();
      
      for(Id wid : l_availableCSRsMap.keySet()){
          limitSize += Integer.valueOf(l_availableCSRsMap.get(wid).Limit__c - l_availableCSRsMap.get(wid).WI_Assigned__c);
      }
        
      if(limitSize <= 0){
         limitSize = 0;
      }
      
      Map<Id, User_Skill__c> userSkillsForAvailableCSRs = WorkItemAssignmentUtility.getUserSkillsForAvailableCSRs(l_availableCSRsMap.keySet());
      
      if (userSkillsForAvailableCSRs.size() <= 0) return new List<Case>();
      
      for (Id usid : userSkillsForAvailableCSRs.keySet()){
        userSkillRuleIds.add(userSkillsForAvailableCSRs.get(usid).User_Skill_Rule__c);
      }
      
      if (userSkillRuleIds.size() <= 0) return new List<Case>();
      
      Map<Id, Case> WIsRelatedToOpenBillCycles = WorkItemAssignmentUtility.getWIsRelatedToOpenBillCycles();
      
      Map<Id, List<Case>> openBillCycleMap = new Map<Id, List<Case>>();
                                               
      if(WIsRelatedToOpenBillCycles.size() > 0){
          for(Id cid : WIsRelatedToOpenBillCycles.keySet()){
              // If the work item has a Parent, add the current work item to the list
              Case c = WIsRelatedToOpenBillCycles.get(cid);
              if(c.ParentId != null){
                  if(openBillCycleMap.containsKey(c.ParentId)){
                      List<Case> temp = openBillCycleMap.get(c.ParentId);
                      temp.add(c);
                      openBillCycleMap.put(c.ParentId, temp);
                  }
                  else{
                      openBillCycleMap.put(c.ParentId, new List<Case> {c});
                  }
              }
              //if the work item doesn't have a ParentId, add it to the map with empty list
              else{
                  if(!openBillCycleMap.containsKey(c.Id)){
                      openBillCycleMap.put(c.Id, new List<Case>());
                  }
              }
          }
      }
      
      // Query Open Bill Cycle Windows and collect Primary Bill Cycle Names
      Set<String> l_openBillCycles = WorkItemAssignmentUtility.getOpenBillCycles();
      
      // Query User Skill Rules that will not be assigned if Bill Cycle is open
      Set<String> l_openBillCycleUSRS = WorkItemAssignmentUtility.getOpenBillCycleUSRs();
        
      for(Id i : openBillCycleMap.keySet()){
          // If the Map returns an empty list, it means it is not grouped. Do not assign.
          if(openBillCycleMap.get(i) == null || openBillCycleMap.get(i).size() == 0){
              excludeWIsIdset.add(i);
          }
          else if(openBillCycleMap.get(i).size() > 0){
               List<Case> childCases = openBillCycleMap.get(i);
               boolean allAreOpen = true;
               for (Case c : childCases){
                 if(!(l_openBillCycles.contains(c.Bill_Cycle__c) && l_openBillCycleUSRS.contains(c.User_Skill_Rule__r.Name))){
                   allAreOpen = false;
                 }
               }
               if (allAreOpen) {
                 excludeWIsIdset.add(i); // Add Parent Id to excludeWIsIdset as well  
                 for (Case c : childCases){
                   excludeWIsIdset.add(c.Id);
                 }
               }
           }
       }
       
      //Diags.Info('userSkillRuleIds = ' + userSkillRuleIds +
      //   ' excludeWIsIdset = ' + excludeWIsIdset +
      //   ' billingExceptionsQueueId = ' + billingExceptionsQueueId + ' limitSize = ' + limitSize);
      
      // Call Diags.Save() in higher level method, e.g. Trigger or Trigger Handler
      //Diags.Save();
      
      Diags.Clear();
      
      highestPriorityWIsList = [select Id, 
                      Priority_Score__c, 
                      User_Skill_Rule__c,
                      User_Skill_Rule__r.Name,
                      Work_Item_Type__c,
                      Approver_Reviewer__c,
                      Approver_Reviewer_Email__c,
                      Bill_Cycle__c,
                      Age__c,
                      SA_Type__c,
                      ParentId,
                      Parent.User_Skill_Rule__c,
                      Parent.Work_Item_Type__c,
                      User_Skill_Rule__r.AssignmentEnabled__c,
                      Parent.User_Skill_Rule__r.AssignmentEnabled__c
                     from Case 
                     where 
                     ((IsParent__c = true and User_Skill_Rule__c IN :userSkillRuleIds) or
                      (IsParent__c = false and Parent.User_Skill_Rule__c IN :userSkillRuleIds))
                      and Status = :System.Label.STATUS_UNASSIGNED
                      and Id NOT IN :excludeWIsIdset 
                      and Hold__c = false
                      and OwnerId = :billingExceptionsQueueId
                      order by Priority_Score__c DESC, CaseNumber ASC
                      limit :limitSize];
                      
      highestPriorityWIsCached = true;
      
      return highestPriorityWIsList;
   }
   
   /*************************************************************************
    * @author         Yefim Shuster
    * @date           05/12/2015
    * @description    This method will perform WI Assignment
    * @parameters     
    *                 highestPriorityWorkItems - list of WI to assign
    *                 caseGroupMap - map of grouped WI from highestPriorityWorkItems list
    *                 casesToUpdate - list of updated WI to update Case object
    *
    * @revisions      YXS7 on 2015-05-26 - add check for User_Skill_Rule__r.AssignmentEnabled__c
    **************************************************************************/
   public static void performWIAssignment(List<Case> highestPriorityWorkItems, Map<Id, List<Case>> caseGroupMap, List<Case> casesToUpdate){
       Diags.Enter('WorkItemAssignmentUtility.performWIAssignment()');
       
       Map<Id, Work_Item_Assignment__c> l_availableCSRsMap = WorkItemAssignmentUtility.getAvailableCSRs();
       
       if (l_availableCSRsMap == null || l_availableCSRsMap.size() == 0) return;
       
       Map<Id, User_Skill__c> userSkillsForAvailableCSRs = WorkItemAssignmentUtility.getUserSkillsForAvailableCSRs(l_availableCSRsMap.keySet());
       
       if (userSkillsForAvailableCSRs == null || userSkillsForAvailableCSRs.size() == 0) return;
       
       Map<Id, List<User_Skill__c>> userSkillMap = new Map<Id, List<User_Skill__c>>();
       Map<Id, User_Skill__c> usMap = new Map<Id, User_Skill__c>();
       
       for(Id usid : userSkillsForAvailableCSRs.keySet()){
            User_Skill__c us = userSkillsForAvailableCSRs.get(usid);
            
            usMap.put(us.User_Skill_Rule__c, us);
            
            // Create a map of each Work Item Assignment and the list of all User Skills under it
            if(userSkillMap.containsKey(us.Work_Item_Assignment__c)){
                List<User_Skill__c> temp = userSkillMap.get(us.Work_Item_Assignment__c);
                temp.add(us);
                userSkillMap.put(us.Work_Item_Assignment__c, temp);
            }
            else{
                userSkillMap.put(us.Work_Item_Assignment__c, new List<User_Skill__c> {us});
            }
        }
          
        Set<String> l_openBillCycles = WorkItemAssignmentUtility.getOpenBillCycles();
      
        Set<Id> l_openBillCycleUSRIds = WorkItemAssignmentUtility.getOpenBillCycleUSRIds();
        
        List<User_Skill__c> tempUS = new List<User_Skill__c>();
        Set<Id> updatedCaseIds = new Set<Id>();
        Set<Id> userSkills = new Set<Id>();
       
       // Loop all Available Work Item Assignment records
        for(Id wiaid : l_availableCSRsMap.keySet()){
            Work_Item_Assignment__c wia = l_availableCSRsMap.get(wiaid);
            userSkills.clear();
            
            Decimal availableSlots = wia.Limit__c - wia.WI_Assigned__c;
            
            // Retrieve User Skill records for the current Work Item Assignment
            if(userSkillMap.containsKey(wia.Id)){
                // get the list of User Skills for the current Work Item
                tempUS = userSkillMap.get(wia.Id);
                // Loop User Skills for the current work Item Assignment
                for(User_Skill__c us : tempUS){
                    userSkills.add(us.User_Skill_Rule__c);
                }
                
                // Loop highest priority work items
                for(Case c : highestPriorityWorkItems){
                    //system.debug('availableSlots: '+availableSlots);
                    // Proceed if current work item assignment has availability
                    if(availableSlots > 0 ){
                        if(!updatedCaseIds.contains(c.Id)){
                            // If current work item is a member of a group
                            if(c.ParentId != null){
                                if(userSkills.contains(c.Parent.User_Skill_Rule__c)){
                                    User_Skill__c tempUserSkill = usMap.get(c.Parent.User_Skill_Rule__c);
                                    if(caseGroupMap.containsKey(c.ParentId)){
                                        List<Case> wiGroup = caseGroupMap.get(c.ParentId);
                                          for(Case wi : wiGroup){
                                              if(wi.User_Skill_Rule__r.AssignmentEnabled__c){
                                                  wi.OwnerId = wia.User__c;
                                                  wi.Work_Item_Assignment__c = wia.Id;
                                                  wi.Status = System.Label.STATUS_ASSIGNED;
                                                  if(tempUserSkill.Work_Item_Assignment__r.User__r.Supervisor__c != null){
                                                      wi.Approver_Reviewer__c = tempUserSkill.Work_Item_Assignment__r.User__r.Supervisor__c;    
                                                      wi.Approver_Reviewer_Email__c = tempUserSkill.Work_Item_Assignment__r.User__r.Supervisor__r.Email;
                                                  }
                                                  updatedCaseIds.add(wi.Id);
                                                  casesToUpdate.add(wi);
                                                  availableSlots = availableSlots - 1;
                                              }
                                              else if (wi.ParentId != null) {
                                                  wi.ParentId = null;
                                                  wi.IsParent__c = true;
                                                  updatedCaseIds.add(wi.Id);
                                                  casesToUpdate.add(wi);
                                              }
                                          }
                                    }
                                }
                            }
                            // If current work item is the parent of a group
                            else{
                                if(userSkills.contains(c.User_Skill_Rule__c)){
                                    User_Skill__c tempUserSkill = usMap.get(c.User_Skill_Rule__c);
                                    if(caseGroupMap.containsKey(c.Id)){
                                        
                                        List<Case> wiGroup = caseGroupMap.get(c.Id);
                                        
                                        Boolean openBillCycle = false;
                                        
                                        if(l_openBillCycles.contains(c.Bill_Cycle__c) && l_openBillCycleUSRIds.contains(c.User_Skill_Rule__c)){
                                            openBillCycle = true;
                                        }
                                        
                                        //system.debug('***openBillCycle: ' + openBillCycle);
                                        //system.debug('***wiGroup.size(): ' + wiGroup.size());
                                        if((wiGroup.size() == 1 && !openBillCycle) || wiGroup.size() > 1){
                                            for(Case wi : wiGroup){
                                                if(wi.User_Skill_Rule__r.AssignmentEnabled__c){
                                                    wi.OwnerId = wia.User__c;
                                                    wi.Work_Item_Assignment__c = wia.Id;
                                                    wi.Status = System.Label.STATUS_ASSIGNED;
                                                    if(tempUserSkill.Work_Item_Assignment__r.User__r.Supervisor__c != null){
                                                        wi.Approver_Reviewer__c = tempUserSkill.Work_Item_Assignment__r.User__r.Supervisor__c;    
                                                        wi.Approver_Reviewer_Email__c = tempUserSkill.Work_Item_Assignment__r.User__r.Supervisor__r.Email;
                                                    }
                                                    updatedCaseIds.add(wi.Id);
                                                    casesToUpdate.add(wi);
                                                    availableSlots = availableSlots - 1;
                                                }
                                                else if (wi.ParentId != null) {
                                                    wi.ParentId = null;
                                                    wi.IsParent__c = true;
                                                    updatedCaseIds.add(wi.Id);
                                                    casesToUpdate.add(wi);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } //!updatedCaseIds.contains(c.Id)
                        
                    } //availableSlots > 0
                    else{
                        break;
                    }
                } // Case c : highestPriorityWorkItems
            } // userSkillMap.containsKey(wia.Id)
        } // Id wiaid : l_availableCSRsMap.keySet()
        
     Diags.Clear();
   }
}