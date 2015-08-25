/*
	Builds groups and assigns the Parent Work Items to the whole group
*/ 
public class GroupingEngine {
    // Code to build a List of WorkItemGroup will be done here 
    public static void GroupingEngine(List<Case> insertedWorkItems, String triggerEvent, Map<Id, Case> newCaseMap){
        Diags.Enter('GroupingEngine()');
        Set<Id> workItemIds = new Set<Id>();
        Set<Id> classIds = new Set<Id>();
        Set<Id> wiClassIds = new Set<Id>();
        Set<Id> allClassIds = new Set<Id>();
        Set<Id> groupingRuleIds = new Set<Id>();
        Set<Id> updatedworkItemIds = new Set<Id>();
        Set<String> allGroupByValues = new Set<String>();
        Set<Id> workItemsToBeAssigned = new Set<Id>();
        
        List<Grouping_Rules__c> groupingRuleList = new List<Grouping_Rules__c>();
        List<WorkItemGroup> workItemGroupList = new List<WorkItemGroup>();
        List<Case> workItemsToUpdate = new List<Case>();
        
        Map<Id,Grouping_Rules__c> groupingRuleMap = new Map<Id,Grouping_Rules__c>();
        Map<Id,Set<Id>> groupingRuleClassMap = new Map<Id,Set<Id>>();
        Map<String,Set<String>> classGroupByMap = new Map<String,Set<String>>();
        Map<String,Set<String>> groupByValuesMap = new Map<String,Set<String>>();
        Map<String,List<Case>> groupByValuesWorkItemsMap = new Map<String,List<Case>>();
        Map<Id,List<Case>> classWorkItemsMap = new Map<Id,List<Case>>();
        Map<String, Grouping> GroupingClasses = GroupingUtility.getGroupingClasses();
            
        String BillingExceptionsQueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        String DuplicateExceptionsQueueId = WorkItemAssignmentUtility.getDuplicateExceptionQueueId();
        String BSEGMBTQueueId = WorkItemAssignmentUtility.getMBTQueueId();
        // Collect Work Item Ids (new work items)
        workitemIds.addAll(newCaseMap.keySet()); 

        // Query Work Item Records
        String InitialQueryString = '';
        InitialQueryString += 'Select ';     
        Set <String> fields = new Set<String>();
        
        for (Schema.FieldSetMember f : sObjectType.Case.FieldSets.Grouping_Query_String.getFields()){    
                fields.add(f.getFieldPath());
        }     
        
        Integer qscounter = 0; 
        for(String s : fields){
            InitialQueryString += s;
            qscounter ++;
            if (qscounter < fields.size()){
                InitialQueryString += ', ';
            }
        }    
        
        InitialQueryString += ' from Case where Id IN: workitemIds'; 
        List<Case> workItemRecords = database.query(InitialQueryString);
        
        // Collect Class Ids (new work items)
        for(Case wi : workItemRecords){
            if(wi.User_Skill_Rule__r.Class__c != null){
            	classIds.add(wi.User_Skill_Rule__r.Class__c);    
            }
        }
        if(classIds.size() > 0){
            Diags.Info('workItemRecords: ' + String.valueOf(workItemRecords.size()));
            // Query related classes from the Class Ids collected
            List<Related_Class__c> relatedClasses = [Select Id,
                                                         Grouping_Class__c,
                                                         Grouping_Rule__c,
                                                         Grouping_Rule__r.Controlling_Class__c,
                                                         Grouping_Rule__r.Group_By_API_Name__c,
                                                         Grouping_Rule__r.Grouping_Type__c,
                                                         Grouping_Rule__r.Sequence__c,
                                                        Grouping_Rule__r.Name
                                                     from Related_Class__c
                                                     where 
                                                     (Grouping_Rule__r.Grouping_Type__c = 'Hierarchy' 
                                                        and Grouping_Rule__r.Controlling_Class__c IN: classIds 
                                                        and Grouping_Class__c IN: classIds)
                                                     OR(Grouping_Rule__r.Grouping_Type__c = 'Priority' 
                                                        and Grouping_Class__c IN: classIds)
                                                     order by Grouping_Rule__r.Sequence__c];
            // Build List of Grouping Rules
            for(Related_Class__c rc : relatedClasses){
            	if(rc.Grouping_Class__c != null){
            		wiClassIds.add(rc.Grouping_Class__c);
	                //KEY: Id (GroupingClassId)
	                //VALUE: Set<String> of GroupBys (AccountId/SFDC_Prem_ID__c/City_c)
	                if(classGroupByMap.containsKey(rc.Grouping_Class__c)){
	                    Set<String> temp = classGroupByMap.get(rc.Grouping_Class__c);
	                    temp.add(rc.Grouping_Rule__r.Group_By_API_Name__c);
	                    classGroupByMap.put(rc.Grouping_Class__c, temp);
	                }
	                else{
	                    classGroupByMap.put(rc.Grouping_Class__c, new Set<String>{rc.Grouping_Rule__r.Group_By_API_Name__c});
	                }
            	}
            }
            // Create Map of groupBy picklist values and Set of values
            // KEY: GroupBy (AccountId/SFDC_Prem_ID__c/SFDC_SP_ID__r.Op_Area_Cd__c)
            // VALUE: Set<String> (actual field values for specific groupby)
            Diags.Info('workItemRecords.size(): '+String.valueOf(workItemRecords.size()));
            for(Case wi : workItemRecords){
                if(classGroupByMap.containsKey(wi.User_Skill_Rule__r.Class__c)){
                    for(String groupBy : classGroupByMap.get(wi.User_Skill_Rule__r.Class__c)){
                        if(groupByValuesMap.containsKey(groupBy)){
                            Set<String> values = groupByValuesMap.get(groupBy);
                            values.add((String)wi.get(groupBy));
                            groupByValuesMap.put(groupBy, values);
                        }
                        else{
                            groupByValuesMap.put(groupBy, new Set<String>{(String)wi.get(groupBy)});
                        }
                    }
                }
            }
            // Build Query String to query existing work items
            String QueryString = GroupingUtility.QueryString(groupByValuesMap,triggerEvent);
            
            for(String groupBy : groupByValuesMap.keySet()){
                allGroupByValues.addAll(groupByValuesMap.get(groupBy));
            }
            Diags.Info(QueryString);
            Diags.Info('QueryString length: ' + String.valueOf(QueryString.length()));
            // Execute QueryString
            // AllWorkItemsNeeded - new + existing work items based on the GroupByValues
            
            List<Case> AllWorkItemsNeeded = database.query(QueryString);
            for(Case c : AllWorkItemsNeeded){
                // Retrieve allClassIds (new + existing work items)
                allClassIds.add(c.User_Skill_Rule__r.Class__c);
                // Create Map of Work Items Per Class
                // KEY: Id - Grouping Class Id
                // VALUE: List<Case> - Work Items with the Same Class
                if(classWorkItemsMap.containsKey(c.User_Skill_Rule__r.Class__c)){
                    List<Case> workitems = classWorkItemsMap.get(c.User_Skill_Rule__r.Class__c);
                    workitems.add(c);
                    classWorkItemsMap.put(c.User_Skill_Rule__r.Class__c, workitems);
                }
                else{
                    classWorkItemsMap.put(c.User_Skill_Rule__r.Class__c, new List<Case> {c});
                }
                // KEY: Actual GroupBy Value
                // VALUE: List<Case> work items based on the GroupByValue
                for(String groupBy : groupByValuesMap.keySet()){
                    // groupByValue is the actual value based on the GroupByValue
                    String groupByValue = (String)c.get(groupBy);
                    if(groupByValuesWorkItemsMap.containsKey(groupByValue)){
                        List<Case> temp = groupByValuesWorkItemsMap.get(groupByValue);
                        temp.add(c);
                        groupByValuesWorkItemsMap.put(groupByValue, temp);
                    }
                    else{
                        groupByValuesWorkItemsMap.put(groupByValue, new List<Case> {c});
                    }
                }
            }
            // Query the Related Classes again to add Related Classes for the existing work items
            relatedClasses = new List<Related_Class__c>();
            relatedClasses = [Select Id,
                              Grouping_Class__c,
                              Grouping_Class__r.Name,
                              Grouping_Rule__c,
                              Grouping_Rule__r.Controlling_Class__c,
                              Grouping_Rule__r.Group_By_API_Name__c,
                              Grouping_Rule__r.Grouping_Type__c,
                              Grouping_Rule__r.Sequence__c,
                              Grouping_Rule__r.Name
                              from Related_Class__c
                              where 
                              (Grouping_Rule__r.Grouping_Type__c = 'Hierarchy' 
                                and Grouping_Rule__r.Controlling_Class__c IN: allClassIds 
                                and Grouping_Class__c IN: allClassIds)
                              OR (Grouping_Rule__r.Grouping_Type__c = 'Priority' 
                                  and Grouping_Class__c IN: allClassIds)
                              order by Grouping_Rule__r.Sequence__c];
            Diags.Info('relatedClasses.size(): '+String.valueOf(relatedClasses.size()));
            // Build List of Grouping Rules
            for(Related_Class__c rc : relatedClasses){
                Diags.Info('relatedClasses: '+String.valueOf(rc.Grouping_Class__r.Name));
                //Create List of Grouping Rules based on the Ids
                if(!groupingRuleIds.contains(rc.Grouping_Rule__c)){
                    // Instantiate new Grouping_Rules__c record
                    Grouping_Rules__c gr = new Grouping_Rules__c();
                    gr.Id = rc.Grouping_Rule__c;
                    gr.Controlling_Class__c = rc.Grouping_Rule__r.Controlling_Class__c;
                    gr.Group_By_API_Name__c = rc.Grouping_Rule__r.Group_By_API_Name__c;
                    gr.Grouping_Type__c = rc.Grouping_Rule__r.Grouping_Type__c;
                    gr.Sequence__c = rc.Grouping_Rule__r.Sequence__c;
                    gr.Name = rc.Grouping_Rule__r.Name;
                    groupingRuleIds.add(gr.Id);
                    groupingRuleList.add(gr);
                    
                    // KEY: Grouping Rule Id
                    // VALUE: Grouping Rule Value
                    groupingRuleMap.put(gr.Id, gr);
                }
                // KEY: Grouping Rule Id
                // VALUE: Set<Id> Grouping Class Ids
                if(rc.Grouping_Class__c != null){
                	if(groupingRuleClassMap.containsKey(rc.Grouping_Rule__c)){
	                    Set<Id> temp = groupingRuleClassMap.get(rc.Grouping_Rule__c);
	                    temp.add(rc.Grouping_Class__c);
	                    groupingRuleClassMap.put(rc.Grouping_Rule__c, temp);
	                }
	                else{
	                    groupingRuleClassMap.put(rc.Grouping_Rule__c, new Set<Id>{rc.Grouping_Class__c});
	                }
                }
            }
            Diags.Info('groupingRuleClassMap.keySet(): '+String.valueOf(groupingRuleClassMap.keySet()));
            // Loop Grouping Rules Ids
            for(Id i : groupingRuleClassMap.keySet()){
                
                Diags.Info('groupingRuleMap.get(i).Name: '+String.valueOf(groupingRuleMap.get(i).Name));
                
                Set<Id> groupByclassIds = groupingRuleClassMap.get(i);
                Set<String> groupByValues = new Set<String>();
                
                // Retrieve the current Grouping Rule record
                Grouping_Rules__c groupingRule = groupingRuleMap.get(i);
                // Loop Class Ids for the current Grouping Rule
                for(String classId : groupByclassIds){
                    // Retrieve Work Items for the Class
                    List<Case> workItems = classWorkItemsMap.get(classId);
                    // Collect actual group by values
                    for(Case wi : workItems){
                        if((String)wi.get(groupingRule.Group_By_API_Name__c) != null){
                        	groupByValues.add((String)wi.get(groupingRule.Group_By_API_Name__c));       
                        }
                    } 
                }
                // Loop groupByValues (1 WorkItemGroup per groupByValue)
                for(String s : groupByValues){
                    // Instantiate WorkItemGroup
                    WorkItemGroup wiGrp = new WorkItemGroup();
                    wiGrp.groupingRule = i;
                    wiGrp.groupingRuleRecord = groupingRule;
                    wiGrp.classIds = groupingRuleClassMap.get(i);
                    wiGrp.groupBy = groupingRule.Group_By_API_Name__c;
                    wiGrp.groupingType = groupingRule.Grouping_Type__c;
                    wiGrp.groupByValue = s;
                    wiGrp.classWorkItemMap = new Map<Id, List<Case>>();
                    if(groupByValuesWorkItemsMap.containsKey(wiGrp.groupByValue)){
                        // Retrieve Work Items for the current groupByValue
                        List<Case> workItemsForGroupByValue = groupByValuesWorkItemsMap.get(wiGrp.groupByValue);
                        Boolean containsControllingClass = false;
                        // If the Grouping Type is 'Hierarchy', check if the workItemsForGroupByValue has 
                        // at least 1 Work Item that belongs to the Controlling Class
                        if(wiGrp.groupingType == 'Hierarchy'){
                            for(Case wi : workItemsForGroupByValue){
                                if(wiGrp.groupingRuleRecord.Controlling_Class__c == wi.User_Skill_Rule__r.Class__c){
                                    containsControllingClass = true;
                                }
                            }
                        }
                        // IF the Grouping Type is 'Hierarchy' and containsControllingClass = true 
                        // OR Grouping Type is 'Priority'
                        if((wiGrp.groupingType == 'Hierarchy' && containsControllingClass && 
                            wiGrp.classIds.contains(wiGrp.groupingRuleRecord.Controlling_Class__c)) || 
                            wiGrp.groupingType == 'Priority'){
                            // Loop Class Ids for the Grouping Rule
                            for(String classId : wiGrp.classIds){
                                // Loop Work Items based on the GroupByValue 
                               for(Case wi : workItemsForGroupByValue){
                                   // If classId is equals to the work item class
                                   if(wi.User_Skill_Rule__r.Class__c == classId){
                                       // Add the work item to the classWorkItemMap
                                       // KEY: ClassId - class id
                                       // VALUE: List<Case> - list of work items
                                       if(wiGrp.classWorkItemMap.containskey(classId)){
                                           List<Case> temp = wiGrp.classWorkItemMap.get(classId);
                                           temp.add(wi);
                                           wiGrp.classWorkItemMap.put(classId, temp);
                                       }
                                       else{
                                           wiGrp.classWorkItemMap.put(classId, new List<Case>{wi});
                                       }                               
                                   }
                               }
                            }
                            // Add the workItemGroup to workItemGroupList
                            workItemGroupList.add(wiGrp); 
                        }
                    }     
                }
            }
            // For Diagnostics Purposes **
            Diags.Info('workItemGroupList.size(): '+String.valueOf(workItemGroupList.size()));
            for(WorkItemGroup wig : workItemGroupList){
                Diags.Info('wig.GroupingRule: '+String.valueOf(wig.groupingRuleRecord.Name));
                Diags.Info('wig.groupBy: '+String.valueOf(wig.groupBy));
                Diags.Info('wig.groupByValue: '+String.valueOf(wig.groupByValue));
                Diags.Info('wig.classIds: '+String.valueOf(wig.classIds));
                for(String classId : wig.classWorkItemMap.keySet()){
                    Diags.Info(classId +': '+String.valueOf(wig.classWorkItemMap.get(classId).size()));
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
            // Loop workItemGroupList
            for(WorkItemGroup wig : workItemGroupList){
                // Retrieve the Parent Work Item
                if(GroupingClasses.containsKey(wig.groupingType)){
                    Grouping grouping = GroupingClasses.get(wig.groupingType);
                	Case parentWorkItem = grouping.getParentWorkItem(wig, BillingExceptionsQueueId);
                    // Group the Work Items
                    if(!updatedworkItemIds.contains(parentWorkItem.Id)){
                        List<Case> groupedWorkItems = grouping.groupWorkItems(wig, parentWorkItem, BillingExceptionsQueueId, updatedworkItemIds, workItemsToBeAssigned);
                        workItemsToUpdate.addAll(groupedWorkItems);
                        //Diags.Info('workItemsToUpdate: '+String.valueOf(workItemsToUpdate));
                        Diags.Info('workItemsToUpdate.size(): '+String.valueOf(workItemsToUpdate.size()));
                        // Collect the updated work item ids
                        for(Case wi : groupedWorkItems){
                            updatedworkItemIds.add(wi.Id);
                        }
                    }
                }
                
            }
            try{
                if (workItemsToUpdate.size()>0){
                    update workItemsToUpdate;
                }
            }
            catch(Exception e){
                Diags.Info('ERROR IN GROUPING: '+e.getMessage());
                Diags.SaveException(e);
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