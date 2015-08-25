public with sharing class TestRequestForm {
    public Webform_Child_Request__c webformChildRequest {
        get {
            if(webformChildRequest == null){
                webformChildRequest = new Webform_Child_Request__c();
            }  
            return webformChildRequest;
        }
        set;
    }
    
    
    public PageReference insertRecord() {
        Webform_Master_Request__c masterRecord = [Select Id from Webform_Master_Request__c where Id = 'a0jq0000000kzix'];
        Id masterRecordId = masterRecord.Id;
        
        webformChildRequest.Webform_Master_request__c = masterRecordId;
        System.debug('web form child request ' + webformChildRequest);
        Database.insert(webformChildRequest);
        
        return null;
    }
    
}