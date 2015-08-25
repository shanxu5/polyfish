/**********************************************************************************************
* @author       Janella Espiritu
* @date         04.22.2015
* @description  This class holds all logic for Hierarchy grouping
* @version      1.0
* @revision(s)  Janella Espiritu - 04.22.2015 - Created
**********************************************************************************************/
global class HierarchyImpl implements Grouping{
    /*
		This method sorts the work items by Priority Score and gets the Parent Work Item Id
		Parameters: wig = WorkItemGroup
				queueId = 'Billing Exceptions' queue
	*/
    
    global Case getParentWorkItem(WorkItemGroup wig, String queueId){
        Diags.Enter('HierarchyImpl.getParentWorkItem');
        Case parentCase = new Case();
        if(wig.classWorkItemMap.containsKey(wig.groupingRuleRecord.Controlling_Class__c)){
            // Retrieve work items that belong to the controlling class
            List<Case> workitems = wig.classWorkItemMap.get(wig.groupingRuleRecord.Controlling_Class__c);
            // Pass the work items to GroupingUtility.retrieveParentCase to retrieve the Parent Work Item
            parentCase = GroupingUtility.retrieveParentCase(workitems, queueId);
            Diags.Info('parentCase: '+String.valueOf(parentCase.CaseNumber));
        }
        
        Diags.Clear();
        // Return the Parent Work Item
        return parentCase;
    }    
    global List<Case> groupWorkItems(WorkItemGroup wig, Case parentWorkItem, Id queueId, Set<Id> updatedWorkItemIds, Set<Id> workItemsToBeAssigned){
        Diags.Enter('HierarchyImpl.groupWorkItems');
        List<Case> updatedWorkItems = new List<Case>();
        updatedWOrkItems = groupingUtility.groupWorkItems(wig, parentWorkItem, queueId, updatedWorkItemIds, workItemsToBeAssigned);
        Diags.Clear();
        return updatedWorkItems;
    }

}