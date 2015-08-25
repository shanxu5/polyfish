/*
 *  5/27/2015 - R2S2 - Tae - Email utility to use to send email out
 * 
*/

public class Email_utility {

    Public static Messaging.SingleEmailMessage create_mail(String email_address, EmailTemplate email_Template, 
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