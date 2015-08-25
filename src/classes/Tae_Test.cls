public class Tae_Test 
{
    /*************************************************************************
    * @author         Tae Tran
    * @date           06/24/2015
    * @description    This method STOP the clock for Case Age
    * @parameters     caseList

    **************************************************************************/
/*	public static void CaseAgeStopClock(List<Case> caseList){ // work
        Diags.Info('###########ENTERING CaseAgeClock STOP');// returns the name of the case type       
		for(Case ca : caseList){         
            if(ca.Case_Age_Stopped__c == false){
				if (ca.Third_Party_Response_Required__c ==  'Yes'){		    
                    ca.Case_Age_Stopped__c = true;
					ca.Case_Age_Stopped_Start_Date__c = date.today();
					ca.Third_Party_Response__c = null;
                    ca.Case_Age_Stopped_End_Date__c = null;
				}
				else if (ca.Customer_Response_Required__c == 'Yes'){
                     ca.Case_Age_Stopped__c = true;
					ca.Case_Age_Stopped_Start_Date__c = date.today();
					ca.Customer_Response_Resolution__c = null;
                    ca.Case_Age_Stopped_End_Date__c = null;
				}
            }
		}
	}
	
	
	/*************************************************************************
    * @author         Tae Tran
    * @date           06/24/2015
    * @description    This method START the clock for Case Age
    * @parameters     caseList

    **************************************************************************/
	/*public static void CaseAgeStartClock(List<Case> caseList,  Map<Id, Case> oldCaseMap){/*
		Diags.Info('###########ENTERING CaseAgeClock START');// returns the name of the case type                      
	  	BusinessHours bh = [SELECT Id from BusinessHours where name = 'Case Age Business Hours'];
        long temp = 0;
              
		for(Case ca : caseList){
            if (ca.Total_Days_Stopped__c == null) {
                ca.Total_Days_Stopped__c = 0;
            }
            if(ca.CreatedDate == null){
                 temp = ((((BusinessHours.diff(bh.id, date.today(), date.today()) / 1000) / 60) / 60 ) /24);
            } 
            else{
                 temp = ((((BusinessHours.diff(bh.id, ca.CreatedDate, date.today()) / 1000) / 60) / 60 ) /24);
            }
               
      		if (oldCaseMap != null)	{ // error checking
                if((oldCaseMap.get(ca.id).Third_Party_Response_Required__c == 'Yes' || 
                    oldCaseMap.get(ca.id).Third_Party_Response_Required__c == 'No') && 
                    ca.Third_Party_Response_Required__c == null){
                    //Diags.Info('###########Ehitting current 3rd party' + ca.Third_Party_Response_Required__c );// returns the name of the case type   
                    //Diags.Info('###########Ehitting Old 3rd party' +  oldCaseMap.get(ca.id).Third_Party_Response_Required__c );// returns the name of the case type   
                    ca.addError('Third Party Response Required can only be YES or NO.');
           
            	}
                else if((oldCaseMap.get(ca.id).Customer_Response_Required__c == 'Yes' || 
                	  oldCaseMap.get(ca.id).Customer_Response_Required__c == 'No') && 
                	  ca.Customer_Response_Required__c == null){
                      //Diags.Info('###########Ehitting current CR' + ca.Customer_Response_Required__c );// returns the name of the case type   
                	  //Diags.Info('###########Ehitting Old CR' + oldCaseMap.get(ca.id).Customer_Response_Required__c );// returns the name of the case type   
                     ca.addError('Customer Response Required can only be YES or NO.');
             	}
      		}
            
            if (ca.Third_Party_Response_Required__c == 'No' && ca.Third_Party_Response__c != null){ // check error
                ca.addError('Third Party Response Required cannot be NO if Third Party Response if filled');
            }
            else if (ca.Customer_Response_Required__c == 'No' && ca.Customer_Response_Resolution__c != null){
                ca.addError('Customer Response Required cannot be NO if Customer Response Resolution if filled');
            }
                
            
       	  	if(ca.Case_Age_Stopped__c == true){
				if (ca.Third_Party_Response__c != null && ca.Third_Party_Response_Required__c != null){                   
                    ca.Third_Party_Response_Required__c = '';
					if(ca.Customer_Response_Required__c != 'Yes'){
						ca.Case_Age_Stopped__c = false;
						ca.Case_Age_Stopped_End_Date__c = date.today(); 
						  //Diags.Info('###########ENTERING CaseAage what is cage stop end date   - ' + ca.Case_Age_Stopped_End_Date__c);     
                          //Diags.Info('###########ENTERING CaseAage what is caage age stop date   - ' + ca.Case_Age_Stopped_Start_Date__c); 
                           //Diags.Info('###########ENTERING CaseAage what is tot day stopd   - ' + ca.Total_Days_Stopped__c);
                           //Diags.Info('###########ENTERING CaseAage what is created date stopd   - ' + ca.CreatedDate);
						long tot_stop = ((((BusinessHours.diff(bh.id, ca.Case_Age_Stopped_Start_Date__c, ca.Case_Age_Stopped_End_Date__c)/ 1000) / 60) / 60) /24);
                        ca.Total_Days_Stopped__c += tot_stop; //BusinessHours.diff(bh.id, ca.Case_Age_Stopped_Start_Date__c, ca.Case_Age_Stopped_End_Date__c);
                         //long temp = ((((BusinessHours.diff(bh.id, ca.CreatedDate, date.today()) / 1000) / 60) / 60 ) /24);
						ca.Case_Age__c = temp - ca.Total_Days_Stopped__c;						
					}
                } 
			 	else if (ca.Customer_Response_Resolution__c != null && ca.Customer_Response_Required__c != null){
                    ca.Customer_Response_Required__c = '';   
					if (ca.Third_Party_Response_Required__c != 'Yes'){
						ca.Case_Age_Stopped__c = false;
						ca.Case_Age_Stopped_End_Date__c = date.today(); 
                          long tot_stop = ((((BusinessHours.diff(bh.id, ca.Case_Age_Stopped_Start_Date__c, ca.Case_Age_Stopped_End_Date__c)/ 1000) / 60) / 60) /24);
						ca.Total_Days_Stopped__c += tot_stop; //BusinessHours.diff(bh.id, ca.Case_Age_Stopped_Start_Date__c, ca.Case_Age_Stopped_End_Date__c);
                       // long temp = ((((BusinessHours.diff(bh.id, ca.CreatedDate, date.today()) / 1000) / 60) / 60 ) /24);
                        ca.Case_Age__c = temp - ca.Total_Days_Stopped__c;						
				    }
			    }
                else if (oldCaseMap != null){
                    if (ca.Third_Party_Response_Required__c == 'No' && oldCaseMap.get(ca.id).Third_Party_Response_Required__c == 'Yes'){
						if(ca.Customer_Response_Required__c != 'Yes'){
							ca.Case_Age_Stopped__c = false;
                      	  	ca.Case_Age_Stopped_Start_Date__c = null;
                     //   long temp = ((((BusinessHours.diff(bh.id, ca.CreatedDate, date.today()) / 1000) / 60) / 60 ) /24);
							ca.Case_Age__c = temp - ca.Total_Days_Stopped__c;									
						}
					}
					else if (ca.Customer_Response_Required__c == 'No' && oldCaseMap.get(ca.id).Customer_Response_Required__c == 'Yes'){
						if(ca.Customer_Response_Required__c != 'Yes'){
							ca.Case_Age_Stopped__c = false;
                       	 	ca.Case_Age_Stopped_Start_Date__c = null;
                       	// long temp = ((((BusinessHours.diff(bh.id, ca.CreatedDate, date.today()) / 1000) / 60) / 60 ) /24);
							ca.Case_Age__c = temp - ca.Total_Days_Stopped__c;									
						}
					}
                }
			}
		}
	}
  
    
    //private static String postPoneCreditFieldId = null;
    public static Case workItem = null;
    
    public static void test_string_contain()
    {
       // String var1 = 'PSSTL; Retro Commencing; QAS8; Delayed Bills; BSEG';
       String var1 = 'BSEG;Delayed Bills;PSSTL;QAS8;Retro Commencing';
       //String var1 = 'BSEG';
        if  (var1.containsAny(';'))
        {
           	String[] multiple_wit = var1.split(';');
            for(String s : multiple_wit)
            {
                 system.debug(logginglevel.info,'value of string is:' + s);
            }
        } 
        else{
                 system.debug(logginglevel.info,'value of only 1:' + var1);
        } 
    }
/*
   System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%% QUERY %%%' + 'select Id, Name, ' + queryFields + ' Recordtype.Name from User_Skill_Rule__c where Work_Item_Type__c IN: workItemTypes OR Name = \'' + USR_SEARCH_NAME + '\' order by Sort_Order__c ASC');      

     	//Tae - Set up string to put to query
     	String list_string = '';
     	for (Integer i = 0; i < workItemTypes.size(); i++ ) {
            String s = new List<String>(workItemTypes)[i];
            if (workItemTypes.size() > 1){            
            	 list_string += '\'' + s + '\',';
        	}
            else{
				list_string += '\'' + s + '\'';
            }
        }
		System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%% workitemtype a list string values %%%...' + list_string); 
     
        //rulesList = Database.query('select Id, Name, ' + queryFields + ' Recordtype.Name from User_Skill_Rule__c where Work_Item_Type__c IN: workItemTypes OR Name = \'' + USR_SEARCH_NAME + '\' order by Sort_Order__c ASC');
        rulesList = Database.query('select Id, Name, ' + queryFields + ' Recordtype.Name from User_Skill_Rule__c where Work_Item_Type__c INCLUDES (' + list_string + ') OR Name = \'' + USR_SEARCH_NAME + '\' order by Sort_Order__c ASC');
 		
		//System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%% Tae rulesList should be two %%%...' + rulesList);    
     	//Diags.info('rulelist query' + rulesList);
  
     
        for(User_Skill_Rule__c usr : rulesList){
			 System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%% inside loop what is this user work item type %%%...' + usr.Work_Item_Type__c);    
           
            //Tae - if there are mutliple work item type will add it to the map one at a time
         /* 	if  (usr.Work_Item_Type__c.containsAny(';'))
            {
                String[] multiple_wit = usr.Work_Item_Type__c.split(';');
                for(String s : multiple_wit)
                {
					System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%% inside loop after iffffff %%%...' + s); 
                    if(witypeUsrMap.containsKey(s)){
                        List<User_Skill_Rule__c> temp = witypeUsrMap.get(s);
                        temp.add(usr);
                        witypeUsrMap.put(s,temp);
                        //System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%% inside loop after ifffffffffffffff %%%...' + witypeUsrMap); 
               	 	}
                	else{
                   		witypeUsrMap.put(s, new List<User_Skill_Rule__c> {usr});
						//System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%% inside loop after ELSESEEEEE %%%...' + witypeUsrMap); 
                	}
                }
            }           
            else{
               	//System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%% inside loop after elseeeee %%%...' + usr.Work_Item_Type__c); 
                if(witypeUsrMap.containsKey(usr.Work_Item_Type__c)){
    	        	List<User_Skill_Rule__c> temp = witypeUsrMap.get(usr.Work_Item_Type__c);
                   	temp.add(usr);
                    witypeUsrMap.put(usr.Work_Item_Type__c,temp);
					//System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%% outside loop after ifffffffffffffff %%%...' + witypeUsrMap); 
                }
                else{
                    witypeUsrMap.put(usr.Work_Item_Type__c, new List<User_Skill_Rule__c> {usr});
					//System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%% outside loop after ELSESEEEEE %%%...' + witypeUsrMap); 
                }
            }
*/
    public static void test_email_utility()
    {
        //email_return
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        String plainBody = 'This is a test';                    
        EmailTemplate emailTemplateSup = [select Id, Body, Subject  from EmailTemplate where DeveloperName = 'WI_is_Re_opened'];
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email = Email_utility.create_mail('txtr@pge.com', emailTemplateSup, false, plainBody);
        emails.add(email); 
        Messaging.sendEmail(emails);
        return;
    }
    
    //public static String getPostponeCreditDateFieldId(){
    public static String joe_test(){
        // Build http request
        HttpRequest req = new HttpRequest(); 
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
              
        //??? The Salesforce URL must be included as a Remote Site before you can query it.  
        //		Will this change? And how do we handle this dynamically, i.e. adding this new url as a remote site?
        // Build Tooling API query
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        String toolingAPIUrl = '/services/data/v33.0/tooling/';		// Spring '15 version
        String queryPostponeCreditFieldId = 'query/?q=select+id,DeveloperName,FullName+from+CustomField+where+DeveloperName=\'Postpone_Credit_Date\'+and+TableEnumOrId=\'Case\'+limit+1';
        String toolingendpoint = baseUrl + toolingAPIUrl + queryPostponeCreditFieldId;
        req.setEndpoint(toolingendpoint);
        req.setMethod('GET');
        
        // Query the Tooling API
        Http h = new Http();
        HttpResponse res = h.send(req);
        system.debug(logginglevel.info,'&&&&&&&&&&&&&&&& res.getBody() &&&&' + res.getBody());
        
        // Deserialize the JSON query result to get Id of the Case.Postpone_Credit_Date__c custom field
        Map<String, Object> fieldQueryMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        system.debug(logginglevel.info,'&&&&&&&&&&& fieldQueryMap &&&&...' + fieldQueryMap);
        List<Object> fieldQueryObject = (List<Object>)fieldQueryMap.get('records');
        Map<String, Object> fieldObjectMap = (Map<String, Object>)fieldQueryObject[0];
        String postPoneCreditDateFieldId = (String)fieldObjectMap.get('Id');
        system.debug(logginglevel.info,'&&&&&&&&&&& field Id 18 digit &&&&...' + postPoneCreditDateFieldId);
        postPoneCreditDateFieldId = postPoneCreditDateFieldId.substring(0, 15);
        system.debug(logginglevel.info,'&&&&&&&&&&& field Id 15 digit &&&&...' + postPoneCreditDateFieldId);
		
        return postPoneCreditDateFieldId;                
     }
     /*
     public static void tae_test()
     {
                  
   
         //Tae Tran - R2S1 - Use field set to populate case fields;
			Case c = new Case(); // set the case
         	
			String queryFields = '';
			for(Schema.FieldSetMember f : SObjectType.Case.FieldSets.Case_Field_Selection.getFields()) 
            {  //loop through the fields
                Schema.DisplayType fielddataType = f.getType();
                String fieldname = f.getFieldPath();
                
                // Check if a value currently exists.
                // If value exists, leave it alone.
                // Else, set a default value based on the field type
                /////// Need to confirm how the values come in from the page.  Are they all null if no data is entered? Or does the page default based on the field type.
                if (c.get(fieldname) != null) {
                    System.debug('Value already exists in field: Field...(' + fieldname + ')  Value...(' + c.get(fieldname) + ')');
                }
                else {
                    System.debug('Value does not already exist in field: Field...(' + fieldname + ')  Value...(' + c.get(fieldname) + ')');
                    
                    if(fielddataType == Schema.DisplayType.Boolean) { // set field false if boolean
       					c.put(fieldname, false);
                		System.debug(' FieldSetMember for case-->' + fieldname + ' = ' + c.get(fieldname) + ' , ' + f.getType()) ;    
                    }
                    else if(fielddataType == Schema.DisplayType.Integer) 
                    {        
                        c.put(fieldname, 0);
                        System.debug(' FieldSetMember for case-->'+ fieldname + ' = ' + c.get(fieldname) + ' , ' + f.getType());    
                    } 
                    else  
                    {
                        c.put(fieldname, null);
                        System.debug(' FieldSetMember for case-->'+ fieldname + ' = ' + c.get(fieldname) + ' , ' + f.getType());    
    
                    }
                }

			}// end for loop
     
    }// end method
	*/
}// end class