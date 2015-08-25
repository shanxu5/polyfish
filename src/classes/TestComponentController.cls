public class TestComponentController {
    
    
    //public Boolean webPageIsInternal {get; set;}
    //public Boolean webPageIsExternal {get; set;}

    public String selectedExternalWI {get; set;}
    public String selectedExternalWIUpdated {get; set;}
    
    public String selectedSubmissionType {get; set;}
        
    public TestComponentController(){
        selectedExternalWI = '';
        selectedSubmissionType = '';
        system.debug('***First creation of TestComponentController object...selectedExternalWI: '+selectedExternalWI);
    }
    
    public PageReference updateSelectedExternalWI(){
        System.debug(logginglevel.info, '%%%%%%%%%%%%% selectedExternalWI ........'+ selectedExternalWI);  
        return null;
    }
    
    public Set<String> webformWITypeNamesSet {
        get{
            List<Webform_Field_Settings__c> externalWebformWITypesList = [Select Id, Name from Webform_Field_Settings__c where Available_for_External_Users__c = true];    
 
            Set<String> webformWITypeNamesSet = new Set<String>();
            For (Webform_Field_Settings__c externalWi : externalWebformWITypesList) {
               webformWITypeNamesSet.add(externalWi.Name);
            }
            return webformWITypeNamesSet;
        } 
        set;
    }
    //public Set<sObject> webformWITypeNamesSet = new Set<sObject>();
    public List<SelectOption> getexternalWiSelectOptions() {
            List<SelectOption> options = new List<SelectOption>();
        	options.add(new SelectOption('','Select...'));    
            for (String wiName : webformWITypeNamesSet) {
                options.add(new SelectOption(wiName,wiName));    
            }
            return options;
    }    
    

}