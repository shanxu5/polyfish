/**********************************************************************************************
* @author       Janella Espiritu
* @date         
* @description  This class will send the XML to OSB Layer 7 to create customer contacts in CC&B
*
* @version      1.1
*
* @revision(s)  Janella Espiritu 06-08-2015 Updated with Release 2 Customer Contact Requirements
**********************************************************************************************/
global without sharing class SendCustomerContact implements Database.Batchable<sObject>, Database.AllowsCallouts{
	/*************************************************************************
    * @author         	Janella Espiritu
    * @date           
    * @description    	This method starts the batch
    * @parameters    	Batchable Context
    **************************************************************************/
	global Database.QueryLocator Start(Database.BatchableContext bc) {
        // Query Related Records recordtype id for Customer Contact
        Id recTypeId = [select Id from RecordType where sObjectType='Related_Records__c' and DeveloperName = 'Customer_Contact' LIMIT 1].Id;
        // Query string to query all Related Records where Recordtype is 'Customer Contact' and Id__c is null
        String query = 'SELECT Id, ' +
            				'Name, ' +
            				'Customer_Contact_Class__c, ' +
            				'Customer_Contact_Type__c, ' +
           					'RR_Customer_Contact_Class__c, ' +
            				'RR_Customer_Contact_Type__c, ' +
            				'ID__c, ' +
            				'Comments__c, ' +
            				'Status_Description__c, ' +
            				'Completion_Comments__c,' +
            				'SFDC_Work_Item__c, ' +
                            'SFDC_Work_Item__r.Work_Item_Type__c, ' +
            				'Additional_Customer_Contact_Log__c, ' +
            				'SFDC_Work_Item__r.CaseNumber,' +
            				'SFDC_Work_Item__r.Account.Name, ' +
            				'CC_Account_ID__c, ' +
            				'CC_Premise_ID__c, ' +
            				'CC_Service_Agreement_ID__c, ' +     
            				'CC_Person_ID__c, ' +
            				'SFDC_Work_Item__r.SFDC_Prem_ID__r.Name, ' +
            				'SFDC_Work_Item__r.Owner.Name, ' +
            				'SFDC_Work_Item__r.Per_ID__c, ' +
            				'SFDC_Work_Item__r.SFDC_SA_ID__r.Name ' + 
            				'from Related_Records__c ' +
            				'where RecordTypeId =\''+recTypeId+'\' ' +
            				'and ID__c = null ' +
            				'and Status_Description__c = \'Pending\'';
        
        /*AsyncApexJob a = [SELECT CreatedBy.Email
                          FROM AsyncApexJob WHERE Id = :bc.getJobId()];*/
       
       
        // Execute query
        return Database.getQueryLocator(query);
    }
	/*************************************************************************
    * @author         	Janella Espiritu
    * @date           
    * @description    	This method executes the batch
    * @parameters    	Batchable Context
						List of queried Customer Contacts
    **************************************************************************/
    global void Execute(Database.BatchableContext bc, List<Related_Records__c> custContList) {
        
         // Instantiate variables for Username, Password and Endpoint
        String username = System.Label.Layer_7_User_Name_for_Customer_Contact;//customercontactnprd
        String password = System.Label.Layer_7_Password_for_Customer_Contact;//customercontact1!
        String endpoint = System.Label.Layer_7_Endpoint_for_Customer_Contact;//'https://apiqa.pge.com/CustomerContact'
        
        // Create the XML Document
        DOM.Document doc = new DOM.Document();
        doc = BuildXML.getDoc(endpoint, custContList, bc.getJobId());
        System.debug(doc.toXmlString());
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);        
       
        // Send the request
        HttpRequest req = new HttpRequest();
        req.setClientCertificateName('MTCWPMS01_pge_com');
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'text/xml;charset=utf-8');
        req.setHeader('SOAPAction', '""');
        req.setHeader('username', username);
        req.setHeader('password', password);
        req.setTimeout(60000);
        req.setBodyDocument(doc);
        system.debug('***req'+req);
        Http http = new Http();
		// Instantiate the response
        HttpResponse res = http.send(req);
        system.debug('***res'+res);
        // If Request Status is 200
        if(res.getStatusCode()==200){
			system.debug('Successful');
			// Update related records status description to 'In-Progress'
			for (Related_Records__c rr : custContList){
                rr.Status_Description__c='In-Progress';               
            } 
            update custContList;
        }
    }
	/*************************************************************************
    * @author         	Janella Espiritu
    * @date           
    * @description    	This method finalizes the batch
    * @parameters    	Batchable Context
    **************************************************************************/
    global void Finish(Database.BatchableContext bc) {
        
    }
}