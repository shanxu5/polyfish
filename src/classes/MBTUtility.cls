global class MBTUtility {
    // This method updates BSEG MBT Electric  SM30 SM40 work item status from 'Unassigned' to 'Assigned'
	webservice static void updateMBTWorkItemStatus(){ 
        Id queueId = [select Id, Name from Group where Name = 'BSEG MBT Elec SM30 SM40' and Type = 'Queue'].Id;
        List<Case> mbtWorkItems = [select Id, Status from Case where OwnerId=:queueId and Status = 'Unassigned'];
        for(Case c : mbtWorkItems){
            c.Status = 'Assigned';
        }
        try{
        	update mbtWorkItems;    
       }catch(Exception e){System.debug('****ERROR Changing Status: ' + e.getMessage());
        }
    }
    // This method updates 'Assigned' BSEG MBT Electric  SM30 SM40 work item Owner 
    // from the BSEG MBT Elec SM30 SM40 queue to the Billing Exceptions queue
    webservice static void updateMBTOwnerId(){ 
        Id queueId = [select Id, Name from Group where Name = 'BSEG MBT Elec SM30 SM40' and Type = 'Queue'].Id;
        Id newQueueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        List<Case> mbtWorkItems = [select Id, Status from Case where OwnerId=:queueId and Status = 'Assigned'];
        for(Case c : mbtWorkItems){
            c.OwnerId = newQueueId;
            c.Status = 'Unassigned';
        }
        try{
        	update mbtWorkItems;    
        }catch(Exception e){System.debug('****ERROR Changing Owner: ' + e.getMessage());
        }
    }
}