global class PriorityImpl implements Grouping{
    /*
		This method sorts the work items by Priority Score and gets the Parent Work Item Id
		Parameters: workitemGrouping = workitems
					queueId = 'Billing Exceptions' queue
	*/
    
    global Case getParentWorkItem(WorkItemGroup wig, String queueId){
        Diags.Enter('PriorityImpl.getParentWorkItem');
        List<Case> workitems = new List<Case>();
        for(String classId : wig.classWorkItemMap.keyset()){
            workitems.addAll(wig.classWorkItemMap.get(classId));
        }
        Case parentCase = GroupingUtility.retrieveParentCase(workitems, queueId);
        Diags.Info('parentCase: '+String.valueOf(parentCase));
        Diags.Clear();
        return parentCase;
    }
    
    global List<Case> groupWorkItems(WorkItemGroup wig, Case parentWorkItem, Id queueId, Set<Id> updatedWorkItemIds, Set<Id> workItemsToBeAssigned){
        Diags.Enter('PriorityImpl.groupWorkItems');
        List<Case> updatedWorkItems = new List<Case>();
        updatedWOrkItems = groupingUtility.groupWorkItems(wig, parentWorkItem, queueId, updatedWorkItemIds, workItemsToBeAssigned);
        Diags.Clear();
        return updatedWorkItems;
    }
}