public class WebformDetailsBlockController{

    public static Webform_Child_Request__c webformDetailRequest {get; set;}
    
    //public ApexPages.StandardSetController stdCntrlr {get; set;}
    public WebformDetailsBlockController(){        
        webformDetailRequest = new Webform_Child_Request__c();
        system.debug(logginglevel.INFO,'%%%%%%%%%%%% WebformDetailsBlockController()/webformDetailRequest %%%%%%%...'+ webformDetailRequest);
    }
    
    
    public WebformDetailsBlockController(ApexPages.StandardController controller) {
        //stdCntrlr = controller;
        webformDetailRequest = (Webform_Child_Request__c)controller.getRecord();
        system.debug(logginglevel.INFO,'%%%%%%%%%%%% WebformDetailsBlockController(controller)/webformDetailRequest %%%%%%%...'+ webformDetailRequest);
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
    
    public static String webformWIName { get; set; }
    public static String submType { get; set; }
    
    
    public static Webform_Child_Request__c getWebformDetailRequest(){
        if(webformDetailRequest == null){
            webformDetailRequest = new Webform_Child_Request__c();
        }
        return webformDetailRequest;
    }


    
    public PageReference insertChild(){
        // Create Webform Master Request
        Webform_Master_Request__c masterWFR = [Select Id from Webform_Master_Request__c where Id = 'a0jq0000000kzix'];
		Id masterWFRid = masterWFR.Id;
        system.debug(logginglevel.info,'%%%%%%%%%%%%% masterWFRid %%%%%...'+ masterWFRid);
        //system.debug(logginglevel.info,'%%%%%%%%%%%%% webformDetailRequest %%%%%...'+ webformDetailRequest);

        // Create Webform Child Request with Id from Master
        //webformDetailRequest.Webform_Master_request__c = masterWFR.Id;
        system.debug(logginglevel.info,'%%%%%%%%%%%%% webformDetailRequest %%%%%...'+ webformDetailRequest);
        insert webformDetailRequest;
        List<Webform_Child_Request__c> childreq = [Select Id from Webform_Child_Request__c where Webform_Master_request__c = :masterWFRid and Account_Id__c = '123456789'];
        system.debug(logginglevel.info,'%%%%%%%%%%%%% childreq %%%%%...'+ childreq);
        
        Id childWFRid = [Select Id from Webform_Child_Request__c where Webform_Master_request__c = :masterWFRid and Account_Id__c = '123456789'].Id;
        system.debug(logginglevel.info,'%%%%%%%%%%%%% childWFRid %%%%%...'+ childWFRid);

		return null;        
    }


    public static Webform_Field_Settings__c webformFS = null;
    
    //public static String webformWIName = 'Hetch Hetchy';
    //
    public static Map<String,Boolean> showFieldMap {
        get{
            // get fields from Schema object
            // loop through fields in list
            // get field from the object
            // if required or visible, set value for that field to true
            // else, set to false
            //Map<String, Schema.SObjectField> wffsFieldMap = Schema.SObjectType.Webform_Field_Settings__c.fields.getMap();
            //List<Schema.SObjectField> wffsFieldMap = Schema.SObjectType.Webform_Field_Settings__c.fields.getMap().values();
            //system.debug(logginglevel.info,'%%%%%%%%%%%%%  wffsFieldMap %%%%%%%....'+wffsFieldMap);
            //getFieldDataType('object type', 'api field name');
            Map<String,Boolean> m = new Map<String,Boolean>();
            String fieldValue = '';
            Schema.DisplayType fieldDataType = null;
            Set<Schema.DisplayType> nonStringDataTypes = new Set<Schema.DisplayType>();
            //nonStringDataTypes.add(getWebformFS().get(f));
            //nonStringDataTypes.add(Schema.DisplayType.BOOLEAN);
            //nonStringDataTypes.add(Schema.DisplayType.DATETIME);
            
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
    
    public static Map<String,Boolean> requiredFieldMap {
        get{
            // get fields from Schema object
            // loop through fields in list
            // get field from the object
            // if required, set value for that field to true
            // else, set to false
            //for (Webform_Field_Settings__c wffs : webformWI) 
            Map<String,Boolean> m = new Map<String,Boolean>();
            String fieldValue = '';
            Schema.DisplayType fieldDataType = null;
            Set<Schema.DisplayType> nonStringDataTypes = new Set<Schema.DisplayType>();
            //nonStringDataTypes.add(getWebformFS().get(f));
            //nonStringDataTypes.add(Schema.DisplayType.BOOLEAN);
            //nonStringDataTypes.add(Schema.DisplayType.DATETIME);
            
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

    
    
    public static Webform_Field_Settings__c getWebformFS(){
        //Webform_Field_Settings__c wf = null;
        if(webformFS == null){
        //    wf = webformFS;
        //}
        //else {
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

   
    public static List<String> webformWIFields {
        get {
            List<String> fields = new List<String>();
            //Schema.DescribeFieldResult fieldName = ;
            // Build query fields from User Skill Rule Map custom setting object
            //List<Webform_WI_Fields__c> wfwif = Webform_WI_Fields__c.getAll().values(); 
            List<Schema.SObjectField> wfwif = Schema.SObjectType.Webform_Field_Settings__c.fields.getMap().values();                
            //Map<String, Schema.SObjectField> wffsFieldMap = Schema.SObjectType.Webform_Field_Settings__c.fields.getMap().values();
            //List<Schema.SObjectField> wffsFieldMap = Schema.SObjectType.Webform_Field_Settings__c.fields.getMap().values();
            for (Schema.SObjectField w : wfwif) {
                //Schema.SObjectField field = (Schema.SObjectField)w;
                //Schema.DescribeFieldResult DescField = field.getDescribe();
                fields.add(w.getDescribe().getName());
            }
            //System.debug(logginglevel.info,'#######%%%%%%%%%%%%%%% (String)fields %%%%%%%%%...'+ (String)fields);
            return fields;
        }
        set;
    }
    
    
    
    public static String getWebformQueryFields() {
        // Build list of field names
        String queryFields = '';
        queryFields = String.join(webformWIFields,',');
        //System.debug(Logginglevel.INFO,'%%%%%%%%%%%%%% queryFields %%%%%%...'+queryFields);
        return queryFields;
    }
    
    
    public static Schema.DisplayType getFieldDataType(String customObjectType, String apiFieldName){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(customObjectType);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
     
        Schema.DisplayType fieldDataType = fieldMap.get(apiFieldName).getDescribe().getType();
		return fieldDataType;
    }
  

}