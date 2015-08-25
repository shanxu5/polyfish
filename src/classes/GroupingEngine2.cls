/*
	Builds groups and assigns the Parent Work Items to the whole group
*/ 
public class GroupingEngine2 {
    // Code to build a List of WorkItemGroup will be done here 
    public static void GroupingEngine(List<Case> insertedWorkItems, String triggerEvent, Map<Id, Case> newMap ){
        Diags.Enter('GroupingEngine.GroupingEngine()');
        Set<Id> classIds = new Set<Id>();
        Set<Id> allClassIds = new Set<Id>();
        Set<Id> groupingRuleIds = new Set<Id>();
        Set<Id> updatedworkItemIds = new Set<Id>();
        Set<String> allGroupByValues = new Set<String>();
		Set<String> groupBySet = new Set<String>();
        Set<Id> workItemsToBeAssigned = new Set<Id>();
        
        List<Grouping_Rules__c> groupingRuleList = new List<Grouping_Rules__c>();
        List<WorkItemGroup> workItemGroupList = new List<WorkItemGroup>();
		List<WorkItemGroup> requiredWorkItemGroupList = new List<WorkItemGroup>();
        List<Case> workItemsToUpdate = new List<Case>();
        
        Map<Id,Grouping_Rules__c> groupingRuleMap = new Map<Id,Grouping_Rules__c>();
        Map<Id,Set<Id>> groupingRuleClassMap = new Map<Id,Set<Id>>();
        Map<String,Set<String>> classGroupByMap = new Map<String,Set<String>>();
        Map<String,List<Case>> groupByValuesWorkItemsMap = new Map<String,List<Case>>();
        Map<Id,List<Case>> classWorkItemsMap = new Map<Id,List<Case>>();
        Map<String, Grouping> GroupingClasses = GroupingUtility.getGroupingClasses();
		Map<Id,Map<Id, Grouping_Rules__c>> classGroupingRuleMap = new Map<Id,Map<Id, Grouping_Rules__c>>();
        Map<Id, List<WorkItemGroup>> classWorkItemGroupMap = new Map<Id, List<WorkItemGroup>>();
		
        String BillingExceptionsQueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        String DuplicateExceptionsQueueId = WorkItemAssignmentUtility.getDuplicateExceptionQueueId();
        String BSEGMBTQueueId = WorkItemAssignmentUtility.getMBTQueueId();
        // Collect Work Item Ids (new work items)
        /*for(Case wi : insertedWorkItems){
            workitemIds.add(wi.Id);
        }
        system.debug('*****workitemIds: '+workitemIds);
		*/
		Map<Id, Grouping_Rules__c> groupingRulesMap = new Map<Id, Grouping_Rules__c>([Select Id,
																							Name,
																							Controlling_Class__c,
																							Group_By_API_Name__c,
																							Grouping_Type__c,
																							Sequence__c,
																							(Select Id, Grouping_Class__c, Grouping_Rule__c from Related_Classes__r order by Grouping_Rule__r.Sequence__c) 
																						from Grouping_Rules__c
																						order by Sequence__c]);
		for(Id groupingRule : groupingRulesMap.keyset()){
			WorkItemGroup wig = new WorkItemGroup();
			Grouping_Rules__c gr = groupingRulesMap.get(groupingRule);
			wig.groupingRuleRecord = gr;
			wig.relatedClasses = gr.Related_Classes__r;
			if(!gr.Related_Classes__r.isEmpty()){
				for(Related_Class__c rc : gr.Related_Classes__r){
					wig.classIds.add(rc.Grouping_Class__c);
					if(classWorkItemGroupMap.containsKey(rc.Grouping_Class__c)){
						List<WorkItemGroup> temp = classWorkItemGroupMap.get(rc.Grouping_Class__c);
						temp.add(wig);
						classWorkItemGroupMap.put(rc.Grouping_Class__c, temp);
					}
					else{
						classWorkItemGroupMap.put(rc.Grouping_Class__c, new List<WorkItemGroup>{wig});
					}
				}
			}
			workItemGroupList.add(wig);
		}
		
		// Query Work Item Records
        List<Case> workItemRecords = [Select Id, 
                                      		AccountId,
                                      		SFDC_Prem_ID__c,
                                      		Work_Item_Type__c,
                                      		User_Skill_Rule__r.Class__c,
											Op_Area_Cd__c
                                      	from Case
                                     	where Id IN: newMap.keySet()
										];
        system.debug('*****workItemRecords: '+workItemRecords);
        // Collect Class Ids (new work items)
        for(Case wi : workItemRecords){
            if(wi.User_Skill_Rule__r.Class__c != null){
            	classIds.add(wi.User_Skill_Rule__r.Class__c);
            }
			if(classWorkItemGroupMap.containsKey(wi.User_Skill_Rule__r.Class__c)){
				List<WorkItemGroup> wigList = classWorkItemGroupMap.get(wi.User_Skill_Rule__r.Class__c);
				for(WorkItemGroup wig : wigList){
					String groupBy = wig.groupingRuleRecord.Group_By_API_Name__c;
					String groupByValue = (String)wi.get(groupBy);
					if((String)wi.get(groupBy) != null){
						wig.groupByValueWIMap.put(groupByValue, new List<Case>{});
						allGroupByValues.add(groupByValue);
						groupBySet.add(groupBy);
					}
				}
			}
        }
		String QueryString = GroupingUtility2.QueryString(groupBySet,triggerEvent);
		System.debug('******QueryString: '+QueryString);
		List<Case> AllWorkItemsNeeded = database.query(QueryString);
		for(Case wi : AllWorkItemsNeeded){
			if(classWorkItemGroupMap.containsKey(wi.User_Skill_Rule__r.Class__c)){
				List<WorkItemGroup> wigList = classWorkItemGroupMap.get(wi.User_Skill_Rule__r.Class__c);
				for(WorkItemGroup wig : wigList){
					String groupBy = wig.groupingRuleRecord.Group_By_API_Name__c;
					String groupByValue = (String)wi.get(groupBy);
					if(groupByValue != null){
						if(wig.groupByValueWIMap.containsKey(groupByValue)){
							List<Case> temp = wig.groupByValueWIMap.get(groupByValue);
							temp.add(wi);
							wig.groupByValueWIMap.put(groupByValue, temp);
						}
						else{
							wig.groupByValueWIMap.put(groupByValue, new List<Case>{wi});
						}
						if(wig.groupByValueclassIdsMap.containsKey(groupByValue)){
							Set<Id> temp = wig.groupByValueclassIdsMap.get(groupByValue);
							temp.add(wi.User_Skill_Rule__r.Class__c);
							wig.groupByValueclassIdsMap.put(groupByValue, temp);
						}
						else{
							wig.groupByValueclassIdsMap.put(groupByValue, new Set<Id>{wi.User_Skill_Rule__r.Class__c});
						}
					}
				}
			}
		}
		for(WorkItemGroup wig : workItemGroupList){
			if(!wig.groupByValueclassIdsMap.isEmpty()){
				for(String s : wig.groupByValueclassIdsMap.keySet()){
					Set<Id> groupClassIds = wig.groupByValueclassIdsMap.get(s);
					if(wig.groupingRuleRecord.Grouping_Type__c == 'Hierarchy' && groupClassIds.contains(wig.groupingRuleRecord.Controlling_Class__c) && wig.classIds.containsAll(groupClassIds)){						
						requiredWorkItemGroupList.add(wig);
						system.debug('****Grouping Rule: '+wig.groupingRuleRecord.Sequence__c+' '+wig.groupingRuleRecord.Name);
					}
					else if(wig.groupingRuleRecord.Grouping_Type__c == 'Priority' && wig.classIds.containsAll(groupClassIds)){						
						requiredWorkItemGroupList.add(wig);
						system.debug('****Grouping Rule: '+wig.groupingRuleRecord.Sequence__c+' '+wig.groupingRuleRecord.Name);
					}
				}
				
			}
		}
		// If the triggerEvent is 'Insert', call AssignmentUtility to get the 
		// Highest Priority work items to be assigned
		if(triggerEvent == 'Insert'){
			// Collect Work Items to be Assigned after Grouping
			for(Case wi : WorkItemAssignmentUtility.getHighestPriorityWIs()){
				workItemsToBeAssigned.add(wi.Id);
			}
		}
		for(WorkItemGroup wig : requiredWorkItemGroupList){
			Grouping grouping = GroupingClasses.get(wig.groupingRuleRecord.Grouping_Type__c);
			for(String groupByValue : wig.groupByValueWIMap.keySet()){
				List<Case> workItems = wig.groupByValueWIMap.get(groupByValue);
				if(workItems.size() > 1){
					Case parentWorkItem = grouping.getParentWorkItem(workItems, BillingExceptionsQueueId);
					// Group the Work Items
					if(!updatedworkItemIds.contains(parentWorkItem.Id)){
						List<Case> groupedWorkItems = grouping.groupWorkItems(workItems, parentWorkItem, BillingExceptionsQueueId, updatedworkItemIds, workItemsToBeAssigned);
						workItemsToUpdate.addAll(groupedWorkItems);
						//System.debug(groupingTypeCS.APEXClass__c + ': '+workItemsToUpdate.size());
						//Diags.Info('workItemsToUpdate: '+String.valueOf(workItemsToUpdate));
						Diags.Info('workItemsToUpdate.size(): '+String.valueOf(workItemsToUpdate.size()));
						// Collect the updated work item ids
						for(Case wi : groupedWorkItems){
							updatedworkItemIds.add(wi.Id);
						}
					}
				}
			}
			for(Case wi : workItemsToUpdate){
				system.debug('**WI'+ wi.CaseNumber +' '+wi.Priority_Score__c+' '+wi.ParentId);
			}
			if(!workItemsToUpdate.isEmpty()){
				update workItemsToUpdate;
			}
        }	
        Diags.Info('Grouping Engine - DMLStatements: ' + Limits.getDMLStatements());
		Diags.Info('Grouping Engine - LimitDMLStatements: ' + Limits.getLimitDMLStatements());
		Diags.Info('Grouping Engine - CPUTime: ' + Limits.getCPUTime());
		Diags.Info('Grouping Engine - LimitCPUTime: ' + Limits.getLimitCPUTime());
		Diags.Info('Grouping Engine - HeapSize: ' + Limits.getHeapSize());
		Diags.Info('Grouping Engine - LimitHeapSize: ' + Limits.getLimitHeapSize());
		Diags.Info('Grouping Engine - Queries: ' + Limits.getQueries());
		Diags.Info('Grouping Engine - LimitQueries: ' + Limits.getLimitQueries());
        Diags.Clear();
    }
}