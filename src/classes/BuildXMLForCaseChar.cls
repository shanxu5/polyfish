public class BuildXMLForCaseChar {

	@future(callout=true)
	public static void sendRequest(String workitemId, String caseId, Boolean thrdPartyResReqChanged, Boolean thrdParResChanged, Boolean custRespReqChanged, Boolean custRespResChanged){
		//Case workitem = [select Id, Customer_Response_Required__c, Customer_Response_Resolution__c, CC_B_Case_ID__c, Third_Party_Response__c, Third_Party_Response_Required__c from Case where Id =: workitemId];
		// Create the XML Document
		
		Id IntegrationProfileId = WorkItemAssignmentUtility.getIntegrationProfileId();
		if(UserInfo.getProfileId() != IntegrationProfileId){
			DOM.Document doc = new DOM.Document();
	        doc = getXMLDoc(workitemId, caseId, thrdPartyResReqChanged, thrdParResChanged, custRespReqChanged, custRespResChanged);
	        System.debug(doc.toXmlString());
			// Send the request
	        HttpRequest req = new HttpRequest();
	        req.setClientCertificateName('MTCWPMS01_pge_com');
	        req.setMethod('POST');
	        req.setEndpoint(System.label.Layer_7_Endpoint_for_Case_Status);
	        req.setHeader('Content-Type', 'text/xml;charset=utf-8');
	        req.setHeader('SOAPAction', '""');
	        req.setTimeout(60000);
	        req.setBodyDocument(doc);
	        system.debug('***req'+req);
			Http http = new Http();
			// Instantiate the response
	        HttpResponse res = http.send(req);
	        system.debug('***res'+res);
		}
   	}
	
	public static DOM.Document getXMLDoc(String workitemId, String caseId, Boolean thrdPartyResReqChanged, Boolean thrdParResChanged, Boolean custRespReqChanged, Boolean custRespResChanged) {
        system.debug('***thrdPartyResReqChanged: '+thrdPartyResReqChanged);
        system.debug('***thrdParResChanged: '+thrdParResChanged);
		system.debug('***custRespReqChanged: '+custRespReqChanged);
        system.debug('***custRespResChanged: '+custRespResChanged);
		String currentUserLanId = [select LAN_ID__c from User where Id =: UserInfo.getUserId()].LAN_ID__c;
        Case workItem = [select Id, Customer_Response_Required__c, Customer_Response_Resolution__c, CC_B_Case_ID__c, Third_Party_Response__c, Third_Party_Response_Required__c from Case where Id =: workitemId];
        Set<String> fieldAPIs = new Set<String>();
        fieldAPIs.add('Customer_Response_Required__c');
        fieldAPIs.add('Customer_Response_Resolution__c');
        fieldAPIs.add('Third_Party_Response__c');
        fieldAPIs.add('Third_Party_Response_Required__c');
		// Create the request envelope
        DOM.Document doc = new DOM.Document();
        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
		// Create root element and set namespaces
        //dom.XmlNode envelope = doc.createRootElement('Envelope', soapNS, '');
        // Add child node body under root element
        //dom.XmlNode body = doc.createRootElement('Body', null, null);
        // Add child node ContactDetails under body
        dom.XmlNode cmwscaseMaint = doc.createRootElement('cmwscaseMaint', null, null);
        cmwscaseMaint.setAttribute('dateTimeTagFormat', 'CdxDateTime');  
        cmwscaseMaint.setAttribute('transactionType', 'UPDATE');
        
        dom.XmlNode cmwscaseMaintService = cmwscaseMaint.addChildElement('cmwscaseMaintService', null, null);
        dom.XmlNode cmwscaseMaintHeader = cmwscaseMaintService.addChildElement('cmwscaseMaintHeader', null, null);
        cmwscaseMaintHeader.setAttribute('CaseID', caseId);
        dom.XmlNode cmwscaseMaintDetails = cmwscaseMaintService.addChildElement('cmwscaseMaintDetails', null, null);
        cmwscaseMaintDetails.setAttribute('Status', '');
        cmwscaseMaintDetails.setAttribute('Substatus', '');
        cmwscaseMaintDetails.setAttribute('CaseID', caseId);
        if(currentUserLanId != null){
          cmwscaseMaintDetails.setAttribute('User', currentUserLanId );  
        }
        dom.XmlNode CaseCharacteristic = cmwscaseMaintDetails.addChildElement('CaseCharacteristic', null, null);
        dom.XmlNode CaseCharacteristicHeader = CaseCharacteristic.addChildElement('CaseCharacteristicHeader', null, null);
        CaseCharacteristicHeader.setAttribute('CaseID', caseId);
        Map<String, List<CC_B_Case_Status_Mapping__c>> mapping = new Map<String, List<CC_B_Case_Status_Mapping__c>>();
        Set<String> addedValue = new Set<String>();
        for(CC_B_Case_Status_Mapping__c csm : [select CC_B_Char_Value__c, CC_B_Char_Type__c, CC_B_Char_Value_Descr__c, SFDC_Field_API_Name__c 
                                               	from CC_B_Case_Status_Mapping__c
                                              	where SFDC_Field_API_Name__c IN: fieldAPIs]){
            if(mapping.containsKey(csm.SFDC_Field_API_Name__c)){
               List<CC_B_Case_Status_Mapping__c> temp = mapping.get(csm.SFDC_Field_API_Name__c);             
               temp.add(csm);
               mapping.put(csm.SFDC_Field_API_Name__c, temp);
            }
            else{
                mapping.put(csm.SFDC_Field_API_Name__c, new List<CC_B_Case_Status_Mapping__c>{csm});	                                            
            }                                        
        }
        system.debug('****mapping: '+mapping);
		if(thrdPartyResReqChanged){
			if(workItem.Third_Party_Response_Required__c == 'No'){
				dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
                CaseCharacteristicRow.setAttribute('CaseID', caseId);
                CaseCharacteristicRow.setAttribute('CharacteristicType', mapping.get('Third_Party_Response_Required__c')[0].CC_B_Char_Type__c);
                CaseCharacteristicRow.setAttribute('CharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('AdhocCharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('CharacteristicValueFK1', '');
				addedValue.add('Third_Party_Response_Required__c');
			}
			else if(workItem.Third_Party_Response_Required__c == 'Yes'){
				dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
                CaseCharacteristicRow.setAttribute('CaseID', caseId);
                CaseCharacteristicRow.setAttribute('CharacteristicType', mapping.get('Third_Party_Response_Required__c')[0].CC_B_Char_Type__c);
                CaseCharacteristicRow.setAttribute('CharacteristicValue', 'Y');
                CaseCharacteristicRow.setAttribute('AdhocCharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('CharacteristicValueFK1', '');
				addedValue.add('Third_Party_Response_Required__c');
			}
		}
		if(thrdParResChanged){
			if(workItem.Third_Party_Response__c != null && workItem.Third_Party_Response__c != ''){
                dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
                CaseCharacteristicRow.setAttribute('CaseID', caseId);
                CaseCharacteristicRow.setAttribute('CharacteristicType', mapping.get('Third_Party_Response__c')[0].CC_B_Char_Type__c);
				for(CC_B_Case_Status_Mapping__c csm : mapping.get('Third_Party_Response__c')){
					 system.debug('****csm.CC_B_Char_Value_Descr__c: '+csm.CC_B_Char_Value_Descr__c);
					 system.debug('****(String)workItem.get(s): '+(String)workItem.get('Third_Party_Response__c'));
					 if(csm.CC_B_Char_Value_Descr__c == (String)workItem.get('Third_Party_Response__c')){
						 CaseCharacteristicRow.setAttribute('CharacteristicValue', csm.CC_B_Char_Value__c);
						 CaseCharacteristicRow.setAttribute('AdhocCharacteristicValue', '');
						 CaseCharacteristicRow.setAttribute('CharacteristicValueFK1', '');
					 }
				 }
			}
			else{
				if(!addedValue.contains('Third_Party_Response_Required__c')){
					dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
					CaseCharacteristicRow.setAttribute('CaseID', caseId);
					CaseCharacteristicRow.setAttribute('CharacteristicType', mapping.get('Third_Party_Response_Required__c')[0].CC_B_Char_Type__c);
					CaseCharacteristicRow.setAttribute('CharacteristicValue', '');
					CaseCharacteristicRow.setAttribute('AdhocCharacteristicValue', '');
					CaseCharacteristicRow.setAttribute('CharacteristicValueFK1', '');
					addedValue.add('Third_Party_Response_Required__c');
				}
				dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
                CaseCharacteristicRow.setAttribute('CaseID', caseId);
                CaseCharacteristicRow.setAttribute('CharacteristicType', mapping.get('Third_Party_Response__c')[0].CC_B_Char_Type__c);
                CaseCharacteristicRow.setAttribute('CharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('AdhocCharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('CharacteristicValueFK1', '');
				addedValue.add('Third_Party_Response__c');
			}
		}
		if(custRespReqChanged){
			if(workItem.Customer_Response_Required__c == 'No'){
				dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
                CaseCharacteristicRow.setAttribute('CaseID', caseId);
                CaseCharacteristicRow.setAttribute('CharacteristicType', mapping.get('Customer_Response_Required__c')[0].CC_B_Char_Type__c);
                CaseCharacteristicRow.setAttribute('CharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('AdhocCharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('CharacteristicValueFK1', '');
				addedValue.add('Customer_Response_Required__c');
			}
			else if(workItem.Customer_Response_Required__c == 'Yes'){
				dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
                CaseCharacteristicRow.setAttribute('CaseID', caseId);
                CaseCharacteristicRow.setAttribute('CharacteristicType', mapping.get('Customer_Response_Required__c')[0].CC_B_Char_Type__c);
                CaseCharacteristicRow.setAttribute('CharacteristicValue', 'Y');
                CaseCharacteristicRow.setAttribute('AdhocCharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('CharacteristicValueFK1', '');
				addedValue.add('Customer_Response_Required__c');
			}
		}
		if(custRespResChanged){
			if(workItem.Customer_Response_Resolution__c != null && workItem.Customer_Response_Resolution__c != ''){
                dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
                CaseCharacteristicRow.setAttribute('CaseID', caseId);
                CaseCharacteristicRow.setAttribute('CharacteristicType', mapping.get('Customer_Response_Resolution__c')[0].CC_B_Char_Type__c);
				for(CC_B_Case_Status_Mapping__c csm : mapping.get('Customer_Response_Resolution__c')){
					 system.debug('****csm.CC_B_Char_Value_Descr__c: '+csm.CC_B_Char_Value_Descr__c);
					 system.debug('****(String)workItem.get(s): '+(String)workItem.get('Customer_Response_Resolution__c'));
					 if(csm.CC_B_Char_Value_Descr__c == (String)workItem.get('Customer_Response_Resolution__c')){
						 CaseCharacteristicRow.setAttribute('CharacteristicValue', csm.CC_B_Char_Value__c);
						 CaseCharacteristicRow.setAttribute('AdhocCharacteristicValue', '');
						 CaseCharacteristicRow.setAttribute('CharacteristicValueFK1', '');
					 }
				 }
			}
			else{
				if(!addedValue.contains('Customer_Response_Required__c')){
					dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
					CaseCharacteristicRow.setAttribute('CaseID', caseId);
					CaseCharacteristicRow.setAttribute('CharacteristicType', mapping.get('Customer_Response_Required__c')[0].CC_B_Char_Type__c);
					CaseCharacteristicRow.setAttribute('CharacteristicValue', '');
					CaseCharacteristicRow.setAttribute('AdhocCharacteristicValue', '');
					CaseCharacteristicRow.setAttribute('CharacteristicValueFK1', '');
					addedValue.add('Customer_Response_Required__c');
				}
				dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
                CaseCharacteristicRow.setAttribute('CaseID', caseId);
                CaseCharacteristicRow.setAttribute('CharacteristicType', mapping.get('Customer_Response_Resolution__c')[0].CC_B_Char_Type__c);
                CaseCharacteristicRow.setAttribute('CharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('AdhocCharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('CharacteristicValueFK1', '');
				addedValue.add('Customer_Response_Resolution__c');
			}
		}
		
        /*if(workItem.Customer_Response_Required__c == 'No' || workItem.Third_Party_Response_Required__c == 'No'){
            if(workItem.Customer_Response_Required__c == 'No' && custRespReqChanged){
                system.debug('**** 1st');
                dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
                CaseCharacteristicRow.setAttribute('CaseID', caseId);
                CaseCharacteristicRow.setAttribute('CharacteristicType', mapping.get('Customer_Response_Required__c')[0].CC_B_Char_Type__c);
                CaseCharacteristicRow.setAttribute('CharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('AdhocCharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('CharacteristicValueFK1', '');
                addedValue.add('Customer_Response_Required__c');
            }
            else if(workItem.Customer_Response_Required__c == 'Yes' && custRespReqChanged){
                system.debug('**** 2nd');
                dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
                CaseCharacteristicRow.setAttribute('CaseID', caseId);
                CaseCharacteristicRow.setAttribute('CharacteristicType', mapping.get('Customer_Response_Required__c')[0].CC_B_Char_Type__c);
                CaseCharacteristicRow.setAttribute('CharacteristicValue', 'Y');
                CaseCharacteristicRow.setAttribute('AdhocCharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('CharacteristicValueFK1', '');
                addedValue.add('Customer_Response_Required__c');
            }
            if(workItem.Third_Party_Response_Required__c == 'No' && thrdPartyResReqChanged){
                system.debug('**** 3rd');
                dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
                CaseCharacteristicRow.setAttribute('CaseID', caseId);
                CaseCharacteristicRow.setAttribute('CharacteristicType', mapping.get('Third_Party_Response_Required__c')[0].CC_B_Char_Type__c);
                CaseCharacteristicRow.setAttribute('CharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('AdhocCharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('CharacteristicValueFK1', '');
                addedValue.add('Third_Party_Response_Required__c');
            }
            else if(workItem.Third_Party_Response_Required__c == 'Yes' && thrdPartyResReqChanged){
                system.debug('**** 4th');
                dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
                CaseCharacteristicRow.setAttribute('CaseID', caseId);
                CaseCharacteristicRow.setAttribute('CharacteristicType', mapping.get('Third_Party_Response_Required__c')[0].CC_B_Char_Type__c);
                CaseCharacteristicRow.setAttribute('CharacteristicValue', 'Y');
                CaseCharacteristicRow.setAttribute('AdhocCharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('CharacteristicValueFK1', '');
                addedValue.add('Customer_Response_Required__c');
            }
        }
        else if(workItem.Customer_Response_Required__c == null && workItem.Customer_Response_Resolution__c == null){
            if(workItem.Third_Party_Response__c == null && workItem.Third_Party_Response_Required__c == null){
                for(String s : mapping.keySet()){
                    dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
                    CaseCharacteristicRow.setAttribute('CaseID', caseId);
                    CaseCharacteristicRow.setAttribute('CharacteristicType', mapping.get(s)[0].CC_B_Char_Type__c);
                    CaseCharacteristicRow.setAttribute('CharacteristicValue', '');
                    CaseCharacteristicRow.setAttribute('AdhocCharacteristicValue', '');
                    CaseCharacteristicRow.setAttribute('CharacteristicValueFK1', '');
                    addedValue.add(s);
                }
            }
            else if(workItem.Third_Party_Response__c != null && workItem.Third_Party_Response_Required__c != null){
                dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
                CaseCharacteristicRow.setAttribute('CaseID', caseId);
                CaseCharacteristicRow.setAttribute('CharacteristicType', mapping.get('Customer_Response_Required__c')[0].CC_B_Char_Type__c);
                CaseCharacteristicRow.setAttribute('CharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('AdhocCharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('CharacteristicValueFK1', '');
                addedValue.add('Customer_Response_Required__c');
                dom.XmlNode CaseCharacteristicRow2 = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
                CaseCharacteristicRow2.setAttribute('CaseID', caseId);
                CaseCharacteristicRow2.setAttribute('CharacteristicType', mapping.get('Customer_Response_Resolution__c')[0].CC_B_Char_Type__c);
                CaseCharacteristicRow2.setAttribute('CharacteristicValue', '');
                CaseCharacteristicRow2.setAttribute('AdhocCharacteristicValue', '');
                CaseCharacteristicRow2.setAttribute('CharacteristicValueFK1', '');
                addedValue.add('Customer_Response_Resolution__c');
            }
        }
        else if(workItem.Third_Party_Response__c == null && workItem.Third_Party_Response_Required__c == null){
            if(workItem.Customer_Response_Required__c != null && workItem.Customer_Response_Required__c != null){
                dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
                CaseCharacteristicRow.setAttribute('CaseID', caseId);
                CaseCharacteristicRow.setAttribute('CharacteristicType', mapping.get('Third_Party_Response__c')[0].CC_B_Char_Type__c);
                CaseCharacteristicRow.setAttribute('CharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('AdhocCharacteristicValue', '');
                CaseCharacteristicRow.setAttribute('CharacteristicValueFK1', '');
                addedValue.add('Third_Party_Response__c');
                dom.XmlNode CaseCharacteristicRow2 = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
                CaseCharacteristicRow2.setAttribute('CaseID', caseId);
                CaseCharacteristicRow2.setAttribute('CharacteristicType', mapping.get('Third_Party_Response_Required__c')[0].CC_B_Char_Type__c);
                CaseCharacteristicRow2.setAttribute('CharacteristicValue', '');
                CaseCharacteristicRow2.setAttribute('AdhocCharacteristicValue', '');
                CaseCharacteristicRow2.setAttribute('CharacteristicValueFK1', '');
                addedValue.add('Third_Party_Response_Required__c');
            }
        }
        else{
            system.debug('*** the code went here ***');
             for(String s : mapping.keySet()){
                 system.debug('*** s: '+s);
                 if((String)workItem.get(s) != null && !addedValue.contains(s)){
                     dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
                     CaseCharacteristicRow.setAttribute('CaseID', caseId);
                     CaseCharacteristicRow.setAttribute('CharacteristicType', mapping.get(s)[0].CC_B_Char_Type__c);
                     for(CC_B_Case_Status_Mapping__c csm : mapping.get(s)){
                         system.debug('****csm.CC_B_Char_Value_Descr__c: '+csm.CC_B_Char_Value_Descr__c);
                         system.debug('****(String)workItem.get(s): '+(String)workItem.get(s));
                         if(csm.CC_B_Char_Value_Descr__c == (String)workItem.get(s)){
                             CaseCharacteristicRow.setAttribute('CharacteristicValue', csm.CC_B_Char_Value__c);
                             CaseCharacteristicRow.setAttribute('AdhocCharacteristicValue', '');
                             CaseCharacteristicRow.setAttribute('CharacteristicValueFK1', '');
                         }
                     }
                 }
             }
        }*/
        return doc;	
	}
}