/**********************************************************************************************
* @author       Tae Tran
* @date         07/21/2015
*
* @version      1.0
*
* @description  test class for email utility
*               
* @revision     
*               
**********************************************************************************************/
@isTest
public class TestEmailUtility {
    
	static testMethod void test_create_mail()
    {         
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        String email_add = 'txtr@pge.com';
        EmailTemplate emailTemplateCSR = [select Id, Body, Subject  from EmailTemplate where DeveloperName = 'WI_is_Re_opened'];
        EmailTemplate emailTemplateSup = [select Id, Body, Subject  from EmailTemplate where DeveloperName = 'Reopened_Billing_Ops_Work_Item'];
        String plainBodysup = emailTemplateSup.Body;
		plainBodysup = plainBodysup.replace('{!Case.CaseNumber}', 'Fake case number test');		
		plainBodysup = plainBodysup.replace('{!Case.Link}', 'Fake URL link test');
        String plainBodyCSR = emailTemplateCSR.Body;                    
		plainBodyCSR = plainBodyCSR.replace('{!Case.CaseNumber}', 'Fake case number test');
		plainBodyCSR = plainBodyCSR.replace('{!Case.OwnerFullName}', 'Fake owner name test');
		plainBodyCSR = plainBodyCSR.replace('{!Case.Work_Item_Type__c}', 'Fake WI type');
		
        Test.startTest();
        email = EmailUtility.create_mail(email_add, emailTemplateSup, false, plainBodysup);
        emails.add(email); 
				
        email = EmailUtility.create_mail(email_add, emailTemplateCSR, false, plainBodyCSR);
		emails.add(email); 
        
		Messaging.sendEmail(emails);   // Send the emails
        TEst.stopTest();
		
    }

}