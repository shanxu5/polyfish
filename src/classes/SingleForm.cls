public class SingleForm
{
	Boolean reqrendered = false;
	Boolean Visrendered = false;
    public Webform_Field_Settings__c fieldSettings;
    public String WorkItem {get;set;}        
    
public SingleForm()
{
fieldSettings = [select Account_ID__c, Person_ID__c,Premise_ID__c,RAP_Work_ID__c,Service_Agreement_ID__c,Service_Point_ID__c from Webform_Field_Settings__c where name =:workItem];


}


}