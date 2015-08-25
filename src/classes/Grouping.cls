global interface Grouping {
	Case getParentWorkItem(WorkItemGroup wig, String queueId);
	List<Case> groupWorkItems(WorkItemGroup wig, Case parentWorkItem, Id queueId, Set<Id> updatedWorkItemIds, Set<Id> workItemsToBeAssigned);	
}