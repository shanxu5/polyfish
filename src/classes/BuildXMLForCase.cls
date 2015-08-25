public class BuildXMLForCase {
  @InvocableMethod(label='Case Status Change' description='Send a request to OSB to update CC&B Case Status together with Required Characteristics')
  public static void buildRequest(List<Case> workitems){
    Id IntegrationProfileId = WorkItemAssignmentUtility.getIntegrationProfileId();
    if(UserInfo.getProfileId() != IntegrationProfileId){
      sendRequest(workitems[0].Id);
    }
  }
  @future(callout=true)
  public static void sendRequest(Id workitemId){
    Case workitem = [select Id, LAN_ID__c, Status, CC_B_Case_ID__c, Sub_Status__c, Work_Item_Type__c from Case where Id =: workitemId];
    // Create the XML Document
        DOM.Document doc = new DOM.Document();
        doc = getXMLDoc(workitem);
        System.debug(doc.toXmlString());
    // Send the request
        HttpRequest req = new HttpRequest();
        req.setClientCertificateName(System.Label.Certificate_Name);
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
  public static DOM.Document getXMLDoc(Case workItem) {
  	String currentUserLanId = [select LAN_ID__c from User where Id =: UserInfo.getUserId()].LAN_ID__c;
    Map<String,Work_Item_Type_Cases__c> CaseCategoryMap = Work_Item_Type_Cases__c.getAll();
    // Create the request envelope
        DOM.Document doc = new DOM.Document();
        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
    // Create root element and set namespaces
        //dom.XmlNode envelope = doc.createRootElement('Envelope', soapNS, '');
        // Add child node body under root element
        //dom.XmlNode body = doc.createRootElement('Body', null, null);
        // Add child node ContactDetails under body
        dom.XmlNode cmwscaseMaint =  doc.createRootElement('cmwscaseMaint', null, null);
        cmwscaseMaint.setAttribute('dateTimeTagFormat', 'CdxDateTime');  
        cmwscaseMaint.setAttribute('transactionType', 'UPDATE');
        
        dom.XmlNode cmwscaseMaintService = cmwscaseMaint.addChildElement('cmwscaseMaintService', null, null);
        dom.XmlNode cmwscaseMaintHeader = cmwscaseMaintService.addChildElement('cmwscaseMaintHeader', null, null);
        cmwscaseMaintHeader.setAttribute('CaseID', workItem.CC_B_Case_ID__c);
        dom.XmlNode cmwscaseMaintDetails = cmwscaseMaintService.addChildElement('cmwscaseMaintDetails', null, null);
        cmwscaseMaintDetails.setAttribute('CaseID', workItem.CC_B_Case_ID__c);
        cmwscaseMaintDetails.setAttribute('Status', workItem.Status);
        if(workItem.Sub_Status__c == 'QAS Approved' || workItem.Sub_Status__c == 'QAS Denied' || workItem.Sub_Status__c == 'Redirect'){
          cmwscaseMaintDetails.setAttribute('SubStatus', workItem.Sub_Status__c);
        }
        else{
          cmwscaseMaintDetails.setAttribute('SubStatus', ''); 
        }
        if(currentUserLanId != null){
          cmwscaseMaintDetails.setAttribute('User', currentUserLanId );  
        }
        // Send Case Category
    if(CaseCategoryMap.containsKey(workItem.Work_Item_Type__c)){
      cmwscaseMaintDetails.setAttribute('Category', CaseCategoryMap.get(workItem.Work_Item_Type__c).Category__c);
    }
    
    dom.XmlNode CaseCharacteristic = cmwscaseMaintDetails.addChildElement('CaseCharacteristic', null, null);
      
    List<CC_B_Case_Status_Mapping__c> caseStatusMapping = [select Id, CC_B_Char_Type__c, 
                                  SFDC_Field_API_Name__c, 
                                  SFDC_Status__c, 
                                  SFDC_Sub_Status__c,
                                  CC_B_Char_Value__c,
                                  CC_B_Char_Value_Descr__c,
								  CC_B_Value_Type__c,
                                  Category__c
                                from CC_B_Case_Status_Mapping__c
                                where SFDC_Status__c=: workItem.Status
                                and Category__c =: CaseCategoryMap.get(workItem.Work_Item_Type__c).Category__c];
    if(caseStatusMapping.size() > 0){
      Map<String, String> charValueMap = new Map<String, String>();
      Set<String> fields = new Set<String>();
      List<CC_B_Case_Status_Mapping__c> neededMappings = new List<CC_B_Case_Status_Mapping__c>();
      String queryString = 'SELECT Id, CC_B_Case_ID__c, Status, Sub_Status__c, LAN_ID__c, Work_Item_Type__c';
      for(CC_B_Case_Status_Mapping__c ccb : caseStatusMapping){
        if(!fields.contains(ccb.SFDC_Field_API_Name__c)){
          queryString += ', '+ccb.SFDC_Field_API_Name__c;
          fields.add(ccb.SFDC_Field_API_Name__c);
        }
		charValueMap.put(ccb.CC_B_Char_Value_Descr__c, ccb.CC_B_Char_Value__c);
      }
      queryString += ' FROM Case WHERE Id =\''+workItem.Id+'\'';
      system.debug('***queryString: '+queryString);
      workItem = Database.query(queryString);
      system.debug('***caseStatusMapping: '+caseStatusMapping);
      for(CC_B_Case_Status_Mapping__c ccb : caseStatusMapping){
        String charValueDesc = string.valueOf(workitem.get(ccb.SFDC_Field_API_Name__c));
        System.debug('ccb.CC_B_Char_Value__c: '+ccb.CC_B_Char_Value__c);
        System.debug('charValueDesc: '+charValueDesc);
        System.debug('charValueMap.containsKey(charValueDesc): '+charValueMap.containsKey(charValueDesc));
        
        if(charValueDesc != null && ((charValueMap.containsKey(charValueDesc) && ccb.CC_B_Char_Value_Descr__c == charValueDesc ) ||  ccb.CC_B_Char_Value__c == null)){
            if((workItem.Sub_Status__c == 'Redirect' || workItem.Sub_Status__c == 'QAS Denied' || workItem.Sub_Status__c == 'QAS Approved') && workItem.Sub_Status__c == ccb.SFDC_Sub_Status__c){
                neededMappings.add(ccb);
            } 
            else if(workItem.Sub_Status__c != 'Redirect' && workItem.Sub_Status__c != 'QAS Denied' && workItem.Sub_Status__c != 'QAS Approved'){
                neededMappings.add(ccb);
            }
        }
      }
	  Schema.DescribeFieldResult fieldResult = CC_B_Case_Status_Mapping__c.CC_B_Value_Type__c.getDescribe();
	  List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      for(CC_B_Case_Status_Mapping__c ccb : neededMappings){
        String charValueDesc = string.valueOf(workitem.get(ccb.SFDC_Field_API_Name__c));
        if(charValueDesc != null && charValueDesc.contains(' 00:00:00')){
              charValueDesc = charValueDesc.left(10);
        }
        System.debug('ccb.CC_B_Char_Value__c: '+ccb.CC_B_Char_Value__c);
        System.debug('charValueDesc: '+charValueDesc);
        System.debug('charValueMap.get(charValueDesc): '+charValueMap.get(charValueDesc));
        System.debug('charValueMap: '+charValueMap);
        if(ccb.CC_B_Char_Value__c == null){
          if(charValueDesc != null){
            dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
            CaseCharacteristicRow.setAttribute('rowAction', 'Add');
            CaseCharacteristicRow.setAttribute('CaseID', workItem.CC_B_Case_ID__c);
            CaseCharacteristicRow.setAttribute('CharacteristicType', ccb.CC_B_Char_Type__c);
            for(Schema.PicklistEntry pe : ple){
                if(ccb.CC_B_Value_Type__c == String.valueOf(pe.getLabel())){
                    CaseCharacteristicRow.setAttribute(ccb.CC_B_Value_Type__c, charValueDesc);  
                }
                else{
                    CaseCharacteristicRow.setAttribute(String.valueOf(pe.getLabel()), '');  
                }
              }
          }
        }
        else{
          if(charValueDesc != null && charValueMap.containsKey(charValueDesc)){
            dom.XmlNode CaseCharacteristicRow = CaseCharacteristic.addChildElement('CaseCharacteristicRow', null, null);
            CaseCharacteristicRow.setAttribute('rowAction', 'Add');
            CaseCharacteristicRow.setAttribute('CaseID', workItem.CC_B_Case_ID__c);
            CaseCharacteristicRow.setAttribute('CharacteristicType', ccb.CC_B_Char_Type__c);
            //CaseCharacteristicRow.setAttribute(ccb.CC_B_Value_Type__c, charValueMap.get(charValueDesc));
			for(Schema.PicklistEntry pe : ple){
                System.debug('ccb.CC_B_Value_Type__c: '+ccb.CC_B_Value_Type__c);
        		System.debug('String.valueOf(pe.getLabel()): '+String.valueOf(pe.getLabel()));
                if(ccb.CC_B_Value_Type__c == String.valueOf(pe.getLabel())){
                    CaseCharacteristicRow.setAttribute(ccb.CC_B_Value_Type__c, charValueMap.get(charValueDesc));  
                }
                else{
                    CaseCharacteristicRow.setAttribute(String.valueOf(pe.getLabel()), '');  
                }
            }
          }
        }
        
      }
    }
        return doc;  
  }
}