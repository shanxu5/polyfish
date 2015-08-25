public class reCAPTCHA {

    public String publicKey { 
        get{ return '6LeqEwsTAAAAALQk6D5iIKSiA-bLDp8pjn2qOel8';	}
        set;
    } 
    private static string secret = '6LeqEwsTAAAAALNpNmXvbqdsQknBKJiTGBVKjdBn';    
    private static string baseUrl = 'https://www.google.com/recaptcha/api/siteverify';

    /*
    reCAPTCHA API Documentation
    
    reCAPTCHA is a freely available CAPTCHA implementation. It distinguishes humans from computers. This may be useful for:
    
        * A registration page for a forum or wiki.
        * A comment form.
        * Hiding information that could be useful to spammers (we recommend the reCAPTCHA Mailhide API for this).
    
    How the reCAPTCHA API Works
    
    API diagram
    
       1. The user loads the web page with the reCAPTCHA challenge JavaScript embedded.
       2. The users browser requests a challenge from reCAPTCHA. reCAPTCHA gives the user a challenge and a token that identifies the challenge.
       3. The user fills out the web page form, and submits the result to your application server, along with the challenge token.
       4. reCAPTCHA checks the users answer, and gives you back a response.
       5. If true, generally you will allow the user access to some service or information. E.g. allow them to comment on a forum, register for a wiki, or get access to an email address. If false, you can allow the user to try again.
    
    This document describes the validation steps in the process. Our Client API is used to embed the reCAPTCHA on your website.
    
    Signing up for a reCAPTCHA Key
    
    In order to use reCAPTCHA, you need a public/private API key pair. This key pair helps to prevent an attack where somebody hosts a reCAPTCHA on their website, collects answers from their visitors and submits the answers to your site. You can sign up for a key on the reCAPTCHA Administration Portal.
    Key Scope
    
    Your reCAPTCHA token is valid only at the domain you sign up for and any subdomains (due to the potential attack mentioned above). Some users require keys for multiple sites, for example, a development server and a production server or simply multiple sites hosted on the same server. Three techniques can be used to work around this:
    
        * If one of your servers is "localhost" or "127.0.0.1", reCAPTCHA will not enforce the same-domain rule. Just use the same key as for the production server.
        * Generate a key for a broader scope. For example, if your application is a.example.com and your test server is test.corp.example.com, generate a key for example.com.
        * Generate a different key for each domain.
    
    Getting a reCAPTCHA Challenge
    
    Your application will need to display a reCAPTCHA challenge on your web page. This can be done with the Client API, a piece of JavaScript code which lets you embed the CAPTCHA on your website.
    
    Verifying the reCAPTCHA Solution
    
    URL     http://api-verify.recaptcha.net/verify
    Parameters (sent via POST)  
    privatekey (required)   Your private key
    remoteip (required)     The IP address of the user who solved the CAPTCHA.
    challenge (required)    The value of "recaptcha_challenge_field" sent via the form
    response (required)     The value of "recaptcha_response_field" sent via the form
    Response    The response from verify is a series of strings separated by \n. To read the string, split the line and read each field. New lines may be added in the future. Implementations should ignore these lines
    Line 1  "true" or "false". True if the reCAPTCHA was successful
    Line 2  if Line 1 is false, then this string will be an error code. reCAPTCHA can display the error to the user (through the error parameter of api.recaptcha.net/challenge). Implementations should not depend on error code names, as they may change in the future.
    
    Example: If your response looks like this:
    
    false
    incorrect-captcha-sol
    
    ... you can add '&error=incorrect-captcha-sol' to the challenge request URL, and the user will get an error code.

    */
    //public string challenge {get; set;} { challenge = null; } 
    public string response {get; set; }  { response = null; } 

    public Boolean correctResponse { get; private set; } { correctResponse = false; } 
    
    public PageReference verify() {
        system.debug(logginglevel.info, 'verify called ');
        // first time thru, this paramater is null, so no request to make yet
        //if ( challenge == null || response == null ) { 
        if ( response == null ) { 
            system.debug(logginglevel.info, 'verify called null' );
            return null; 
        }
                
        HttpResponse r = makeRequest(  baseUrl ,
          'secret='+ secret + 
          '&response=' + response +
          '&remoteip=' + remoteHost +                                      
          '&error=incorrect-captcha-sol'
        );
        
        if ( r != null ) {  // is null when test methods run
            correctResponse = ( r.getBody().contains('true') );
        } 
        system.debug(logginglevel.info, 'correctResponse==' + correctResponse);
        return null;    
    }
    
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
/*      
    public static  testmethod void test_1() {
        reCaptcha re = new reCaptcha();
        string href = baseUrl;
        re.challenge = re.response = 'foo';
        string publick = re.publicKey; 
        string host = re.remoteHost; 
        re.verify();
    }
    public static  testmethod void test_2() {
        reCaptcha re = new reCaptcha();
        re.verify();
    }
*/  
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

    public Webform_Field_Settings__c webformFS;
    public String webformWIName { get; set; }
    public String submType { get; set; }
    public String  selectedRequestType{get;set;}//string from the drop down menue
    public String  selectedSubmissionType {get; set;}
    public String getSelectedSubType(){
        return selectedSubmissionType;
    }
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
    public Blob csvBody {get;set;}
    public String csvFileName {get;set;}
    public List<ContentVersion> chatterFiles {
        get {
            if (chatterFiles == null) {
                chatterFiles = new List<ContentVersion>();
                for (Integer i=0; i<5; i++) {
                chatterFiles.add(new ContentVersion());
                }
            }
            return chatterFiles;
        }
        set;
    }

    public csvFileReaderController2 csvFileReadCtr {get;set;}
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
  /*----------------------Properties------------------*/


    public reCAPTCHA(){
        
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
        List<Webform_Field_Settings__c> wfs = [Select Name from Webform_Field_Settings__c where Available_for_External_Users__c = :isExternal];
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

    public void renderInfoField() {
        infoText = [Select Info__c from Webform_Field_Settings__c where Name = :selectedRequestType].Info__c;
    }
    
    public void reloadRequestType() {
        webformFS = null;
        getWebformFS();
        System.debug('selectedRequestType ' + selectedRequestType);
    }

    public PageReference insertChild(){
        // Verify the CAPTCHA
        system.debug(logginglevel.info, 'begin verify CAPTCHA');
        // first time thru, this paramater is null, so no request to make yet
        //if ( challenge == null || response == null ) { 
        if ( response == null || response == '' ) { 
            system.debug(logginglevel.info, 'CAPTCHA response not received from user' );
            correctResponse = false;            
        } 
        else {   
            system.debug(logginglevel.info, 'CAPTCHA response *received* from user' );
            HttpResponse r = makeRequest(  baseUrl ,
              'secret='+ secret + 
              '&response=' + response +
              '&remoteip=' + remoteHost
            );
            
            if ( r != null ) {  // is null when test methods run
                correctResponse = ( r.getBody().contains('true') );
            } 
            system.debug(logginglevel.info, 'correctResponse==' + correctResponse);
            // 
            // 
            // 
        }
        
        if(correctResponse == true) {                   
            PageReference confirmationPage = new PageReference('/apex/requestConfirmation');
            confirmationPage.setRedirect(false);
            List<String> errorList = new List<String>();
    
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
                        errorList.add('Email address must contain @pge.com');
                    }
    
                    // Single Request fields Validation:
                    if (idFieldNotValid('Account_ID__c', webformDetailRequest.Account_ID__c)) {
                        errorList.add('Account ID needs to be numeric and 10 digits long');
                        //System.debug('errorList after single validation ' + errorList);
                        webformDetailRequest.Account_ID__c.addError('Account ID needs to be numeric and 10 digits long');
                        //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Account ID needs to be numeric and 10 digits long'));
                    } 
                    if (idFieldNotValid('Premise_ID__c', webformDetailRequest.Premise_ID__c)) {
                        webformDetailRequest.Premise_ID__c.addError('Premise ID needs to be numeric and 10 digits long');
                        errorList.add('Premise ID needs to be numeric and 10 digits long');
                    } 
                     if (idFieldNotValid('Person_ID__c', webformDetailRequest.Person_ID__c)) {
                        webformDetailRequest.Person_ID__c.addError('Person ID needs to be numeric and 10 digits long');
                        errorList.add('Person ID needs to be numeric and 10 digits long');
                    } 
                     if (idFieldNotValid('RAP_Work_ID__c', webformDetailRequest.RAP_Work_ID__c)) {
                        webformDetailRequest.RAP_Work_ID__c.addError('RAP Work ID needs to be numeric and 10 digits long');
                        errorList.add('RAP Work ID needs to be numeric and 10 digits long');
                    } 
                     if (idFieldNotValid('Field_Order_ID__c', webformDetailRequest.Field_Order_ID__c)) {
                        webformDetailRequest.Field_Order_ID__c.addError('Field Order ID needs to be numeric and 10 digits long');
                        errorList.add('Field Order ID needs to be numeric and 10 digits long');
                    } 
                     if (idFieldNotValid('Service_Agreement_ID__c', webformDetailRequest.Service_Agreement_ID__c)) {
                        webformDetailRequest.Service_Agreement_ID__c.addError('Service Agreement ID needs to be numeric and 10 digits long');
                        errorList.add('Service Agreement ID needs to be numeric and 10 digits long');
                    } 
                     if (idFieldNotValid('Service_Point_ID__c', webformDetailRequest.Service_Point_ID__c)) {
                        webformDetailRequest.Service_Point_ID__c.addError('Service Point ID needs to be numeric and 10 digits long');
                        errorList.add('Service Point ID needs to be numeric and 10 digits long');
                    } else {
    
                            try {
                                webFormMaster.WI_Type__c = selectedRequestType;
                                webFormMaster.Submission_Type__c = selectedSubmissionType;
                                if (!chatterFileMap.isEmpty()) {
                                    webFormMaster.Supporting_document_IDs__c = chatterFileMap.get('documentIds');
                                }
                                insert webFormMaster;
                                Id webFormMasterId = webFormMaster.Id;
                                webformDetailRequest.Webform_Master_request__c = webFormMasterId;
                                if (!chatterFileMap.isEmpty()) {
                                    webformDetailRequest.Supporting_documents_link__c = chatterFileMap.get('documentLinks');
                                }
                                insert webformDetailRequest;
    
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
    
                    System.debug('CSV BODY ' + csvBody);
                    chatterFileUtilities = new ChatterFileUtilities(chatterFiles);
                    Map<String, String> chatterFileMap = chatterFileUtilities.uploadFile();
                    if (csvBody != null) {
                        csvFileReadCtr = new csvFileReaderController2(csvBody, selectedRequestType);
                        csvErrorList = csvFileReadCtr.readcsvFile();
                        System.debug('csvErrorList ' + csvErrorList + 'is null? ' + csvErrorList.isEmpty());
    
                        if (csvErrorList.isEmpty()) {
                            try {
                                if (csvFileReadCtr.csvFileBody != null) {
                                    webFormMaster.WI_Type__c = selectedRequestType;
                                    webFormMaster.Submission_Type__c = selectedSubmissionType;
                                    if (!chatterFileMap.isEmpty()) {
                                        webFormMaster.Supporting_document_IDs__c = chatterFileMap.get('documentIds');
                                    }
                                    insert webFormMaster;
                                    if(webFormMaster != null) {
                                        insertAttachment(webFormMaster);
                                    }
                                    Id webFormMasterId = webFormMaster.Id;
                                    for (Webform_Child_Request__c childRequest : csvFileReadCtr.webFormList) {
                                        childRequest.Webform_Master_request__c = webFormMasterId;
                                        if (!chatterFileMap.isEmpty()) {
                                            childRequest.Supporting_documents_link__c = chatterFileMap.get('documentLinks');
                                        }
                                    }
                                    if (csvFileReadCtr.WebFormList != null) {
                                        insert csvFileReadCtr.WebformList;
                                    }
                                }
                            } catch(DmlException e) {
                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error ' + e.getMessage()));
                                System.debug('Error ' + e.getMessage());
                            }
                        } else {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error ' + csvErrorList));
                            System.debug('csvErrorList ' + csvErrorList);
                        }
                    }
                }
            }
    
            if (errorList.isEmpty()) {
                System.debug('errorList ' + errorList);
                return confirmationPage;       
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error ' + errorList));
                return null;
            }
        } else {
            // correct captcha response not received.  return to page.
        	return null;    
        }
        
    }

    public void insertAttachment(Webform_Master_Request__c master) {
        Attachment att = new Attachment();
        att.Body = csvBody;
        att.Name = csvFileName;
        att.ParentId = master.Id;
        try {
            insert att;
            System.debug('insert att? ' + att);
        } catch (DmlException e) {
            System.debug('insert attahcment Error ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error ' + e.getMessage()));
        }
    }   

    // validate the password agianst the Password__c field on Webform_Field_Setting__c
    public Boolean invalidPassword() {
        System.debug('password entered ' + password + 'password valid? ' + (password == null || !password.equals(webFormFS.Password__c)));
        if (password == null || !password.equals(webFormFS.Password__c)) {
            return true;
        } else {
            return false;
        }
    } 
    

    public Map<String,Boolean> showFieldMap {
        get{
            Map<String,Boolean> m = new Map<String,Boolean>();
            String fieldValue = '';
            Schema.DisplayType fieldDataType = null;
            Set<Schema.DisplayType> nonStringDataTypes = new Set<Schema.DisplayType>();
            
            for (String f : webformWIFields){
                fieldDataType = getFieldDataType('Webform_Field_Settings__c', f);
                //system.debug(logginglevel.info,'%%%%%%%%%%%%%  field::fieldDataType %%%%%%%....'+ f +'::'+ fieldDataType);
                                
                try {
                    fieldValue = (String)getWebformFS().get(f);
                }
                catch(Exception e){
                    nonStringDataTypes.add(fieldDataType);
                }
                
                if(nonStringDataTypes.contains(fieldDataType)){
                    m.put(f,false);
                }
                else {
                    fieldValue = (String)getWebformFS().get(f);
                    //system.debug(logginglevel.info,'%%%%%%%%%%%%%  field::fieldValue %%%%%%%....'+ f +'::'+ fieldValue);
                    if(fieldValue == 'Required' || fieldValue == 'Visible'){
                        m.put(f,true);
                    }else {
                        m.put(f,false);
                    }
                }
            }
            return m;
        }
        set;
    }
    
    public Map<String,Boolean> requiredFieldMap {
        get{
            Map<String,Boolean> m = new Map<String,Boolean>();
            String fieldValue = '';
            Schema.DisplayType fieldDataType = null;
            Set<Schema.DisplayType> nonStringDataTypes = new Set<Schema.DisplayType>();

            for (String f : webformWIFields){
                fieldDataType = getFieldDataType('Webform_Field_Settings__c', f);
                //system.debug(logginglevel.info,'%%%%%%%%%%%%%  field::fieldDataType %%%%%%%....'+ f +'::'+ fieldDataType);

                try {
                    fieldValue = (String)getWebformFS().get(f);
                }
                catch(Exception e){
                    nonStringDataTypes.add(fieldDataType);
                }
                
                if(nonStringDataTypes.contains(fieldDataType)){
                    m.put(f,false);
                }
                else {
                    fieldValue = (String)getWebformFS().get(f);
                    //system.debug(logginglevel.info,'%%%%%%%%%%%%%  field::fieldValue %%%%%%%....'+ f +'::'+ fieldValue);
                    if(fieldValue == 'Required'){
                        m.put(f,true);
                    }else {
                        m.put(f,false);
                    }
                }
            }
            return m;
        }   
        set;
    }

    
    
    public Webform_Field_Settings__c getWebformFS(){
        if(webformFS == null){
            if(selectedRequestType != null) {
                String wfQueryFields = getWebformQueryFields();
                String webformSelectStmt = 'SELECT '+ wfQueryFields + ' FROM Webform_Field_Settings__c where Name = \'' + selectedRequestType + '\'';
                System.debug(logginglevel.info,'#######%%%%%%%%%%%%%%% webformSelectStmt %%%%%%%%%...'+ webformSelectStmt);
                webformFS = Database.query(webformSelectStmt);
                System.debug(logginglevel.info,'#######%%%%%%%%%%%%%%% webformFS %%%%%%%%%...'+ webformFS);
            }
        }
        return webformFS;
    }
    
    public void setWebformFS(Webform_Field_Settings__c fs) {
        this.webFormFS = fs;
    }
   
    public List<String> webformWIFields {
        get {
            List<String> fields = new List<String>();
            // Build query fields from Webform Field Settings object
            List<Schema.SObjectField> wfwif = Schema.SObjectType.Webform_Field_Settings__c.fields.getMap().values();                
            for (Schema.SObjectField w : wfwif) {
                fields.add(w.getDescribe().getName());
            }
            return fields;
        }
        set;
    }
    
    
    
    public String getWebformQueryFields() {
        // Build list of field names
        String queryFields = '';
        queryFields = String.join(webformWIFields,',');
        //System.debug(Logginglevel.INFO,'%%%%%%%%%%%%%% queryFields %%%%%%...'+queryFields);
        return queryFields;
    }
    
    
    public Schema.DisplayType getFieldDataType(String customObjectType, String apiFieldName){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(customObjectType);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
     
        Schema.DisplayType fieldDataType = fieldMap.get(apiFieldName).getDescribe().getType();
        return fieldDataType;
    }

    public Boolean idFieldNotValid (String fieldName, String fieldValue) {
        Boolean isTrue = (showFieldMap.get(fieldName) || requiredFieldMap.get(fieldName)) && (fieldValue != null) && (fieldValue.length() < 10 || !fieldValue.isNumeric() );
        System.debug('isTrue ' + isTrue);
        if ((showFieldMap.get(fieldName) || requiredFieldMap.get(fieldName)) && (fieldValue != null) && (fieldValue.length() < 10 || !fieldValue.isNumeric() )) {
            return true;
        } else {
            return false;
        }
    }

    public Boolean isEmailValidate (String email) {
        System.debug('isExternal?? ' + isExternal);
        if (!isExternal && !email.contains('@pge.com')) {
            return true;
        } else {
            return false;
        }
    }
}