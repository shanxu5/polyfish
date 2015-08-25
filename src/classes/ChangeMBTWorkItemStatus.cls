global class ChangeMBTWorkItemStatus {
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
}