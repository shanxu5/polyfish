global without sharing class SendSLANotification implements Database.Batchable<sObject>{
	global Database.QueryLocator Start(Database.BatchableContext bc) {
        // Date in 2 days
        date d = date.today().addDays(Integer.valueOf(System.Label.SLA_Notification_Days)); // j1eu added for PCR 139854
        
        // Must use SLA_Notification_Days - commented out below and replaced - by yxs7 on 2015-01-28
        //String dt = DateTime.newInstance(System.today().addDays(2), Time.newInstance(0, 0, 0,0)).format('yyyy-MM-dd');
        String dt = DateTime.newInstance(System.today().addDays(Integer.valueOf(System.Label.SLA_Notification_Days)), Time.newInstance(0, 0, 0,0)).format('yyyy-MM-dd');
        
        // Query Related Records recordtype id for Customer Contact
        Id recTypeId = [select Id from RecordType where sObjectType='Case' and DeveloperName = 'Billing_Exceptions' LIMIT 1].Id;
        // Query string to query all Related Records where Recordtype is 'Customer Contact' and Id__c is null
        String query = 'SELECT Id, ' +
            				'SLA_Date__c, ' +
            				'Account.Name, ' +
            				'SFDC_SA_ID__c, ' +
            				'SFDC_SA_ID__r.Name, ' + // j1eu added for defect 107
            				'CaseNumber, ' +
            				'Work_Item_Type__c, ' +
            				'Owner.Name, ' +
            				'OwnerId, ' +
            				'Subject, ' +
            				'Owner.Email ' +
            				'from Case ' +
            				'where RecordTypeId =\''+recTypeId+'\' ' +
            				'and Owner.Type = \'User\' ' +
            				'and SLA_Date__c = '+dt ;
        system.debug('***query: '+query);
        /*AsyncApexJob a = [SELECT CreatedBy.Email
                          FROM AsyncApexJob WHERE Id = :bc.getJobId()];*/
        // Execute query
        return Database.getQueryLocator(query);
    }
    global void Execute(Database.BatchableContext bc, List<Case> caseList) {
		// Query Email Template
		EmailTemplate emailTemplate = [select Id, Body, Subject  from EmailTemplate where DeveloperName =: System.Label.SLA_Notification_Email_Template];
        system.debug('***caseList: '+caseList);
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Case c : caseList){
            String[] toAddresses = new String[] {c.Owner.Email};
            String subject = emailTemplate.Subject;
            subject = subject.replace('{!Case.CaseNumber}', c.CaseNumber);
            if(c.Subject != null){
            	subject = subject.replace('{!Case.Subject}', c.Subject);    
            }
            else{
                subject = subject.replace('{!Case.Subject}', '');    
            }
            
            
            String plainBody = emailTemplate.Body;
            
            if(c.Account.Name != null){
            	plainBody = plainBody.replace('{!Account.Name}', c.Account.Name);    
            }
            else{
                plainBody = plainBody.replace('{!Account.Name}', '');    
            }
            if(c.SFDC_SA_ID__c != null){
            	plainBody = plainBody.replace('{!Case.SFDC_SA_ID__c}', c.SFDC_SA_ID__r.Name);  // j1eu added for defect 107
            }
            else{
                plainBody = plainBody.replace('{!Case.SFDC_SA_ID__c}', '');   
            }
            
            plainBody = plainBody.replace('{!Case.CaseNumber}', c.CaseNumber);
            plainBody = plainBody.replace('{!Case.Work_Item_Type__c}', c.Work_Item_Type__c);
            plainBody = plainBody.replace('{!Case.OwnerFullName}', c.Owner.Name);
        	
            String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            plainBody = plainBody.replace('{!Case.Link}', sfdcBaseURL+'/'+c.Id);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(toAddresses);
            //email.setTargetObjectId(c.OwnerId);
            //email.setTemplateId(emailTemplate.Id);
            email.setSaveAsActivity(false);
            email.setSubject(subject);
            email.setPlainTextBody(plainBody);
            //mail.setWhatId(c.Id);
    		emails.add(email);
        }
        Messaging.sendEmail(emails);        
    }
    global void Finish(Database.BatchableContext bc) {
    }
}