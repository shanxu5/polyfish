/**********************************************************************************************
* @author       Janella Espiritu
* @date         10/14/2014
* @description  This class holds all the methods used for Grouping Work Items
* @version      1.1
* @revision(s)  Yefim Shuster on 2015-04-07 - Defect 154 - cannot complete WIs - new version is 1.1
			Melody Yang on 2015-05-01 - R2S1 - Added QueryString method
**********************************************************************************************/
public class GroupingUtility2 {
  	// Cached values initialized lazily
    private static Boolean GroupingClassesCached = false;
    private static Map<String, Grouping> GroupingClasses = new Map<String, Grouping>();
    
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           07/06/2015
    * @description    This method obtains MBT Queue Id from cache or from SObject
    * @parameters    None
    **************************************************************************/
	public static Map<String, Grouping> getGroupingClasses(){
        Diags.Enter('GroupingUtility.GroupingClasses');
	   	if (GroupingClassesCached) return GroupingClasses;

        Map<String, GroupingTypes__c> groupingTypesMap = GroupingTypes__c.getAll();
        for(String s : groupingTypesMap.keySet()){
            // Retrieve Custom Setting field for the WorkItemGroup - Grouping Type (Hierarchy/Priority)
            GroupingTypes__c groupingTypeCS = groupingTypesMap.get(s);
            String apexClass = groupingTypeCS.APEXClass__c;
            // Instantiate the APEX Class dynamically
            Type t = Type.forName(apexClass);
            Grouping grouping = (Grouping)t.newInstance();
            GroupingClasses.put(s, grouping);
        }
	   	GroupingClassesCached = true;
	    Diags.Clear();
	   	return GroupingClasses;
	}
    
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           09/16/2014
    * @description    This method retrieves the Highest Priority / If there is 
    *           a WI that is assigned to a CSR already
    * @parameters    
    **************************************************************************/
    public static Case retrieveParentCase(List<Case> caseList, Id queueID){
        Diags.Enter('GroupingUtility.retrieveParentCase');
        // Set WI with highest priority score on the group as the Parent
        Case parentWI = caseList[0];
        //Loop cases
        for(Case c : caseList){
            // If parentWI.OwnerId == queue{
            	// If the owner Id is not the Default Queue Id
                if(c.OwnerId != queueID && parentWI == caseList[0]){
                    // Set it as the Parent
                    parentWI = c;
                    break;
                }
        	//}
        }
        Diags.Clear();
        return parentWI;
    }
    
    
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           09/16/2014
    * @description    This method updates a group of list and updates the 
    *           Parent and Owner Id fields
    * @parameters    List<Case> caseList, Id queueID, Case parentCase
    **************************************************************************/
    public static List<Case> groupWorkItems(List<Case> wiList, Case parentWorkItem, Id queueId, Set<Id> updatedWorkItemIds, Set<Id> workItemsToBeAssigned){
        Diags.Enter('GroupingUtility.groupWorkItems');
        Diags.Info('updatedWorkItemIds: '+String.valueOf(updatedWorkItemIds));
		List<Case> updatedWorkItems = new List<Case>();
		/*
        
        for(String classId : wig.classIds){
            List<Case> workitems = wig.classWorkItemMap.get(classId);
            Diags.Info('workItems: '+ String.valueOf(workitems));
            for(Case wi : workItems){
                if(!updatedWorkItemIds.contains(wi.Id)){
                    Diags.Info('updatedWorkItemIds: '+ String.valueOf(updatedWorkItemIds));
                    // If the current work item is not the parent work item
                    if(wi.Id != parentWorkItem.Id){
                        // If the parent of current work item is not the parent work item
                        if(wi.ParentId != parentWorkItem.Id){
                            // If the current work item is 'Unassigned'
                            if(wi.Status == 'Unassigned'){
                                // Assign the Parent Work Item
                                wi.ParentId = parentWorkItem.Id;
                                // Set the IsParent field to false
                                wi.IsParent__c = false;
                                // If the Work Item is NOT on Hold and the Parent Work Item Owner is not the
                                // Billing Exceptions queue
                                if(!wi.Hold__c && 
                                    parentWorkItem.OwnerId != queueId &&
                                    wi.User_Skill_Rule__r.AssignmentEnabled__c
                                    ){
                                  wi.OwnerId = parentWorkItem.OwnerId;    
                                  wi.Status = 'Assigned';
                                }
                                 updatedWorkItemIds.add(wi.Id);
                            }
                            // If the current work item is 'Assigned' AND Parent Work Item Owner Id is not the QueueId
                            // Add Call to the Work Item Assignment Utility for Highest Priority Work Items
                            else if(wi.Status == 'Assigned' && (parentWorkItem.OwnerId != queueId || workItemsToBeAssigned.contains(parentWorkItem.Id))){
                            //else if(wi.Status == 'Assigned' && (parentWorkItem.OwnerId != queueId || workItemsToBeAssigned.contains(wi.Id))){
                                // If parentWorkItem is NOT the 'Billing Exceptions' queue
                                //if(parentWorkItem.OwnerId != queueId || casesToBeAssigned.contains(parentWorkItem.Id)){
                                    List<User_Skill__c> temp = new List<User_Skill__c>();
                                    //temp = usrWIAMap.get(parentWorkItem.User_Skill_Rule__c);
                                    //if(parentWorkItem.OwnerId != queueId || temp != null){
                                        // Assign the Parent Work Item
                                        wi.ParentId = parentWorkItem.Id;
                                        // Set the IsParent field to false
                                        wi.IsParent__c = false;
                                        // If the current work item is NOT on hold and the parent work item is 
                                        // not the Billing Exceptions Queue
                                        if(!wi.Hold__c &&
                                            wi.User_Skill_Rule__r.AssignmentEnabled__c
                                            ){
                                            // Assign to the Owner of the Parent Work Item AND 
                                            // change the status to 'Assigned'
                                            wi.OwnerId = parentWorkItem.OwnerId;   
                                            wi.Status = 'Assigned';
                                        }    
                                		updatedWorkItemIds.add(wi.Id);
                                   // }
                                //}
                            }                  
                        }
                    }
                    // If the current work item is the parent work item
                    else if(wi.Id == parentWorkItem.Id){
                        // Set ParentId to NULL and IsParent to TRUE
                        wi.ParentId = null;
                        wi.IsParent__c = true;
                    }
                    updatedWorkItems.add(wi);
                    updatedWorkItemIds.add(wi.Id);
                }
            }
        }
		*/
		for(Case wi : wiList){
			if(!updatedWorkItemIds.contains(wi.Id)){
				Diags.Info('updatedWorkItemIds: '+ String.valueOf(updatedWorkItemIds));
				// If the current work item is not the parent work item
				if(wi.Id != parentWorkItem.Id){
					// If the parent of current work item is not the parent work item
					if(wi.ParentId != parentWorkItem.Id){
						// If the current work item is 'Unassigned'
						if(wi.Status == 'Unassigned'){
							// Assign the Parent Work Item
							wi.ParentId = parentWorkItem.Id;
							// Set the IsParent field to false
							wi.IsParent__c = false;
							// If the Work Item is NOT on Hold and the Parent Work Item Owner is not the
							// Billing Exceptions queue
							if(!wi.Hold__c && 
								parentWorkItem.OwnerId != queueId &&
								wi.User_Skill_Rule__r.AssignmentEnabled__c
								){
							  wi.OwnerId = parentWorkItem.OwnerId;    
							  wi.Status = 'Assigned';
							}
							 updatedWorkItemIds.add(wi.Id);
						}
						// If the current work item is 'Assigned' AND Parent Work Item Owner Id is not the QueueId
						// Add Call to the Work Item Assignment Utility for Highest Priority Work Items
						else if(wi.Status == 'Assigned' && (parentWorkItem.OwnerId != queueId || workItemsToBeAssigned.contains(parentWorkItem.Id))){
						//else if(wi.Status == 'Assigned' && (parentWorkItem.OwnerId != queueId || workItemsToBeAssigned.contains(wi.Id))){
							// If parentWorkItem is NOT the 'Billing Exceptions' queue
							//if(parentWorkItem.OwnerId != queueId || casesToBeAssigned.contains(parentWorkItem.Id)){
								List<User_Skill__c> temp = new List<User_Skill__c>();
								//temp = usrWIAMap.get(parentWorkItem.User_Skill_Rule__c);
								//if(parentWorkItem.OwnerId != queueId || temp != null){
									// Assign the Parent Work Item
									wi.ParentId = parentWorkItem.Id;
									// Set the IsParent field to false
									wi.IsParent__c = false;
									// If the current work item is NOT on hold and the parent work item is 
									// not the Billing Exceptions Queue
									if(!wi.Hold__c &&
										wi.User_Skill_Rule__r.AssignmentEnabled__c
										){
										// Assign to the Owner of the Parent Work Item AND 
										// change the status to 'Assigned'
										wi.OwnerId = parentWorkItem.OwnerId;   
										wi.Status = 'Assigned';
									}    
									updatedWorkItemIds.add(wi.Id);
							   // }
							//}
						}                  
					}
				}
				// If the current work item is the parent work item
				else if(wi.Id == parentWorkItem.Id){
					// Set ParentId to NULL and IsParent to TRUE
					wi.ParentId = null;
					wi.IsParent__c = true;
				}
				updatedWorkItems.add(wi);
				updatedWorkItemIds.add(wi.Id);
			}
		}
        Diags.Info('updatedWorkItems: '+ String.valueOf(updatedWorkItems));
        Diags.Clear();
        return updatedWorkItems;
    }
    

     /*************************************************************************
    * @author         Janella Espiritu, moved to GroupingUtility by mxyq
    * @date           05/01/2014
    * @description    This method creates a query string that selects all work items to be grouped
    * @parameters    groupByValuesMap with Key - GroupBy, Value - Actual GroupBy Values
    **************************************************************************/
    public static String QueryString (Set<String> groupBySet, String triggerEvent){
        String BillingExceptionsQueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();        
        String QueryString = '';
        QueryString += 'Select ';     
        Set <String> fields = new Set<String>();
        for (Schema.FieldSetMember f : sObjectType.Case.FieldSets.Grouping_Query_String.getFields()){    
                fields.add(f.getFieldPath());
        }     
        /*
        for(String groupBy : groupByValuesMap.keySet()){
           fields.add(groupBy);
        }
		*/
        
        Integer qscounter = 0; 
        for(String s : fields){
            QueryString += s;
            qscounter ++;
			if (qscounter < fields.size()){
                QueryString += ', ';
            }
			
        }    
 		 
        QueryString += ' from Case where ';   
        /*
        if(!groupByValuesMap.isEmpty()){
            Integer gbcounter = 0;
            QueryString += '(';
            for(String groupBy : groupByValuesMap.keySet()){
               //Set<String> values = groupByValuesMap.get(groupBy);
                QueryString += groupBy + ' IN: allGroupByValues';
                gbcounter++;
                if(gbcounter < groupByValuesMap.keySet().size()){
                    QueryString += ' OR ';
                }
            }
            if(groupByValuesMap.keySet().size() > 0){
                QueryString += ') AND ';    
            }
        }
		*/
		if(!groupBySet.isEmpty()){
            Integer gbcounter = 0;
            QueryString += '(';
            for(String groupBy : groupBySet){
               //Set<String> values = groupByValuesMap.get(groupBy);
                QueryString += groupBy + ' IN: allGroupByValues';
                gbcounter++;
                if(gbcounter < groupBySet.size()){
                    QueryString += ' OR ';
                }
            }
            if(groupBySet.size() > 0){
                QueryString += ') AND ';    
            }
        }
        //Integer gbcounter = 0;
        /*Set<String> allGroupByValues = new Set<String>();
        for(String groupBy : groupByValuesMap.keySet()){
            allGroupByValues.addAll(groupByValuesMap.get(groupBy));
        }*/      
       
       /* for(String groupBy : groupByValuesMap.keySet()){
           //Set<String> values = groupByValuesMap.get(groupBy);
            QueryString += groupBy + ' IN: allGroupByValues';
            gbcounter++;
            if(gbcounter < groupByValuesMap.keySet().size()){
                QueryString += ' OR ';
            }
        }
        if(groupByValuesMap.keySet().size() > 0){
        	QueryString += ') AND ';    
        }
        */
        
        if(triggerEvent == 'Insert'){
            QueryString += ' Status IN(\'Assigned\',\'Unassigned\',\'Being Worked On\',\'Pending\')'; // Exclude 'Completed' OR 'Canceled'
        }
        else if(triggerEvent == 'Update'){
            QueryString += ' Status IN(\'Unassigned\')'; // Include Unassigned Only
        }
        
        //QueryString += ' AND User_Skill_Rule__r.Class__c IN: wiClassIds';
        QueryString += ' AND User_Skill_Rule__r.GroupingEnabled__c = TRUE'; // User Skill Rule Grouping Enabled must be TRUE
        QueryString += ' AND Reopened__c = FALSE AND Recreated__c = FALSE'; // Exclude Reopen and Recreates
        //QueryString += ' AND (';
        //if (!Test.isRunningTest()) QueryString += ' Owner.Type =\'User\' OR '; -j1eu commented
        //QueryString += ' OwnerId = \''+ BillingExceptionsQueueId +'\') '; // Include only work items that are Owned by a User or Owned by Billing Exceptions Queue
        //j1eu removed comment and add ownerid starts 500
        QueryString += ' AND (Owner.Type = \'User\' OR OwnerId = \''+ BillingExceptionsQueueId +'\')'; // Include only work items that are Owned by a User or Owned by Billing Exceptions Queue
        QueryString += ' ORDER BY Priority_Score__c DESC, CaseNumber ';
        return QueryString;
    }
}