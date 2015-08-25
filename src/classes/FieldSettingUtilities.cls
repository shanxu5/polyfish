public with sharing class FieldSettingUtilities {
    public String workItemType {get;set;}
    public Webform_Field_Settings__c webFormFS;
    public String test {
        get {
            return 'blah';
        }
    }

    public FieldSettingUtilities(String wiType) {
        this.workItemType = wiType;
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
            if(workItemType != null) {
                String wfQueryFields = getWebformQueryFields();
                String webformSelectStmt = 'SELECT '+ wfQueryFields + ' FROM Webform_Field_Settings__c where Name = \'' + workItemType + '\'';
                //System.debug(logginglevel.info,'#######%%%%%%%%%%%%%%% webformSelectStmt %%%%%%%%%...'+ webformSelectStmt);
                webformFS = Database.query(webformSelectStmt);
                //System.debug(logginglevel.info,'#######%%%%%%%%%%%%%%% webformFS %%%%%%%%%...'+ webformFS);
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
}