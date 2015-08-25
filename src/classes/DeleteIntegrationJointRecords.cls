global without sharing class DeleteIntegrationJointRecords implements Database.Batchable<sObject>, Database.Stateful{
	global Database.QueryLocator Start(Database.BatchableContext bc) {
    	// Query string to query all Integration Joint records
        String query = 'SELECT Id, Error_Log__c ' +
            				'from Integration_Joint__c ';
        // Execute query
        return Database.getQueryLocator(query);
    }
    global void Execute(Database.BatchableContext bc, List<Integration_Joint__c> integJointList) {
        List<Integration_Joint__c> ijList = new List<Integration_Joint__c>();
        for(Integration_Joint__c ij : integJointList){
            // If Error Log is 'Successful', add the record to list to be deleted
            if(ij.Error_Log__c == 'Successful'){
                ijList.add(ij);
            }
        }
        if(ijList.size() > 0){
        	delete ijList;    
        }
    }
	global void Finish(Database.BatchableContext bc) {
    }    
}