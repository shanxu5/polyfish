public class vfpageextensions{
    //Constructor
    public void vfpageextensions(){
        //code for fetching default values for the picklists for work item type selection,setting up flag values etc
    }
    
        public  List<List<String>> parseCSV(String contents,Boolean skipHeaders)
    {
        List<List<String>> allFields = new List<List<String>>();
    
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            lines = contents.split('\n');
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for(String line : lines) {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',');  
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field : fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }
            
            allFields.add(cleanFields);
        }
        if (skipHeaders) allFields.remove(0);
        return allFields;       
    }
 
    public static list<sObject> csvTosObject(List<List<String>> parsedCSV, string objectType)
    {
        Schema.sObjectType objectDef = Schema.getGlobalDescribe().get(objectType).getDescribe().getSObjectType();
        system.debug(objectDef);
        
        list<sObject> objects = new list<sObject>();
        list<string> headers = new list<string>();
        
        for(list<string> row : parsedCSV)
        {
            for(string col : row)
            {
                headers.add(col);
            }
            break;
        }
        system.debug('========================= File Column Headers');
        system.debug(headers);
            
        integer rowNumber = 0;
        for(list<string> row : parsedCSV)
        {
            system.debug('========================= Row Index' + rowNumber);
            if(rowNumber == 0)
            {
                rowNumber++;
                continue;
            }
            else
            {
                sObject thisObj = objectDef.newSobject();
                integer colIndex = 0;
                for(string col : row)
                {                   
                    string headerName = headers[colIndex].trim();
                    system.debug('========================= Column Name ' + headerName);
                    if(headerName.length() > 0)
                    {                  
                        try
                        {                       
                            thisObj.put(headerName,col.trim());
                        }
                        catch(exception e)
                        {
                            system.debug('============== Invalid field specified in header ' + headerName);                           
                        }
                        colIndex++;
                    }
                } 
                objects.add(thisObj);
                rowNumber++;
            }       
        }
        return objects;
    }
    
    
    
    }