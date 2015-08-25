global class FastSlowUtility {
    // This method updates Fast/Slow Meter Adj - Gas work item status from 'Unassigned' to 'Assigned'
	webservice static void updateFastSlowGasWorkItemStatus(){ 
        //Id queueId = [select Id, Name from Group where Name = 'BSEG MBT Elec SM30 SM40' and Type = 'Queue'].Id;
		Id queueId = WorkItemAssignmentUtility.getFastSlowToDoQueueId();
        List<Case> fastSlowWorkItems = [select Id, Status from Case where OwnerId=:queueId and Status = 'Unassigned'];
        for(Case c : fastSlowWorkItems){
            c.Status = 'Assigned';
        }
        try{
        	update fastSlowWorkItems;    
       }catch(Exception e){System.debug('****ERROR Changing Status: ' + e.getMessage());
        }
    }
    // This method updates 'Assigned' Fast/Slow Meter Adj - Gas work items Owner 
    // from the BSEG MBT Elec SM30 SM40 queue to the Billing Exceptions queue
    webservice static void updateFastSlowGasOwnerId(){ 
        //Id queueId = [select Id, Name from Group where Name = 'BSEG MBT Elec SM30 SM40' and Type = 'Queue'].Id;
        //Id newQueueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
		Id queueId = WorkItemAssignmentUtility.getFastSlowToDoQueueId();
		Id newQueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        List<Case> fastSlowWorkItems = [select Id, Status from Case where OwnerId=:queueId and Status = 'Assigned'];
        for(Case c : fastSlowWorkItems){
            c.OwnerId = newQueueId;
            c.Status = 'Unassigned';
        }
        try{
        	update fastSlowWorkItems;    
        }catch(Exception e){System.debug('****ERROR Changing Owner: ' + e.getMessage());
        }
    }
}