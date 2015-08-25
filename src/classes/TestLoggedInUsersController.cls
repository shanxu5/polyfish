@isTest
private class TestLoggedInUsersController {
	static testMethod void testLoggedInUsersController() {
    	PageReference pageRef = Page.CurrentlyLoggedinUsers;
        Test.setCurrentPage(pageRef); 
        
        LoggedinUsersController cont = new LoggedinUsersController();
        cont.getpageHelperList();
    }
}