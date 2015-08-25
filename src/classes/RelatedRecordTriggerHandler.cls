/**********************************************************************************************
* @author       Janella Espiritu
* @date         06/22/2015
* @description  This class holds all the processes for RelatedRecordTrigger
* @revision(s)  
**********************************************************************************************/
public class RelatedRecordTriggerHandler {
	/*************************************************************************
    * @author        Janella Espiritu
    * @date          06/22/2015
    * @description   This method creates a Case Log is necessary
    * @parameters    customerContacts - Created Customer Contact
    **************************************************************************/
    public static void CreateCaseLog(List<Related_Records__c> customerContacts){
        Diags.Enter('CreateCaseLog');
		// Instantiate variables
        List<CC_B_Case_Log__c> caseLogInsert = new List<CC_B_Case_Log__c>();
		// Loop related records created
        for(Related_Records__c rr : customerContacts){
			// If Add to CC&B Case Log is checked
            if(rr.Add_to_CC_B_Case_Log__c){
                String caseLogDetails = '';
                // Concatenate Comments
                if(rr.Comments__c != null){
                    caseLogDetails += rr.Comments__c;
                    caseLogDetails += '\n';
                }
                // Concatenate Completion Comments
                if(rr.Completion_Comments__c != null){
                    caseLogDetails += rr.Completion_Comments__c;
                    caseLogDetails += '\n';
                }
                // Concatenate Additional Customer Contact Log
                if(rr.Additional_Customer_Contact_Log__c != null){
                    caseLogDetails += rr.Additional_Customer_Contact_Log__c;
                    caseLogDetails += '\n';
                }
                // Instantiate new CC&B Case Log record
                // Populate CC&B Case Log Details and Work Item
                CC_B_Case_Log__c caseLog = new CC_B_Case_Log__c();
                caseLog.CC_B_Case_Log_Details__c = caseLogDetails;
                caseLog.Work_Item__c = rr.SFDC_Work_Item__c;
                // Add instance to caseLogInsert list
                caseLogInsert.add(caseLog);
            }
        }
		// If caseLogInsert is not empty,
		// insert the case log records
        if(caseLogInsert.size() > 0){
            insert caseLogInsert;
            /*
            try{
                insert caseLogInsert;
        		Diags.Clear();
            }
            catch(Exception e){
                Diags.SaveException(e);
      			Diags.ClearAll();
            }
			*/
        }
        
    }
    /*************************************************************************
    * @author        Janella Espiritu
    * @date          06/22/2015
    * @description   This method creates a Case Log is necessary
    * @parameters    customerContacts - Created Customer Contact
    **************************************************************************/
    public static void UpdateCustomerContactStatus(List<Related_Records__c> customerContacts){
        Diags.Enter('UpdateCustomerContactStatus');
		// Loop related records created
        for(Related_Records__c rr : customerContacts){
			// If Add to CC&B Case Log is checked
            if(rr.Status_Description__c == 'Pending'){
                rr.Status_Description__c = 'In-Progress';
            }
            // If Add to CC&B Case Log is checked
            else if(rr.Status_Description__c == 'In-Progress'){
                rr.Status_Description__c = 'Complete';
            }
        }      
    }
    /*************************************************************************
    * @author        Janella Espiritu
    * @date          08/25/2015
    * @description   This method creates a Case Log is necessary
    * @parameters    customerContacts - Created Customer Contact
    **************************************************************************/
    public static void UpdateCustomerContactLogStatus(List<Related_Records__c> customerContacts, Map<Id,Related_Records__c> newMap){
        Diags.Enter('UpdateCustomerContactStatus');
		// Query related Customer Contact Logs
        List<Customer_Contact_Log__c> relatedCustomerContactLogs = [select Id, Status__c from Customer_Contact_Log__c where Id IN: newMap.keySet() and Status__c = 'Pending'];
        if(relatedCustomerContactLogs.size() > 0){
            // Loop related records created
            for(Customer_Contact_Log__c ccl : relatedCustomerContactLogs){
                ccl.Status__c = 'In-Progress';
            }  
            update relatedCustomerContactLogs;
        }
            
    }
	/*************************************************************************
    * @author         
    * @date           
    * @description    This method is called from RelatedRecordTrigger 
						and handles all trigger processing
    * @parameters    newRelatedRecordList - Trigger.new
    *                newRelatedRecordMap - Trigger.newMap
    *                oldRelatedRecordList - Trigger.old
    *                oldRelatedRecordMap - Trigger.oldMap
    *                isBefore - Trigger.isBefore
    *                isUpdate - Trigger.isUpdate
    *                isInsert - Trigger.isInsert
    **************************************************************************/
	public static void handle(List<Related_Records__c> newRelatedRecordList,
                              Map<Id, Related_Records__c> newRelatedRecordMap,
                              List<Related_Records__c> oldRelatedRecordList,
                              Map<Id, Related_Records__c> oldRelatedRecordMap,
                              Boolean isBefore,
                              Boolean isUpdate,
                              Boolean isInsert){
	  Id ccRecordTypeId = Schema.SObjectType.Related_Records__c.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
	  List<Related_Records__c> rrUpdatedList = new List<Related_Records__c> ();                         
      try {
          Diags.Enter('RelatedRecordTriggerHandler.handle');
        //Diags.Enter('CaseTriggerHandler.handle():IsBefore=' + isBefore + ':IsUpdate=' + isUpdate + ' - newCaseList size = ' + newCaseList.size() + ' oldCaseList size = ' + oldCaseList.size());
        
        // Before DML
        if(isBefore){
            // If trigger is insert
            if(isInsert){
                Diags.Info('Before Insert');
                // Call ValidationUtility to validate fields
                ValidationUtility.CustomerContactValidationRelatedRecords(newRelatedRecordList);
            }
            // If trigger is update
            if(isUpdate){
                Diags.Info('Before Update');
                for(Related_Records__c rr : newRelatedRecordList){
                    Related_Records__c oldMap = oldRelatedRecordMap.get(rr.Id);
                    if(rr.RecordTypeId == ccRecordTypeId && rr.ID__c != oldMap.ID__c){
                        rrUpdatedList.add(rr);
                    }
                }
                if(rrUpdatedList.size() > 0){
                    UpdateCustomerContactStatus(rrUpdatedList);
                }
            }
        }
        // After DML
        if(!isBefore){
            // If trigger is insert
            if(isInsert){
				// Call method to CreateCaseLog
                CreateCaseLog(newRelatedRecordList);
                for(Related_Records__c rr : newRelatedRecordList){
                    if(rr.RecordTypeId == ccRecordTypeId && rr.ID__c == null){
                        system.debug('****send customer contact***');
                        BuildXMLForCustomerContact.sendRequest(rr.Id);  
                    }  
                }
            }
            // If trigger is Update
            if(isUpdate){
               for(Related_Records__c rr : newRelatedRecordList){
                    Related_Records__c oldMap = oldRelatedRecordMap.get(rr.Id);
                    if(rr.RecordTypeId == ccRecordTypeId && rr.Status_Description__c == 'Complete'){
                        rrUpdatedList.add(rr);
                    }
                }
                if(rrUpdatedList.size() > 0){
                    UpdateCustomerContactLogStatus(rrUpdatedList, newRelatedRecordMap);
                }
            }
        }
        
        Diags.Save();
        Diags.Clear();
     }
     catch(Exception e){
       System.debug('***Error in RelatedRecordTriggerHandler.handle(): ' + e.getMessage());
       Diags.SaveException(e);
       Diags.ClearAll();
     }
   }
}