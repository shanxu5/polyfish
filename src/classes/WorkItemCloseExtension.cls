/*
	@Company		Pacific Gas & Electric
	@Author	        Joe Kowalsky
	@Date			01.June.2015
	@Description	Controller extension for Work Item Close visual force page
	@Revision(s)	
*/

public class WorkItemCloseExtension {
    
    public static String postponeCreditDateFieldId {get; set;}
    public WorkItemCloseExtension(ApexPages.StandardController sc){
    	// Call method and set variable to make it available to the VF page.
    	// Need get/set to make this work.       
        postponeCreditDateFieldId = System.Label.Case_Postpone_Credit_Date_Field_Id;

    }
    
}