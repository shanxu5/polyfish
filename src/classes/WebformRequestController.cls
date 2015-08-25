public class WebformRequestController {

    public Webform_Child_Request__c webformDetailRequest {
        get{
		    if(webformDetailRequest == null){
            	webformDetailRequest = new Webform_Child_Request__c();
        	}   
            return webformDetailRequest;
        }
        set;
    }
    
    public PageReference insertChild(){
        // Create Webform Master Request
        Webform_Master_Request__c masterWFR = [Select Id from Webform_Master_Request__c where Id = 'a0jq0000000kzix'];
		Id masterWFRid = masterWFR.Id;
        system.debug(logginglevel.info,'%%%%%%%%%%%%% masterWFRid %%%%%...'+ masterWFRid);
        //system.debug(logginglevel.info,'%%%%%%%%%%%%% webformDetailRequest %%%%%...'+ webformDetailRequest);

        // Create Webform Child Request with Id from Master
        webformDetailRequest.Webform_Master_request__c = masterWFR.Id;
        
        //system.debug(logginglevel.info,'%%%%%%%%%%%%% getWebformDetailRequest() %%%%%...'+ getWebformDetailRequest());
        system.debug(logginglevel.info,'%%%%%%%%%%%%% webformDetailRequest %%%%%...'+ webformDetailRequest);

        insert webformDetailRequest;
        /*
        List<Webform_Child_Request__c> childreq = [Select Id from Webform_Child_Request__c where Webform_Master_request__c = :masterWFRid and Account_Id__c = '123456789'];
        
        system.debug(logginglevel.info,'%%%%%%%%%%%%% childreq %%%%%...'+ childreq);
        
        Id childWFRid = [Select Id from Webform_Child_Request__c where Webform_Master_request__c = :masterWFRid and Account_Id__c = '123456789'].Id;
        system.debug(logginglevel.info,'%%%%%%%%%%%%% childWFRid %%%%%...'+ childWFRid);
		*/
		return null;        
    }    
   
    //public Boolean webPageIsInternal { get; set; }
    //public Boolean webPageIsExternal { get; set; }
    public Boolean webPageIsInternal {
        get{ return true;}
        set;
    }
    public Boolean webPageIsExternal {
        get{ return false;}
        set;
    }
    
    public String webformWIName { get; set; }
    public String submType { get; set; }

    public Webform_Field_Settings__c webformFS = null;
    
    //public static String webformWIName = 'Hetch Hetchy';
    //
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
            if(webformWIName != null) {
                String wfQueryFields = getWebformQueryFields();
                String webformSelectStmt = 'SELECT '+ wfQueryFields + ' FROM Webform_Field_Settings__c where Name = \'' + webformWIName + '\'';
                System.debug(logginglevel.info,'#######%%%%%%%%%%%%%%% webformSelectStmt %%%%%%%%%...'+ webformSelectStmt);
                webformFS = Database.query(webformSelectStmt);
                System.debug(logginglevel.info,'#######%%%%%%%%%%%%%%% webformFS %%%%%%%%%...'+ webformFS);
            }
        }
        return webformFS;
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