public with sharing class csvFileReaderController {
    public String strDocUrl {get;set;}
    public Blob csvFileBody {get;set;}
    public String csvAsString {get;set;}
    public String WorkItem {get;set;}
    public Webform_Field_Settings__c fieldSettings;
    public Map < String, String > fieldSettingsMap;
    public Map < String, String > errorMap;
    public List < String > error {get;set;}
    public List<String> headerError;
    public List< Webform_Child_Request__c > webFormList;
    
    public csvFileReaderController(Blob csvBody, String workItemType) {
        this.workItem = workItemType;
        this.csvFileBody = csvBody;
    }


    public List<String> readcsvFile() {
        System.debug('csvFileBody--->-' + csvFileBody);
        if(csvFileBody != null){
            csvAsString = csvFileBody.toString();
            System.debug('csvAsString --->-' + csvAsString);
            List < List < String >> parsedContent = parseCSV(csvAsString, false);
    
            fieldSettings = [Select Account_ID__c, Correct_Constant__c, Incorrect_Constant__c, Field_Order_ID__c, Person_ID__c, Premise_ID__c, RAP_Work_ID__c, Service_Agreement_ID__c, Service_Point_ID__c, Retro_End_Date__c, Retro_Start_Date__c, Badge_Set_Date__c, Correction_Date__c from Webform_Field_Settings__c where Name = : WorkItem];
    
            fieldSettingsMap = new Map < String, String > ();
            fieldSettingsMap.put('Account_ID__c', fieldSettings.Account_ID__c);
            fieldSettingsMap.put('Correct_Constant__c', fieldSettings.Correct_Constant__c);
            fieldSettingsMap.put('Incorrect_Constant__c', fieldSettings.Incorrect_Constant__c);
            fieldSettingsMap.put('Field_Order_ID__c', fieldSettings.Field_Order_ID__c);
            fieldSettingsMap.put('Person_ID__c', fieldSettings.Person_ID__c);
            fieldSettingsMap.put('Premise_ID__c', fieldSettings.Premise_ID__c);
            fieldSettingsMap.put('Premise_ID__c', fieldSettings.Premise_ID__c);
            fieldSettingsMap.put('RAP_Work_ID__c', fieldSettings.RAP_Work_ID__c);
            fieldSettingsMap.put('Service_Agreement_ID__c', fieldSettings.Service_Agreement_ID__c);
            fieldSettingsMap.put('Service_Point_ID__c', fieldSettings.Service_Point_ID__c);
            fieldSettingsMap.put('Retro_End_Date__c', fieldSettings.Retro_End_Date__c);
            fieldSettingsMap.put('Retro_Start_Date__c', fieldSettings.Retro_Start_Date__c);
            fieldSettingsMap.put('Badge_Set_Date__c', fieldSettings.Badge_Set_Date__c);
            fieldSettingsMap.put('Correction_Date__c', fieldSettings.Correction_Date__c);
    
            String err = null;
            errorMap = new Map < String, String > ();
            errorMap.put('Empty',err);
            errorMap.put('Size',err);
            errorMap.put('Account_ID__clen', err);
            errorMap.put('Field_Order_ID__clen', err);
            errorMap.put('Person_ID__clen', err);
            errorMap.put('Premise_ID__clen', err);
            errorMap.put('Premise_ID__clen', err);
            errorMap.put('RAP_Work_ID__clen', err);
            errorMap.put('Service_Agreement_ID__clen', err);
            errorMap.put('Service_Point_ID__clen', err);
            errorMap.put('Account_ID__creq', err);
            errorMap.put('Correct_Constant__creq', err);
            errorMap.put('Incorrect_Constant__creq', err);
            errorMap.put('Field_Order_ID__creq', err);
            errorMap.put('Person_ID__creq', err);
            errorMap.put('Premise_ID__creq', err);
            errorMap.put('Premise_ID__creq', err);
            errorMap.put('RAP_Work_ID__creq', err);
            errorMap.put('Service_Agreement_ID__creq', err);
            errorMap.put('Service_Point_ID__creq', err);
            errorMap.put('Retro_End_Date__creq', err);
            errorMap.put('Retro_Start_Date__creq', err);
            errorMap.put('Badge_Set_Date__creq', err);
            errorMap.put('Correction_Date__creq', err);
            errorMap.put('Date', err);
            errorMap.put('Info', err);
            headerError = new List<String>();    
            //Specify your object here
            webFormList = (list < Webform_Child_Request__c > ) csvTosObject(parsedContent, 'Webform_Child_Request__c');
    
            System.debug('WebFormList--->-' + WebFormList);
    
            error = new List < String > ();
            error.add('Please reattach corrected csv file');
            error.add('Error in CSV Template:');
            String errs;
            for (String id: errorMap.keySet()) {
                errs = errorMap.get(id);
                if (!headerError.isEmpty()){
                    error.addAll(headerError);
                }
                if (errs != null) {
                    error.add(errs);
                }
            }
    
            if (error.size() == 2) {
                error.clear();
                /*
                Webform_Master_request__c wfr = new Webform_Master_request__c(Requestor_s_Name__c = 'bharghavi', Requestor_s_Email__c = 'bharghavin@slalom.com');
                insert wfr;
                for (Webform_Child_Request__c wfdetail: WebFormList)
                    wfdetail.Webform_Master_request__c = wfr.id;
                insert WebFormList;
                */
            }
        }
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
        if(parsedCSV.size() > 1 ){
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
            headerError = new List<String>();
            for(string id :fieldSettingsMap.keyset()){
                Integer errorCount = 0;
                if (fieldSettingsMap.get(id) == 'Required'){
                    for(String header:headers){
                        String apiNameHeader = labelToAPIName.get(header);
                        if(id == apiNameHeader){
                            errorCount = 1;
                        }
                    }
                    if (errorCount != 1){
                        headerError.add(id  + 'Required column is missing' );
                            
                    }
                    errorCount = 0;
                }
            }
            system.debug('========================= headerError'+headerError);
            if(headerError.isEmpty()){
                system.debug('========================= File Column Headers');
                system.debug(headers);
                //stores row number
                integer rowNumber = 0;

                //Iterate each row
                for (list < String > row: parsedCSV) {
                    system.debug('========================= Row Index' + rowNumber);
                    if (rowNumber == 0) {
                        rowNumber++;
                        continue;
                    } 
                    else {
                        //Create object instance
                        sObject thisObj = objectDef.newSobject();
                        //stores column number of each row
                        integer colIndex = 0;
                        //iterate over the column cells
                        String Value = null;
                        for (String col: row) {
                            String headerName = headers[colIndex].trim();
                            System.debug('headerName---->' + headerName);

                            String columnValue = col.trim();
                            //check if header is null or not, if null ignore it
                            if (headerName.length() > 0) {
                                //check if header has a corresponding api field

                                if (labelToAPIName.containsKey(headerName)) {
                                    //if yes, fetch the values and assign it to the appropiate api field
                                    String APINAME = labelToAPIName.get(headerName);
                                    System.debug('APINAME---->' + APINAME);
                                    String settings = fieldSettingsMap.get(APINAME);
                                    if (APINAME.contains('ID')) {
                                        System.debug('IDs---->' + APINAME);
                                        if (settings == 'Required' && (columnValue == null || columnValue.length() == 0)) {
                                            String errReq = errorMap.get(APINAME + 'req');
                                            if (errReq == null)
                                                errReq = headerName + ' required at row:  ' + (rowNumber + 1);
                                            else
                                                errReq = errReq + ', ' + (rowNumber + 1);
                                            if (errReq != null) {
                                                errorMap.put(APINAME + 'req', errReq);
                                            }
                                        } else if ((settings == 'Required' || settings == 'Visible') && (columnValue.length() > 0 && columnValue.length() != 10)) {
                                            String errLen = errorMap.get(APINAME + 'len');
                                            if (errLen == null)
                                                errLen = headerName + ' is not 10 digits at row ' + (rowNumber + 1);
                                            else
                                                errLen = errLen + ', ' + (rowNumber + 1);
                                            if (errLen != null) {
                                                errorMap.put(APINAME + 'len', errLen);
                                            }
                                        } else if ((settings == 'Required' || settings == 'Visible') && (columnValue != null && columnValue.length() == 10)) {
                                            thisObj.put(APINAME, columnValue);
                                            System.debug(APINAME + '---->' + columnValue);
                                        }
                                    } else if (APINAME.contains('Date')) {
                                        System.debug('Date---->' + APINAME);
                                        if (settings == 'Required' && (columnValue == null || columnValue.length() == 0)) {
                                            String errReq = errorMap.get(APINAME + 'req');
                                            if (errReq == null)
                                                errReq = headerName + ' required at row:  ' + (rowNumber + 1);
                                            else
                                                errReq = errReq + ', ' + (rowNumber + 1);
                                            if (errReq != null) {
                                                errorMap.put(APINAME + 'req', errReq);
                                            }
                                        } else if ((settings == 'Required' || settings == 'Visible') && (columnValue != null )) {
                                            try {
                                                thisObj.put(APINAME, Date.parse(columnValue));
                                                System.debug(APINAME + '---->' + columnValue);
                                            } catch (Exception e) {
                                                String errDate = errorMap.get('Date');
                                                if (errDate == null)
                                                    errDate = headerName + ' not in proper format MM/DD/YYYY at row :' + (rowNumber + 1);
                                                else
                                                    errDate = errDate + ', ' + (rowNumber + 1);
                                                if (errDate != null) {
                                                    errorMap.put('Date', errDate);
                                                }
                                            }
                                        }

                                    } else {
                                        System.debug('Other Fields---->' + APINAME);
                                        if (settings == 'Required' && (columnValue == null || columnValue.length() == 0)) {
                                            String errReq = errorMap.get(APINAME + 'req');
                                            if (errReq == null)
                                                errReq = headerName + ' required at row:  ' + (rowNumber + 1);
                                            else
                                                errReq = errReq + ', ' + (rowNumber + 1);
                                            if (errReq != null) {
                                                errorMap.put(APINAME + 'req', errReq);
                                            }
                                        }  else if ((settings == 'Required' || settings == 'Visible') && (columnValue != null )) {
                                            thisObj.put(APINAME, columnValue);
                                            System.debug(APINAME + '---->' + columnValue);
                                        }
                                    }

                                }
                                //If header doesnt have an API name then add it to Info field 
                                else {
                                    System.debug('INFO---->');
                                    System.debug('headerName---->'+headerName);
                                    System.debug('Info columnValue---->' + columnValue);
                                    if ((columnValue != null || columnValue.length() != 0 || !String.isEmpty(columnValue)) && columnValue.length() < 200) {
                                        if (value == null) {
                                            value = headerName + ':' + columnValue + '\n';
                                        } else {
                                            value = value + headerName + ':' + columnValue + '\n';
                                        }

                                    }
                                    else if(headerName != 'Other-Reason' && workItem != 'UUT Webform Template' && columnValue.length() >200){
                                        
                                        String err = errorMap.get('Size');
                                        System.debug('info err ' + err + ' header name ' +headerName + ' column value ' +columnValue);
                                        if (err == null)
                                            err =  headerName + ' is greater than 200 characters row ' + (rowNumber + 1);
                                        else
                                            err = err + ', ' + (rowNumber + 1);
                                        if (err != null) {
                                            errorMap.put('Size', err);
                                        }
                                    }                                   
                                    if(headerName == 'Other-Reason' && workItem == 'UUT Webform Template' && columnValue.length() <500 && columnValue.length() >0){
                                        if (value == null) {
                                            value = headerName + ':' + columnValue + '\n';
                                        } else {
                                            value = value + headerName + ':' + columnValue + '\n';
                                        }
                                    }
                                }
                            }
                            colIndex++;
                        }
                        String APINAME = 'Info__c';
                        System.debug('value---->' + value);
                        if (value != null) {
                            System.debug('what is value? ' + value);
                            if(value.length()<=4000 && value.length()>0)
                                thisObj.put(APINAME, value);
                            else
                            {
                                String err = errorMap.get('Info');
                                System.debug('null err? ' + err);
                                if (err == null)
                                    err =  'Info is greater than 4000 characters row ' + (rowNumber + 1);
                                else
                                    err = err + ', ' + (rowNumber + 1);
                                if (err != null) {
                                    errorMap.put('Size', err);
                                }
                            }
                        } 
                        objects.add(thisObj);
                        rowNumber++;
                    }
                }
                if(parsedCSV.size() > 201){
                    String err = errorMap.get('Empty');
                    if (err == null){
                        if(parsedCSV.size() > 201)
                            err = 'CSV file has gerater than 200 records';    
                    }   
                    if (err != null) {
                        errorMap.put('Empty', err);
                    }
                    return null;
                }
                else
                    return objects;
            }
            else
                return null;
        }
        else{
            //Error for empty csv
            String err = errorMap.get('Empty');
            if (err == null)
                if(parsedCSV.size() <= 1)
                    err = 'CSV file is empty';
                   
            
            if (err != null) {
                errorMap.put('Empty', err);
            }
            return null;
        }
    }
}