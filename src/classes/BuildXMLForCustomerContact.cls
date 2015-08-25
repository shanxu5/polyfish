public class BuildXMLForCustomerContact {
	@future(callout=true)
	public static void sendRequest(String relatedRecordId){
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
            				'where Id =: relatedRecordId';
        Related_Records__c relatedRecord = database.query(query);
        DOM.Document doc = new DOM.Document();
        doc = getXMLDoc(relatedRecord);
	    System.debug(doc.toXmlString());
    }    
    /*************************************************************************
    * @author         	Janella Espiritu
    * @date           
    * @description    	This method builds XML request file for Customer Contact
    * @parameters    	String endpoint
						List of Related Records
						String Batch Job Id
    **************************************************************************/
    public static DOM.Document getXMLDoc(Related_Records__c rr){
		// Create the request envelope
        DOM.Document doc = new DOM.Document();
        // Deckare namespaces        
        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
        String xsi = 'http://www.w3.org/2001/XMLSchema-instance';
        String cus = 'http://xmlns.pge.com/Customer/CustomerContactMessage';
        String mes = 'http://xmlns.pge.com/Core/Message';
        String cus1 = 'http://xmlns.pge.com/Customer/CustomerContact';
		// Format Date/Time now to String format
        String dateTimeNow = datetime.now().format('yyyy-MM-dd HH:mm:ss');
		// Create root element and set namespaces
        dom.XmlNode envelope = doc.createRootElement('Envelope', soapNS, 'soapenv');
        envelope.setNamespace('xsi', xsi);
        envelope.setNamespace('cus', cus);
        envelope.setNamespace('mes', mes);
        envelope.setNamespace('cus1', cus1);
		// Add child node header under root element
        dom.XmlNode header = envelope.addChildElement('Header', soapNS, null);
		// Add child node body under root element
        dom.XmlNode body = envelope.addChildElement('Body', soapNS, null);
		// Add child node CreateCustomerContactRequestMessage under root element and set namespaces
        dom.XmlNode cccrm = body.addChildElement('CreateCustomerContactRequestMessage', cus, null);   
        cccrm.setNameSpace('mes', mes);
        cccrm.setNameSpace('cus', cus);
        cccrm.setNameSpace('cus1', cus1);
		// Add child node Header under CreateCustomerContactRequestMessage
        dom.XmlNode cccrmHeader = cccrm.addChildElement('Header', mes, null);
		// Add child node Verb under Header with a value Create
        cccrmHeader.addChildElement('Verb', mes, null).addTextNode('create');
		// Add child node Verb under Noun with a value CustomerContact
        cccrmHeader.addChildElement('Noun', mes, null).addTextNode('CustomerContact');
		// Add child node Verb under Revision with a value 1.0
        cccrmHeader.addChildElement('Revision', mes, null).addTextNode('1.0');
		// Add child node Verb under Timestamp with a value of formatted dateTimeNow
        cccrmHeader.addChildElement('Timestamp', mes, null).addTextNode(dateTimeNow);
		// Add child node Verb under Source with a value SFDC
        cccrmHeader.addChildElement('Source', mes, null).addTextNode('SFDC');
		// Add child node Verb under MessageID with a value jobId (passed in parameters)
        cccrmHeader.addChildElement('MessageID', mes, null).addTextNode('');
		// Add child node Verb under Property with a child node Name that has null value
        cccrmHeader.addChildElement('Property', mes, null).addChildElement('Name',mes,null).addTextNode('');
		// Add child node Verb under User with a child node UserID with the value ^CCBVF
        cccrmHeader.addChildElement('User', mes, null).addChildElement('UserID',mes,null).addTextNode('^CCBVF');
        // Add child node Request under CreateCustomerContactRequestMessage
        dom.XmlNode cccrmRequest = cccrm.addChildElement('Request', mes, null);
		// Add child node Payload under CreateCustomerContactRequestMessage
        dom.XmlNode cccrmPayload = cccrm.addChildElement('Payload', cus, null);
		// Add child node CustomerContact under cccrmPayload
        dom.XmlNode cccrmCustomerContact = cccrmPayload.addChildElement('CustomerContact', cus1, null);
		// Loop Related Records
        //for(Related_Records__c rr : custContList){
			// Retrieve CustomerContactClass custom setting value
            CustomerContactClass__c contactClass = CustomerContactClass__c.getInstance(rr.RR_Customer_Contact_Class__c);
            string classCode = contactClass.Code__c;
			// Retrieve CustomerContactType custom setting value
            CustomerContactType__c contactType = CustomerContactType__c.getInstance(rr.RR_Customer_Contact_Type__c);
            string typeCode = contactType.Code__c;
			// Add child node ContactDetails under cccrmCustomerContact
        	dom.XmlNode cccrmContactDetails = cccrmCustomerContact.addChildElement('ContactDetails', cus1, null);
			// Add attribute to ContactDetails for personId
            if(rr.CC_Person_ID__c != null){
            	cccrmContactDetails.setAttribute('personID', rr.CC_Person_ID__c);    
            }
			// Add attribute to ContactDetails for dateTimeNow
            cccrmContactDetails.setAttribute('contactDateTime', dateTimeNow);
			// If there is a class, add attribute to ContactDetails for contactClass
            if(classCode != null){
            	cccrmContactDetails.setAttribute('contactClass', classCode);    
            }
			// If there is a type, add attribute to ContactDetails for contactType
            if(typeCode != null){
            	cccrmContactDetails.setAttribute('contactType', typeCode);    
            }
			// If there are Comments, add attribute to ContactDetails for longDescription
            if(rr.Comments__c != null){
            	cccrmContactDetails.setAttribute('longDescription', rr.Comments__c);    
            }
            /*
            // Create Log Entry under ContactDetails if Completion Comments is not null
            if(rr.Completion_Comments__c != null){
                dom.XmlNode logEntry = cccrmContactDetails.addChildElement('logEntry', cus1, null);
				// Add a child node logEntryRow under logEntry
                dom.XmlNode logEntryRow = logEntry.addChildElement('logEntryRow', cus1, null);
				// Add attribute to logEntryRow for rowAction and logEntry
                logEntryRow.setAttribute('rowAction', 'Add');
                logEntryRow.setAttribute('logEntry', rr.Completion_Comments__c);
            }
            
			// Create Log Entry under ContactDetails if Additional Customer Contact Log is not null
            if(rr.Additional_Customer_Contact_Log__c != null){
                dom.XmlNode logEntry = cccrmContactDetails.addChildElement('logEntry', cus1, null);
				// Add a child node logEntryRow under logEntry
                dom.XmlNode logEntryRow = logEntry.addChildElement('logEntryRow', cus1, null);
				// Add attribute to logEntryRow for rowAction and logEntry
                logEntryRow.setAttribute('rowAction', 'Add');
                logEntryRow.setAttribute('logEntry', rr.Additional_Customer_Contact_Log__c);
            }
			*/
            // Create Characteristic Rows under Contact Details
            dom.XmlNode ccCharacteristic = cccrmContactDetails.addChildElement('ccCharacteristic', cus1, null);
			// If contactType required ACCT ID
            if(contactType.ACCT_ID__c){
				// If ACCT Id is not null, add a characteristicRow for the ACCT-ID
            	if(rr.CC_Account_ID__c != null){
                    dom.XmlNode ccCharacteristicRowACCTID = ccCharacteristic.addChildElement('ccCharacteristicRow', cus1, null);
                    ccCharacteristicRowACCTID.setAttribute('characteristicType', 'ACCT-ID');    
                    ccCharacteristicRowACCTID.setAttribute('characteristicValueFK1', rr.CC_Account_ID__c);    
                }    
            }
			// If contactType required SA ID
            if(contactType.SA_ID__c){
				// If SA Id is not null, add a characteristicRow for the SA-ID
            	if(rr.CC_Service_Agreement_ID__c !=null){
                    dom.XmlNode ccCharacteristicRowSAID = ccCharacteristic.addChildElement('ccCharacteristicRow', cus1, null);
                    ccCharacteristicRowSAID.setAttribute('characteristicType', 'SA-ID');   
                    ccCharacteristicRowSAID.setAttribute('characteristicValueFK1', rr.CC_Service_Agreement_ID__c);    
                }    
            }
			// If contactType required PREM ID
            if(contactType.PREM_ID__c){
				// If Premise Id is not null, add a characteristicRow for the PREM-ID
            	if(rr.CC_Premise_ID__c != null){
                    dom.XmlNode ccCharacteristicRowPREMID = ccCharacteristic.addChildElement('ccCharacteristicRow', cus1, null);
                    ccCharacteristicRowPREMID.setAttribute('characteristicType', 'PREM-ID');  
                    ccCharacteristicRowPREMID.setAttribute('characteristicValueFK1', rr.CC_Premise_ID__c);    
                }    
            }
			// Add characteristicRow for SFWI (Work Item Salesforce Id)
            dom.XmlNode ccCharacteristicRowSFDCWI = ccCharacteristic.addChildElement('ccCharacteristicRow', cus1, null);
            ccCharacteristicRowSFDCWI.setAttribute('characteristicType', 'SFDCWI');
            ccCharacteristicRowSFDCWI.setAttribute('adhocCharacteristicValue', rr.SFDC_Work_Item__c);
           
           // Sending SFDC IDs-Changed to SFDC case NUmber
            
            //ccCharacteristicRowSFDCWI.setAttribute('adhocCharacteristicValue', rr.SFDC_Work_Item__r.CaseNumber);
			// Add characteristicRow for SFRI (Related Record Salesforce Id)
            dom.XmlNode ccCharacteristicRowSFDCWRI = ccCharacteristic.addChildElement('ccCharacteristicRow', cus1, null);
            ccCharacteristicRowSFDCWRI.setAttribute('characteristicType', 'SFDCRI');
          	ccCharacteristicRowSFDCWRI.setAttribute('adhocCharacteristicValue', rr.Id);
            
		// Return XML file
        return doc;
    }
}