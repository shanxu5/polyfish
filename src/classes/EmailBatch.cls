/**********************************************************************************************
* @author       Tae Tran
* @date         07/21/2015
*
* @version      1.0
*
* @description  Email batch process use by reopenworkitem class in Casetriggerhandler
*               
* @revision     
*               
**********************************************************************************************/

global class EmailBatch implements Database.batchable<sObject>
{
	global final string query;

    //set up the query
	global EmailBatch (String q){   
		//query pass from reopenworkitem in case trigger handler
		query = q;
	}

    //calls the query
	global Database.QueryLocator start(Database.BatchableContext BC){
		// run the query
		return Database.getQueryLocator(query);
    }
   
    //execute the query
    global void execute(Database.BatchableContext BC, List<Case> scope){
        
        System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%%what is in scope...' + scope);
		Map<Id, String> ownerNameMap = new Map<Id, String>();
        Map<Id, String> ownerEmailMap = new Map<Id, String>();
		Set<Id> userIds = new Set<Id>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Id csrId = WorkItemAssignmentUtility.getCSRProfileId();
		List<Case> caseUpdate = new List<Case>();
        
		EmailTemplate emailTemplateCSR = [select Id, Body, Subject  from EmailTemplate where DeveloperName = 'WI_is_Re_opened'];
        EmailTemplate emailTemplateSup = [select Id, Body, Subject  from EmailTemplate where DeveloperName = 'Reopened_Billing_Ops_Work_Item'];
		
		// Loop reopened work items
        for(Case c : scope){
            userIds.add(c.OwnerId);
        }
        System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%%userIds...' + userIds);
        
		// Query and Loop the User records of the work item owners
        for(User u : [select Id, IsActive, FirstName, LastName, Name, Email from User where Id IN: userIds]){
			// Populate Maps
			// Key: Owner Id Value: Owner Name
            ownerNameMap.put(u.Id, u.Name);
			// Key: Owner Id Value: Owner Email
            ownerEmailMap.put(u.Id, u.Email);
        }
        System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%%What is the ownerEmailMap...' + ownerEmailMap);
               
		//loop through and build email list to send it out
        for(Case c : scope){            
			if(c.Approver_Reviewer_Email__c != null){	
				String plainBody = emailTemplateSup.Body;
				plainBody = plainBody.replace('{!Case.CaseNumber}', c.CaseNumber);
				String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();				
				plainBody = plainBody.replace('{!Case.Link}', sfdcBaseURL+'/'+c.Id);					
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				email = EmailUtility.create_mail(c.Approver_Reviewer_Email__c, emailTemplateSup, false, plainBody);
				emails.add(email); 
			}
			
			//TXTR - R2S2 - only send CSR email if the ower type is user
			System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%%userIds for csr...' + c.OwnerId);
			if(String.valueOf(c.OwnerId).startsWith('005')) //|| c.Owner.type == 'User' 
			{
				String plainBodyCSR = emailTemplateCSR.Body;                    
				plainBodyCSR = plainBodyCSR.replace('{!Case.CaseNumber}', c.CaseNumber);
				plainBodyCSR = plainBodyCSR.replace('{!Case.OwnerFullName}', ownerNameMap.get(c.OwnerId));
				plainBodyCSR = plainBodyCSR.replace('{!Case.Work_Item_Type__c}', c.Work_Item_Type__c);
				
				if(c.Root_Cause__c != null){
					plainBodyCSR = plainBodyCSR.replace('{!Case.Root_Cause__c}', c.Root_Cause__c); 
				}
				else{
					plainBodyCSR = plainBodyCSR.replace('{!Case.Root_Cause__c}', '' );
				}
				if(c.Root_Cause_Other__c != null){
					plainBodyCSR = plainBodyCSR.replace('{!Case.Root_Cause_Other__c}', c.Root_Cause_Other__c);
				}
				else{
					plainBodyCSR = plainBodyCSR.replace('{!Case.Root_Cause_Other__c}', '');
				}

				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				email = EmailUtility.create_mail(ownerEmailMap.get(c.OwnerId), emailTemplateCSR, false, plainBodyCSR);
				emails.add(email); 
                
				// blank out root cause and  root cause other field after the email is sent
                c.Root_Cause__c = null;
                c.Root_Cause_Other__c = null;
                caseUpdate.add(c);
               
			}		
		}
        Messaging.sendEmail(emails);   // Send the emails
        update caseUpdate;
    }
   
    global void finish(Database.BatchableContext BC)
    {
		// not implemented since not need for this batch
    }
   
}