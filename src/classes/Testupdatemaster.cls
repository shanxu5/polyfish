@isTest
public class Testupdatemaster {
    static testMethod void updateWebformRequest() {
        Webform_Master_Request__c wfm = new Webform_Master_Request__c();

        wfm.Requestor_s_Email__c = 'myemail@pge.com';
        wfm.Requestor_s_Name__c = 'myname';
        wfm.Total_Completed_Work_Items__c = 0;
        insert wfm;
        
        RecordType rec = [Select id from RecordType where DeveloperName = 'Mailbox' and sObjecttype = 'Case'];
        // Create Test data for Work Item record
        List < Case > wiList = new List < Case > ();
        for (Integer i = 1; i <= 20; i++)

        {
            Case wi = new Case();
            wi.Webform_Request_Number__c = 'wfr' + i;
            wi.status = 'Unassigned' + i;
            wi.Webform_Request_Number__c = wfm.Name;
            wi.RecordTypeId = rec.id ;
            wi.origin = 'Email' + i;
            wi.CC_Person_ID__c = '1234' + i;
            wi.Customer_Contact_ID__c = '23455' + i;
            wi.Customer_Contact_Class__c = 'Direct Access' + i;
            wi.Customer_Contact_Type__c = 'Direct Access Inquiry/Note' + i;
            wi.SOX_Required_Information__c = 'Service Agreement ID' + i;
            wi.CC_Service_Agreement_ID__c = '123' + i;
            wi.CC_Account_ID__c = '987' + i;
            wi.CC_Service_Point_ID__c = '7898' + i;
            wi.CC_Premise_ID__c = '890' + i;
            wi.CC_Premise_Address__c = 'premise address' + i;
            wiList.add(wi);

        }

        insert wiList;
        

        Test.startTest();

        List < Case > updatedwiList = new List < Case > ();
        for (Case wi: wiList) {
            wi.status = 'Completed';
            wi.CC_Person_ID__c = 'test';
            wi.Customer_Contact_Class__c = 'Billing Inquiry Note';
            wi.Customer_Contact_Type__c = 'Billing Inquiry Note';
            updatedwiList.add(wi);

        }
        update updatedwiList;

        System.assertEquals(wfm.Total_Completed_Work_Items__c, 20);

        Test.stopTest();



    }

}