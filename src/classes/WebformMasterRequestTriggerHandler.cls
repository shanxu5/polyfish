/**********************************************************************************************
* @author       Joe Kowalsky
* @date         08/04/2015
* @description  This class holds all the processes for the WebformMasterRequestTrigger
* @version      1.0
* @revision(s)  
**********************************************************************************************/
public class WebformMasterRequestTriggerHandler {

    ///////////////////////////////////////////////////////
    /////// REMOVE MASTER & CHILD WFRs >= 7 DAYS OLD //////
    ///////////////////////////////////////////////////////
    //  @author			Joe Kowalsky
    //  @date			07/31/15
    //  @description	
    //  *
    //  Criteria of when to delete records from webform staging objects 
    //
    //  Webform Master Request record's: 
    //  a) "Last Modified Date" is => 7 days old 
    //  AND 
    //  
    //  b) Last Modified Date" is NOT the same as "Created Date" - if it is then this means that ETL never updated or attempted to process 
    //  
    //  AND 
    //  c) (Both "Notification of Completion Required?" AND Notification_Sent__c box is checked) OR ("Notification of Completion Required?" is unchecked)
    //  
    //  Assume: 
    //  - Any errors in WI creation will be addressed within a day through normal process (failures go to support team) 
    //  - Support team will have access to all details regarding errored record (at minimum the WI Type, Batch ID, and Date ) 
    //  - The email notification for invalid IDs is sent immediately after ETL updates the master record status is to 'Error' 
    //  - Any situation where WI was not created would have been handled before 7 days when the situation occurred 
    //  - Any WIs not created would be dataloaded so that the # of WI's Completed will be accurate and trigger the completion email 
    //  *
    //  @version		1.0
    //	@revision		Original
    ///////////////////////////////////////////////////////
    public static void removeMasterChildWFRs(){
        System.debug(Logginglevel.info,'%%%% WebformMasterRequestTriggerHandler.removeMasterChildWFRs() %%%%');
        
        // Get Master Webform Requests that meet the removal criteria.
        Map<Id, Webform_Master_Request__c> masterWfrToRemove = new Map<Id, Webform_Master_Request__c>(
            [Select Id,Name,LastModifiedDate,CreatedDate,Status__c,Supporting_document_IDs__c
             from Webform_Master_Request__c 
             where	LastModifiedDate <= :Datetime.now()-7 and 
                 	(LastModifiedNotEqualToCreated__c = true)	and 
                    ((Notification_of_Completion_Required__c = true and Notification_Sent__c = true) or 
                    (Notification_of_Completion_Required__c = false))
            ]);
        
        // If Master WFRs found                                                            
        if(masterWfrToRemove != null && masterWfrToRemove.size() != 0) {
            
            // Create list of Master Webform objects to delete
            List<Webform_Master_Request__c> masterWfrObjectsToRemove = masterWfrToRemove.values();
            
            // Create set of Ids from objects above.  Used in Child Webform query below.
            Set<Id> masterWfrIdsToRemove = masterWfrToRemove.keySet();
            
            // Loop through Master Webform objects and gather Ids of attachments, i.e. Chatter objects.
            List<String> attatchmentIdsToRemove = new List<String>();
            
            
            for(Webform_Master_Request__c mwfr : masterWfrObjectsToRemove){
                
                // If the Master Webform has an error status, gather the attachment ids to delete later.
                if(mwfr.Status__c == 'Error'){                    
                    String attatchmentIds = mwfr.Supporting_document_IDs__c;
                    
                    if(attatchmentIds != null && attatchmentIds != ''){                    
                        List<String> attatchmentIdsList = attatchmentIds.split(';');
                        attatchmentIdsToRemove.addAll(attatchmentIdsList);
                    }
                }
                
            }
            
            
            // Get all attachment objects
            List<ContentVersion> attachmentObjectsToRemove = 
                [Select Id 
                 from ContentVersion
                 where Id IN :attatchmentIdsToRemove
                ];
            
            
            // Get any Child Webform Requests that are owned by the master                  
            List<Webform_Child_Request__c> childWfrObjectsToRemove = 
                [Select Id 
                 from Webform_Child_Request__c 
                 where Webform_Master_request__c IN :masterWfrIdsToRemove
                ];

            
            // Delete the Attachments and then Children and then Master WFRs.
            if(attachmentObjectsToRemove != null && attachmentObjectsToRemove.size() != 0) {
                // Can't delete the ContentVersion objects directly so must delete the ContentDocument, which accomplishes the following:
                // 	"When you delete a document, all versions of that document are deleted, including ratings, comments, and tags."
                Set<Id> attachmentDocumentIds = new Set<Id>();
                for(ContentVersion cv : attachmentObjectsToRemove){
                    attachmentDocumentIds.add(cv.ContentDocumentId);
                }
                
                List<ContentDocument> attachmentDocumentsToRemove = [Select Id from ContentDocument where Id IN: attachmentDocumentIds];
            	//delete attachmentDocumentsToRemove;
            }
            
            if(childWfrObjectsToRemove != null && childWfrObjectsToRemove.size() != 0) {                
                //delete childWfrObjectsToRemove;
            }
			
            //delete masterWfrObjectsToRemove;                        
        }                              
    ///////////////////////////////////////////////////////
    /////// REMOVE MASTER & CHILD WFRs >= 7 DAYS OLD //////
    ///////////////////////////////////////////////////////
    }
    
    
    
    /*************************************************************************
    * @author         Joe Kowalsky
    * @date           08/04/2015
    * @description	  This method is called from WebformMasterRequestTrigger and handles all trigger processing
    * @parameters	  newMasterWfrList 	- Trigger.new
    *                 newMasterWfrMap 	- Trigger.newMap
    *                 oldMasterWfrList	- Trigger.old
    *                 oldMasterWfrMap	- Trigger.oldMap
    *                 isBefore - Trigger.isBefore
    *                 isUpdate - Trigger.isUpdate
    *                 isInsert - Trigger.isInsert
    **************************************************************************/
    public static void handle(List<Webform_Master_Request__c> newMasterWfrList,
                              Map<Id, Webform_Master_Request__c> newMasterWfrMap,
                              List<Webform_Master_Request__c> oldMasterWfrList,
                              Map<Id, Webform_Master_Request__c> oldMasterWfrMap,
                              Boolean isBefore,
                              Boolean isUpdate,
                              Boolean isInsert){
                              
      try {
      
        Diags.Enter('WebformMasterRequestTriggerHandler.handle():IsBefore=' + isBefore + ':IsUpdate=' + isUpdate + ' - newUSList size = ' + (newMasterWfrList == null ? 0 : newMasterWfrList.size()));
       
        // After DML
        if(!isBefore){
            // On Update of Record
            if(isUpdate){
				// Check if any Webform Requests need to be removed.
                WebformMasterRequestTriggerHandler.removeMasterChildWFRs();
            }
        }
        
        Diags.Save();
        Diags.Clear();
      }
      catch(Exception e){
        Diags.SaveException(e);
        Diags.ClearAll();
        throw e;
      }                     
    }
}