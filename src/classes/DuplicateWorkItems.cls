/**********************************************************************************************
* @author       Melody Yang
* @date         June 2015
* @description  This method will be added CaseTriggerHandler to handle Duplicate VEE, 
				after insert before grouping
* @version      1.0
* @revision(s)  Original Version
**********************************************************************************************/

public class DuplicateWorkItems {
    //creating a default query string. test class will use owner!=duplicateQueue, all else will not have '!='
    @TestVisible private static String QueryString 
	= 'Select Id, AccountId, Work_Item_Type__c, SFDC_SA_ID__c, Duplicate_Vee_Indicator__c, OwnerId, Status from Case where SFDC_SA_ID__c IN: saIds and Work_Item_Type__c IN (\'VEE\', \'BSEG\', \'Delayed Bills\') and Status IN (\'Unassigned\',\'Assigned\', \'Being Worked On\', \'Pending\', \'Unavailable\') and (OwnerId IN (:billingExceptionsQueueId, :floorSupportQueueId, :bsegMBTQueueId) or Owner.Type = \'User\')';
     public static void DuplicateUtility(List<Case> workItemsInserted){
        Diags.Enter('CaseTriggerHandler - DuplicateWorkItems.DuplicateUtility()');
        //initialize and instantiate list of variables used
        Set<Id> saIds = new Set<Id>();
        Set<Id> workItemsInsertedId = new Set<Id>();
        Map<Id, List<Case>> saIdWorkItemsMap = new Map<Id, List<Case>>();
        Map<Id, Case> workItemsUpdateMap = new Map<Id, Case>();
        String billingExceptionsQueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        String duplicateExceptionsQueueId = WorkItemAssignmentUtility.getDuplicateExceptionQueueId();
        String bsegMBTQueueId = WorkItemAssignmentUtility.getMBTQueueId();
        String floorSupportQueueId = WorkItemAssignmentUtility.getFloorSupportQueueId();
            
		
        //collect a list of newly inserted WI Ids and inserted SA Ids
        for (Case c : workItemsInserted){
            workItemsInsertedId.add(c.Id);
        //add SA Ids if the field is not null/blank    
            if (c.SFDC_SA_ID__c != null){
            	saIds.add(c.SFDC_SA_ID__c);
            }
        }
         
        //query a list of all vee, bseg, db WIs based on inserted WI SA Ids
      if (!saIds.isEmpty()){
        List<Case> WorkItemRecords = database.query(QueryString);
    
        //create a map SAIdWorkItemsMap (key - SaIds; values - WIs)
        for (Case wi : WorkItemRecords){
            if (saIdWorkItemsMap.containsKey(wi.SFDC_SA_ID__c)){
                List<Case> temp = saIdWorkItemsMap.get(wi.SFDC_SA_ID__c);
                temp.add(wi);
                saIdWorkItemsMap.put(wi.SFDC_SA_ID__c, temp);
            }
            else{
                saIdWorkItemsMap.put(wi.SFDC_SA_ID__c, new List<Case>{wi});
            }
        }
         
        
        //loop through SaIdWorkItemsMap
        for (Id i : saIdWorkItemsMap.keySet()){
            List<Case> saIdWorkItems = saIdWorkItemsMap.get(i);
            if (saIdWorkItemsMap.size()>0){
                
                List<Case> veeWI  = new List<Case>();
                List<Case> bsegWI = new List<Case>();
                List<Case> dbWI   = new List<Case>();
                
                for (Case c : saIdWorkItems){
                    workItemsUpdateMap.put(c.Id, c);
                    //separate workItems into individual category: Vee, Bseg, Db
                    if (c.Work_Item_Type__c == 'VEE'){
                    	veeWI.add(c);
                    }
                    if (c.Work_Item_Type__c == 'BSEG'){
                        bsegWI.add(c);
                    }
                    if (c.Work_Item_Type__c == 'Delayed Bills'){
                        dbWI.add(c);
                    }                    
                }
                
                //when VEE is created and there is an open BSEG OR an open DB with the same SA Id
                if(!veeWI.isEmpty() && (!bsegWI.isEmpty() || !dbWI.isEmpty())){
					for(Case v : veeWI){
                        //if the VEE WI in question is a newly inserted WI
                        if(workItemsInsertedId.contains(v.Id)){
                            if (v.Status == 'Unassigned'){
                                v.OwnerId = duplicateExceptionsQueueId;
                                workItemsUpdateMap.put(v.Id, v);
                            }
                        }
                    }
                }
                        
                //when BSEG is created and there is an open VEE with the same SA Id
                //when BSEG is created and there is an open DB with the same SA Id
                if (!bsegWI.isEmpty() && (!veeWI.isEmpty() || !dbWI.isEmpty())){
                    for (Case b : bsegWI){
                        //if BSEG is newly inserted with the Unassigned status
                        if (workItemsInsertedId.contains(b.Id)){
                            if (b.Status == 'Unassigned'){
                                //if there is an open VEE
                                if (!veeWI.isEmpty() && dbWI.isEmpty()){
                                   b.Duplicate_Vee_Indicator__c = TRUE;
                                   for (Case v : veeWI){
                                       if (v.Status == 'Pending' || v.Status == 'Being Worked On' || v.Status == 'Unavailable'){
                                            b.OwnerId = v.OwnerId;
                                        }
                                        if (v.Status == 'Unassigned'){
                                            v.OwnerId = duplicateExceptionsQueueId;
                                        }
                                        if (v.Status == 'Assigned'){
                                            b.OwnerId = v.OwnerId;
                                            v.OwnerId = duplicateExceptionsQueueId;
                                        }
                                       workItemsUpdateMap.put(v.Id, v);
                                   }
                                }
                                //if there is an open DB
                                if (!dbWI.isEmpty() && veeWI.isEmpty()){
                                    b.OwnerId = duplicateExceptionsQueueId;
                                    /*for (Case d : dbWI){		//mxyq - done by ETL logic
                                        d.Exception_Message_Text__c = b.Exception_Message_Text__c;
                                        d.Message_Category_Number__c = b.Message_Category_Number__c;
                                        d.Message_Number__c = b.Message_Number__c;
                                        workItemsUpdateMap.put(d.Id, d);
                                    }*/ 
                                }
                            }
                        }
                               workItemsUpdateMap.put(b.Id, b);
                    }
                }

                //when DB is created and there is an open VEE with the same SA Id
                if (!dbWI.isEmpty() && !veeWI.isEmpty()){
                	for (Case d : dbWI){
                        if (workItemsInsertedId.contains(d.Id)){
                            if (d.Status == 'Unassigned'){
                                for (Case v : veeWI){
                                    d.Duplicate_Vee_Indicator__c = TRUE;
                                    if (v.Status == 'Pending' || v.Status == 'Being Worked On' || v.Status == 'Unavailable'){
                                        d.OwnerId = v.OwnerId;
                                    }
                                    if (v.Status == 'Unassigned'){
                                        v.OwnerId = duplicateExceptionsQueueId;
                                    }
                                    if (v.Status == 'Assigned'){
                                        d.OwnerId = v.OwnerId;
                                        v.OwnerId = duplicateExceptionsQueueId; 
                                    }
                                    workItemsUpdateMap.put(v.Id, v);
                                }
                        	}
                        }
                        WorkItemsUpdateMap.put(d.Id, d);
                    }
                }
                
                //when DB is created and there is no open VEE but open BSEG with the same SA Id
                if (!dbWI.isEmpty() && veeWI.isEmpty() && !bsegWI.isEmpty()){
                    for (Case d : dbWI){
                        if (workItemsInsertedId.contains(d.Id)){
                            if (d.Status == 'Unassigned'){
                                for (Case b : bsegWI){
                                    if (b.Status == 'Pending' || b.Status == 'Being Worked On' || b.Status == 'Unavailable'){
                                        d.OwnerId = b.OwnerId;
                                    }
                                    //if (b.OwnerId == bsegMBTQueueId){
                                    //    d.OwnerId = duplicateExceptionsQueueId;  //mxyq db should be in billing exceptions queue per business 7/9/15
                                    //    }
                                    if ((b.Status == 'Unassigned' && b.OwnerId == billingExceptionsQueueId)|| b.Status == 'Assigned'){
                                        if (b.Status == 'Assigned'){
                                            d.OwnerId = b.OwnerId;
                                        }
                                        b.OwnerId = duplicateExceptionsQueueId;
                                    }
                                    workItemsUpdateMap.put(b.Id, b);
                                }
                            }
                        }
                        WorkItemsUpdateMap.put(d.Id, d);
                    }
                }
            }
        }
update workItemsUpdateMap.values();
Diags.Clear();
         }
    }
}