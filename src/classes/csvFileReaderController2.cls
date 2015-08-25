public with sharing class csvFileReaderController2 {
    public Boolean displayErr{get;set;}
    public String strDocUrl {get;set;}
    public transient Blob csvFileBody {get;set;}
    public String csvAsString {get;set;}
    public String WorkItem {get;set;}
    public Webform_Field_Settings__c fieldSettings;
    public List <String> error{get;set;}
    public String  errorAccReq{get;set;}
    public String  errorAcclen{get;set;}
    public String errorFieldReq{get;set;}
    public String errorFieldLen{get;set;}
    public String errorPersonReq{get;set;}
    public String errorPersonLen{get;set;}
    public String errorPremiseReq{get;set;}
    public String errorPremiseLen{get;set;}
    public String errorRAPReq{get;set;}
    public String errorRAPLen{get;set;}
    public String errorSAReq{get;set;}
    public String errorSALen{get;set;}
    public String errorSPReq{get;set;}
    public String errorSPLen{get;set;}
    public String errorDR{get;set;}
    public String errorCC{get;set;}
    public String errorIC{get;set;}
    
    // For displaying fields based on single entry
    //Flags for fields, binf the fields to the apex inputfield rendered and required attributes
    public Boolean AccIdReq{get;set;}
    public Boolean AccIdRen{get;set;}   
    //Create similar falgs for rest of the fields
    
	public List< Webform_Child_Request__c > webFormList {get;set;}    
    
    
    ////Single entry controller logic
    //public void actionOnLoad(){
    //    fieldSettings = [Select Account_ID__c,Correct_Constant__c,Incorrect_Constant__c,Field_Order_ID__c,Person_ID__c,Premise_ID__c,RAP_Work_ID__c,Service_Agreement_ID__c,Service_Point_ID__c from Webform_Field_Settings__c where Name =:WorkItem];
        
    //    //Set values for flags
    //    if(fieldSettings.Account_ID__c == 'Required'){
    //        AccIdReq = true;
    //        AccIdRen = true;
    //    }
    //    else if(fieldSettings.Account_ID__c == 'Visible'){
    //        AccIdReq = false;
    //        AccIdRen = true;
    //    }
    //    else if(fieldSettings.Account_ID__c == 'Hidden'){
    //        AccIdReq = false;
    //        AccIdRen = false;
    //    }
    //    // Now check and set for rest of the fields
        
    //}
    
    public csvFileReaderController2(Blob csvBody, String selectedWorkItemType){
        this.csvFileBody = csvBody;
        this.WorkItem = selectedWorkItemType;
        //displayErr = false;
        //try {
        //    List < Document > FirstDocument = [SELECT Id, Name FROM Document WHERE Name = 'template1'
        //        LIMIT 1
        //    ];
        //    String strOrgId = UserInfo.getOrganizationId();
        //    strDocUrl = '/servlet/servlet.FileDownload?file=' + FirstDocument[0].Id;

        //} catch (Exception e) {
        //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error in getDocumentLogoUrl() ' + e.getMessage()));
        //    System.debug('Error: ' + e.getMessage());
        //}
        //System.debug('The URL is ' + strDocUrl);
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The URL returned is ' + strDocUrl));
    }

    
    public List<String> readcsvFile(){
        System.debug('csvFileBody--->-'+csvFileBody);
        
        csvAsString = csvFileBody.toString();
        System.debug('csvAsString --->-'+csvAsString );
        List < List < String >> parsedContent = parseCSV(csvAsString, false);
        fieldSettings = [Select Account_ID__c,Correct_Constant__c,Incorrect_Constant__c,Field_Order_ID__c,Person_ID__c,Premise_ID__c,RAP_Work_ID__c,Service_Agreement_ID__c,Service_Point_ID__c from Webform_Field_Settings__c where Name =:WorkItem];
        
        
        //Specify ur object here
        webFormList = (list < Webform_Child_Request__c > ) csvTosObject(parsedContent, 'Webform_Child_Request__c');
        System.debug('WebFormList--->-'+webFormList);
        error = new List<String>();
        
        if(errorAccReq != null)
            error.add(errorAccReq);
        if(errorAccLen != null)    
            error.add(errorAccLen);
        if(errorFieldReq != null)    
            error.add(errorFieldReq);
        if(errorFieldLen != null)
           error.add (errorFieldLen);
        if(errorPersonReq != null)
           error.add (errorPersonReq);
        if(errorPersonLen!= null)
           error.add (errorPersonLen);
        if (errorPremiseReq != null)
           error.add(errorPremiseReq);
        if (errorPremiseLen != null)
            error.add(errorPremiseLen);
        if (errorRAPReq != null) 
            error.add(errorRAPReq);
        if (errorRAPLen != null)
            error.add (errorRAPLen);
        if (errorSAReq != null)
            error.add (errorSAReq) ;
        if (errorSALen != null) 
            error.add (errorSALen);
        if (errorSPReq != null) 
            error.add (errorSPReq);
        if (errorSPLen != null) 
            error.add (errorSPLen);
        if (errorDR != null)
            error.add (errorDR);
        if (errorCC != null )
            error.add (errorCC);
        if (errorIC != null) 
            error.add (errorIC) ;             


        //if (error.isEmpty()){
        //    Webform_Master_request__c wfr = new Webform_Master_request__c(Requestor_s_Name__c = 'bharghavi', Requestor_s_Email__c = 'bharghavin@slalom.com');
        //    insert wfr;
        //    for (Webform_Child_Request__c wfdetail: WebFormList)
        //        wfdetail.Webform_Master_request__c = wfr.id;
        //    insert WebFormList;
        //}
        //else{
        //    displayErr = true;
        //    System.debug('error---->'+error);
        //}
        return error;
    }

    public List < List < String >> parseCSV(String contents, Boolean skipHeaders) {
        List < List < String >> allFields = new List < List < String >> ();

        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""', ',"DBLQT').replaceall('""",', 'DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""', 'DBLQT');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List < String > lines = new List < String > ();
        try {
            lines = contents.split('\n');
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for (String line: lines) {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',', '').trim().length() == 0) break;

            List < String > fields = line.split(',');
            List < String > cleanFields = new List < String > ();
            String compositeField;
            Boolean makeCompositeField = false;
            for (String field: fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT', '"'));
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT', '"'));
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField += ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT', '"'));
                }
            }

            allFields.add(cleanFields);
        }
        if (skipHeaders) allFields.remove(0);
        return allFields;
    }
    public list < sObject > csvTosObject(List < List < String >> parsedCSV, String objectType) {
        Schema.sObjectType objectDef = Schema.getGlobalDescribe().get(objectType).getDescribe().getSObjectType();
        system.debug(objectDef);
        //Map to store Label and api name
        Map < String, String > labelToAPIName = new Map < String, String > ();
        // Map to store object field describe
        Map < String, Schema.SObjectField > fieldsMap = Schema.SObjectType.Webform_Child_Request__c.fields.getMap();
        //Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.Account.fields.getMap();
        for (Schema.SObjectField field: fieldsMap.values()) {
            labelToAPIName.put(field.getDescribe().getLabel(), field.getDescribe().getName());
        }

        list < sObject > objects = new list < sObject > ();
        list < String > headers = new list < String > ();

        for (list < String > row: parsedCSV) {
            for (String col: row) {
                headers.add(col);
            }
            break;
        }
        system.debug('========================= File Column Headers');
        system.debug(headers);
        //stores row number
        integer rowNumber = 0;
        //stores all the validation errors
     /*
     errorAccReq='';
     errorAcclen = '';
     errorFieldReq = '';
     errorFieldLen = '';
     errorPersonReq = '';
     errorPersonLen ='';
     errorPremiseReq = '';
     errorPremiseLen = '';
     errorRAPReq = '';
     errorRAPLen = '';
     errorSAReq = '';
     errorSALen = '';
     errorSPReq = '';
     errorSPLen = '';
     errorDR = '';
     errorCC = '';
     errorIC = '';
     */
        
        //Iterate each row
        for (list < String > row: parsedCSV) {
            system.debug('========================= Row Index' + rowNumber);
            if (rowNumber == 0) {
                rowNumber++;
                continue;
            } else {
                //Create object instance
                sObject thisObj = objectDef.newSobject();
                //stores column number of each row
                integer colIndex = 0;
                //iterate over the column cells
                for (String col: row) {
                    String headerName = headers[colIndex].trim();
                    System.debug('headerName---->'+headerName);
                    String Value = '';
                    String columnValue = col.trim();
                    //check if header is null or not, if null ignore it
                    if (headerName.length() > 0 ) {
                        //check if header has a corresponding api field
                        if(labelToAPIName.containsKey(headerName)){
                            //if yes, fetch the values and assign it to the appropiate api field
                            String APINAME = labelToAPIName.get(headerName);
                            System.debug('APINAME---->'+APINAME);
                            
                            if(APINAME == 'Account_ID__c'){
                                System.debug('columnValue---->'+columnValue);
                                //check if field is required and if the cell contains data
                                if (fieldSettings.Account_ID__c == 'Required' && (columnValue== null || columnValue.length() == 0 )){

                                   // errorAccReq.add(headerName +' is required. Error at row '+ rowNumber);
                                    errorAccReq= 'Account is required at row '+ rowNumber + '\n';
                                    System.debug('Null Error---->'+columnValue);
                                }
                                else if ((fieldSettings.Account_ID__c == 'Required' || fieldSettings.Account_ID__c == 'Visible') && (columnValue== null || columnValue.length() == 0 || columnValue.length() < 10)){
                                  //errorAccLen.add(headerName +' is not 10 digits. Error at row '+ rowNumber);
                                  errorAccLen = 'Account ID is not 10 digits at row ' + rowNumber + '\n';
                                    System.debug('Size error---->'+columnValue);
                                } 
                                else if ((fieldSettings.Account_ID__c == 'Required' || fieldSettings.Account_ID__c == 'Visible') && (columnValue!= null && columnValue.length() == 10 )){
                                    thisObj.put(APINAME,columnValue); 
                                    System.debug(APINAME+'---->'+columnValue);
                                }   
                                  
                            }
                            if(APINAME == 'Field_Order_ID__c'){
                                System.debug('columnValue---->'+columnValue);
                                //check if field is required and if the cell contains data
                                if (fieldSettings.Field_Order_ID__c == 'Required' && (columnValue== null || columnValue.length() == 0 )){
                                  //  errorFieldReq.add(headerName +' is required. Error at row '+ rowNumber);
                                  errorFieldReq = ' FieldOrder ID is required at row' + rowNumber + '\n';
                                    System.debug('Null Error---->'+columnValue);
                                }
                                else if ((fieldSettings.Field_Order_ID__c == 'Required' || fieldSettings.Field_Order_ID__c == 'Visible') && (columnValue== null || columnValue.length() == 0 || columnValue.length() < 10)){
                                  //errorFieldLen.add(headerName +' is not 10 digits. Error at row '+ rowNumber);
                                 errorFieldLen = ' FieldOrder ID is not of length 10 digits at row ' + rowNumber + '\n';
                                    System.debug('Size error---->'+columnValue);
                                } 
                                else if ((fieldSettings.Field_Order_ID__c == 'Required' || fieldSettings.Field_Order_ID__c == 'Visible') && (columnValue!= null || columnValue.length() == 10 )){
                                    thisObj.put(APINAME,columnValue); 
                                    System.debug(APINAME+'---->'+ columnValue);
                                }   
                                  
                            }
                            
                            if(APINAME == 'Person_ID__c'){
                                System.debug('columnValue---->'+ columnValue);
                                //check if field is required and if the cell contains data
                                if (fieldSettings.Person_ID__c == 'Required' && (columnValue== null || columnValue.length() == 0 )){
                                    errorPersonReq = 'PersonID is required at row' + rowNumber + '\n';
                                    System.debug('Null Error---->'+ columnValue);
                                }
                                else if ((fieldSettings.Person_ID__c == 'Required' || fieldSettings.Person_ID__c == 'Visible') && (columnValue== null || columnValue.length() == 0 || columnValue.length() < 10)){
                                    errorPersonLen = 'PersonID is not of length 10 digits at row ' + rowNumber + '\n';
                                    System.debug('Size error---->'+ columnValue);
                                } 
                                else if ((fieldSettings.Person_ID__c == 'Required' || fieldSettings.Person_ID__c == 'Visible') && (columnValue!= null || columnValue.length() == 10 )){
                                    thisObj.put(APINAME,columnValue); 
                                    System.debug(APINAME+'---->'+ columnValue);
                                }   
                                  
                            }
                            if(APINAME == 'Premise_ID__c'){
                                System.debug('columnValue---->'+ columnValue);
                                //check if field is required and if the cell contains data
                                if (fieldSettings.Premise_ID__c == 'Required' && (columnValue== null || columnValue.length() == 0 )){
                                    errorPremiseReq = 'PremiseID is required at row ' + rowNumber + '\n';
                                    System.debug('Null Error---->'+ columnValue);
                                }
                                else if ((fieldSettings.Premise_ID__c == 'Required' || fieldSettings.Premise_ID__c == 'Visible') && (columnValue== null || columnValue.length() == 0 || columnValue.length() < 10)){
                                    errorPremiseLen = 'Premise ID is not of length 10 digits at row' + rowNumber + '\n';
                                    System.debug('Size error---->'+ columnValue);
                                } 
                                else if ((fieldSettings.Premise_ID__c == 'Required' || fieldSettings.Premise_ID__c == 'Visible') && (columnValue!= null || columnValue.length() == 10 )){
                                    thisObj.put(APINAME,columnValue); 
                                    System.debug(APINAME+'---->'+ columnValue);
                                }   
                                  
                            }
                            if(APINAME == 'RAP_Work_ID__c'){
                                System.debug('columnValue---->'+ columnValue);
                                //check if field is required and if the cell contains data
                                if (fieldSettings.RAP_Work_ID__c == 'Required' && (columnValue== null || columnValue.length() == 0 )){
                                    errorRAPReq = 'RAP ID required at row' +rowNumber + '\n';
                                    System.debug('Null Error---->'+ columnValue);
                                }
                                else if ((fieldSettings.RAP_Work_ID__c == 'Required' || fieldSettings.RAP_Work_ID__c == 'Visible') && (columnValue== null || columnValue.length() == 0 || columnValue.length() < 10)){
                                    errorRAPLen = errorRAPLen + 'RAP ID is not of length 10 digits at row  ' + rowNumber + '\n';
                                    System.debug('Size error---->'+ columnValue);
                                } 
                                else if ((fieldSettings.RAP_Work_ID__c == 'Required' || fieldSettings.RAP_Work_ID__c == 'Visible') && (columnValue!= null || columnValue.length() == 10 )){
                                    thisObj.put(APINAME,columnValue); 
                                    System.debug(APINAME+'---->'+columnValue);
                                }   
                                  
                            }
                            if(APINAME == 'Service_Agreement_ID__c'){
                                System.debug('columnValue---->'+columnValue);
                                //check if field is required and if the cell contains data
                                if (fieldSettings.Service_Agreement_ID__c == 'Required' && (columnValue== null || columnValue.length() == 0 )){
                                    errorSAReq = 'SA ID is required at row' + rowNumber + '\n';
                                    System.debug('Null Error---->'+columnValue);
                                }
                                else if ((fieldSettings.Service_Agreement_ID__c == 'Required' || fieldSettings.Service_Agreement_ID__c == 'Visible') && (columnValue== null || columnValue.length() == 0 || columnValue.length() < 10)){
                                    errorSALen = 'SA ID is not of length 10 digits at row' + rowNumber;
                                    System.debug('Size error---->'+columnValue);
                                } 
                                else if ((fieldSettings.Service_Agreement_ID__c == 'Required' || fieldSettings.Service_Agreement_ID__c == 'Visible') && (columnValue!= null || columnValue.length() == 10 )){
                                    thisObj.put(APINAME,columnValue); 
                                    System.debug(APINAME+'---->'+ columnValue);
                                }   
                                  
                            }
                            if(APINAME == 'Service_Point_ID__c'){
                                System.debug('columnValue---->'+ columnValue);
                                //check if field is required and if the cell contains data
                                if (fieldSettings.Service_Point_ID__c == 'Required' && (columnValue== null || columnValue.length() == 0 )){
                                    errorSPReq = 'SP ID is required at row ' + rowNumber + '\n';
                                    System.debug('Null Error---->'+ columnValue);
                                }
                                else if ((fieldSettings.Service_Point_ID__c == 'Required' || fieldSettings.Service_Point_ID__c == 'Visible') && (columnValue== null || columnValue.length() == 0 || columnValue.length() < 10)){
                                    errorSPLen = 'SP ID is not 10 digits at row '+ rowNumber + '\n';
                                    System.debug('Size error---->'+ columnValue);
                                } 
                                else if ((fieldSettings.Service_Point_ID__c == 'Required' || fieldSettings.Service_Point_ID__c == 'Visible') && (columnValue!= null || columnValue.length() == 10 )){
                                    thisObj.put(APINAME,columnValue); 
                                    System.debug(APINAME+'---->'+ columnValue);
                                }   
                                  
                            }
                            if(APINAME == 'Details_of_Request__c'){
                                System.debug('columnValue---->'+columnValue);
                                //check if field is required and if the cell contains data
                                if (fieldSettings.Details_of_Request__c == 'Required' && (columnValue== null || columnValue.length() == 0 )){
                                    errorDR = ' details of request is required at row'  + rowNumber + '\n' ;
                                    System.debug('Null Error---->'+ columnValue);
                                }
                                else if ((fieldSettings.Details_of_Request__c == 'Required' || fieldSettings.Details_of_Request__c == 'Visible') && (columnValue!= null || columnValue.length() > 0 )){
                                    thisObj.put(APINAME,columnValue); 
                                    System.debug(APINAME+'---->'+ columnValue);
                                }   
                                  
                            }
                            
                            else if(APINAME == 'Correct_Constant__c'){
                                System.debug('columnValue---->'+ columnValue);
                                //check if field is required and if the cell contains data
                                if (fieldSettings.Correct_Constant__c == 'Required' && (columnValue== null || columnValue.length() == 0 )){
                                    errorCC = ' Correct Constant is required at row '+ rowNumber + '\n';
                                }
                                else if ((fieldSettings.Correct_Constant__c == 'Required' || fieldSettings.Correct_Constant__c == 'Visible') && (columnValue!= null || columnValue.length() != 0 )){
                                    
                                        thisObj.put(APINAME,Integer.valueof(columnValue));    
                                        System.debug(APINAME+'---->'+ columnValue);
                                    
                                } 
                                
                                    
                                     
                            } 
                            else if(APINAME == 'Incorrect_Constant__c'){
                                System.debug('columnValue---->'+columnValue);
                                //check if field is required and if the cell contains data
                                if (fieldSettings.Incorrect_Constant__c == 'Required' && (columnValue== null || columnValue.length() == 0 )){
                                    errorIC = 'Incorrect constant is required at row '+ rowNumber + '\n';
                                }
                                else if ((fieldSettings.Incorrect_Constant__c == 'Required' || fieldSettings.Incorrect_Constant__c == 'Visible') && (columnValue!= null || columnValue.length() != 0 )){
                                   
                                        thisObj.put(APINAME,Integer.valueof(columnValue));    
                                        System.debug(APINAME+'---->'+ columnValue);
                                    
                                } 
                                                                     
                            }
                            
            
                            else if(APINAME.contains('Date')){
                                System.debug('columnValue---->'+columnValue);
                                if(columnValue!= null || columnValue.length() != 0){

                                    thisObj.put(APINAME,Date.parse(columnValue));  
                                    System.debug(APINAME+'---->'+ columnValue);  
                                }   
                            }
                            
                        }
                        //If header doesnt have an API name then add it to Info field 
                        else {
                            if(columnValue!= null && columnValue.length() != 0){
                                System.debug('info columnValue ' + columnValue);
                                if (value == null){
                                    value =  headerName +  ':'+  columnValue + '\n';
                                }
                                else{
                                    value = headerName +  ':' +  value + columnValue + '\n'; 
                                }   
                                String APINAME = 'Info__c';
                                if (thisObj.get(APINAME) != null) {
                                	value = value + thisObj.get(APINAME);
                                }
                                thisObj.put(APINAME, value);
                                
                            }   
                        }       
                    }
                    colIndex++;
                }
                objects.add(thisObj);
                rowNumber++;
            }
        }
        return objects;
    }
}