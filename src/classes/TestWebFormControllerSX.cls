public without sharing class TestWebFormControllerSX {
    /*----------------------Properties------------------*/
    public Webform_Child_Request__c webformDetailRequest {
        get{
            if(webformDetailRequest == null){
                webformDetailRequest = new Webform_Child_Request__c();
            }   
            return webformDetailRequest;
        }
        set;
    }

    public Webform_Master_Request__c webFormMaster {
        get {
            if (webFormMaster == null) {
                webFormMaster = new Webform_Master_Request__c();
            }
            return webFormMaster;
        }
        set;
    }

    //public Webform_Field_Settings__c webformFS;
    public String webformWIName { get; set; }
    public String submType { get; set; }
    public String  selectedRequestType{get;set;}//string from the drop down menue
    public String  selectedSubmissionType {get; set;}
    public Boolean requestTypeSelected {
        get {
            if (selectedRequestType != null) {
               requestTypeSelected = true;
            }
            return requestTypeSelected;
        }
        set;
        } // use to render the page block when request type has selected
    public Boolean submissionTypeSelected {
        get {
            if (selectedSubmissionType != null) {
                if (selectedSubmissionType.equals('Single')) {
                        submissionTypeSelected = true;
                    } else if (selectedSubmissionType.equals('Multiple')){
                        submissionTypeSelected = false;
                    }
                }
                return submissionTypeSelected;
            }
        set;
    } // use to render the page block based on single/multiple submission type
    public transient Blob csvBody {get;set;}
    public String csvFileName {get;set;}

    transient List<ContentVersion> chatterFiles;
    public List<ContentVersion> getChatterFiles() {
        if (chatterFiles == null) {
            chatterFiles = new List<ContentVersion>();
            for (Integer i=0; i<5; i++) {
            chatterFiles.add(new ContentVersion());
            }
        }
        return chatterFiles;
    }
    public void setChatterFiles(List<ContentVersion> files) {
        this.chatterFiles = files;
    }

    public CsvFileReader csvFileReadCtr {get;set;}
    public ChatterFileUtilities chatterFileUtilities {get;set;}

    // Query for template Id based on work item type selection
    public String templateId {
        get {
            if (selectedRequestType != null) {
                templateId = [select Template_ID__c from Webform_Field_Settings__c where Name = :selectedRequestType limit 1].Template_ID__c;
            }
            return templateId;
        }
        set;
    }

    public Document template {
        get {
            if (templateId != null) {
                return [Select Id, Name from Document where Id = :templateId];
            } else {
                return null;
            }
        }
        set;
    }

    public String infoText {get;set;}
    public String password {get;set;} // to hold password for internal only, it will used to validate against the actual field values on Webform_Field_Setting__c

    public Boolean isExternal {
        get {
            return Site.getPathPrefix().equals('/external');
        }
    }

    public List<String> csvErrorList {get;set;}
    public String batchNumber {get;set;}

    // get IP Address
    public String ipAddress {
        get {
            Map<String, String> mapHeaders = ApexPages.currentPage().getHeaders();
            if (mapHeaders != null) {
                ipAddress = mapHeaders.get('True-Client-IP');

                if (ipAddress == null) {
                    ipAddress = mapHeaders.get('X-Salesforce-SIP');
                }
            }
            return ipAddress;
        }
        set;
    }
    
    public String workItemType {get;set;}
    public FieldSettingUtilities fieldSettingUt {get;set;}
    //public Boolean supportingDocSelected {get;set;}
    public Boolean supportingDocWarning {get;set;}

  /*----------------------Properties------------------*/


    public TestWebFormControllerSX(){
        //supportingDocSelected = false;
        supportingDocWarning = false;
    }    
 
 
    public List<SelectOption> getRequestTypeSelection() {
     
        return getWorkItemTypePicklistValues();
    }

    public List<SelectOption> getSubmissionTypeSelection() {
        return getPicklistValues('Webform_Master_Request__c', 'Submission_Type__c');
    }
    
    public List<SelectOption> getWorkItemTypePicklistValues() {
        ///***** TODO: remove this block of code when site has setup, this is used for me to test internal/external site***/
        //Boolean isExternal;
        //String sitePrefix = ApexPages.currentPage().getParameters().get('sitePrefix');  //Site.getPathPrefix().equals('/external');
        //isExternal = (sitePrefix != null) && (sitePrefix.equals('external'));
        ///***** TODO: remove this block of code when site has setup, this is used for me to test internal/external site***/
        List<Webform_Field_Settings__c> wfs;
        if (isExternal) {
            wfs = [Select Name from Webform_Field_Settings__c where Available_for_External_Users__c = :isExternal];
        } else {
            wfs = [Select Name from Webform_Field_Settings__c];
        }
        List<SelectOption> workItemTypePickvals = new List<SelectOption>();
        workItemTypePickvals.add(New SelectOption('','Select...'));
        for (Webform_Field_Settings__c fs : wfs) {
            workItemTypePickvals.add(new SelectOption(fs.Name, fs.Name));
        }
        return workItemTypePickvals;
        
    }

    public static List<SelectOption> getPicklistValues(String ObjectApi_name,String Field_name){ 

        List<SelectOption> lstPickvals=new List<SelectOption>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        lstPickvals.add(New SelectOption('','Select...'));
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
          lstPickvals.add(New SelectOption(a.getValue(), a.getValue()));//add the value  to our final list
        }

        return lstPickvals;
    }
    
    public void reloadRequestType() {
        fieldSettingUt = null;       
        fieldSettingUt = new FieldSettingUtilities(selectedRequestType);
        fieldSettingUt.getWebformFS();
    }

    public PageReference insertChild(){
        // Verify the reCAPTCHA
        System.debug(logginglevel.info, 'begin verify CAPTCHA');
        
        System.debug('sfdc default message ' + ApexPages.getMessages());
        
        // First time thru, this user's client side reponse is null, so no request to make yet
        if ( response == null || response == '' ) { 
            System.debug(logginglevel.info, 'CAPTCHA response not received from user' );
            correctResponse = false;            
        } 
        else {   
            System.debug(logginglevel.info, 'CAPTCHA response *received* from user' );
            // Send user's client response to Google to be verified
            HttpResponse r = makeRequest(  baseUrl ,
              'secret='+ secret + 
              '&response=' + response +
              '&remoteip=' + remoteHost
            );
            
            // Verify server response, that user's response was good
            if ( r != null ) {  // is null when test methods run
                correctResponse = ( r.getBody().contains('true') );
            } 
            System.debug(logginglevel.info, 'correctResponse==' + correctResponse);
        }
        
        // If User correctly solved the reCAPTCHA, process the Webform Request
        if(correctResponse == true || !isExternal) {
            PageReference confirmationPage = new PageReference('/apex/requestConfirmation');
            confirmationPage.setRedirect(false);
            List<String> errorList = new List<String>();
            Integer fieldErrorCount = 0;

            if (selectedSubmissionType.equals('Single')) {
                // validate password if work item is Miscellaneous Webform
                if (selectedRequestType.equals('Miscellaneous Webform') && this.invalidPassword()) {
                    //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid password'));
                    String passwordError = 'Invalid password';
                    errorList.add(passwordError);
                } else { // If password is valid, continue the submission process   
                    System.debug('Chatter files: ' + chatterFiles);
                    // Create Chatter files
                    chatterFileUtilities = new ChatterFileUtilities(chatterFiles);
                    Map<String, String> chatterFileMap = chatterFileUtilities.uploadFile();
                    System.debug('chatterFileMap ' + chatterFileMap);

                    // email validation if internal
                    if (isEmailValidate(webFormMaster.Requestor_s_Email__c)) {
                        webFormMaster.Requestor_s_Email__c.addError('Email address must contain @pge.com');
                        fieldErrorCount++;
                    }

                    // Single Request fields Validation:
                    if (idFieldNotValid('Account_ID__c', webformDetailRequest.Account_ID__c)) {
                        fieldErrorCount++;
                        webformDetailRequest.Account_ID__c.addError('Account ID needs to be numeric and 10 digits long');
                    } 
                    if (idFieldNotValid('Premise_ID__c', webformDetailRequest.Premise_ID__c)) {
                        webformDetailRequest.Premise_ID__c.addError('Premise ID needs to be numeric and 10 digits long');
                        fieldErrorCount++;
                    } 
                     if (idFieldNotValid('Person_ID__c', webformDetailRequest.Person_ID__c)) {
                        webformDetailRequest.Person_ID__c.addError('Person ID needs to be numeric and 10 digits long');
                        fieldErrorCount++;
                    } 
                     if (idFieldNotValid('RAP_Work_ID__c', webformDetailRequest.RAP_Work_ID__c)) {
                        webformDetailRequest.RAP_Work_ID__c.addError('RAP Work ID needs to be numeric and 10 digits long');
                        fieldErrorCount++;
                    } 
                     if (idFieldNotValid('Field_Order_ID__c', webformDetailRequest.Field_Order_ID__c)) {
                        webformDetailRequest.Field_Order_ID__c.addError('Field Order ID needs to be numeric and 10 digits long');
                        fieldErrorCount++;
                    } 
                     if (idFieldNotValid('Service_Agreement_ID__c', webformDetailRequest.Service_Agreement_ID__c)) {
                        webformDetailRequest.Service_Agreement_ID__c.addError('Service Agreement ID needs to be numeric and 10 digits long');
                        fieldErrorCount++;
                    } 
                     if (idFieldNotValid('Service_Point_ID__c', webformDetailRequest.Service_Point_ID__c)) {
                        webformDetailRequest.Service_Point_ID__c.addError('Service Point ID needs to be numeric and 10 digits long');
                        fieldErrorCount++;
                    } //if (supportingDocSelected) {
                       // errorList.add('Please re-select your supporting documents');
                   // }
                    else if (fieldErrorCount==0) {

                            try {
                                webFormMaster.WI_Type__c = selectedRequestType;
                                webFormMaster.Submission_Type__c = selectedSubmissionType;
                                if (!chatterFileMap.isEmpty()) {
                                    webFormMaster.Supporting_document_IDs__c = chatterFileMap.get('documentIds');
                                }
                                webFormMaster.IP_Address__c = ipAddress;
                                insert webFormMaster;
                                Id webFormMasterId = webFormMaster.Id;
                                webformDetailRequest.Webform_Master_request__c = webFormMasterId;
                                webformDetailRequest.Info__c = fieldSettingUt.webFormFS.Info__c != null ? fieldSettingUt.webFormFS.Info__c : '';
                                batchNumber = [Select Name from Webform_Master_Request__c where Id = :webFormMasterId].Name;
                                System.debug('webFormMaster.Name ' + webFormMaster.Name + ' master Id ' + webFormMaster.Id);

                                if (!chatterFileMap.isEmpty()) {
                                    webformDetailRequest.Supporting_documents_link__c = chatterFileMap.get('documentLinks');
                                }
                                webformDetailRequest.Status__c = 'Pending';
                                try {
                                    insert webformDetailRequest;
                                } catch (DmlException e){
                                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error ' + e.getMessage()));
                                    errorList.add('DML Error ' + e.getMessage());
                                }
                                // update the child request created checkbox on master after record is created 
                                webFormMaster.Child_Requests_created__c = true;
                                update webFormMaster;

                            } catch (DmlException e) {
                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error ' + e.getMessage()));
                                System.debug('Error ' + e.getMessage());
                            }
                        }
                }

            } else if (selectedSubmissionType.equals('Multiple')) {
                // validate password if work item is Miscellaneous Webform
                if (selectedRequestType.equals('Miscellaneous Webform') && this.invalidPassword()) {
                    //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid password'));
                    String passwordError = 'Invalid password';
                    errorList.add(passwordError);
                } else { // If password is valid, continue the submission process  

                    // email validation if internal
                    if (isEmailValidate(webFormMaster.Requestor_s_Email__c)) {
                        webFormMaster.Requestor_s_Email__c.addError('Email address must contain @pge.com');
                        errorList.add('Email address must contain @pge.com');
                    }
                    // validate whether the user has previously selected supporting documents
                    //if (supportingDocSelected) {
                      //  errorList.add('Please re-select your supporting documents');
                   // }
                    System.debug(logginglevel.info, 'CSV BODY ' + csvBody);
                    chatterFileUtilities = new ChatterFileUtilities(chatterFiles);
                    Map<String, String> chatterFileMap = chatterFileUtilities.uploadFile();
                    if (csvBody != null) {
                        try {
                            csvFileReadCtr = new CsvFileReader(csvBody, selectedRequestType);
                            csvErrorList = csvFileReadCtr.readcsvFile();
                        } catch (Exception e) {
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Exception ' + e.getMessage()));
                            PageReference exceptionPage = Page.Exception;
                            exceptionPage.getParameters().put('exception', e.getMessage());
                            return exceptionPage; 
                        }

                        if (csvErrorList.isEmpty()) {
                            try {
                                if (csvFileReadCtr.csvFileBody != null) {
                                    webFormMaster.WI_Type__c = selectedRequestType;
                                    webFormMaster.Submission_Type__c = selectedSubmissionType;
                                    webFormMaster.IP_Address__c = ipAddress;
                                    if (!chatterFileMap.isEmpty()) {
                                        webFormMaster.Supporting_document_IDs__c = chatterFileMap.get('documentIds');
                                    }
                                    insert webFormMaster;                                
                                    Id webFormMasterId = webFormMaster.Id;

                                    if(webFormMaster != null) {
                                        insertAttachment(webFormMasterId);
                                    }
                                    batchNumber = [Select Name from Webform_Master_Request__c where Id = :webFormMasterId].Name;

                                    for (Webform_Child_Request__c childRequest : csvFileReadCtr.webFormList) {
                                        childRequest.Webform_Master_request__c = webFormMasterId;
                                        childRequest.Status__c = 'Pending';
                                        childRequest.Details_of_Request__c = webformDetailRequest.Details_of_Request__c != null ? webformDetailRequest.Details_of_Request__c : '';
                                        if (!chatterFileMap.isEmpty()) {
                                            childRequest.Supporting_documents_link__c = chatterFileMap.get('documentLinks');
                                        }
                                    }
                                    System.debug('webFormList ' + csvFileReadCtr.WebFormList );
                                    if (csvFileReadCtr.WebFormList != null) {
                                        insert csvFileReadCtr.WebformList;
                                    }

                                    // update the child request created checkbox on master after record is created 
                                    webFormMaster.Child_Requests_created__c = true;
                                    update webFormMaster;
                                }
                            } catch(DmlException e) {
                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error ' + e.getMessage()));
                                System.debug('Error ' + e.getMessage());
                                PageReference exceptionPage = Page.Exception;
                                exceptionPage.getParameters().put('exception', e.getMessage());
                                return exceptionPage;
                            } catch (Exception e) {
                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Exception ' + e.getMessage()));
                                System.debug('exception ' + e.getMessage());
                                PageReference exceptionPage = Page.Exception;
                                exceptionPage.getParameters().put('exception', e.getMessage());
                                return exceptionPage;  
                            } 

                        } else {
                            errorList.addAll(csvErrorList);
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error ' + errorList));
                            System.debug('csvErrorList ' + csvErrorList);
                        }
                    } else {
                        errorList.add('CSV Attachment is required');
                    }
                }
            }

            if (errorList.isEmpty() && fieldErrorCount == 0) {
                return confirmationPage;       
            } else {
                //if (chatterFiles != null && !chatterFiles.isEmpty()) {
                //    supportingDocSelected = true;
                //}
                supportingDocWarning = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error' + errorList + '\n' + ' Please re-attach supporting documents if any'));
                return null;
            }
        } else {
            // Correct reCAPTCHA response not received from User. Return to page.
            return null;
        }
    }

    public PageReference returnToPrevious() {
        if (isExternal) {
            PageReference externalPage = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/external');
            return externalPage;
        } else {
            PageReference internalPage = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/internal');
            return internalPage;
        }
    }

    public void insertAttachment(Id masterId) {
        Attachment att = new Attachment();
        att.Body = csvBody;
        att.Name = csvFileName;
        att.ParentId = masterId;
        try {
            insert att;
        } catch (DmlException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error ' + e.getMessage()));
        }
    }   

    // validate the password agianst the Password__c field on Webform_Field_Setting__c
    public Boolean invalidPassword() {
        //System.debug('password entered ' + password + 'password valid? ' + (password == null || !password.equals(webFormFS.Password__c)));
        if (password == null || !password.equals(fieldSettingUt.webFormFS.Password__c)) {
            return true;
        } else {
            return false;
        }
    } 
    

    //public Map<String,Boolean> showFieldMap {
    //    get{
    //        Map<String,Boolean> m = new Map<String,Boolean>();
    //        String fieldValue = '';
    //        Schema.DisplayType fieldDataType = null;
    //        Set<Schema.DisplayType> nonStringDataTypes = new Set<Schema.DisplayType>();
            
    //        for (String f : webformWIFields){
    //            fieldDataType = getFieldDataType('Webform_Field_Settings__c', f);
    //            //system.debug(logginglevel.info,'%%%%%%%%%%%%%  field::fieldDataType %%%%%%%....'+ f +'::'+ fieldDataType);
                                
    //            try {
    //                fieldValue = (String)getWebformFS().get(f);
    //            }
    //            catch(Exception e){
    //                nonStringDataTypes.add(fieldDataType);
    //            }
                
    //            if(nonStringDataTypes.contains(fieldDataType)){
    //                m.put(f,false);
    //            }
    //            else {
    //                fieldValue = (String)getWebformFS().get(f);
    //                //system.debug(logginglevel.info,'%%%%%%%%%%%%%  field::fieldValue %%%%%%%....'+ f +'::'+ fieldValue);
    //                if(fieldValue == 'Required' || fieldValue == 'Visible'){
    //                    m.put(f,true);
    //                }else {
    //                    m.put(f,false);
    //                }
    //            }
    //        }
    //        return m;
    //    }
    //    set;
    //}
    
    //public Map<String,Boolean> requiredFieldMap {
    //    get{
    //        Map<String,Boolean> m = new Map<String,Boolean>();
    //        String fieldValue = '';
    //        Schema.DisplayType fieldDataType = null;
    //        Set<Schema.DisplayType> nonStringDataTypes = new Set<Schema.DisplayType>();

    //        for (String f : webformWIFields){
    //            fieldDataType = getFieldDataType('Webform_Field_Settings__c', f);
    //            //system.debug(logginglevel.info,'%%%%%%%%%%%%%  field::fieldDataType %%%%%%%....'+ f +'::'+ fieldDataType);

    //            try {
    //                fieldValue = (String)getWebformFS().get(f);
    //            }
    //            catch(Exception e){
    //                nonStringDataTypes.add(fieldDataType);
    //            }
                
    //            if(nonStringDataTypes.contains(fieldDataType)){
    //                m.put(f,false);
    //            }
    //            else {
    //                fieldValue = (String)getWebformFS().get(f);
    //                //system.debug(logginglevel.info,'%%%%%%%%%%%%%  field::fieldValue %%%%%%%....'+ f +'::'+ fieldValue);
    //                if(fieldValue == 'Required'){
    //                    m.put(f,true);
    //                }else {
    //                    m.put(f,false);
    //                }
    //            }
    //        }
    //        return m;
    //    }   
    //    set;
    //}

    
    
    //public Webform_Field_Settings__c getWebformFS(){
    //    if(webformFS == null){
    //        if(selectedRequestType != null) {
    //            String wfQueryFields = getWebformQueryFields();
    //            String webformSelectStmt = 'SELECT '+ wfQueryFields + ' FROM Webform_Field_Settings__c where Name = \'' + selectedRequestType + '\'';
    //            //System.debug(logginglevel.info,'#######%%%%%%%%%%%%%%% webformSelectStmt %%%%%%%%%...'+ webformSelectStmt);
    //            webformFS = Database.query(webformSelectStmt);
    //            //System.debug(logginglevel.info,'#######%%%%%%%%%%%%%%% webformFS %%%%%%%%%...'+ webformFS);
    //        }
    //    }
    //    return webformFS;
    //}
    
    //public void setWebformFS(Webform_Field_Settings__c fs) {
    //    this.webFormFS = fs;
    //}
   
    //public List<String> webformWIFields {
    //    get {
    //        List<String> fields = new List<String>();
    //        // Build query fields from Webform Field Settings object
    //        List<Schema.SObjectField> wfwif = Schema.SObjectType.Webform_Field_Settings__c.fields.getMap().values();                
    //        for (Schema.SObjectField w : wfwif) {
    //            fields.add(w.getDescribe().getName());
    //        }
    //        return fields;
    //    }
    //    set;
    //}
    
    
    
    //public String getWebformQueryFields() {
    //    // Build list of field names
    //    String queryFields = '';
    //    queryFields = String.join(webformWIFields,',');
    //    //System.debug(Logginglevel.INFO,'%%%%%%%%%%%%%% queryFields %%%%%%...'+queryFields);
    //    return queryFields;
    //}
    
    
    //public Schema.DisplayType getFieldDataType(String customObjectType, String apiFieldName){
    //    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    //    Schema.SObjectType leadSchema = schemaMap.get(customObjectType);
    //    Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
     
    //    Schema.DisplayType fieldDataType = fieldMap.get(apiFieldName).getDescribe().getType();
    //    return fieldDataType;
    //}

    public Boolean idFieldNotValid (String fieldName, String fieldValue) {
        if ((fieldSettingUt.showFieldMap.get(fieldName) || fieldSettingUt.requiredFieldMap.get(fieldName)) && (fieldValue != null) && (fieldValue.length() < 10 || !fieldValue.isNumeric() )) {
            return true;
        } else {
            return false;
        }
    }

    public Boolean isEmailValidate (String email) {
        if (!isExternal && !email.contains('@pge.com')) {
            return true;
        } else {
            return false;
        }
    }
    
    public PageReference helpPage() {
        PageReference helpPage = Page.WebFormHelpText;
        helpPage.getParameters().put('workItemType', workItemType);
        return helpPage;
    }


    /////////////////////////////////
    /////////// reCAPTCHA ///////////
    /////////////////////////////////
    public String publicKey { 
        get{ return '6LeqEwsTAAAAALQk6D5iIKSiA-bLDp8pjn2qOel8'; }
        set;
    } 
    private static string secret = System.Label.reCAPTCHA_Secret_Key;    
    private static string baseUrl = 'https://www.google.com/recaptcha/api/siteverify';

    public String response {get; set; }  { response = null; } 
    public Boolean correctResponse { get; private set; } { correctResponse = false; } 
    
    
    public static HttpResponse makeRequest(string url, string body)  {
        HttpRequest req = new HttpRequest();   
        HttpResponse response = null;
        req.setEndpoint( url );
        req.setMethod('POST');
        req.setBody ( body);
        try {
            Http http = new Http();
            response = http.send(req);
            System.debug(logginglevel.info,'response: '+ response);
            System.debug(logginglevel.info,'body: '+ response.getBody());
           
        } catch( System.Exception e) {
            System.debug(logginglevel.info,'ERROR: '+ e);
        }
        return response;
    }   
        
    public string remoteHost { get { string ret = '127.0.0.1';
        // also could use x-original-remote-host 
        map<string , string> hdrs = ApexPages.currentPage().getHeaders();
        if ( hdrs.get('x-original-remote-addr') != null)
            ret =  hdrs.get('x-original-remote-addr');
        else if ( hdrs.get('X-Salesforce-SIP') != null)
            ret =  hdrs.get('X-Salesforce-SIP');
        return ret;
    } }

    /////////////////////////////////
    /////////// reCAPTCHA ///////////
    /////////////////////////////////
}