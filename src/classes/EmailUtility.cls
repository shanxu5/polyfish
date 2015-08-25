/**********************************************************************************************
* @author       Tae Tran
* @date         07/21/2015
*
* @version      1.0
*
* @description  Email utility to send out emails.   
*               
* @revision     
*               
**********************************************************************************************/

public class EmailUtility {
 	public static Messaging.SingleEmailMessage create_mail(String email_address, EmailTemplate email_Template, 
														Boolean setSaveAsActivity_value, String email_body)
	{
    	
        String[] toAddresses = new String[] {email_address};
		String subject = email_Template.Subject;
		
    	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setToAddresses(toAddresses);					
		email.setSaveAsActivity(setSaveAsActivity_value);// optional so do we need it?	
		email.setSubject(subject);
        email.setPlainTextBody(email_body);
  
		return email;
	}
}