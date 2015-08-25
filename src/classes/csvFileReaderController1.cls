public with sharing class csvFileReaderController1 {

    public String strDocUrl {get;set;}
    public Blob csvFileBody {get;set;}
    public String csvAsString {get;set;}
    public String WorkItem {get;set;}
    public Webform_Field_Settings__c fieldSettings ;
    
    //Get field settings for specific item type
    public void retriveFieldSettings(){
        //SOQL query to fetch data
        
        //fieldSettings.Account_ID__c = 'Required';
            
    }
    
    public csvFileReaderController1(){
        try {
            List < Document > FirstDocument = [SELECT Id, Name FROM Document WHERE Name = 'template1'
                LIMIT 1
            ];
            String strOrgId = UserInfo.getOrganizationId();
            strDocUrl = '/servlet/servlet.FileDownload?file=' + FirstDocument[0].Id;

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error in getDocumentLogoUrl() ' + e.getMessage()));
            System.debug('Error: ' + e.getMessage());
        }
        System.debug('The URL is ' + strDocUrl);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The URL returned is ' + strDocUrl));
    }


    public void readcsvFile(){
        csvAsString = csvFileBody.toString();
        List < List < String >> parsedContent = parseCSV(csvAsString, false);
        fieldSettings = [Select Account_ID__c,Field_Order_ID__c,Person_ID__c,Premise_ID__c,RAP_Work_ID__c,Service_Agreement_ID__c,Service_Point_ID__c from Webform_Field_Settings__c where Name =:WorkItem];
        System.debug('@@@@@@@@@@@' + fieldSettings);
        //Specify ur object here
        list < Webform_Child_Request__c > WebFormList = (list < Webform_Child_Request__c > ) csvTosObject(parsedContent, 'Webform_Child_Request__c');
        System.debug(WebFormList);
        Webform_Master_request__c wfr = new Webform_Master_request__c(Requestor_s_Name__c = 'bharghavi', Requestor_s_Email__c = 'bharghavin@slalom.com');
        insert wfr;
        for (Webform_Child_Request__c wfdetail: WebFormList)
            wfdetail.Webform_Master_request__c = wfr.id;
        insert WebFormList;
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
        List <String> error = new List<String>();
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
                    String Value = '';
                    //check if header is null or not, if null ignore it
                    if (headerName.length() > 0) {
                        //check if header has a corresponding api field
                        if(labelToAPIName.containsKey(headerName)){
                            //if yes, fetch the values and assign it to the appropiate api field
                            String APINAME = labelToAPIName.get(headerName);
                            if(APINAME == 'Account_ID__c'){

                                //check if field is required and if the cell contains data
                                if (fieldSettings.Account_ID__c == 'Required') {
                                    error.add(headerName +'is required. Error at cell '+ rowNumber+','+colIndex);
                    
                                }
                                else if ((fieldSettings.Account_ID__c == 'Required' || fieldSettings.Account_ID__c == 'Visible') && col.trim() != null){
                                   
                                    thisObj.put(APINAME,col.trim());    
                                } 
                                /*
                                    Add other validations in else conditions
                                */  
                            }
                            else if(APINAME == 'Field_Order_ID__c'){
                                //check if field is required and if the cell contains data
                                if (fieldSettings.Field_Order_ID__c == 'Required' && col.trim() == null){
                                    error.add(headerName +'is required. Error at cell '+ rowNumber+','+colIndex);
                                }
                                else if ((fieldSettings.Field_Order_ID__c == 'Required' || fieldSettings.Field_Order_ID__c == 'Visible') && col.trim() != null){
                                    thisObj.put(APINAME,col.trim());    
                                }
                                /*
                                    Add other validations in else conditions
                                */                                  
                            }
                            else if(APINAME == 'Person_ID__c'){
                                //check if field is required and if the cell contains data    
                                if (fieldSettings.Person_ID__c == 'Required' && col.trim() == null){
                                    error.add(headerName +'is required. Error at cell '+ rowNumber+','+colIndex);
                                }
                                else if ((fieldSettings.Person_ID__c == 'Required' || fieldSettings.Person_ID__c == 'Visible') && col.trim() != null){
                                    thisObj.put(APINAME,col.trim());    
                                }
                                /*
                                    Add other validations in else conditions
                                */                                  
                            }
                            else if(APINAME == 'Premise_ID__c'){
                                //check if field is required and if the cell contains data
                                if (fieldSettings.Premise_ID__c == 'Required' && col.trim() == null){
                                    error.add(headerName +'is required. Error at cell '+ rowNumber+','+colIndex);
                                }
                                else if ((fieldSettings.Premise_ID__c == 'Required' || fieldSettings.Premise_ID__c == 'Visible') && col.trim() != null){
                                    thisObj.put(APINAME,col.trim());    
                                }  
                                /*
                                    Add other validations in else conditions
                                */                                      
                            }
                            else if(APINAME == 'RAP_Work_ID__c'){
                                //check if field is required and if the cell contains data
                                if (fieldSettings.RAP_Work_ID__c == 'Required' && col.trim() == null){
                                    error.add(headerName +'is required. Error at cell '+ rowNumber+','+colIndex);
                                }
                                else if ((fieldSettings.RAP_Work_ID__c == 'Required' || fieldSettings.RAP_Work_ID__c == 'Visible') && col.trim() != null){
                                    thisObj.put(APINAME,col.trim());    
                                }  
                                /*
                                    Add other validations in else conditions
                                */                                      
                            }
                            else if(APINAME == 'Service_Point_ID__c'){
                                //check if field is required and if the cell contains data
                                if (fieldSettings.Service_Point_ID__c == 'Required' && col.trim() == null){
                                    error.add(headerName +'is required. Error at cell '+ rowNumber+','+colIndex);
                                }
                                else if ((fieldSettings.Service_Point_ID__c == 'Required' || fieldSettings.Service_Point_ID__c == 'Visible') && col.trim() != null){
                                    thisObj.put(APINAME,col.trim());    
                                } 
                                /*
                                    Add other validations in else conditions
                                */                                      
                            }
                            else if(APINAME == 'Service_Agreement_ID__c'){
                                //check if field is required and if the cell contains data
                                if (fieldSettings.Service_Agreement_ID__c == 'Required' && col.trim() == null){
                                    error.add(headerName +'is required. Error at cell '+ rowNumber+','+colIndex);
                                }
                                else if ((fieldSettings.Service_Agreement_ID__c == 'Required' || fieldSettings.Service_Agreement_ID__c == 'Visible') && col.trim() != null){
                                    thisObj.put(APINAME,col.trim());    
                                } 
                                /*
                                    Add other validations in else conditions
                                */                                      
                            }
                            //need to add as many validation as above
                            // for other api fields with out validations
                            else{
                                if(col.trim()!= null){
                                    thisObj.put(APINAME,col.trim());
                                }   
                            }
                        }
                        //If header doesnt have an API name den add it to details of request 
                        else {
                            if(col.trim()!= null){
                                if (value == null){
                                    value = col.trim() + '\n';
                                }
                                else{
                                    value = value + col.trim() + '\n';  
                                }   
                                String APINAME = 'Info__c';
                                value = value + thisObj.get(APINAME);
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