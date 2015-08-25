/*
	@Company		Pacific Gas & Electric	
	@Author			Joe Kowalsky
	@Date			02.June.2015
	@Description	Test Class for the Work Item Close Visualforce Page
	@Revision(s)	
*/
@isTest
public class TestWorkItemCloseExtension {
    // A portion of the getPostponeCredidDateFieldId() method will not be tested because
    // 	'Methods defined as TestMethod do not support Web service callouts, test skipped'
    public static testMethod void testGetPostponeDateFieldId() {
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
            
        System.runAs(thisUser){
            Case wi = new Case();
            ApexPages.StandardController sc= new ApexPages.StandardController(wi);
            WorkItemCloseExtension wice= new WorkItemCloseExtension(sc);
        }
    }
}