public class CustomerContactLogTriggerHandler {
    /*************************************************************************
    * @author        Janella Espiritu
    * @date          06/22/2015
    * @description   This method creates a Case Log is necessary
    * @parameters    customerContacts - Created Customer Contact
    **************************************************************************/
    public static void UpdateCustomerContactLogStatus(List<Customer_Contact_Log__c> customerContactLogs){
        Diags.Enter('UpdateCustomerContactLogStatus');
		// Loop related records created
        for(Customer_Contact_Log__c ccl : customerContactLogs){
			// If Add to CC&B Case Log is checked
            if(ccl.Status__c == 'Pending'){
                ccl.Status__c = 'In-Progress';
            }
            // If Add to CC&B Case Log is checked
            else if(ccl.Status__c == 'In-Progress'){
                ccl.Status__c = 'Complete';
            }
        }  
        Diags.Clear();
    }
    /*************************************************************************
    * @author        Janella Espiritu
    * @date          06/22/2015
    * @description   This method creates a Case Log is necessary
    * @parameters    customerContacts - Created Customer Contact
    **************************************************************************/
    public static void UpdateCustomerContactLogStatusOnInsert(List<Customer_Contact_Log__c> customerContactLogs){
        Diags.Enter('UpdateCustomerContactLogStatusOnInsert');
        Set<Id> ccLogIds = new Set<Id>();
        for(Customer_Contact_Log__c ccl : customerContactLogs){
            ccLogIds.add(ccl.Related_Record_ID__c);
        }
        Map<Id, Related_Records__c> rrMap = new Map<Id, Related_Records__c>([select Id, Status_Description__c from Related_Records__c where Id IN: ccLogIds]);
        Diags.Info(String.valueOf(rrMap));
		// Loop related records created
        for(Customer_Contact_Log__c ccl : customerContactLogs){
            if(rrMap.get(ccl.Related_Record_ID__c).Status_Description__c == 'Complete'){
                ccl.Status__c = 'In-Progress';
            }
            else{
                ccl.Status__c = 'Pending';
            }
        }  
        Diags.Clear();
    }
	/*************************************************************************
    * @author         
    * @date           
    * @description    This method is called from RelatedRecordTrigger 
						and handles all trigger processing
    * @parameters    newCustContLogList - Trigger.new
    *                newCustContLogMap - Trigger.newMap
    *                oldCustContLogList - Trigger.old
    *                oldCustContLogMap - Trigger.oldMap
    *                isBefore - Trigger.isBefore
    *                isUpdate - Trigger.isUpdate
    *                isInsert - Trigger.isInsert
    **************************************************************************/
	public static void handle(List<Customer_Contact_Log__c> newCustContLogList,
                              Map<Id, Customer_Contact_Log__c> newCustContLogMap,
                              List<Customer_Contact_Log__c> oldCustContLogList,
                              Map<Id, Customer_Contact_Log__c> oldCustContLogMap,
                              Boolean isBefore,
                              Boolean isUpdate,
                              Boolean isInsert){
	  //Id ccRecordTypeId = Schema.SObjectType.Related_Records__c.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
	  List<Customer_Contact_Log__c> ccLogUpdatedList = new List<Customer_Contact_Log__c> ();                         
      try {
          Diags.Enter('CustomerContactLogTriggerHandler.handle');
        //Diags.Enter('CaseTriggerHandler.handle():IsBefore=' + isBefore + ':IsUpdate=' + isUpdate + ' - newCaseList size = ' + newCaseList.size() + ' oldCaseList size = ' + oldCaseList.size());
        
        // Before DML
        if(isBefore){
            
            // If trigger is insert
            if(isInsert){
                Diags.Info('Before Insert');
                UpdateCustomerContactLogStatusOnInsert(newCustContLogList);
            }
            // If trigger is update
            if(isUpdate){
                Diags.Info('Before Update');
                for(Customer_Contact_Log__c rr : newCustContLogList){
                    Customer_Contact_Log__c oldMap = oldCustContLogMap.get(rr.Id);
                    if(rr.Log_ID__c != oldMap.Log_ID__c){
                        ccLogUpdatedList.add(rr);
                    }
                }
                if(ccLogUpdatedList.size() > 0){
                    UpdateCustomerContactLogStatus(ccLogUpdatedList);
                }
            }
        }
        // After DML
        if(!isBefore){
            // If trigger is insert
            if(isInsert){
				for(Customer_Contact_Log__c rr : newCustContLogList){
                    Customer_Contact_Log__c oldMap = oldCustContLogMap.get(rr.Id);
                    if(rr.Status__c == 'In-Progress'){
                        ccLogUpdatedList.add(rr);
                    }
                }
                if(ccLogUpdatedList.size() > 0){
                    // Send Customer Contact Log to CC&B
                }
            }
            // If trigger is Update
            if(isUpdate){
                for(Customer_Contact_Log__c rr : newCustContLogList){
                    Customer_Contact_Log__c oldMap = oldCustContLogMap.get(rr.Id);
                    if(rr.Status__c == 'In-Progress' && rr.Status__c != oldMap.Status__c){
                        ccLogUpdatedList.add(rr);
                    }
                }
                if(ccLogUpdatedList.size() > 0){
                    // Send Customer Contact Log to CC&B
                }
            }
        }
        
        Diags.Save();
        Diags.Clear();
     }
     catch(Exception e){
       System.debug('***Error in CustomerContactLogTriggerHandler.handle(): ' + e.getMessage());
       Diags.SaveException(e);
       Diags.ClearAll();
     }
   }
}