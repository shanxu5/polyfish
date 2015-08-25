/*
  @Company    Slalom Consulting
  @Author          Janella/Swetha 
  @Date      26.August.2014
  @Description  Controller extension for UserSkills Selection visual force page
  @Revision(s)  Janella Espiritu 10092014  Updates for Sprint 3
  @Revision Bharghavi Nekkanti updates for sprint3 
*/
public class UserSkillSelectionExtension { 
    public final Work_Item_Assignment__c wia{get;set;}
    public List<User_Skill_Rule__c> userSkills {get;set;}
    public List<User_Skill__c> existingUserSkills;
    public List<PageHelper> pageHelperList {get;set;}
    List<User_Skill__c> usInsert = new List<User_Skill__c>();
    List<User_Skill__c> usDelete = new List<User_Skill__c>();
    public pagereference pr{get;set;}
    public map<string,string> grClassMap {get;set;}
    public String selectedwit {get;set;}
    public String selectedFilter {get;set;}
    public String selectedRctype {get;set;}
    public String selectedGrpClass {get;set;}
    public Boolean mailboxSelected {get;set;}
    public String daccaSelected {get;set;}
    public String intervalSelected {get;set;}
    public String satypeEntered {get;set;}
    public String queryFields ;
    public Set<Id> selectedIds = new Set<Id>();
    public Set<Id> selectedIdsForDel = new Set<Id>();
    public Map<Id, User_Skill__c> usMap;
    //public static String RECORDTYPE_MAILBOX = System.Label.RECORDTYPE_MAILBOX;
    
    public UserSkillSelectionExtension(ApexPages.StandardController sc){
      
        this.wia = (Work_Item_Assignment__c)sc.getRecord();
        selectedwit = '';
        selectedFilter = '';
        selectedRctype = '';
        selectedGrpClass = '';
        mailboxSelected = false;
        daccaSelected = '';
        intervalSelected = '';
        satypeEntered = '';
        existingUserSkills = new List<User_Skill__c>();
        userSkills = new List<User_Skill_Rule__c>();
        pageHelperList = new List<PageHelper>();
        usMap = new Map<Id, User_Skill__c>();
        grClassMap = new Map<string,string>();
        
        // Get fields from the Field Set
        queryFields = '';
        for(Schema.FieldSetMember f : SObjectType.User_Skill_Rule__c.FieldSets.User_Skill_Selection.getFields()) {
            if(queryFields.length() > 0) {
                queryFields += ', ';
            }
            queryFields += f.getFieldPath();
        }
    // Query User Skill Rules
      userSkills = Database.query(' SELECT ' + queryFields + ', RecordType.Name , Class__r.Name FROM ' + ' User_Skill_Rule__c  ORDER BY Sort_Order__c ');
        
        Diags.Enter('userskills are %%%' + userSkills);
        // Query all existing User Skills for the Work Item Assignment
        existingUserSkills = [select Id, User_Skill_Rule__c, Work_Item_Assignment__c from User_Skill__c where Work_Item_Assignment__c =: wia.Id];
        // Loop Existing User Skills and put them on a map
        for(User_Skill__c us : existingUserSkills){
            usMap.put(us.User_Skill_Rule__c, us);
        }
        // Loop user skill rules and collect Work Item Types, RecordTypes and Grouping class
        
        for(User_Skill_Rule__c usr : userSkills){
            
                if (usr.Class__r.Name!=null && usr.Class__r.Name!='')
                {
                    if (!grClassMap.containsKey(usr.class__c))
                        grClassMap.put(usr.class__c,usr.Class__r.Name);
                
                }
                                            
        }

        // Call the method to Populate lists displayed
        populatePageHelperList();
    }
    
   // This method populates the PageHelperList which is used to display records on the page
  
    public void populatePageHelperList(){
     
        string query= ' SELECT ' + queryFields + ', RecordType.Name , Class__r.Name FROM ' + ' User_Skill_Rule__c';
        if ( (selectedRctype!=null && selectedRctype!='') || selectedGrpClass!= null && selectedGrpClass!='')
        {
            userSkills = new List<User_Skill_Rule__c>();
            if (selectedRctype!=null && selectedRctype!='') {
                if (query.contains('where'))
                    query = query+ '  and  RecordTypeid= \''+selectedRctype+'\'';
                else
                    query = query+ '  where  RecordTypeid= \''+selectedRctype+'\'';
            }
            if ( selectedGrpClass!= null && selectedGrpClass!='') {
                if (query.contains('where'))
                    query = query+ ' and Class__c= \''+ selectedGrpClass+'\'';
                else
                    query = query+ ' where Class__c= \''+ selectedGrpClass+'\'';
            }        
        }

       query = query+ '  ORDER BY Sort_Order__c';
        
        system.debug('Query:'+query);
            userSkills=Database.query(query);
        pageHelperList = new List<PageHelper>();
        //Loop User Skills
        for(User_Skill_Rule__c usr : userSkills){
      
          if( ((selectedwit == null || selectedwit == '') || usr.Work_Item_Type__c.containsIgnoreCase(selectedwit) )){
                if(selectedFilter == null || selectedFilter == ''){
                    if(satypeEntered == null || satypeEntered == ''){
                        Boolean existing = false;
                        // Set User Skill as selected if User Skill is existing
                        if((usMap.containsKey(usr.Id) || selectedIds.contains(usr.Id)) && !selectedIdsForDel.contains(usr.Id)){
                            existing = true;
                        }
                        // Add to PageHelperList
                        pageHelperList.add(new PageHelper(usr, usr.Work_Item_Type__c, existing));
                    }
                    else if(usr.SA_Type__c != null && usr.SA_Type__c != '' && satypeEntered != null && satypeEntered != ''){
                        if(usr.SA_Type__c.contains(satypeEntered)){
                            Boolean existing = false;
                            // Set User Skill as selected if User Skill is existing
                            if((usMap.containsKey(usr.Id) || selectedIds.contains(usr.Id)) && !selectedIdsForDel.contains(usr.Id)){
                                existing = true;
                            }
                            // Add to PageHelperList
                            pageHelperList.add(new PageHelper(usr, usr.Work_Item_Type__c, existing));
                        }
                    }
                }
                else{
                    if(selectedFilter == 'DA CCA' && usr.DA_CCA_Indicator__c == 'True'){
                        Boolean existing = false;
                        // Set User Skill as selected if User Skill is existing
                        if((usMap.containsKey(usr.Id) || selectedIds.contains(usr.Id)) && !selectedIdsForDel.contains(usr.Id)){
                            existing = true;
                        }
                        // Add to PageHelperList
                        pageHelperList.add(new PageHelper(usr, usr.Work_Item_Type__c, existing));
                    }
                    else if(selectedFilter == 'Interval' && usr.Interval__c == 'True'){
                        if((satypeEntered == null || satypeEntered == '') /*&& usr.SA_Type__c == null*/){
                            Boolean existing = false;
                            // Set User Skill as selected if User Skill is existing
                            if((usMap.containsKey(usr.Id) || selectedIds.contains(usr.Id)) && !selectedIdsForDel.contains(usr.Id)){
                                existing = true;
                            }
                            // Add to PageHelperList
                            pageHelperList.add(new PageHelper(usr, usr.Work_Item_Type__c, existing));
                        }
                        else if(usr.SA_Type__c != null && usr.SA_Type__c != '' && satypeEntered != null && satypeEntered != ''){
                            if(usr.SA_Type__c.contains(satypeEntered)){
                                Boolean existing = false;
                                // Set User Skill as selected if User Skill is existing
                                if((usMap.containsKey(usr.Id) || selectedIds.contains(usr.Id)) && !selectedIdsForDel.contains(usr.Id)){
                                    existing = true;
                                }
                                // Add to PageHelperList
                                pageHelperList.add(new PageHelper(usr, usr.Work_Item_Type__c, existing));
                            }
                        }
                    }
                    
                }
            }
         }
    }
  
    /*
    This method is called when the Save button is clicked
  */
  public PageReference save(){
        String FilterInsertRecordsStr = ApexPages.currentPage().getParameters().get('FilterInsertRecordsStr');
        String DeletedPredefinedSkillsStr = ApexPages.currentPage().getParameters().get('DeletedPredefinedSkillsStr');
        List< String > FilterInsertRecords =  new List<String>();
        if(FilterInsertRecordsStr.length()>0){
            FilterInsertRecords = FilterInsertRecordsStr.split(',');
        }
        List< String > DeletedPredefinedSkills = new List<String>();
        if(DeletedPredefinedSkillsStr.length()>0){
            DeletedPredefinedSkills = DeletedPredefinedSkillsStr.split(',');
        }
        User_Skill__c temp ;
        usInsert= new List<User_Skill__c>();
        if(!FilterInsertRecords.isEmpty() ){
            for(String st:FilterInsertRecords ){
                System.debug('st1 ==='+st );
                
                temp = new User_Skill__c();
                temp.User_Skill_Rule__c = st;
                temp.Work_Item_Assignment__c = wia.Id;
                usInsert.add(temp);
                selectedIds.add(st);
            }
        }
        usDelete = new List<User_Skill__c>();
        if(!DeletedPredefinedSkills.isEmpty() ){
            for(String st:DeletedPredefinedSkills ){
                if(st != ' ' || st != ''){
                User_Skill__c us1 = usMap.get(st);
                usDelete.add(us1); 
                }
            }
        } 
            
        try{
            if(usInsert.size() > 0){
              insert usInsert;    
            }
            if(usDelete.size() > 0){
              delete usDelete;        
            }
        }
        catch(Exception e){
            System.debug('***ERROR in Inserting or Deleting User Skills: '+ e.getMessage());
        }
        // Instantiate a PageReference that will redirect to the Work Item Assignment record
        Pagereference pageref= new Pagereference('/'+wia.id);
        pageref.setRedirect(true);
        return pageref;
    }

   // This is the picklist used to filter recordTypes of User skill rules
    public List<SelectOption> recordTypesSelection{
        get{
            // Add work item types to picklist
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', ''));
            for(RecordType recType : [Select  r.Name,   r.Id From RecordType r where r.SobjectType='User_Skill_Rule__c' and r.IsActive=true]){
                //workItemTypes.add(usr.Work_Item_Type__c);
                options.add(new SelectOption(recType.id,recType.name));
            }
            return options;
        }   
        private set;
    }
    
  //  This is the picklist used to filter User Skills on grouping class
    public List<SelectOption> grpClassSelection{
        get{
            // Add work item types to picklist
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', ''));
            for(String gclass : grClassMap.KeySet()){
                  options.add(new SelectOption(gclass, grClassMap.get(gclass)));
            }
            return options;
      }  
        private set;
    } 
  //  This is a helper class which helps the page to organize data
    public class PageHelper{
        public Boolean selected {get;set;}
        public String worktype {get;set;}
        public User_Skill_Rule__c usr {get;set;}
        public PageHelper(User_Skill_Rule__c usr, String worktype, boolean selected){
            this.usr = usr;
            this.worktype = worktype;
            this.selected = selected;
        }
    }
    
    public Pagereference cancel(){
        Pagereference pageref= new Pagereference('/'+wia.id);
        pageref.setRedirect(true);
        return pageref;
    }
}