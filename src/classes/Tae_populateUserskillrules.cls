public class Tae_populateUserskillrules {
     /*************************************************************************
    * @author         Janella Espiritu
    * @date           08/26/2014
    * @description    This method loops through User Skill Rule records to 
    *           look for the correct User Skill based on criteria
    * @parameters    List of Cases Inserted
    **************************************************************************/
 	public static void populateUserSkillRule(List<Case> caseList){
        // Query All User Skill Rule Records
        List<User_Skill_Rule__c> rulesList = new List<User_Skill_Rule__c>();
        Map<String,List<User_Skill_Rule__c>> witypeUsrMap = new Map<String,List<User_Skill_Rule__c>>();
        Set<String> workItemTypes = new Set<String>();
        Id notAbleToAssign;
        Id mbtQueue = WorkItemAssignmentUtility.getMBTQueueId();
		Id fastSlowQueue = WorkItemAssignmentUtility.getFastSlowToDoQueueId();
       
        Diags.enter('entering populating user skill rules.  Case list size is:' + caselist.size());
            for(Case c : caseList){
            workItemTypes.add(c.Work_Item_Type__c);
        }
  
        String USR_SEARCH_NAME = 'Billing Operations Not Able to Assign';
        String queryFields = '';
		List<UserSkillRulesAndCaseMap__c> mcs = UserSkillRulesAndCaseMap__c.getAll().values();        
                        
		// Build query fields from User Skill Rule Map custom setting object
        for (UserSkillRulesAndCaseMap__c m : mcs) {
            queryFields += m.name + ', ';
        }
		
		//Tae - Set up string to put to query
        String list_string = '';
        for (Integer i = 0; i < workItemTypes.size(); i++ ) {
			String s = new List<String>(workItemTypes)[i];
			if (i < (workItemTypes.size() -1) ){            
				list_string += '\'' + s + '\', ';
				//list_string += s + ',';
			}
			else{
				//list_string +=  s ;
				list_string += '\'' + s + '\' ';
			}
        }		
		String var_temp = 'select Id, Name, ' + queryFields + ' Recordtype.Name, Owner_Type__c from User_Skill_Rule__c where Work_Item_Type__c INCLUDES (' + list_string + ') OR Name = \'' + USR_SEARCH_NAME + '\' order by Sort_Order__c ASC';
		//String var_temp = 'select Id, Name, ' + queryFields + ' Recordtype.Name, Owner_Type__c from User_Skill_Rule__c where Work_Item_Type__c INCLUDES ( :list_string ) OR Name = \'' + USR_SEARCH_NAME + '\' order by Sort_Order__c ASC';	        
		Diags.Info('Work item types %%%' + workItemTypes);
     	Diags.Info('List of string query %%%' + list_string);
     	Diags.Info('Var_temp string %%%' + var_temp);
        
		rulesList = Database.query(var_temp);
     	Diags.Info('Query results %%%...' + rulesList);
     
		system.debug(logginglevel.info,'Query results %%%...' + rulesList);
        for(User_Skill_Rule__c usr : rulesList){
            //Tae - if there are mutliple work item type will add it to the map one at a time
            if  (usr.Work_Item_Type__c.containsAny(';')){
                String[] multiple_wit = usr.Work_Item_Type__c.split(';');
                for(String s : multiple_wit){
                    if(witypeUsrMap.containsKey(s)){
                        List<User_Skill_Rule__c> temp = witypeUsrMap.get(s);
                        temp.add(usr);
                        witypeUsrMap.put(s,temp);
					}
                    else{
						witypeUsrMap.put(s, new List<User_Skill_Rule__c> {usr});
					}
                }
            } 
            else{
                if(witypeUsrMap.containsKey(usr.Work_Item_Type__c)){
					List<User_Skill_Rule__c> temp = witypeUsrMap.get(usr.Work_Item_Type__c);
					temp.add(usr);
                    witypeUsrMap.put(usr.Work_Item_Type__c,temp);
    
                }
                else{
                    witypeUsrMap.put(usr.Work_Item_Type__c, new List<User_Skill_Rule__c> {usr});

                }
            }

			if(usr.Name == USR_SEARCH_NAME){
				notAbleToAssign = usr.Id;
			}
        } // end for loop user_skill_rule__c

        // Loop inserted Cases
        for(Case c : caseList){
                  
            if(witypeUsrMap.containsKey(c.Work_Item_Type__c)){
                // Default value is Billing Exceptions not able to Assign
                c.User_Skill_Rule__c = notAbleToAssign;
                List<User_Skill_rule__c> usrList = witypeUsrMap.get(c.Work_Item_Type__c);
                // Initialize boolean variables for fields to be validated
                boolean validate_all = false;
                boolean RuleSelected = false;
				// Tae - R2S3 - this loop will create a new list if the Owner_Type__c in user skills object is marked Queue or User
				List<User_Skill_rule__c> tempList = new List<User_Skill_rule__c>();
				for (User_Skill_rule__c usrc : usrList)
				{
					if (usrc.Owner_Type__c != '' && usrc.Owner_Type__c != null )
					{
						if(String.valueOf(c.OwnerId).startsWith('00G') && (usrc.Owner_Type__c == 'Queue')) // grouped for queue
						{
	                      	tempList.add(usrc);
    		            }
            	        else if(String.valueOf(c.OwnerId).startsWith('005') &&  (usrc.Owner_Type__c == 'User')) //not group for user
                	    {
							tempList.add(usrc);
						} 
					}
				} // end for
	
				if( tempList.size() > 0 ) // check the templist is big before updating the list
				{
					usrList = tempList;
				}
                // Loop User Skill Rule records
                for(User_Skill_Rule__c usr : usrList){
                    // If there is no User Skill Rules found, go to the validation process
                    Diags.Enter('************User skill rull being eveluated: ' + usr.Name);
                    if(!RuleSelected){
				        //Loop through User Skill Rule Fields and validate
				        for (UserSkillRulesAndCaseMap__c m : mcs) {
				        	// First check for validations that must be performed against multiple fields
				        	if (m.Name == 'SA_Status__c' || m.Name == 'Commencing_Bill__c') {
				        		// Validate SA Status/Commencing Bill
				        		// If the current user skill rule has value for SA Status OR Commencing Bill
		                    	if((usr.SA_Status__c != null && usr.SA_Status__c != '') || (usr.Commencing_Bill__c != null && usr.Commencing_Bill__c != '')){
		                            Boolean validSAStatus = false;
		                            Boolean validCommencingBill = false;
		                            // If the current case has value for SA Status
		                            if(c.SA_Status__c != null && c.SA_Status__c != ''){
		                                // Call validateStringContains from UserSkillRuleUtility and pass the Case's and User Skill Rules' values for SA Type
		                                validSAStatus = UserSkillRuleUtility.validateStringContains(c.SA_Status__c , usr.SA_Status__c);
		                            }
		                            if(usr.Commencing_Bill__c != null && usr.Commencing_Bill__c != ''){
		                                validCommencingBill = UserSkillRuleUtility.validateBoolean(c.Commencing_Bill__c, usr.Commencing_Bill__c);
		                                validate_all = validCommencingBill;
		                            }
		                            // If the case does not have value for SA Status, then it's not valid
		                            if(validSAStatus || validCommencingBill){
		                                validate_all = true;
		                            }
		                            else{
		                                validate_all = false;
		                            } 
		                        }
		                        // If the current user skill rule does not have value on SA Status and Commencing Bill, the code will bypass validation
		                        else if((usr.SA_Status__c == null || usr.SA_Status__c == '') && (usr.Commencing_Bill__c == null || usr.Commencing_Bill__c == '')){
		                            validate_all = true;
		                        }
		                    }	
		                    else if (m.Name == 'Age_Bucket_Start__c' || m.Name == 'Age_Bucket_End__c' || m.Name == 'Days_Late_Age_Evaluator__c') {
								// Validate Days Late / Age
								//system.debug(logginglevel.info,'age bucket...usr...' + usr.Name + '::' + usr.Medical_Allotment__c + '::' + usr.Medical_Allotment_Evaluator__c);
		                        // If the current user skill rule has value for Age Bucket AND Days Late Age Evaluator
		                        if(usr.Age_Bucket_Start__c != null && usr.Days_Late_Age_Evaluator__c != null && usr.Days_Late_Age_Evaluator__c != ''){
		                            // If Days Late/ Age Evaluator is 'equals', call validateEquals from UserSkillRuleUtility and pass the Case's Age and User Skill Rules' Age Bucket
		                            if(usr.Days_Late_Age_Evaluator__c == 'equals'){
		                                validate_all =  UserSkillRuleUtility.validateEquals(usr.Age_Bucket_Start__c, c.Age__c);
		                            }
		                            // If Days Late/ Age Evaluator is 'not equal to', call validateNotEqualTo from UserSkillRuleUtility and pass the Case's Age and User Skill Rules' Age Bucket
		                            else if(usr.Days_Late_Age_Evaluator__c == 'not equal to'){
		                                validate_all =  UserSkillRuleUtility.validateNotEqualTo(usr.Age_Bucket_Start__c, c.Age__c);
		                            }
		                            // If Days Late/ Age Evaluator is 'less than', call validateLessThan from UserSkillRuleUtility and pass the Case's Age and User Skill Rules' Age Bucket
		                            else if(usr.Days_Late_Age_Evaluator__c == 'less than'){
		                                validate_all =  UserSkillRuleUtility.validateLessThan(usr.Age_Bucket_Start__c, c.Age__c);
		                            }
		                            // If Days Late/ Age Evaluator is 'greater than', call validateGreaterThan from UserSkillRuleUtility and pass the Case's Age and User Skill Rules' Age Bucket
		                            else if(usr.Days_Late_Age_Evaluator__c == 'greater than'){
		                                validate_all =  UserSkillRuleUtility.validateGreaterThan(usr.Age_Bucket_Start__c, c.Age__c);
		                            }
		                            // If Days Late/ Age Evaluator is 'less or equal', call validateLessOrEqual from UserSkillRuleUtility and pass the Case's Age and User Skill Rules' Age Bucket
		                            else if(usr.Days_Late_Age_Evaluator__c == 'less or equal'){
		                                validate_all =  UserSkillRuleUtility.validateLessOrEqual(usr.Age_Bucket_Start__c, c.Age__c);
		                            }
		                            // If Days Late/ Age Evaluator is 'greater or equal', call validateGreaterOrEqual from UserSkillRuleUtility and pass the Case's Age and User Skill Rules' Age Bucket
		                            else if(usr.Days_Late_Age_Evaluator__c == 'greater or equal'){
		                                validate_all =  UserSkillRuleUtility.validateGreaterOrEqual(usr.Age_Bucket_Start__c, c.Age__c);
		                            }
		                            // If Days Late/ Age Evaluator is 'between', call validateBetween from UserSkillRuleUtility and pass the Case's Age and User Skill Rules' Age Bucket
		                            else if(usr.Days_Late_Age_Evaluator__c == 'between'){
		                                validate_all =  UserSkillRuleUtility.validateBetween(usr.Age_Bucket_Start__c, usr.Age_Bucket_End__c, c.Age__c);
		                            }
		                            // Else, it is invalid
		                            else{
		                                validate_all = false;
		                            } 
		                        }
		                        // If the current user skill rule does not have value on Age Bucket and Days/Late Age Evaluator, the code will bypass validation
		                        else if(usr.Age_Bucket_Start__c == null && usr.Age_Bucket_End__c == null && (usr.Days_Late_Age_Evaluator__c == null || usr.Days_Late_Age_Evaluator__c =='')){
		                            validate_all = true;
		                        }
		                    }
                            else if(m.Name == 'Medical_Allotment_Evaluator__c' || m.Name == 'Medical_Allotment__c') 
                            {
                             	if(usr.Medical_Allotment__c != null && usr.Medical_Allotment_Evaluator__c != null && usr.Medical_Allotment_Evaluator__c != '')
                                {
                                    if(usr.Medical_Allotment_Evaluator__c == 'equals'){
                                        validate_all =  UserSkillRuleUtility.validateEquals(usr.Medical_Allotment__c, c.Medical_Allotment__c);
                                    }
                                    else if(usr.Medical_Allotment_Evaluator__c == 'not equal to'){
                                        validate_all =  UserSkillRuleUtility.validateNotEqualTo(usr.Medical_Allotment__c, c.Medical_Allotment__c);
                                    }
                                    else if(usr.Medical_Allotment_Evaluator__c == 'less than'){
                                        validate_all =  UserSkillRuleUtility.validateLessThan(usr.Medical_Allotment__c, c.Medical_Allotment__c);
                                    }
                                    else if(usr.Medical_Allotment_Evaluator__c == 'greater than'){
                                        validate_all =  UserSkillRuleUtility.validateGreaterThan(usr.Medical_Allotment__c, c.Medical_Allotment__c);
                                    }
                                    else if(usr.Medical_Allotment_Evaluator__c == 'less or equal'){
                                        validate_all =  UserSkillRuleUtility.validateLessOrEqual(usr.Medical_Allotment__c, c.Medical_Allotment__c);
                                    }
                                    else if(usr.Medical_Allotment_Evaluator__c == 'greater or equal'){
                                        validate_all =  UserSkillRuleUtility.validateGreaterOrEqual(usr.Medical_Allotment__c, c.Medical_Allotment__c);
                                    }
                                    // Else, invalid evaluator was chosen.
                                    else{
                                        validate_all = false;
                                    } 
                                } 
                                else {
                                    validate_all = true;
                                }
                            }
							
		                    else {	// validate single fields not dependent on other fields
                                
                                String usrStrValue   = '';
                                Decimal usrDecimalValue = 0;
                                
                                String wiStrValue    	= '';
                                Decimal wiDecimalValue  = 0;
                                Boolean wiBoolValue  	= false;
                                
                                // Get User Skill Rule value
                                if (m.USR_Field_Type__c == 'String') {
                                    usrStrValue = (String)usr.get(m.Name);
                                }
                                if (m.USR_Field_Type__c == 'Decimal') {
                                    usrDecimalValue = (Decimal)usr.get(m.Name);
                                }
                                
                                // Get Work Item value
                                if (m.WI_Field_Type__c == 'String') {
                                    wiStrValue = (String)c.get(m.Work_Item_Field_Name__c);
                                }
                                if (m.WI_Field_Type__c == 'Decimal') {
                                    wiDecimalValue = (Decimal)c.get(m.Work_Item_Field_Name__c);
                                }
                                if (m.WI_Field_Type__c == 'Boolean') {
                                    wiBoolValue = (Boolean)c.get(m.Work_Item_Field_Name__c);
                                }
                                
								Diags.Enter('************what is the work item field name: ' + c.get(m.Work_Item_Field_Name__c));

                                // Validate remaining fields
					            if (usr.get(m.Name) != null && usr.get(m.Name) != '') {
                                    if (m.Validation_Method__c == 'validateBoolean') {
				                        validate_all = UserSkillRuleUtility.validateBoolean(wiBoolValue, usrStrValue);
				                    }
				                    else {
										Diags.Enter('************entering validate: ' + m.Validation_Method__c);
						                if (c.get(m.Work_Item_Field_Name__c) != null && c.get(m.Work_Item_Field_Name__c) != '') {
                                            // Validation methods with String parameters
						                    if (m.Validation_Method__c == 'validateStringContains') {
						                        validate_all = UserSkillRuleUtility.validateStringContains(wiStrValue, usrStrValue);
						                    }
						                    else if (m.Validation_Method__c == 'validateEqualStrings') {
											Diags.Enter('************entering validateEqualStrings: **WISTRVALUE' + wiStrValue + '; **USRSTRVALUE ' +usrStrValue);
						                        validate_all = UserSkillRuleUtility.validateEqualStrings(wiStrValue, usrStrValue);
						                    }
                                            // Validation methods with Decimal parameters
                                            else if (m.Validation_Method__c == 'validateEquals') {
                                                    validate_all = UserSkillRuleUtility.validateEquals(usrDecimalValue, wiDecimalValue);    
                                            }
                                            else if (m.Validation_Method__c == 'validateNotEqualTo') {
                                                validate_all = UserSkillRuleUtility.validateNotEqualTo(usrDecimalValue , wiDecimalValue);    
                                            }
                                            else if (m.Validation_Method__c == 'validateLessThan') {
                                                validate_all = UserSkillRuleUtility.validateLessThan(usrDecimalValue , wiDecimalValue);    
                                            }
                                            else if (m.Validation_Method__c == 'validateGreaterThan') {
                                                validate_all = UserSkillRuleUtility.validateGreaterThan(usrDecimalValue , wiDecimalValue);    
                                            }
                                            else if (m.Validation_Method__c == 'validateLessOrEqual') {
                                                validate_all = UserSkillRuleUtility.validateLessOrEqual(usrDecimalValue, wiDecimalValue);    
                                            }
                                            else if (m.Validation_Method__c == 'validateGreaterOrEqual') {
                                                validate_all = UserSkillRuleUtility.validateGreaterOrEqual(usrDecimalValue, wiDecimalValue);    
                                            }
                                            else {  // validation method entered is not recognized
                                                validate_all = false;
												Diags.Enter('Hitting false for Validate_all if none of the validation rule pass');
                                            }
						                }
						                else {  // Work Item field is null or empty string
                                           	Diags.Enter('%%%%%%%Hitting false for Validate_all' + usr );
						                    validate_all = false;
						                }
				                    }
					            }
					            else {  // User Skill Rule field is null or empty string
					                validate_all = true;
					            }
		                    }	// end validate all fields

		                    //System.debug(Logginglevel.info,'Current field being validated: ' + m.Name + ' Validation result: ' + validate_all);
		                    // if any of the fields validate to false, break out of loop to validate field names and move on to validate next user skill rule
				            if (validate_all == false) {
				            	break;
				            }
				            
				        }   // End for loop on User Skill Rule field names
                        
                        // If all fields validate to TRUE, set RuleSelected boolean to stop the loop					
                        if(validate_all){
                           	Diags.Enter('%%%%%%%%%%%%%%%%%%All fields validated to true What is usr.Recordtype.Name:' + usr.Recordtype.Name + ' - ' +usr.Name );
                            c.User_Skill_Rule__c = usr.Id;
                            // Assign to MBT iMacro Queue
                            if(usr.Recordtype.Name == 'BSEG MBT Elec SM30 SM40'){
                                   c.OwnerId = mbtQueue;
                            }
							// If the User Skill Rule Name is Fast/Slow Meter Adj - Gas
							if(usr.Name == 'Fast/Slow Meter Adj - Gas' ){
								c.OwnerId = fastSlowQueue;
							}
                            RuleSelected = true;
                        }
                        
                    }	// End if !RuleSelected
                }	// End loop of User Skill Rules that apply for the current case/work item being processed
            }
            else{
            	// Unable to assign a User Skill Rule to the current case/work item being processed, because no USR applies for that WI.
                c.User_Skill_Rule__c = notAbleToAssign;
            }
        }
        //system.debug('populateUserSkillRule current cpu usage is' + limits.getLimitCpuTime()+' : ' + limits.getCpuTime());
		//.clear();
     }

}