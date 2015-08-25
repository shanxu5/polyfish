@isTest
public class YefimTestWorkItemCloseExtension {

    public static testMethod void testGetPostponeDateFieldId() {
        Profile pfAdmin = [select Id from profile where Name = 'Administrator'];
        User pAdmin = [Select Id from User where ProfileId = :pfAdmin.Id limit 1];
        System.assert(pAdmin != null);
        
        Id billingExceptionsQueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
        
        Id recordTypeId = WorkItemAssignmentUtility.getCaseBillingExceptionsRecordTypeId();
        
        Case DaccaWI = TestUtility.CreateWorkItem('30', 'DACCA', 'Active', date.today()-300, '', '', null, null, True, null, null, billingExceptionsQueueId, recordTypeId);
        
        system.debug(logginglevel.info,'DaccaWI = ' + DaccaWI);
        System.runAs(pAdmin) {         
            
            Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());    
      
            ApexPages.StandardController sc= new ApexPages.StandardController(DaccaWI);
            WorkItemCloseExtension wice= new WorkItemCloseExtension(sc);
            
            Test.stopTest();
        }
    }
}