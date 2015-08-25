/**********************************************************************************************
* @author       Janella Espiritu
* @date         08/26/2014
* @description  This class holds all the processes for CaseTrigger
*
* @version      1.2
*
* @revision(s)  Janella Espiritu 09102014 R1S2 : Ability to Group Work Items
        Janella Espiritu 09102014 R1S2 : Retrieve related work Items on Assignment
        Janella Espiritu 09152014 R1S2 : Add User Skill Rule validation for DA
        Janella Espiritu 10142014 R1S3 : Add Grouping Rules for NEM
        01.16.2015 J1EU R1 Stabilisation - updated query to look for Parent and added order
                    for CaseNumber
        Yefim Shuster on 2015-02-04 - Defect 135 - call createStatusTimes After Insert for Recreated WI
        Yefim Shuster on 2015-02-18 - PCR 140278 - MBT Reassignment - remove User_Skill_Rule__r.RecordType.Name !=: USR_RECORDTYPE_MBT
                                     query criteria from groupWorkItems() and assignWorkItems()
        Yefim Shuster on 2015-02-19 - PCR 140421 BSEG and Delayed Bill being created for same SA - exclude WI owned by Duplicate Exceptions Queue from grouping
        Yefim Shuster on 2015-02-19 - Defect 139 - Auto assignment does not work if Parent has open bill cycle and child is
                                      canceled or completed
        Tae Tran on 2015-04-06    - Defect 154 - On WI assignment record change, if the assigned work item load score is <100 then it throws 
                    the error message. Because if the load score is less than 100 it tries to assign the work based on user skill 
                    rules and it error out. Also same error can be re-produce when WI are getting auto assigned.
        Yefim Shuster on 2015-04-20 - R2 - added Diagnostics
        Yefim Shuster on 2015-05-13 - R2 - refactor Work Item Assignment - new version is 1.1
        Janella Espiritu on 2015-05-14 - R2S1 - Update concatenateAdditionalComments and concatenateCustomerContactFields
        Janella Espiritu on 2015-06-24 - R2S3 - Update to call ValidationUtility.ValidateCanceledSubStatus for Cancelled work items
        Janella Espiritu on 2015-06-24 - R2S3 - Update to call ValidationUtility.ValidateCanceledSubStatus for Cancelled work items
        Yefim Shuster on 2015-07-28 - R2S4 - replace DLRS - new version is 1.2
		
**********************************************************************************************/
public without sharing class CaseTriggerHandler_DEV {

/*************************************************************************
    * @author         Bharghavi Nekkanti
    * @date           08/04/2015
    * @description    This method updates the field no of work items completed on Webform master object whenever a case
    status is changed to completed.
    * @parameters    Old map and new map of case wen status changes to complete
    **************************************************************************/

	public static void updateWebformRequest(Map<ID,Case> oldMap, Map<Id, Case> newMap){

	
        //Variable declarations
        AggregateResult[] aggr;
        RecordType caseRecordtype = [Select id from RecordType where sObjectType = 'Case' and Name = 'Mailbox'];
        Set<String> wfBatchnumbers = new Set<String>();
        Map<String,Integer> resMap= new Map<String,Integer>();
        List<Webform_Master_Request__c> masterRequests = new List<Webform_Master_Request__c>();
        List<Webform_Master_Request__c> masterRequestsUpdate = new List<Webform_Master_Request__c>();
        
        //Filter out recors which are updated to completed and is of recordtype Mailbox
        for(ID idKey : newMap.keyset()){
            if(newMap.get(idKey).recordtypeid == caseRecordtype.id && newMap.get(idKey).Status == 'Completed' && oldMap.get(idKey).Status != 'Completed'){
                wfBatchnumbers.add(newMap.get(idKey).Webform_Request_Number__c);
            }
        }
        
        if(!wfBatchnumbers.isEmpty()){
            // Find out count per batch number
            aggr = [ Select count(id) cnt,Webform_Request_Number__c FROM Case Where Webform_Request_Number__c IN: wfBatchnumbers And Status = 'Completed' Group By Webform_Request_Number__c];
            System.debug('@@@@@@@@@@' + aggr);
            //query master request details
            masterRequests = [Select id,Name,Total_Completed_Work_Items__c from Webform_Master_Request__c where Name IN: wfBatchnumbers ];
            
            //put aggregarete data in a map
            for(AggregateResult ar:aggr){
                System.debug('$$$$$$$' + ar);
                resMap.put((String) ar.get('Webform_Request_Number__c'),(Integer) ar.get('cnt') );
                System.debug('*********' + resMap.values());
            }
            
            //assign count of completed items to master request
            if(!masterRequests.isEmpty()){
                for (Webform_Master_Request__c wmr:masterRequests ){
                    wmr.Total_Completed_Work_Items__c = resMap.get(wmr.Name);
                    masterRequestsUpdate.add(wmr);
                  System.debug('*******' + wmr);      
                }
            } 
            // update records
            if(!masterRequestsUpdate.isEmpty()){
                update masterRequestsUpdate;
                System.debug ('***********' + masterRequestsUpdate);

            }
        }   
    }
    
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
		System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%% workItemTypes %%%...' + workItemTypes);             
  
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
		System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%% Work item types %%%' + workItemTypes);
        System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%% String Query %%%' + var_temp);
        System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%% List of string query %%%...' + list_string); 
        System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%% Query results %%%...' + rulesList);    
     
        //Diags.info('rulelist query' + rulesList);
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
                //Diags.Enter('%%%%%%%%%%%%%%%%%% inside loop after elseeeee %%%...' + usr.Work_Item_Type__c); 
                if(witypeUsrMap.containsKey(usr.Work_Item_Type__c)){
					List<User_Skill_Rule__c> temp = witypeUsrMap.get(usr.Work_Item_Type__c);
					temp.add(usr);
                    witypeUsrMap.put(usr.Work_Item_Type__c,temp);
                    //Diags.Enter('%%%%%%%%%%%%%%%%%% outside loop after ifffffffffffffff %%%...' + witypeUsrMap); 
                }
                else{
                    witypeUsrMap.put(usr.Work_Item_Type__c, new List<User_Skill_Rule__c> {usr});
                    //Diags.Enter('%%%%%%%%%%%%%%%%%% outside loop after ELSESEEEEE %%%...' + witypeUsrMap); 
                }
            }

			if(usr.Name == USR_SEARCH_NAME){
				notAbleToAssign = usr.Id;
			}
        } // end for loop user_skill_rule__c

      
      	Diags.Enter('%%%%%%%%%%%%%%%%%% WitUsrMap out of loop results%%%...' + witypeUsrMap);    
        system.debug('**id'+notAbleToAssign);
		System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%% wit_type_ur_map: %%%...');   

        // Loop inserted Cases
        for(Case c : caseList){
                  
            if(witypeUsrMap.containsKey(c.Work_Item_Type__c)){
                // Default value is Billing Exceptions not able to Assign
                c.User_Skill_Rule__c = notAbleToAssign;
                List<User_Skill_rule__c> usrList = witypeUsrMap.get(c.Work_Item_Type__c);
                // Initialize boolean variables for fields to be validated
                boolean validate_all = false;
                boolean RuleSelected = false;
                Diags.Enter('WHAT IS THE LIST OF USER SKILL RULES ' + usrList);  // SHOW BOTH GROUPED AND NOT GROUPED
system.debug(logginglevel.info, '*WHAT IS THE LIST OF USER SKILL RULES ' + usrList);  		
				// Tae - R2S3 - this loop will create a new list if the Owner_Type__c in user skills object is marked Queue or User
				List<User_Skill_rule__c> tempList = new List<User_Skill_rule__c>();
                
                //comment for unaged debt user skill rule
				for (User_Skill_rule__c usrc : usrList)
				{
					Diags.Enter('What ownertype filed in user skill ' + usrc.Owner_Type__c);
system.debug(logginglevel.info, 'What ownertype filed in user skill ' + usrc.Owner_Type__c);
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
	
				Diags.Enter('What templist' + tempList);
system.debug(logginglevel.info, 'What templist' + tempList);
				if( tempList.size() > 0 ) // check the templist is big before updating the list
				{
					usrList = tempList;
				}
				Diags.Enter('What is the final list look like ' + usrList);
system.debug(logginglevel.info, 'What is the final list look like ' + usrList);                     
                // Loop User Skill Rule records
                // 
                
                for(User_Skill_Rule__c usr : usrList){
                    // If there is no User Skill Rules found, go to the validation process
					System.debug(Logginglevel.info,'************User skill rull being eveluated: ' + usr.Name);
                    Diags.Enter('************User skill rull being eveluated: ' + usr.Name);
                    if(!RuleSelected){
				        //Loop through User Skill Rule Fields and validate
				        for (UserSkillRulesAndCaseMap__c m : mcs) {
				        	// First check for validations that must be performed against multiple fields
							//System.debug(Logginglevel.info,'SA Status and Commening bill. Current field being validated: ' + m.Name + ' Validation result: ' + validate_all);

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
								system.debug(logginglevel.info,'age bucket...usr...' + usr.Name + '::' + usr.Medical_Allotment__c + '::' + usr.Medical_Allotment_Evaluator__c);
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
                                system.debug(logginglevel.info,'medical allotment...usr...' + usr.Name + '::' + usr.Medical_Allotment__c + '::' + usr.Medical_Allotment_Evaluator__c);
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
                                        Diags.Enter('Invalid evaluator for UserSkillRule.Medical_Allotment_Evaluator__c field: ' + usr.Medical_Allotment_Evaluator__c);
system.debug(logginglevel.info, 'Invalid evaluator for UserSkillRule.Medical_Allotment_Evaluator__c field: ' + usr.Medical_Allotment_Evaluator__c);                                        
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
system.debug(logginglevel.info, '************what is the work item field name: ' + c.get(m.Work_Item_Field_Name__c));
                                // Validate remaining fields
					            if (usr.get(m.Name) != null && usr.get(m.Name) != '') {
                                    if (m.Validation_Method__c == 'validateBoolean') {
				                        validate_all = UserSkillRuleUtility.validateBoolean(wiBoolValue, usrStrValue);
				                    }
				                    else {
										Diags.Enter('************entering validate: ' + m.Validation_Method__c);
system.debug(logginglevel.info, '************entering validate: ' + m.Validation_Method__c);
						                if (c.get(m.Work_Item_Field_Name__c) != null && c.get(m.Work_Item_Field_Name__c) != '') {
                                            // Validation methods with String parameters
						                    if (m.Validation_Method__c == 'validateStringContains') {
						                        validate_all = UserSkillRuleUtility.validateStringContains(wiStrValue, usrStrValue);
						                    }
						                    else if (m.Validation_Method__c == 'validateEqualStrings') {
											Diags.Enter('************entering validateEqualStrings: **WISTRVALUE' + wiStrValue + '; **USRSTRVALUE ' +usrStrValue);
system.debug(logginglevel.info, '************entering validateEqualStrings: **WISTRVALUE' + wiStrValue + '; **USRSTRVALUE ' +usrStrValue);                                                
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
system.debug(logginglevel.info, 'Hitting false for Validate_all if none of the validation rule pass');
                                            }
						                }
						                else {  // Work Item field is null or empty string
                                           	Diags.Enter('%%%%%%%Hitting false for Validate_all' + usr );
system.debug(logginglevel.info, '%%%%%%%Hitting false for Validate_all' + usr );                                            
						                    validate_all = false;
						                }
				                    }
					            }
					            else {  // User Skill Rule field is null or empty string
					                validate_all = true;
					            }
		                    }	// end validate all fields

		                    System.debug(Logginglevel.info,'Current field being validated: ' + m.Name + ' Validation result: ' + validate_all);
		                    // if any of the fields validate to false, break out of loop to validate field names and move on to validate next user skill rule
				            if (validate_all == false) {
				            	break;
				            }
				            
				        }   // End for loop on User Skill Rule field names
                        
                        // If all fields validate to TRUE, set RuleSelected boolean to stop the loop					
                        if(validate_all){
							System.debug(Logginglevel.info,'**********All fields validated to true.  What is usr.Recordtype.Name:' + usr.Recordtype.Name + ' - ' +usr.Name );                        
                           	Diags.Enter('%%%%%%%%%%%%%%%%%%All fields validated to true What is usr.Recordtype.Name:' + usr.Recordtype.Name + ' - ' +usr.Name );
                            c.User_Skill_Rule__c = usr.Id;
                            // Assign to MBT iMacro Queue
                            // check with Janella
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
        system.debug('populateUserSkillRule current cpu usage is' + limits.getLimitCpuTime()+' : ' + limits.getCpuTime());
		//.clear();
     }

    /*************************************************************************
    * @author         Janella Espiritu
    * @date           08/26/2014
    * @description    This method updates the Work Item Assignment Id field on
    *           the Work Item if the Owner Id is updated
    * @parameters    List of Cases Updated
    * Modified by YXS7 on 2015-04-20 - R2 - added Diagnostics - new version is 1.3
    **************************************************************************/
    public static void updateWorkItemAssignment(List<Case> caseList){
		// Instantiate Variables
        Set<Id> ownerIds = new Set<Id>();
        Map<Id,Work_Item_Assignment__c> wiaUserMap = new Map<Id,Work_Item_Assignment__c>();
        List<Work_Item_Assignment__c> wiaList = new List<Work_Item_Assignment__c>();
        
        // Collect Owner Ids of the Work Items
        for(Case c : caseList){
            ownerIds.add(c.OwnerId);
        }
        Map<Id, User> ownerUserMap = new Map<Id, User>([select Id, LAN_Id__c, Supervisor__c, Supervisor__r.Email from User where Id IN: ownerIds]);
        // Query Work Item Assignments related to the Owner Ids collected
        wiaList = [select Id, User__c, User__r.Supervisor__c, User__r.Supervisor__r.Email, LAN_ID__c from Work_Item_Assignment__c where User__c IN: ownerIds];
        // Create a Map of the User and Work Item Assignments
        for(Work_Item_Assignment__c wia : wiaList){
            wiaUserMap.put(wia.User__c, wia);
    	}
        // Loop updated cases
        for(Case c : caseList){
            // If the owner Id is related to a Work Item Assignment record
            if(wiaUserMap.containsKey(c.OwnerId)){
                Work_Item_Assignment__c wia = wiaUserMap.get(c.OwnerId);
                // Change the Work Item Assignment
                c.Work_Item_Assignment__c = wia.Id;
                if(c.Work_Item_Type__c != 'High Bill' && c.Work_Item_Type__c != 'Unaged Debt'){
                	c.LAN_ID__c = wia.LAN_ID__c;    
                }
				// Change the Status
                if(c.Status == 'Unassigned'){
                  c.Status = 'Assigned';    
                  c.Sub_Status__c = null;
                }
				// Change the Approver Reviewer and Approver Reviewer Email
                if(wiaUserMap.get(c.OwnerId).User__r.Supervisor__c != null){
                  c.Approver_Reviewer__c = wia.User__r.Supervisor__c;
                  c.Approver_Reviewer_Email__c = wia.User__r.Supervisor__r.Email;    
                }
            }
            // If the new owner is a queue, change status back to unassigned
			// and blank out necessary fields
            else if(String.valueOf(c.OwnerId).startsWith('00G')){
                c.Work_Item_Assignment__c = null;
                c.Approver_Reviewer__c = null;
                c.Approver_Reviewer_Email__c = null;
                c.Pending_Other_Reason__c = null;
                c.Sub_Status__c = null;
                c.Status = 'Unassigned';
                if(c.Work_Item_Type__c != 'High Bill' && c.Work_Item_Type__c != 'Unaged Debt'){
                	c.LAN_ID__c = null;   
                }
                
            }
            // Else, change the status to 'Assigned' 
			// and blank out necessary fields
            else{
                c.Work_Item_Assignment__c = null;
                c.Approver_Reviewer__c = null;
                c.Approver_Reviewer_Email__c = null;
                c.Status = 'Assigned';  
                c.Sub_Status__c = null;
                if(ownerUserMap.containsKey(c.OwnerId)){
                 	User temp =   ownerUserMap.get(c.OwnerId);  
                    if(c.Work_Item_Type__c != 'High Bill' && c.Work_Item_Type__c != 'Unaged Debt'){
                        c.LAN_ID__c = temp.LAN_ID__c;    
                    }
                    if(temp.Supervisor__c != null){
                        c.Approver_Reviewer__c = temp.Supervisor__c;
                        c.Approver_Reviewer_Email__c = temp.Supervisor__r.Email;
                    }
                }
            }
        }
    }
	/*************************************************************************
    * @author        Janella Espiritu  
    * @date           
    * @description   This method handles all logic happening when work 
	*					items are reopened
    * @parameters    List of Cases Updated, Old values of the Cases updated
    * @Revisions
    **************************************************************************/
	public static void reopenWorkItems(List<Case> caseList, Map<Id,Case> oldMap){
        System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%% case list %%%...' + caseList);             
		// Instantiate variables
        Set<Id> userIds = new Set<Id>();
        Set<Id> activeIds = new Set<Id>();
        String STATUS_UNASSIGNED = System.Label.STATUS_UNASSIGNED;
        String STATUS_ASSIGNED = System.Label.STATUS_ASSIGNED;
        Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
      	//Tae - R2S2 replace with custom setting to get the record id       
       	//Id recordtypeId = [select Id from RecordType where Name='To Dos' and sObjectType = 'Case'].Id;
       	List<CaseRecordTypeMap__c> caserecord_map = CaseRecordTypeMap__c.getAll().values(); // get a list of values from custom setting 
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById(); // get a list of all case work item type to use for later
		System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%% What is rtMap %%%...' +  rtMap); 
        Id IntegrationProfileId = WorkItemAssignmentUtility.getIntegrationProfileId(); // txtr 07/26/2015
		
        //R2S4 - Tae - use for batch jobs
        List<Id> old_case_ID = new List<Id>();            
    
		// Loop reopened work items
        for(Case c : caseList){
            //if (c.CC_B_Case_Reopen_Reason__c == null){
			if (c.CC_B_Case_Reopen_Reason__c == null && rtMap.get(c.RecordTypeId).getName() == 'Closed Work Item - CC&B Billing Ops Cases'){
                 c.addError('Require CC&B Case Reopen Reason.');
            }
			userIds.add(c.OwnerId);
        }
        system.debug('****userIds'+userIds);
		// Query and Loop the User records of the work item owners
        for(User u : [select Id, IsActive, FirstName, LastName, Name, Email from User where Id IN: userIds]){
            // Collect the Id if the User is active
			if(u.IsActive){
                activeIds.add(u.Id);
            }
        }
       // system.debug('****ownerEmailMap'+ownerEmailMap);
        
        //Tae check to make sure a case is reopen if it's redirect or if it's not part of the custom setting Unreopen_cases__c list
		List<Work_Item_Type_Cases__c> wit_case = Work_Item_Type_Cases__c.getAll().values(); // get a list of values fr
		// Loop reopened work items
        for(Case c : caseList){
                       
            String user_type_value = (string)c.OwnerID;
			if((c.Owner.type == 'User' || user_type_value.substring(0,3) == '005') && 
               (rtMap.get(c.RecordTypeId).getName() == 'Closed Work Item - CC&B Billing Ops Cases') &&
               (c.Sub_Status__c == 'Redirect' || !(Work_Item_Type_Cases__c.getValues(c.Work_Item_Type__c).Manual_Reopen__c)) &&
               (UserInfo.getProfileId() != IntegrationProfileId))
			{
				 //c.addError('Cannot reopen workitem where sub status is Redirect or work item type is Streetlight or QAS1-9 case');
					c.addError(System.Label.Cases_To_Not_Reopen);
			}
            else{			
				if(oldMap.containsKey(c.Id)){
				  
					Case oldCase = oldMap.get(c.Id);
                    old_case_ID.add(oldCase.ID); // use for batch email
				}
				//TAE - check if owner is type user or owner
				//if(activeIds.contains(c.OwnerId)){
				if(activeIds.contains(c.OwnerId) && (c.Owner.type == 'User' || user_type_value.substring(0,3) == '005')){
					c.Status = STATUS_ASSIGNED;
				}
				//else if(c.Owner.type == 'Queue' || user_type_value.substring(0,3) == '00G'){
                else{ 
					c.Status = STATUS_UNASSIGNED;
					c.OwnerId = queueId;
					c.Work_Item_Assignment__c = null;
					c.Approver_Reviewer__c = null;
					c.Approver_Reviewer_Email__c = null;
				}
				
				 // Tae - R2S2 - use custom setting to get the record type and populate case record id dynamically 
				for (CaseRecordTypeMap__c crt : caserecord_map) 
				{
					if(rtMap.get(c.RecordTypeId).getName() == crt.Closed_Work_Item_Record_Type__c)
					{
						 c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(crt.Name).getRecordTypeId();
					}
				}
				//Diags.Info('What is the case record ID after it gets assigned: '+ c.RecordTypeId);
				//c.RecordTypeId = recordtypeId;
				
				//Tae Tran - R2S1 - Use field set to populate case fields 
				for(Schema.FieldSetMember f : SObjectType.Case.FieldSets.Case_Field_Selection.getFields()) {  
					//loop through the fields
					Schema.DisplayType fielddataType = f.getType();
					String fieldname = f.getFieldPath();
					
					//set a default value based on the field type
					system.debug(Logginglevel.info,'%%%%Value does not already exist in field: Field...(' + fieldname + ')  Value...(' + c.get(fieldname) + ') Type:' +  f.getType());
						
					if(fielddataType == Schema.DisplayType.Boolean) { // set field false if boolean
						c.put(fieldname, false);
						system.debug(Logginglevel.info,' FieldSetMember for case-->' + fieldname + ' = ' + c.get(fieldname) + ' , ' + f.getType()) ;    
					}
					else if(fielddataType == Schema.DisplayType.Integer) {
						c.put(fieldname, 0);
						system.debug(Logginglevel.info,' FieldSetMember for case-->'+ fieldname + ' = ' + c.get(fieldname) + ' , ' + f.getType());    
					}
					else if(fielddataType == Schema.DisplayType.Double) {
						c.put(fieldname, 0.0);
						system.debug(Logginglevel.info,' FieldSetMember for case-->'+ fieldname + ' = ' + c.get(fieldname) + ' , ' + f.getType());    
					}
					else {
						c.put(fieldname, null);
						system.debug(Logginglevel.info,' FieldSetMember for case-->'+ fieldname + ' = ' + c.get(fieldname) + ' , ' + f.getType());    
                        //Diags.Info('#####POSTPHONECREDIT FieldSetMember for case-->'+ fieldname + ' = ' + c.get(fieldname) + ' , ' + f.getType() );
					}
				}
			}// end else
        }// end for
	
        //R2S4 - Tae - Set up string to put to query for email to be call by batch
        String list_ids = '';
        for (Integer i = 0; i < old_case_ID.size(); i++ ) {
			if (i < (old_case_ID.size()-1) ){            
				list_ids += '\'' + old_case_ID[i] + '\', ';
			}
			else{
				list_ids += '\'' + old_case_ID[i] + '\' ';
			}
        }		
        String query = 'select Id, OwnerID, Work_Item_Type__c, CaseNumber, Approver_Reviewer_Email__c, Root_Cause__c, Root_Cause_Other__c from Case where Id IN (' + list_ids + ')';                        
		System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%% old case list %%%...' + query);
		EmailBatch batchApex = new EmailBatch(query); // call the email batch process
		ID batchprocessid = Database.executeBatch(batchApex, 50); // call apex batch
        //Messaging.sendEmail(emails);   // Send the emails	
        
	}
	
	/* Tae - R2S2 comment out use code above for latest reopenworkitems
   public static void reopenWorkItems(List<Case> caseList, Map<Id,Case> oldMap){

        Set<Id> userIds = new Set<Id>();
        Set<Id> activeIds = new Set<Id>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Map<Id, String> ownerNameMap = new Map<Id, String>();
        Map<Id, String> ownerEmailMap = new Map<Id, String>();
        String STATUS_UNASSIGNED = System.Label.STATUS_UNASSIGNED;
        String STATUS_ASSIGNED = System.Label.STATUS_ASSIGNED;
        Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;
        EmailTemplate emailTemplateCSR = [select Id, Body, Subject  from EmailTemplate where DeveloperName = 'WI_is_Re_opened'];
        EmailTemplate emailTemplateSup = [select Id, Body, Subject  from EmailTemplate where DeveloperName = 'Reopened_Billing_Ops_Work_Item'];
        for(Case c : caseList){
            userIds.add(c.OwnerId);
        }
        system.debug('****userIds'+userIds);
        for(User u : [select Id, IsActive, FirstName, LastName, Name, Email from User where Id IN: userIds]){
            if(u.IsActive){
                activeIds.add(u.Id);
            }
            ownerNameMap.put(u.Id, u.Name);
            ownerEmailMap.put(u.Id, u.Email);
        }
        system.debug('****ownerEmailMap'+ownerEmailMap);
        
        for(Case c : caseList){
            if(oldMap.containsKey(c.Id)){
              
                Case oldCase = oldMap.get(c.Id);
                // Build Email to Supervisor
                if(c.Approver_Reviewer_Email__c != null){
                    
                    String plainBody = emailTemplateSup.Body;
                    plainBody = plainBody.replace('{!Case.CaseNumber}', oldCase.CaseNumber);
                    String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
                    plainBody = plainBody.replace('{!Case.Link}', sfdcBaseURL+'/'+c.Id);
                    
					Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
					email = Email_utility.create_mail(c.Approver_Reviewer_Email__c, emailTemplateSup, false, plainBody);
                    emails.add(email); 
                                       
                    //Tae - R2S2 use the email utility above
                    /*String[] toAddresses = new String[] {c.Approver_Reviewer_Email__c};
                    String subject = emailTemplateSup.Subject;
                    String plainBody = emailTemplateSup.Body;
                    
                    plainBody = plainBody.replace('{!Case.CaseNumber}', oldCase.CaseNumber);
                    String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
                    plainBody = plainBody.replace('{!Case.Link}', sfdcBaseURL+'/'+c.Id);
                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(toAddresses);
                    email.setSaveAsActivity(false);
                    email.setSubject(subject);
                    email.setPlainTextBody(plainBody);
                    emails.add(email);    
					*/
/*                }
				 system.debug(Logginglevel.info,'%%%%Value for owner WORK ITEM:'+ c.Work_Item_Owner__c);
				 system.debug(Logginglevel.info,'%%%%Value for owner ID:'+ c.OwnerID);
				 system.debug(Logginglevel.info,'%%%%Value for owner:'+ c.Work_Item_Type__c);
                //TXTR - R2S2 - only send CSR email if the ower type is user
				String user_type_value = (string)c.OwnerID;
                if(c.Owner.type == 'User' || user_type_value.substring(0,3) == '005')
                {
					String plainBodyCSR = emailTemplateCSR.Body;                    
                    plainBodyCSR = plainBodyCSR.replace('{!Case.CaseNumber}', oldCase.CaseNumber);
                    plainBodyCSR = plainBodyCSR.replace('{!Case.OwnerFullName}', ownerNameMap.get(oldCase.OwnerId));
                    plainBodyCSR = plainBodyCSR.replace('{!Case.Work_Item_Type__c}', oldCase.Work_Item_Type__c);
                    if(oldCase.Root_Cause__c != null){
                        plainBodyCSR = plainBodyCSR.replace('{!Case.Root_Cause__c}', oldCase.Root_Cause__c);    
                    }
                    else{
                        plainBodyCSR = plainBodyCSR.replace('{!Case.Root_Cause__c}', '');
                    }
                    if(oldCase.Root_Cause_Other__c != null){
                        plainBodyCSR = plainBodyCSR.replace('{!Case.Root_Cause_Other__c}', oldCase.Root_Cause_Other__c);    
                    }
                    else{
                        plainBodyCSR = plainBodyCSR.replace('{!Case.Root_Cause_Other__c}', '');
                    }

                   	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
					email = Email_utility.create_mail(ownerEmailMap.get(c.OwnerId), emailTemplateCSR, false, plainBodyCSR);
                    emails.add(email); 
                    
                    /* Tae - R2S2 use email utility to create email
                    // Build Email to CSR
                    String[] toAddressesCSR = new String[] {ownerEmailMap.get(c.OwnerId)};
                    String subjectCSR = emailTemplateCSR.Subject;
                    String plainBodyCSR = emailTemplateCSR.Body;
                    
                    plainBodyCSR = plainBodyCSR.replace('{!Case.CaseNumber}', oldCase.CaseNumber);
                    plainBodyCSR = plainBodyCSR.replace('{!Case.OwnerFullName}', ownerNameMap.get(oldCase.OwnerId));
                    plainBodyCSR = plainBodyCSR.replace('{!Case.Work_Item_Type__c}', oldCase.Work_Item_Type__c);
                    if(oldCase.Root_Cause__c != null){
                        plainBodyCSR = plainBodyCSR.replace('{!Case.Root_Cause__c}', oldCase.Root_Cause__c);    
                    }
                    else{
                        plainBodyCSR = plainBodyCSR.replace('{!Case.Root_Cause__c}', '');
                    }
                    if(oldCase.Root_Cause_Other__c != null){
                        plainBodyCSR = plainBodyCSR.replace('{!Case.Root_Cause_Other__c}', oldCase.Root_Cause_Other__c);    
                    }
                    else{
                        plainBodyCSR = plainBodyCSR.replace('{!Case.Root_Cause_Other__c}', '');
                    }
                    
                    Messaging.SingleEmailMessage emailCSR = new Messaging.SingleEmailMessage();
                    emailCSR.setToAddresses(toAddressesCSR);
                    emailCSR.setSaveAsActivity(false);
                    emailCSR.setSubject(subjectCSR);
                    emailCSR.setPlainTextBody(plainBodyCSR);
                    emails.add(emailCSR);  
                    */
/*             }
            }
            if(activeIds.contains(c.OwnerId)){
                c.Status = STATUS_ASSIGNED;
            }
            else{
                c.Status = STATUS_UNASSIGNED;
                c.OwnerId = queueId;
                c.Work_Item_Assignment__c = null;
                c.Approver_Reviewer__c = null;
                c.Approver_Reviewer_Email__c = null;
            }
            
            c.RecordTypeId = recordtypeId;
            //Tae Tran - R2S1 - Use field set to populate case fields 
            for(Schema.FieldSetMember f : SObjectType.Case.FieldSets.Case_Field_Selection.getFields()) {  
                //loop through the fields
                Schema.DisplayType fielddataType = f.getType();
                String fieldname = f.getFieldPath();
                
                // Check if a value currently exists.
                // If value exists, leave it alone.
                // Else, set a default value based on the field type
                system.debug(Logginglevel.info,'%%%%Value does not already exist in field: Field...(' + fieldname + ')  Value...(' + c.get(fieldname) + ') Type:' +  f.getType());
                    
                if(fielddataType == Schema.DisplayType.Boolean) { // set field false if boolean
                    c.put(fieldname, false);
                    system.debug(Logginglevel.info,' FieldSetMember for case-->' + fieldname + ' = ' + c.get(fieldname) + ' , ' + f.getType()) ;    
                }
                else if(fielddataType == Schema.DisplayType.Integer) {
                    c.put(fieldname, 0);
                    system.debug(Logginglevel.info,' FieldSetMember for case-->'+ fieldname + ' = ' + c.get(fieldname) + ' , ' + f.getType());    
                }
                else if(fielddataType == Schema.DisplayType.Double) {
                    c.put(fieldname, 0.0);
                    system.debug(Logginglevel.info,' FieldSetMember for case-->'+ fieldname + ' = ' + c.get(fieldname) + ' , ' + f.getType());    
                }
                else {
                    c.put(fieldname, null);
                    system.debug(Logginglevel.info,' FieldSetMember for case-->'+ fieldname + ' = ' + c.get(fieldname) + ' , ' + f.getType());    
                }
            }
        }
        Messaging.sendEmail(emails);   // Send the emails
	}
	*/
    /*************************************************************************
    * @author        Janella Espiritu 
    * @date           
    * @description   This method will concatenate Customer Contact Comments 
    * @parameters    List of Cases Updated
    * @Revisions	J1EU - Added SOX Required Information
    **************************************************************************/
    public static void concatenateCustomerContactFields(List<Case> caseList){
		// Loop work items
        for(Case c : caseList){
			// Clear the Customer Contact Comments
            c.Customer_Contact_Comments__c = '';
			// If the SOX Required Information is Service Agreement ID
			// and CC Service Agreement ID is not null
			// Add CC Service Agreement ID to Customer Contact Comment
			if(c.SOX_Required_Information__c == 'Service Agreement ID' && c.CC_Service_Agreement_ID__c != null){
				c.Customer_Contact_Comments__c += 'SA: ' + c.CC_Service_Agreement_ID__c + '; \n';
			}
			// If the SOX Required Information is Account ID
			// and CC Account ID is not null
			// Add CC Account ID to Customer Contact Comment
			else if(c.SOX_Required_Information__c == 'Account ID' && c.CC_Account_ID__c != null){
				c.Customer_Contact_Comments__c += 'ACCT: ' + c.CC_Account_ID__c + '; \n';
			}
			// If the SOX Required Information is Service Point ID
			// and CC Service Point ID is not null
			// Add CC Service Point ID to Customer Contact Comment
			else if(c.SOX_Required_Information__c == 'Service Point ID' && c.CC_Service_Point_ID__c != null){
				c.Customer_Contact_Comments__c += 'SP: ' + c.CC_Service_Point_ID__c + '; \n';
			}
			// If the SOX Required Information is Premise ID
			// and CC Premise ID is not null
			// Add CC Premise ID to Customer Contact Comment
			else if(c.SOX_Required_Information__c == 'Premise ID' && c.CC_Premise_ID__c != null){
				c.Customer_Contact_Comments__c += 'PREM: ' + c.CC_Premise_ID__c + '; \n';
			}
			// If the SOX Required Information is Premise Address
			// and CC Premise Address is not null
			// Add CC Premise Address to Customer Contact Comment
			else if(c.SOX_Required_Information__c == 'Premise Address' && c.CC_Premise_Address__c != null){
				c.Customer_Contact_Comments__c += 'PREM ADD: ' + c.CC_Premise_Address__c + '; \n';
			}
            // If As Billed Corrected From is not null,
			// Concatenate As Billed/Corrected From-To to Customer Contact Comment
            if(c.As_Billed_Corrected_From__c  != null){
                String frm = DateTime.newInstance(c.As_Billed_Corrected_From__c, Time.newInstance(0, 0, 0,0)).format('MM/dd/yyyy');
                String todate = DateTime.newInstance(c.As_Billed_Corrected_To__c, Time.newInstance(0, 0, 0,0)).format('MM/dd/yyyy');
                c.Customer_Contact_Comments__c += 'As Billed/Corrected From: ' + frm + ' To: ' + todate + ';\n';
            }
			// If As Billed Amount is not null,
			// Concatenate As Billed Amount to Customer Contact Comment
            if(c.As_Billed_Amount__c != null){
                c.Customer_Contact_Comments__c += 'As Billed Amt: $' + c.As_Billed_Amount__c + '; \n';
            }
			// If As Billed Corrected From is not null,
			// Concatenate As Billed/Corrected From-To to Customer Contact Comment
            if(c.As_Corrected_Amount__c != null){
                c.Customer_Contact_Comments__c += 'As Corrected Amt: $' + c.As_Corrected_Amount__c + '; \n';
            }
			// If As Billed Corrected Diff Amt is not null,
			// Concatenate As Billed Corrected Diff Amt  to Customer Contact Comment
            if(c.As_Billed_Corrected_Diff_Amt__c != null && (c.As_Billed_Amount__c != null || c.As_Corrected_Amount__c != null)){
                c.Customer_Contact_Comments__c += 'As Billed/Corrected Diff Amt: $' + c.As_Billed_Corrected_Diff_Amt__c + '; \n';
            }
			// If Billed From Date is not null,
			// Concatenate Billed From-To Date  to Customer Contact Comment
            if(c.Billed_From_Date__c != null){
                String frm = DateTime.newInstance(c.Billed_From_Date__c, Time.newInstance(0, 0, 0,0)).format('MM/dd/yyyy');
                String todate = DateTime.newInstance(c.Billed_To_Date__c, Time.newInstance(0, 0, 0,0)).format('MM/dd/yyyy');
                c.Customer_Contact_Comments__c += 'Billed From: ' + frm  + ' To: ' + todate + '; \n';
            }
			// If Billed To Amount is not null,
			// Concatenate Billed To Amount to Customer Contact Comment
            if(c.Billed_To_Amount__c != null){
                c.Customer_Contact_Comments__c += 'Billed To Amt: $' + c.Billed_To_Amount__c + '\n';
            }
			// If the length of Customer Contact Comments
			// is greater than 254
            if(c.Customer_Contact_Comments__c.length() > 254){
				// If SOX Required Information = Premise Address 
				// and Premise Address is not null
				if(c.SOX_Required_Information__c == 'Premise Address' && c.CC_Premise_Address__c != null){
					// Make Customer Contact Comments is Premise Address
                    c.Customer_Contact_Comments__c = 'PREM ADD: ' + c.CC_Premise_Address__c + '; \n';
					// Populate Additional Customer Contact Log with As Billed/Corrected Details
                    c.Additional_Customer_Contact_Log__c = '';
					//c.Additional_Customer_Contact_Log__c = c.Customer_Contact_Comments__c;
					if(c.As_Billed_Corrected_From__c  != null){
						String frm = DateTime.newInstance(c.As_Billed_Corrected_From__c, Time.newInstance(0, 0, 0,0)).format('MM/dd/yyyy');
						String todate = DateTime.newInstance(c.As_Billed_Corrected_To__c, Time.newInstance(0, 0, 0,0)).format('MM/dd/yyyy');
						c.Additional_Customer_Contact_Log__c += 'As Billed/Corrected From: ' + frm + ' To: ' + todate + ';\n';
					}
					if(c.As_Billed_Amount__c != null){
						c.Additional_Customer_Contact_Log__c += 'As Billed Amt: $' + c.As_Billed_Amount__c + '; \n';
					}
					if(c.As_Corrected_Amount__c != null){
						c.Additional_Customer_Contact_Log__c += 'As Corrected Amt: $' + c.As_Corrected_Amount__c + '; \n';
					}
					if(c.As_Billed_Corrected_Diff_Amt__c != null && (c.As_Billed_Amount__c != null || c.As_Corrected_Amount__c != null)){
						c.Additional_Customer_Contact_Log__c += 'As Billed/Corrected Diff Amt: $' + c.As_Billed_Corrected_Diff_Amt__c + '; \n';
					}
					if(c.Billed_From_Date__c != null){
						String frm = DateTime.newInstance(c.Billed_From_Date__c, Time.newInstance(0, 0, 0,0)).format('MM/dd/yyyy');
						String todate = DateTime.newInstance(c.Billed_To_Date__c, Time.newInstance(0, 0, 0,0)).format('MM/dd/yyyy');
						c.Additional_Customer_Contact_Log__c += 'Billed From: ' + frm  + ' To: ' + todate + '; \n';
					}
					if(c.Billed_To_Amount__c != null){
						c.Additional_Customer_Contact_Log__c += 'Billed To Amt: $' + c.Billed_To_Amount__c + '\n';
					}
				}
				else{
					//Else throw an error message
					c.addError('The maximum number of characters for Customer Contact Comments is 254.');
				}
            }
        }
    }
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           
    * @description   This method will create customer contact
    * @parameters    List of Cases Updated
    * @Revisions
    **************************************************************************/
	// Update Janella Espiritu - 05/27/2015 - Added Fields to be updated when Customer Contact record is created
    public static void CreateCustomerContact(List<Case> caseList){
		Diags.Enter('CaseTriggerHandler.CreateCustomerContact');
		//Diags.Info('caseList: '+String.valueOf(caseList));
		// Instantiate variables
        List<Related_Records__c> relatedRecords = new List<Related_Records__c>();
		// Retrieve Customer Contact record type Id
        Id ccRecordTypeId = Schema.SObjectType.Related_Records__c.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
        //Diags.Info('ccRecordTypeId: '+String.valueOf(ccRecordTypeId));
		// Loop work items
		for(Case c : caseList){
			// Instantiate new related records and populate fields
            Related_Records__c r = new Related_Records__c();
            r.Comments__c = c.Customer_Contact_Comments__c;
			r.Additional_Customer_Contact_Log__c = c.Additional_Customer_Contact_Log__c;
            r.Completion_Comments__c = c.Additional_Customer_Comments_back_end__c;
			r.RR_Customer_Contact_Class__c = c.Customer_Contact_Class__c;
			r.RR_Customer_Contact_Type__c = c.Customer_Contact_Type__c;
			r.SOX_Required_Information__c = c.SOX_Required_Information__c;
			r.CC_Premise_Address__c = c.CC_Premise_Address__c;
            r.CC_Account_ID__c = c.CC_Account_ID__c;
            r.CC_Service_Agreement_ID__c = c.CC_Service_Agreement_ID__c;
            r.CC_Premise_ID__c = c.CC_Premise_ID__c;
            r.CC_Person_ID__c = c.CC_Person_ID__c;
			r.CC_Service_Point_ID__c = c.CC_Service_Point_ID__c;
            r.RecordTypeId = ccRecordTypeId;
            r.SFDC_Work_Item__c = c.Id;
			r.Add_to_CC_B_Case_Log__c = c.Add_to_CC_B_Case_Log__c;
			// Add related record to relatedRecords
            relatedRecords.add(r);
        }
		//Diags.Info('relatedRecords: '+String.valueOf(relatedRecords));
		// If there are relatedRecords, insert relatedRecords
        if(relatedRecords.size() > 0){
           insert relatedRecords;
        }
    
        Diags.Clear();
    }
    
    /*************************************************************************
    * @author        Janella Espiritu
    * @date          2014
    *
    * @version      1.2
    *           
    * @description    
    * @parameters    List of Cases Updated, Old values of the Cases updated
    *
    * @Revisions  Yefim Shuster - 02-04-2015 - Call status times for Recreated
    *             Yefim Shuster on 2015-07-28 - R2S4 - replace DLRS - added WorkItemRollupSummary.recalculateHandleTime() - new version is 1.2
    **************************************************************************/
    public static void createStatusTimes(List<Case> caseList, Map<Id, Case> oldMap, Boolean isUpdate){
      
      Diags.Enter('CaseTriggerHandler_DEV.createStatusTimes()');
      
      Set<Id> userIds = new Set<Id>();
      List<Status_Times__c> statusTimes = new List<Status_Times__c>();
      List<Case> caseUpdate = new List<Case>();
        
      for(Case c : caseList){
        userIds.add(c.Floor_Support_Analyst__c);
      }
    
      Map<Id, User> userNameMap = new Map<Id, User>([select Id, Name from User where Id in: userIds]);
    
      // Loop work items
      for(Case c : caseList){
            
            // Instantiate new Status Times and populate fields
            Status_Times__c s = new Status_Times__c();
            s.Approver_Reviewer__c = c.Approver_Reviewer__c;
            s.Current_Status_Time__c = datetime.now();
            s.Current_Status__c = c.Status;           
            s.WI_Owner__c = c.Work_Item_Owner__c;
            s.Work_Item__c = c.Id;
			
            if(oldMap != null && oldMap.containsKey(c.Id)){
            
                // Retrieve the old values of the current work item
                Case oldCase = oldMap.get(c.Id);
            
                // If oldCase is not null 
                // (It will be null for recreated work items)
                if(oldCase != null){
                    s.Last_Status_Time__c = oldCase.LastModifiedDate;
                    s.Last_Status__c = oldCase.Status;
                    s.Last_Sub_Status__c = oldCase.Sub_Status__c;
                    // If the Floor Support Request Completed field is changed
                    if(c.Floor_Support_Request_Completed__c && !oldCase.Floor_Support_Request_Completed__c){
                        if(userNameMap.containsKey(c.Floor_Support_Analyst__c)){
                            s.Floor_Support_Analyst__c = userNameMap.get(c.Floor_Support_Analyst__c).Name;
                        }
                        s.Floor_Support_Request_Completed__c = c.Floor_Support_Request_Completed__c;
                    }
                } 
            }
      
            // Add Status Times to statusTimes
            statusTimes.add(s);      
      }
    
      // If the statusTimes list is not null, insert statusTimes
      if(statusTimes.size() > 0){
         insert statusTimes;
         
         WorkItemRollupSummary.recalculateHandleTime(caseList, oldMap, isUpdate); 
      }
      
      Diags.Clear();
   }
   
  /*************************************************************************
    * @author        Janella Espiritu 
    * @date           
    * @description   This method will populate the postpone credit date on 
					 the Account record if the postpone credit date in the 
					 work item is greater than the Account's
    * @parameters    List of Cases Updated
    * @Revisions
    **************************************************************************/
    public static void populatePostponeCredit(List<Case> caseList){
		// Instantiate variables
        List<Account> accountsUpdate = new List<Account>();
        List<Account> relatedAccounts = new List<Account>();
		Set<Id> accountIds = new Set<Id>();
        Set<Id> updatedAccounts = new Set<Id>();
        Map<Id, Account> accDateMap = new Map<Id,Account>();
        Map<Id, Account> accUpdateMap = new Map<Id,Account>();
		
		// Loop work items and collect Account ids
        for(Case c : caseList){
            accountIds.add(c.AccountId);
        }
        // Query Account records
        relatedAccounts = [select Id, Postpone_Credit_Date__c from Account where Id IN: accountIds];
		// Populate a map with account details
		// Key: Account Id
		// Value: Account Record
        for(Account a : relatedAccounts){
            accDateMap.put(a.Id, a);
        }
		// Loop work items
        for(Case c : caseList){
			// If the accDateMap contains the work item Account Id
            if(accDateMap.containsKey(c.AccountId)){
				// If the accUpdateMap contains the work item Account Id
                if(accUpdateMap.containsKey(c.AccountId)){
					// Retrieve the Account record
                    Account acc = accUpdateMap.get(c.AccountId);
                    system.debug('**accUpdateMap.containsKey(c.AccountId) = TRUE');
					// If the work item postpone credit date 
					// is greater than the account postpone credit date
					// OR account postpone credit date is null
                    if(c.Postpone_Credit_Date__c > acc.Postpone_Credit_Date__c || acc.Postpone_Credit_Date__c == null){
						// Populate postpone credit date on Account
						// and Postpone Credit Date Sent = false
                        system.debug('***greater than');
                        acc.Postpone_Credit_Date__c = c.Postpone_Credit_Date__c;
                        acc.Postpone_Credit_Date_Sent__c = false;
						// Put the account on accUpdateMap
						// Key: Account Id
						// Value: Account Record with updated postpone credit date
                        accUpdateMap.put(acc.Id,acc);
                    }
                }
				// Else
                else{
                    system.debug('**accUpdateMap.containsKey(c.AccountId) = FALSE');
					// Retrieve the Account record
					Account acc = accDateMap.get(c.AccountId);
					// If the work item postpone credit date 
					// is greater than the account postpone credit date
					// OR account postpone credit date is null
                    if(c.Postpone_Credit_Date__c > acc.Postpone_Credit_Date__c || acc.Postpone_Credit_Date__c == null){
						// Populate postpone credit date on Account
						// and Postpone Credit Date Sent = false
                        system.debug('***greater than');
                        acc.Postpone_Credit_Date__c = c.Postpone_Credit_Date__c;
                        acc.Postpone_Credit_Date_Sent__c = false;
						// Put the account on accUpdateMap
						// Key: Account Id
						// Value: Account Record with updated postpone credit date
                        accUpdateMap.put(acc.Id,acc);
                    }
                }
            }
        }
        system.debug('**accUpdateMap: '+accUpdateMap);
		// Put the accounts in accUpdateMap to accountsUpdate
        for(Id i : accUpdateMap.keySet()){
            accountsUpdate.add(accUpdateMap.get(i));
        }
        system.debug('**accountsUpdate: '+accountsUpdate);
		// If accountsUpdate is not empty,
		// update accountsUpdate
        if(accountsUpdate.size() > 0){
            update accountsUpdate;
        }
    }
	/*************************************************************************
    * @author         Janella Espiritu
    * @date           
    * @version        1.0
    * @description    This method concatenates Additional Customer Contact Comments
    * @parameters    None
    * @revision      Removed Root Cause Category
					 Moved Case Id to follow Work Item Type
    **************************************************************************/
    public static void concatenateAdditionalComments(List<Case> caseList){
		System.debug('caseList: '+caseList);
		// Instantiate variables
        // J1EU Add LAN Id To Additional Comments
        //Set<Id> caseOwnerIds = new Set<Id>();
        //Map<Id, String> idLanIdMap = new Map<Id, String>();
		// Loop work items
        /*for(Case c : caseList){
            caseOwnerIds.add(c.OwnerId);
        }*/
		// Query the LAN Ids of the Users and put into a map
		// KEY: User Id
		// VALUE: LAN Id
        /*for(User u : [select Id, Lan_Id__c from User where Id IN: caseOwnerIds]){
            idLanIdMap.put(u.Id, u.Lan_Id__c);
        }*/
		// Loop Work Items
        for(Case c : caseList){
			System.debug('c: '+c);
	        // clear Additional Customer Contact Comments backend
            c.Additional_Customer_Comments_back_end__c='';
			// Concatenate the LAN Id if it's not null
            if(/*idLanIdMap.containsKey(c.OwnerId) && idLanIdMap.get(c.OwnerId) != null*/ c.LAN_ID__c != null){
                //c.Additional_Customer_Comments_back_end__c += 'LAN ID: '+ idLanIdMap.get(c.OwnerId) +'; \n';
                c.Additional_Customer_Comments_back_end__c += 'LAN ID: '+ c.LAN_ID__c +'; \n';
            }    
			// Concatenate the Work Item Type if it's not null
            if(c.Work_Item_Type__c!=null){
               c.Additional_Customer_Comments_back_end__c +='Work Source: ' +c.Work_Item_Type__c + '; \n';
            }
			// j1eu Added CC&B Case Id to Additional Customer Contact Comments for Case Id 5/13/2015
			// J1EU Moved to follow Work Item Type 05/29/2015
			// Concatenate the CC&B Case Id if it's not null
			if(c.CC_B_Case_ID__c != null){
				c.Additional_Customer_Comments_back_end__c +='Case ID: ' + c.CC_B_Case_ID__c + '; \n';
			}
			// Concatenate the Created Date if it's not null
            if(c.CreatedDate!= null){
              DateTime crtdate = c.CreatedDate.date();
               string formatdate =crtdate.format('MM/dd/yyyy');
              c.Additional_Customer_Comments_back_end__c +='Date Created: ' + formatdate +'; \n';
            }   
			// Concatenate the Postpone Created Date if it's not null
            if(c.Postpone_Credit_Date__c  != null){
                String postpone = DateTime.newInstance(c.Postpone_Credit_Date__c, Time.newInstance(0, 0, 0,0)).format('MM/dd/yyyy');
                c.Additional_Customer_Comments_back_end__c += 'Postpone Credit Date: ' + postpone  + '; \n';
            }
			// Concatenate the Additional Customer Contact Comments if it's not null
            if(c.Additional_Customer_Contact_Comments__c != null){
               c.Additional_Customer_Comments_back_end__c += '' + c.Additional_Customer_Contact_Comments__c + '\n'; 			   
            }
			// Concatenate the CaseNumber if it's not null
            if(c.CaseNumber!=null){
               c.Additional_Customer_Comments_back_end__c +='Work Item Number: ' + c.CaseNumber + '; \n';
            }
			// Concatenate the Revenue Assurance Account Number if it's not null
			if(c.Revenue_Assurance_Account_Number__c != null){
               c.Additional_Customer_Comments_back_end__c +='Revenue Assurance Account Number: ' + c.Revenue_Assurance_Account_Number__c + '; \n';
            }
			// Concatenate the Revenue Assurance SA ID if it's not null
			if(c.Revenue_Assurance_SA_ID__c != null){
               c.Additional_Customer_Comments_back_end__c +='Revenue Assurance SA ID: ' + c.Revenue_Assurance_SA_ID__c + '; \n';
            }
			// Concatenate the Billed Reason if it's not null
			if(c.Billed_Reason__c != null){
               c.Additional_Customer_Comments_back_end__c +='Billed Reason: ' + c.Billed_Reason__c + '; \n';
            }
			//Removed J1EU as per business 05-29-2015
			/*if(c.Root_Cause_Category__c != null){
               c.Additional_Customer_Comments_back_end__c +='Root Cause Category: ' + c.Root_Cause_Category__c + '; \n';
            }*/
			// Concatenate the Root Cause if it's not null
			if(c.Root_Cause__c != null){
               c.Additional_Customer_Comments_back_end__c +='Root Cause: ' + c.Root_Cause__c + '; \n';
            }
			// Concatenate the Root Cause Other if it's not null
			if(c.Root_Cause_Other__c != null){
               c.Additional_Customer_Comments_back_end__c +='Root Cause Other: ' + c.Root_Cause_Other__c + '; \n';
            }
            
        }
    }
    
     /*************************************************************************
    * @author         Yefim Shuster (refactored assignWorkItems by Janella Espiritu)
    * @date           2015-05-13
    * @version        1.0
    * @description    This method checks for unassigned cases, looks for the 
    *           one with the highest priority and assigns to the Work 
    *           Item Assignment records that are updated based on their 
    *           User Skill
    * @parameters    None
    * @revision      Original version
    **************************************************************************/
    public static void assignWIs(){
    
        Diags.Enter('CaseTriggerHandler_DEV.assignWIs()');
        
        List<Case> casesToUpdate = new List<Case>();
        
        List<Case> highestPriorityWIs = WorkItemAssignmentUtility.getHighestPriorityWIs();
        
        if (highestPriorityWIs == null || highestPriorityWIs.size() == 0) return;
        
        Set<Id> parentIds = new Set<Id>();
        
        for(Case c : highestPriorityWIs){
            if(c.ParentId != null){
                parentIds.add(c.ParentId);
            }
            else{
              parentIds.add(c.Id);    
            }
        }
       
        // Query Unassigned Work Items
        Map<Id, Case> allRelatedCasesMap = WorkItemAssignmentUtility.getAssignedOrUnassignedWIsRelatedTo(parentIds);
        
        Map<Id, List<Case>> caseGroupMap = new Map<Id, List<Case>>();
         
        if(allRelatedCasesMap.size() > 0){
          for(Id cid : allRelatedCasesMap.keySet()){
                Case c = allRelatedCasesMap.get(cid);
                if(c.ParentId != null){
                    if(caseGroupMap.containsKey(c.ParentId)){
                        List<Case> temp = caseGroupMap.get(c.ParentId);
                        temp.add(c);
                        caseGroupMap.put(c.ParentId, temp);
                    }
                    else{
                        caseGroupMap.put(c.ParentId, new List<Case>{c});
                    }
                }
                else{
                    if(caseGroupMap.containsKey(c.Id)){
                        List<Case> temp = caseGroupMap.get(c.Id);
                        temp.add(c);
                        caseGroupMap.put(c.Id, temp);
                    }
                    else{
                        caseGroupMap.put(c.Id, new List<Case>{c});
                    }
                } 
          }    
        }
        
        WorkItemAssignmentUtility.performWIAssignment(highestPriorityWIs, caseGroupMap, casesToUpdate);
        
        // If there are highest priority cases to be updated
        if(casesToUpdate.size() > 0){
           Diags.Info('In assignWIs(): update casesToUpdate. size() = ' + casesToUpdate.size());
           update casesToUpdate;
        }
        
        Diags.Clear();
    }
	/*************************************************************************
    * @author         Janella Espiritu
    * @date           2015-05-22
    * @version        1.0
    * @description    This method throws an error if the work item if a CSR 
						tries to perform a mass action (i.e. Change Owner and 
						Change Status) from the list view.
    * @parameters    None
    * @revision      Original version
    **************************************************************************/
	public static void validateMassReassignment(List<Case> workItems){
		Diags.Enter('validateMassReassignment');
		// Retrieve CSR Profile Id
		Id csrId = WorkItemAssignmentUtility.getCSRProfileId();
		// Loop work items
		for(Case c : workItems){
			// If the CurrentRequestURL contains the string 'CaseMassAction',
			// throw an error message
			if(userinfo.getProfileId() == csrId && (String.valueOf(URL.getCurrentRequestUrl()).contains('CaseMassAction'))){
				c.addError(Label.CSR_Mass_Action_Error_Message);
			}
			// Else
			else{
				// If the owner is a queue,
				// Change the Status to Unassigned 
				// and clear the Sub Status
				if(String.valueOf(c.OwnerId).startsWith('00G')){
					c.Status = 'Unassigned';
                    c.Sub_Status__c = null;
				}
				// If the owner is a user of the profile is not a CSR,
				// Change the status to Assigned
				// and clear the sub status
				else if(String.valueOf(c.OwnerId).startsWith('005') && userinfo.getProfileId() != csrId){
					c.Status = 'Assigned';
                    c.Sub_Status__c = null;
				}
			}
		}
		Diags.Clear();
	}
	
	/*************************************************************************
    * @author         Janella Espiritu
    * @date           2015-05-22
    * @version        1.0
    * @description    This method will change the owner of related 'Assigned' 
						or 'Unassigned' work items.
    * @parameters    None
    * @revision      Original version
    **************************************************************************/
	public static void assignTheWholeGroup(List<Case> workItems){
		Diags.Enter('assignTheWholeGroup');
		//Diags.Info('workItems: '+String.valueOf(workItems));
		// Instantiate variables
		Map<Id, Id> WorkItemOwnerMap = new Map<Id,Id>();
		Map<Id, List<Case>> parentChildMap = new Map<Id, List<Case>>();
		Set<Id> parentIds = new Set<Id>();
		List<Case> updatedWorkitems = new List<Case>();
		// Loop work items
		for(Case wi : workItems){
			// If the work item is a parent
			if(wi.IsParent__c){
				// Add the values to a map
				// KEY: work item Id
				// VALUE: work item owner Id
				parentIds.add(wi.Id);
				WorkItemOwnerMap.put(wi.Id, wi.OwnerId);
			}
			else{
				// Add the values to a map
				// KEY: work item Parent Id
				// VALUE: work item owner Id
				parentIds.add(wi.ParentId);
				WorkItemOwnerMap.put(wi.ParentId, wi.OwnerId);
			}
			
		}
		//Diags.Info('WorkItemOwnerMap: '+String.valueOf(WorkItemOwnerMap));
		// Query Related Work Items
		List<Case> relatedWorkItems = [select Id, ParentId, OwnerId, IsParent__c from Case 
										where (ParentId IN: parentIds OR Id IN: parentIds)
										and Status IN('Unassigned','Assigned')
										//and Hold__c = FALSE
										//and User_Skill_Rule__r.AssignmentEnabled__c = TRUE
										];
		//Diags.Info('relatedWorkItems: '+String.valueOf(relatedWorkItems));
		// Loop related work items
		for(Case wi : relatedWorkItems){
			// If the work item is a Parent
			if(wi.IsParent__c){
				// Put the values in a map
				// KEY: Work Item Id
				// VALUE: List of Related Work items
				if(parentChildMap.containsKey(wi.Id)){
					List<Case> temp = parentChildMap.get(wi.Id);
					temp.add(wi);
					parentChildMap.put(wi.Id, temp);
				}
				else{
					parentChildMap.put(wi.Id, new List<Case>{wi});
				}
			}
			// If the work item is a child
			else{
				// Put the values in a map
				// KEY: Work Item Parent Id
				// VALUE: List of Related Work items
				if(parentChildMap.containsKey(wi.ParentId)){
					List<Case> temp = parentChildMap.get(wi.ParentId);
					temp.add(wi);
					parentChildMap.put(wi.ParentId, temp);
				}
				else{
					parentChildMap.put(wi.ParentId, new List<Case>{wi});
				}
			}
		}
		//Diags.Info('parentChildMap: '+String.valueOf(parentChildMap));
		// Loop parent ids
		for(Id i : parentChildMap.keySet()){
			// If the WorkItemOwnerMap contains the Parent Id
			if(WorkItemOwnerMap.containsKey(i)){
				// Retrieve the new owner Id from the map
				Id newOwnerId = WorkItemOwnerMap.get(i);
				// Loop related work items
				for(Case wi : parentChildMap.get(i)){
					// If the current owner is not the new owner
					if(wi.OwnerId != newOwnerId){
						// Assign the new owner
						wi.OwnerId = newOwnerId;
						// If the new owner is a User,
						// change the status to Assigned
						// and blank the Sub Status
						if(String.valueOf(wi.OwnerId).startsWith('005')){
							wi.Status = 'Assigned';
                            wi.Sub_Status__c = null;
						}
						// If the new owner is a Queue,
						// change the status to Unassigned
						// and blank the Sub Status
						else if(String.valueOf(wi.OwnerId).startsWith('00G')){
							wi.Status = 'Unassigned';
                            wi.Sub_Status__c = null;
            }
            // Add the work item to updatedWorkItems
            updatedWorkitems.add(wi);
          }
        }
      }
    }
    //Diags.Info('updatedWorkitems: '+String.valueOf(updatedWorkitems));
    // If the updatedWorkItems is not empty
    // update updatedWorkItems
    if(updatedWorkItems.size() > 0){
       update updatedWorkItems;
    }
    
    Diags.Clear();
  }

    /*************************************************************************
    * @author         Janella Espiritu
    * @date           2015-05-22
    * @version        1.0
    * @description    This method will assign work items that got removed from 
						Hold status to the Parent Work Item's owner
    * @parameters    None
    * @revision      Original version
    **************************************************************************/
	public static void assignHoldWorkItems(List<Case> workItems){
		Diags.Enter('assignHoldWorkItems');
		Set<Id> parentWIs = new Set<Id>();
		Map<Id,Id> parentIdOwnerMap = new Map<Id,Id>();
		// Loop work items that are updated
		for(Case wi : workItems){
			// If there is a Parent Id, add the Parent Id to a set
			if(wi.ParentId != null){
				parentWIs.add(wi.ParentId);
			}
		}
		// If there are parent ids
		if(parentWIs.size() > 0){
			// Query and loop parent work items
			for(Case wi : [select id, OwnerId, Owner.Type from Case where Id IN: parentWIs]){
				// If the Parent is owned by a User, put the Id and Owner Id to parentIdOwnerMap
				if(wi.Owner.Type == 'User' || String.valueOf(wi.OwnerId).startsWith('005')){
					parentIdOwnerMap.put(wi.Id, wi.OwnerId);
				}
			}
		}
		// Loop the work items updated again
		for(Case wi : workItems){
			// If the parentId is in parentIdOwnerMap and it's does not have a null value
			if(parentIdOwnerMap.containsKey(wi.ParentId) || parentIdOwnerMap.get(wi.ParentId) != null){
				// Assign the work item to the parent's owner
				wi.OwnerId = parentIdOwnerMap.get(wi.ParentId);
				// Change the status to Assigned
				wi.Status = 'Assigned';
			}
		}
		Diags.Clear();
	}
	
	/*************************************************************************
    * @author         Tae Tran
    * @date           06/24/2015
    * @description    This method will update Work Item Owner field depending on Freeze User ID field
    * @parameters     caseList

    **************************************************************************/    
	public static void FreezeUserIDFields(List<Case> caseList){
        // create my own mapping where the LAN id is the key to check if Lan ID in freeze User skill is in SFDC
        Map<String, User> user_Lan_ID = new Map<String, User>();
		Set<String> lan_id_var = new Set<String>();
		// get all the lan ID first and use it in the query to save time
		for(Case wi : caseList){
            if(wi.LAN_ID__c != null){
            	lan_id_var.add(wi.LAN_ID__c.toUpperCase());    
            }
		}
        for(User temp : [select LAN_ID__c, ID from user where IsActive = true and LAN_ID__c IN: lan_id_var]) 
        {
            user_Lan_ID.put(temp.LAN_ID__c.toUpperCase(), temp); // create a mapping with Lan ID as the ID to look for in the map
        }
        //Map<String, User> user_Lan_ID = new Map<String, User>([select LAN_ID__c, ID from user where IsActive = true]);
        
		for(Case wi : caseList){
            if (wi.LAN_ID__c != null &&  wi.LAN_ID__c != '' && wi.Work_Item_Type__c == 'Unaged Debt'){
                //Diags.Info('###########What is the list of freeze ID lan ID: ' + wi.Freeze_User_ID__c); //need to loop through the list
                if (user_Lan_ID.containsKey(wi.LAN_ID__c.toUpperCase())){ // look for the LAN ID in the map
                	 wi.OwnerID = user_Lan_ID.get(wi.LAN_ID__c.toUpperCase()).ID;
					// Diags.Info('###########GET THE id for the freeze id : ' + user_Lan_ID.get(wi.Freeze_User_ID__c).ID); //need to loop through the list   
                }
                else if (wi.LAN_ID__c.toUpperCase() == '@BILLING' || !(user_Lan_ID.containsKey(wi.LAN_ID__c.toUpperCase())))
                {
	                wi.OwnerID = WorkItemAssignmentUtility.getBillingExceptionQueueId();
    		      //  Diags.Info('###########GET THE id for the freeze id : ' + WorkItemAssignmentUtility.getBillingExceptionQueueId()); 
                } // end else if
            }  // end if
        } // end for

    } // end UpdateFreezeUserIDFields
    
    /*************************************************************************
    * @author         Janella Espiritu
    * @date           07/14/2015
    * @description    This method will automatically complete a work item and 
						update the Approver/Reviewer
    * @parameters     caseList

    **************************************************************************/
	public static void HighBillUtility(List<Case> caseList){
		Set<String> lanIds = new Set<String>();
		for(Case wi : caseList){
            if(wi.LAN_ID__c != null){
            	lanIds.add(wi.LAN_ID__c.toUpperCase());    
            }
		}
        // create my own mapping where the LAN id is the key to check if Lan ID in freeze User skill is in SFDC
        Map<String, User> userMap = new Map<String, User>();
        for(User u : [select LAN_ID__c, Supervisor__c, Supervisor__r.Email, ID from user where IsActive = true and LAN_ID__c IN: lanIds]){
            userMap.put(u.LAN_ID__c.toUpperCase(), u);
        }
        system.debug('**userMap: ' + userMap);
        Map<String, High_Bill_Threshold__c> hbThresholdMap = High_Bill_Threshold__c.getAll();
		List<High_Bill_Threshold__c> hbThreshold = hbThresholdMap.values();
		for(Case wi : caseList){
			if(wi.High_Bill_Difference_Amount__c < hbThreshold[0].High_Bill_Threshold_Amount__c){
				wi.Status = 'Canceled';
				wi.Sub_Status__c = 'Completed by System';
			}
			else{
                wi.Status = 'Pending';
                wi.Sub_Status__c = 'High Bill Review';
                wi.OwnerID = WorkItemAssignmentUtility.getBillingExceptionQueueId();
				if (wi.LAN_ID__c != null &&  wi.LAN_ID__c != ''){
					if (userMap.containsKey(wi.LAN_ID__c.toUpperCase())){ // look for the LAN ID in the map
						User temp = userMap.get(wi.LAN_ID__c.toUpperCase());
                        system.debug('threshold is greater than wi difference');
                        if(temp.Supervisor__c != null){
                            wi.Approver_Reviewer__c = temp.Supervisor__c;
                            wi.Approver_Reviewer_Email__c = temp.Supervisor__r.Email;
                        }
					}
				}  // end if
			}
        } // end for
        system.debug('**caseList: '+caseList);

    } 
	
	/*************************************************************************
    * @author         Janella Espiritu
    * @date           07/16/2015
    * @description    This method create a Case Log upon Completion of the 
    *					work item and Create Customer Contact checkbox is false
    * @parameters     caseList

    **************************************************************************/
	public static void CreateCaseLog(List<Case> caseList){
		Diags.Enter('CreateCaseLog');
		// Instantiate variables
        List<CC_B_Case_Log__c> caseLogInsert = new List<CC_B_Case_Log__c>();
		// Loop related records created
        for(Case wi : caseList){
			// If Add to CC&B Case Log is checked
            if(wi.Add_to_CC_B_Case_Log__c){
                String caseLogDetails = '';
                if(wi.Customer_Contact_Comments__c != null){
                    caseLogDetails += wi.Customer_Contact_Comments__c;
                    caseLogDetails += '\n';
                }
                if(wi.Additional_Customer_Comments_back_end__c != null){
                    caseLogDetails += wi.Additional_Customer_Comments_back_end__c;
                    caseLogDetails += '\n';
                }
                if(wi.Additional_Customer_Contact_Log__c != null){
                    caseLogDetails += wi.Additional_Customer_Contact_Log__c;
                    caseLogDetails += '\n';
                }
                CC_B_Case_Log__c caseLog = new CC_B_Case_Log__c();
                caseLog.CC_B_Case_Log_Details__c = caseLogDetails;
                caseLog.Work_Item__c =wi.Id;
                caseLogInsert.add(caseLog);
            }
        }
        
        // If caseLogInsert is not empty,
        // insert the case log records
        if (caseLogInsert.size() > 0){
          insert caseLogInsert;
        }
    }
	/*************************************************************************
    * @author         Melody Yang
    * @date           07/24/2015
    * @description    This method changes owner from MBT to Billing Exceptions
    * 					if USR is no longer MBT
    * @parameters     caseList
    **************************************************************************/
	public static void UpdateWIOwner(List<Case> caseList){
		Diags.Enter('***%%UpdateWiOwner');
		Id billingExceptionQueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
      	Id MBTQueueId = WorkItemAssignmentUtility.getMBTQueueId();
        //List<User_Skill_Rule__c> USRlist = new List<User_Skill_Rule__c>();
        //USRlist = [select Id from User_Skill_Rule__c where Name = 'BSEG MBT Elec SM30' or Name = 'BSEG MBT Elec SM40'];
		Map<Id, User_Skill_Rule__c> usrMap = new Map<Id, User_Skill_Rule__c>();
        for(User_Skill_Rule__c temp : [select Id from User_Skill_Rule__c where Name = 'BSEG MBT Elec SM30' or Name = 'BSEG MBT Elec SM40']) 
        {
            usrMap.put(temp.Id, temp);
        }
        //for (User_Skill_Rule__c usr: USRList){
        	for (Case c: caseList){
                if (c.OwnerId == MBTQueueId && !usrMap.containsKey(c.User_Skill_Rule__c)){
                        Diags.Info('***%%%caseList: '+ caseList);
                        Diags.Info('***%%% Current WI Owner: '+ c.OwnerId);
                        c.OwnerId = BillingExceptionQueueId;
                        Diags.Info('***%%%Updated WI Owner: '+ c.OwnerId);
                        Diags.Info('***%%%case Id: '+ c.Id);
                }
           }
        //}
        Diags.Save();
    }

    
	public static Integer cpuTime = 0;
    /*************************************************************************
    * @author         Yefim Shuster
    * @date           05/04/2015
    * @description    This method is called from Case Trigger and handle all trigger processing
    * @parameters    newCaseList - Trigger.new
    *                newCaseMap - Trigger.newMap
    *                oldCaseList - Trigger.old
    *                oldCaseMap - Trigger.oldMap
    *                isBefore - Trigger.isBefore
    *                isUpdate - Trigger.isUpdate
    *                isInsert - Trigger.isInsert
	*                isDelete - Trigger.isDelete
    **************************************************************************/
    public static void handle(List<Case> newCaseList,
                              Map<Id, Case> newCaseMap,
                              List<Case> oldCaseList,
                              Map<Id, Case> oldCaseMap,
                              Boolean isBefore,
                              Boolean isUpdate,
                              Boolean isInsert,
                              Boolean isDelete){
      List<Case> caseList = new List<Case>();
      List<Case> reopenCaseList = new List<Case>();
      List<Case> caseList2 = new List<Case>();
      List<Case> customerContactList = new List<Case>();
      List<Case> additionalCustContList = new List<Case>();
      //List<Case> createCustomerContact = new List<Case>();
      List<Case> parentCases = new List<Case>();
      List<Case> recreatedCases = new List<Case>();
      List<Case> closedWorkItemsCC = new List<Case>();
      List<Case> closedWorkItemsWI = new List<Case>();
      List<Case> closedWorkItemsCL = new List<Case>(); // J1EU added 07/16/2015
      List<Case> HighBillWorkItems = new List<Case>(); // J1EU added 07/14/2015
	  List<Case> canceledWorkItemsWI = new List<Case>(); // J1EU added 06/24/2015
      List<Case> sendCharacteristics = new List<Case>(); // J1EU added 06/24/2015
      List<Case> UpdateWIOwner = new List<case>();
      Id IntegrationProfileId = WorkItemAssignmentUtility.getIntegrationProfileId(); // J1EU 07/09/2015 
      Id billingExceptionQueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId(); //mxyq 7/23/2015
      Id MBTQueueId = WorkItemAssignmentUtility.getMBTQueueId(); //mxyq 7/23/2015

      Diags.Enter('CaseTriggerHandler_DEV.handle():IsBefore=' + isBefore + ':IsUpdate=' + isUpdate + ':IsDelete=' + IsDelete + ':newCaseList.size=' + (newCaseList == null ? 0 : newCaseList.size()));
		
	
	// Tae - R2S2 - get a list of close Ids to use when a reopenwork item is open
      String close_ids = '';
                                        
	  List<CaseRecordTypeMap__c> cwi = CaseRecordTypeMap__c.getAll().values(); // get a list of values from custom setting 
	  for (CaseRecordTypeMap__c cwis : cwi) 
      {
      	close_ids += Schema.SObjectType.Case.getRecordTypeInfosByName().get(cwis.Closed_Work_Item_Record_Type__c).getRecordTypeId() + ',';
	  }
	  //Diags.Info('###########LIST OF CASE RECORD MAP WITHIN REOPEN : '+ close_ids);// returns the name of the case type
           
      try {
        
        // Before DML
        if(isBefore){
            // If trigger is insert
            if(isInsert){
				//Tae - R2S3 - Update freeze User ID fields before populating user skill rules
				// J1EU - Moved the call outside the For Loop
				Diags.Info('###########ENTERING CaseAgeClock');// returns the name of the case type
				if (UserInfo.getProfileId() != IntegrationProfileId){
                    System.debug(Logginglevel.info,'@@@@@@@@@Case Age on INsert');
					CaseAgeStartStopHandler.CaseAgeStopClock(newCaseList, isInsert); // TXTR 07/24/2015
            	}
			    Diags.Info('###########ENTERING UPDATE FREEZE USER ID : '+ newCaseList);// returns the name of the case type
                CaseTriggerHandler_DEV.FreezeUserIDFields(newCaseList); // TXTR 06/22/2015
                cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
				System.debug('FreezeUserIDFields - CPUTime: ' + cpuTime);
                System.debug('Total CPUTime: ' + Limits.getCPUTime());
				//System.debug('FreezeUserIDFields - LimitCPUTime: ' + Limits.getLimitCPUTime());
                
				// Loop inserted work items
                for(Case c : newCaseList){
					// If Work Item Type is QAS8 and QAS8 Date is not null,
					// Change IsEscalated to TRUE
					if(c.Work_Item_Type__c != 'QAS8' && c.QAS8_Date__c != null){
                        c.IsEscalated = true;
                    }   
					// If the owner is not a Queue,
					// Change the status to Assigned and blank out Sub Status
                    if(!String.valueOf(c.OwnerId).startsWith('00G')){
                        c.Status = 'Assigned';
						c.Sub_Status__c = null;
                    } 
                    // If Recreated is TRUE
					// Add the work item to recreatedCases
                    if (c.Recreated__c) {
                      recreatedCases.add(c);
                    }
                    if(c.Work_Item_Type__c == 'High Bill'){
						HighBillWorkItems.add(c);
					}
                }
                cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                System.debug('CaseTriggerHandler before insert for loop - CPUTime: ' + cpuTime);
                System.debug('Total CPUTime: ' + Limits.getCPUTime());
				
                    
				// Populate User Skill Rule
                CaseTriggerHandler_DEV.populateUserSkillRule(newCaseList);
//Tae_populateUserskillrules.populateUserSkillRule(newCaseList);
                cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                System.debug('populateUserSkillRule - CPUTime: ' + cpuTime);
                System.debug('Total CPUTime: ' + Limits.getCPUTime());
				//System.debug('populateUserSkillRule - LimitCPUTime: ' + Limits.getLimitCPUTime());
                //Modified by Yefim Shuster on 2015-02-04 - Defect 134 - call updateWorkItemAssignment Before Insert for Recreated WI - added below
                if (recreatedCases.size() > 0){
                  	CaseTriggerHandler.updateWorkItemAssignment(recreatedCases);
                  	cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                    System.debug('updateWorkItemAssignment - CPUTime: ' + cpuTime);
                    System.debug('Total CPUTime: ' + Limits.getCPUTime());
					//System.debug('updateWorkItemAssignment - LimitCPUTime: ' + Limits.getLimitCPUTime());
                }
                if(HighBillWorkItems.size() > 0){
					HighBillUtility(HighBillWorkItems);
                    cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());                
                    System.debug('HighBillUtility - CPUTime: ' + cpuTime);
                    System.debug('Total CPUTime: ' + Limits.getCPUTime());
					//System.debug('HighBillUtility - LimitCPUTime: ' + Limits.getLimitCPUTime());
				}
                //System.debug('CaseTriggerHandler before insert for loop - LimitCPUTime: ' + Limits.getLimitCPUTime());
				// Concatenate Customer Contact Comments 
				// and Additional Customer Contact Comments
                CaseTriggerHandler_DEV.concatenateAdditionalComments(newCaseList); // J1EU 05/05/2015
                cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                System.debug('concatenateAdditionalComments - CPUTime: ' + cpuTime);
                System.debug('Total CPUTime: ' + Limits.getCPUTime());
				//System.debug('concatenateAdditionalComments - LimitCPUTime: ' + Limits.getLimitCPUTime());
                CaseTriggerHandler_DEV.concatenateCustomerContactFields(newCaseList); // J1EU 05/05/2015
                cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                System.debug('concatenateCustomerContactFields - CPUTime: ' + cpuTime);
                System.debug('Total CPUTime: ' + Limits.getCPUTime());
				//System.debug('concatenateCustomerContactFields - LimitCPUTime: ' + Limits.getLimitCPUTime());
            }
            // If trigger is update
            if(isUpdate){

				// Instantiate variables
                List<Case> updatedSubStatusWorkItems = new List<Case>();
				List<Case> holdWIs = new List<Case>();
      			List<Case> reevaluateUSRwi = new List<Case> (); // mxyq 7/24/2015
                List<Case> UpdateOwner = new List<Case>();
      			List<Case> closingWorkItemAgain = new List<Case>(); //mxyq added 8/4/2015
                
				// Id ClosedRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Closed Work Item - Billing Exceptions').getRecordTypeId();
                //if(checkRecursive.runOnce() || Test.isRunningTest()){
                    //system.debug('CaseList: '+newCaseList);
					// Loop updated work items
                	cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                    System.debug('CaseTriggerHandler before update for loop (before) - CPUTime: ' + cpuTime);
                    System.debug('Total CPUTime: ' + Limits.getCPUTime());
					//System.debug('CaseTriggerHandler before update for loop (before) - LimitCPUTime: ' + Limits.getLimitCPUTime());
                    for(Case c : newCaseList){                     
                        Case oldMap = oldCaseMap.get(c.Id);
System.debug(logginglevel.info, '***%%% what is the old map value at the very beginning: '+oldMap);  
                        //mxyq - added 8/4/2015; cannot close WI if already closed
                        if (oldMap.IsClosed && c.IsClosed){
                            closingWorkItemAgain.add(c);
                        }
						// If the Hold field changed from true to false, 
						// add the work item to holdWIs
						if(!c.Hold__c && oldMap.Hold__c){
							holdWIs.add(c);
						}
						// If the Sub Status changed,
						// add the work item to updatedSubStatisWorkItems
						if(c.Sub_Status__c != oldMap.Sub_Status__c){
							updatedSubStatusWorkItems.add(c);
						}
						// If the Status Changed, change the Last Status Time, 
						// Last Status and Last Sub Status fields
                        if(c.Status != oldMap.Status){
							c.Last_Status_Time__c = datetime.now();
							c.Last_Status__c = oldMap.Status;
                            c.Last_Sub_Status__c = oldMap.Sub_Status__c;
                        }
						// If the Work Item Type is not QAS8 and QAS8 Date is not null,
						// update IsEscalated to true
                        if(c.Work_Item_Type__c != 'QAS8' && c.QAS8_Date__c != null){
                            c.IsEscalated = true;
                        }
						// If As Billed Corrected Diff Amt changed, 
						// blank out Net Variance Approval Status
                        if(c.As_Billed_Corrected_Diff_Amt__c != oldMap.As_Billed_Corrected_Diff_Amt__c){
                            c.Net_Variance_Approval_Status__c = null;
                        }
						// If Postpone Credit if applicable is not Yes,
						// blank out Postpone Credit Date
                        if(c.Postpone_Credit_if_applicable__c != 'Yes'){
                            c.Postpone_Credit_Date__c = null;
                        }
						// If Owner is changed, add work item to caseList
                        if(c.OwnerId != oldMap.OwnerId){
                            caseList.add(c);
                        }
                        //if(c.Reopened__c && !oldMap.Reopened__c && c.RecordTypeId == ClosedRecordTypeId){
							//reopenCaseList.add(c);
                        //}
						//Tae - R1S2 loop though to get the correct record type ID from custom settings
                        //if(c.Reopened__c && !oldMap.Reopened__c && (c.RecordTypeId == ClosedRecordTypeId_Case || c.RecordTypeId == ClosedRecordTypeId_Mail || c.RecordTypeId == ClosedRecordTypeId_Todos))
						//Diags.Info('###########Case id in handel : '+ c_id);// returns the name of the case type
                        //Diags.Info('###########Case id in handel true or false : '+ close_ids.contains(c_id));// returns the name of the case type
                        String c_id = c.RecordTypeId;
						// If work item has been reopened and is allowed to be manually reopened
System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%%% What is the close IDS...' + close_ids);
System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%%% What is the CASE IDS...' + c_id);
System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%%% What is the REOPEN...' + c.Reopened__c);
System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%%% What is the OPENMAPREOPEN...' + oldMap.Reopened__c);
                        if(c.Reopened__c && !oldMap.Reopened__c && (close_ids.contains(c_id)))
                        {
                           reopenCaseList.add(c);
                        }
						// If any Customer Contact Comment related fields are changed,
						// add the work item to customerContactList
                        if(c.SOX_Required_Information__c != oldMap.SOX_Required_Information__c || 
							c.CC_Account_ID__c != oldMap.CC_Account_ID__c ||
							c.CC_Service_Agreement_ID__c != oldMap.CC_Service_Agreement_ID__c ||
							c.CC_Service_Point_ID__c != oldMap.CC_Service_Point_ID__c || 
							c.CC_Premise_Address__c != oldMap.CC_Premise_Address__c ||
							c.CC_Premise_ID__c != c.CC_Premise_ID__c ||
                            c.As_Billed_Amount__c != oldMap.As_Billed_Amount__c ||
                            c.As_Corrected_Amount__c != oldMap.As_Corrected_Amount__c ||
                            c.As_Billed_Corrected_Diff_Amt__c != oldMap.As_Billed_Corrected_Diff_Amt__c ||
                            c.As_Billed_Corrected_From__c != oldMap.As_Billed_Corrected_From__c || 
                             c.As_Billed_Corrected_To__c != oldMap.As_Billed_Corrected_To__c ||
                            c.Billed_To_Amount__c != oldMap.Billed_To_Amount__c || 
                            c.Billed_From_Date__c != oldMap.Billed_From_Date__c ||
                            c.Billed_To_Date__c != oldMap.Billed_To_Date__c || 
                            c.Postpone_Credit_Date__c != oldMap.Postpone_Credit_Date__c ||
                            c.Customer_Contact_Class__c != oldMap.Customer_Contact_Class__c || 
                            c.Customer_Contact_Type__c != oldMap.Customer_Contact_Type__c || 
                             c.isClosed){
                            customerContactList.add(c);
                        }
						// If any Additional Customer Contact comments are changed,
						// add the work item to additionalCustContList
                        if(c.Work_Item_Type__c != oldMap.Work_Item_Type__c ||
                            c.Root_Cause__c != oldMap.Root_Cause__c ||
                            c.Postpone_Credit_Date__c != oldMap.Postpone_Credit_Date__c ||
                            c.Additional_Customer_Contact_Comments__c != oldMap.Additional_Customer_Contact_Comments__c ||
                            c.isClosed ||
                            c.Customer_Contact_Class__c != oldMap.Customer_Contact_Class__c || 
                            c.Customer_Contact_Type__c != oldMap.Customer_Contact_Type__c ||
							c.CC_B_Case_ID__c != oldMap.CC_B_Case_ID__c || // j1eu Added comparison for Case Id 5/13/2015
                            c.Revenue_Assurance_Account_Number__c != oldMap.Revenue_Assurance_Account_Number__c ||
                            c.Revenue_Assurance_SA_ID__c != oldMap.Revenue_Assurance_SA_ID__c ||
                            c.Billed_Reason__c != oldMap.Billed_Reason__c ||
                            //c.Root_Cause_Category__c != oldMap.Root_Cause_Category__c || - Removed J1EU as per business 05-29-2015
                            c.Root_Cause_Other__c != oldMap.Root_Cause_Other__c ||
                            c.OwnerId != oldMap.OwnerId // Added J1EU 05/28/2015
                          ){ 
                            additionalCustContList.add(c);
                        }
						// J1EU - added 05/13/2015: Collect work items to be closed
                        if(c.Status =='Completed' && !oldMap.isClosed && UserInfo.getProfileId() != IntegrationProfileId){
                            if(c.Create_Customer_Contact_in_CC_B__c){
                            	closedWorkItemsCC.add(c);    
                            }
                            closedWorkItemsWI.add(c);
                        }
                        // J1EU - added 06/24/2015: collect Canceled work items
                        if(c.Status == 'Canceled' && !oldMap.isClosed){
                            canceledWorkItemsWI.add(c);
                        }
                        //mxyq - added 7/23/2015; re-evaluate USR if error msg/cat or DaCca Ind changes
                        if (c.Status == 'Unassigned' && c.Work_Item_Type__c == 'BSEG' && c.OwnerId == MBTQueueId && 
                            (c.Message_Category_Number__c != oldMap.Message_Category_Number__c 
							|| c.Message_Number__c != oldMap.Message_Number__c 
                            )){
                                     reevaluateUSRwi.add(c);
                        }
                        if((c.Third_Party_Response__c != oldMap.Third_Party_Response__c ||
                          	c.Third_Party_Response_Required__c != oldMap.Third_Party_Response_Required__c ||
                            c.Customer_Response_Required__c != oldMap.Customer_Response_Required__c ||
                            c.Customer_Response_Resolution__c != oldMap.Customer_Response_Resolution__c)){
//&& c.CC_B_Case_ID__c != null){
                            sendCharacteristics.add(c);
                        }
                        
                    }
             
                	//mxyq - added 8/4/2015 - cannot close if already closed
                        if (checkRecursiveValidateClosingWIAgain.runOnce() && closingWorkItemAgain.size()>0){
                           ValidationUtility.ValidateClosingWIagain(closingWorkItemAgain);                         
                        }
                
                	cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                    System.debug('CaseTriggerHandler before update for loop (after) - CPUTime: ' + cpuTime);
                    System.debug('Total CPUTime: ' + Limits.getCPUTime());
					//System.debug('CaseTriggerHandler before update for loop (after) - LimitCPUTime: ' + Limits.getLimitCPUTime());
                	//Diags.Info('canceledWorkItemsWI.size()'+string.valueOf(canceledWorkItemsWI.size()));
					// If holdWIs is not empty, call assignHoldWorkItems
					if(holdWIs.size() > 0){
						assignHoldWorkItems(holdWIs);
                        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                        System.debug('assignHoldWorkItems - CPUTime: ' + cpuTime);
                        System.debug('Total CPUTime: ' + Limits.getCPUTime());
						//System.debug('assignHoldWorkItems - LimitCPUTime: ' + Limits.getLimitCPUTime());
					}
                	//mxyq - re-evaluate USR
                	if(reevaluateUSRwi.size() > 0){
                        CaseTriggerHandler_DEV.populateUserSkillRule(reevaluateUSRwi);
//Tae_populateUserskillrules.populateUserSkillRule(reevaluateUSRwi);
                    }
                	Diags.Info('***%%%right before the if loop');
                	Diags.Info('***%%%caselist size: '+newCaseList.size());
                	//mxyq - update WI owner if owner = MBT but USR is not MBT 
                    if (newCaseList.size()>0){
                        CaseTriggerHandler_DEV.UpdateWIOwner(newCaseList);
                        Diags.Info('***%%% this is the newCaseList owner afterwards: '+newCaseList);
                    }
					// If updatedSubStatusWorkItems is not empty, 
					// call ValidationUtility.ValidateFastSlowAutomationSubStatus
					if(updatedSubStatusWorkItems.size() > 0 && UserInfo.getProfileId() != IntegrationProfileId){
						ValidationUtility.ValidateFastSlowAutomationSubStatus(updatedSubStatusWorkItems);
                        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                        System.debug('ValidateFastSlowAutomationSubStatus - CPUTime: ' + cpuTime);
                        System.debug('Total CPUTime: ' + Limits.getCPUTime());
						//System.debug('ValidateFastSlowAutomationSubStatus - LimitCPUTime: ' + Limits.getLimitCPUTime());
					}
					// If closedWorkItemsWI is not empty, 
					// call ValidationUtility.RequiredFieldsValidationWorkItem and 
					// ShiftTimesUtility.updateBusinessHoursOnComplete
                	if(closedWorkItemsWI.size() > 0 && UserInfo.getProfileId() != IntegrationProfileId){
                        ValidationUtility.RequiredFieldsValidationWorkItem(closedWorkItemsWI);
                        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                        System.debug('RequiredFieldsValidationWorkItem - CPUTime: ' + cpuTime);
                        System.debug('Total CPUTime: ' + Limits.getCPUTime());
						//System.debug('RequiredFieldsValidationWorkItem - LimitCPUTime: ' + Limits.getLimitCPUTime());
						ShiftTimesUtility.updateBusinessHoursOnComplete(closedWorkItemsWI); // J1EU Added on 06-22-2015
                        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                        System.debug('updateBusinessHoursOnComplete - CPUTime: ' + cpuTime);
                        System.debug('Total CPUTime: ' + Limits.getCPUTime());
						//System.debug('updateBusinessHoursOnComplete - LimitCPUTime: ' + Limits.getLimitCPUTime());
						// validate a WI cannot be closed if it's owned by billingExceptions queue mxyq 8/11/2015
                        ValidationUtility.ValidateClosingWIasBillingExceptions(closedWorkItemsWI);//mxyq 8/4/2015

                    }   
                	if (UserInfo.getProfileId() != IntegrationProfileId && sendCharacteristics.size() > 0){
                        System.debug(Logginglevel.info,'@@@@@@@@@Checking case age on Update');
                        CaseAgeStartStopHandler.CaseErrorCheck(sendCharacteristics, oldCaseMap); // check error first TXTR
                        CaseAgeStartStopHandler.CaseAgeStopClock(sendCharacteristics, false); // TXTR 07/24/2015
                        CaseAgeStartStopHandler.CaseAgeStartClock(sendCharacteristics, oldCaseMap); // TXTR 07/24/2015
                    	for(Case c : sendCharacteristics){
                            Case oldCase = oldCaseMap.get(c.Id);
                            Boolean thrdPartyResReqChanged = false; 
                            Boolean custRespReqChanged = false;
                            Boolean thrdParResChanged = false; 
                            Boolean custRespResChanged = false;
                            if(c.Third_Party_Response_Required__c != oldCase.Third_Party_Response_Required__c){
                                thrdPartyResReqChanged = true;
                            }
                            if(c.Third_Party_Response__c != oldCase.Third_Party_Response__c){
                                thrdParResChanged = true;
                            }
                            if(c.Customer_Response_Required__c != oldCase.Customer_Response_Required__c){
                                custRespReqChanged = true;
                            }
                            if(c.Customer_Response_Resolution__c != oldCase.Customer_Response_Resolution__c){
                                custRespResChanged = true;
                            }
                            BuildXMLForCaseChar.sendRequest(c.Id, c.CC_B_Case_ID__c, thrdPartyResReqChanged, thrdParResChanged, custRespReqChanged, custRespResChanged); 
                        }
                    }

                	// If canceledWorkItemsWI is not empty, 
                    // call ValidationUtility.ValidateCanceledSubStatus 
                    // added J1EU on 06-24-2015
                    if(canceledWorkItemsWI.size() > 0 && UserInfo.getProfileId() != IntegrationProfileId){
                        ValidationUtility.ValidateCanceledSubStatus(canceledWorkItemsWI);
                        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                        System.debug('ValidateCanceledSubStatus - CPUTime: ' + cpuTime);
                        System.debug('Total CPUTime: ' + Limits.getCPUTime());
						//System.debug('ValidateCanceledSubStatus - LimitCPUTime: ' + Limits.getLimitCPUTime());
                    }
					// If closedWorkItemsCC is not empty, 
					// call ValidationUtility.RequiredFieldsValidationWorkItem 
                    if(closedWorkItemsCC.size() > 0 && UserInfo.getProfileId() != IntegrationProfileId){
						ValidationUtility.CustomerContactValidationWorkItem(closedWorkItemsCC);
                        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                        System.debug('CustomerContactValidationWorkItem - CPUTime: ' + cpuTime);
                        System.debug('Total CPUTime: ' + Limits.getCPUTime());
						//System.debug('CustomerContactValidationWorkItem - LimitCPUTime: ' + Limits.getLimitCPUTime());
                    }
					// If caseList is not empty, 
					// call validateMassReassignment and updateWorkItemAssignment
                    if(caseList.size() > 0){
						validateMassReassignment(caseList);
                        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                        System.debug('validateMassReassignment - CPUTime: ' + cpuTime);
                        System.debug('Total CPUTime: ' + Limits.getCPUTime());
						//System.debug('validateMassReassignment - LimitCPUTime: ' + Limits.getLimitCPUTime());
                        CaseTriggerHandler_DEV.updateWorkItemAssignment(caseList);
                        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                        System.debug('updateWorkItemAssignment - CPUTime: ' + cpuTime);
                        System.debug('Total CPUTime: ' + Limits.getCPUTime());
						//System.debug('updateWorkItemAssignment - LimitCPUTime: ' + Limits.getLimitCPUTime());
                    }
					// If reopenCaseList is not empty, 
					// call reopenWorkItems
                    if(reopenCaseList.size() > 0){
                        CaseTriggerHandler_DEV.reopenWorkItems(reopenCaseList, oldCaseMap);
                        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                        System.debug('reopenWorkItems - CPUTime: ' + cpuTime);
                        System.debug('Total CPUTime: ' + Limits.getCPUTime());
						//System.debug('reopenWorkItems - LimitCPUTime: ' + Limits.getLimitCPUTime());
                    }
					// If customerContactList is not empty, 
					// call concatenateCustomerContactFields
                    if(customerContactList.size() > 0){
                        CaseTriggerHandler_DEV.concatenateCustomerContactFields(customerContactList);
                        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                        System.debug('concatenateCustomerContactFields - CPUTime: ' + cpuTime);
                        System.debug('Total CPUTime: ' + Limits.getCPUTime());
						//System.debug('concatenateCustomerContactFields - LimitCPUTime: ' + Limits.getLimitCPUTime());
                    }
					// If additionalCustContList is not empty, 
					// call concatenateAdditionalComments
                    if(additionalCustContList.size() > 0){
                        CaseTriggerHandler_DEV.concatenateAdditionalComments(additionalCustContList);
                        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                        System.debug('concatenateAdditionalComments - CPUTime: ' + cpuTime);
                        System.debug('Total CPUTime: ' + Limits.getCPUTime());
						//System.debug('concatenateAdditionalComments - LimitCPUTime: ' + Limits.getLimitCPUTime());
                    }
               // }
            }
        }
        // After DML
        if(!isBefore){
            // If trigger is insert
            if(isInsert){
//txtr - comment out need to look at it again
DuplicateWorkItems.DuplicateUtility(newCaseList); //mxyq 07/04/2015
                cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                System.debug('DuplicateUtility - CPUTime: ' + cpuTime);
                System.debug('Total CPUTime: ' + Limits.getCPUTime());
                //System.debug('DuplicateUtility - LimitCPUTime: ' + Limits.getLimitCPUTime());
                // Modified by YXS7 on 2015-05-13 - R2 - assignmentEnabledWITypes are no longer used - commented out below - new version is 1.1
                //Set<String> assignmentEnabledWITypes = UserSkillRuleUtility.assignmentEnabled();
                
                //Set<String> groupingEnabledWITypes = GroupingUtility.groupingEnabled();
                //CaseTriggerHandler.populateCaseOwner(newCaseList);
                //CaseTriggerHandler.groupWorkItems(newCaseList, groupingEnabledWITypes, assignmentEnabledWITypes);
                
				// Call Grouping Engine and pass the new work items inserted
//txtr - comment out need to look at it over again. 			
//GroupingEngine.GroupingEngine(newCaseList, 'Insert', newCaseMap); // j1eu 05/06/2015
                cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                System.debug('GroupingEngine - CPUTime: ' + cpuTime);
                System.debug('Total CPUTime: ' + Limits.getCPUTime());
                //System.debug('GroupingEngine - LimitCPUTime: ' + Limits.getLimitCPUTime());
                //GroupingEngine2.GroupingEngine(newCaseList, 'Insert', newCaseMap); // j1eu 05/06/2015
                // Modified by YXS7 on 2015-05-13 - R2 - refactor Work Item Assignment - commented out and replaced below - new version is 1.1
                //CaseTriggerHandler_DEV.assignWorkItems(caseList);
				
                // Call the Assignment Engine
				CaseTriggerHandler_DEV.assignWIs();
                cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                System.debug('assignWIs - CPUTime: ' + cpuTime);
                System.debug('Total CPUTime: ' + Limits.getCPUTime());
                //System.debug('assignWIs - LimitCPUTime: ' + Limits.getLimitCPUTime());
                //Modified by Yefim Shuster on 2015-02-04 - Defect 135 - call createStatusTimes After Insert for Recreated WI - modified below
                //if(checkRecursive.runOnce() || Test.isRunningTest()){
				// Call recreated work items
                recreatedCases.clear();
                cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                System.debug('after insert for loop (before) - CPUTime: ' + cpuTime);
                System.debug('Total CPUTime: ' + Limits.getCPUTime());
                //System.debug('after insert for loop (before) - LimitCPUTime: ' + Limits.getLimitCPUTime());
                for(Case c : newCaseList){
					if (c.Recreated__c) {
						recreatedCases.add(c);
                    }
                }
                cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                System.debug('after insert for loop (after) - CPUTime: ' + cpuTime);
                System.debug('Total CPUTime: ' + Limits.getCPUTime());
                //System.debug('after insert for loop (after) - LimitCPUTime: ' + Limits.getLimitCPUTime());
				// If there are recreatedCases, call createStatisTimes
                if (recreatedCases.size() > 0){
                    
                    // Modified by YXS7 on 2015-07-28 - replace DLRS - commented out below and replaced - new version is 1.2
                    //CaseTriggerHandler_DEV.createStatusTimes(recreatedCases, oldCaseMap);
                    CaseTriggerHandler_DEV.createStatusTimes(recreatedCases, oldCaseMap, isUpdate);
                    
                    cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                    System.debug('createStatusTimes - CPUTime: ' + cpuTime);
                    System.debug('Total CPUTime: ' + Limits.getCPUTime());
                	//System.debug('createStatusTimes - LimitCPUTime: ' + Limits.getLimitCPUTime());
                }
                //}
            }
            // If trigger is Update
            if(isUpdate){
            	CaseTriggerHandler_DEV.updateWebformRequest (oldCaseMap,newCaseMap);
				// Check if this is the first time the trigger is running
                if(checkRecursive.runOnce() /*|| Test.isRunningTest()*/){
					// Instantiate variables
					List<Case> custContList = new List<Case>();
					//commented by SWetha
                    List<Case> statTimeList = new List<Case>();
                    List<Case> postponeList = new List<Case>();
                    List<Case> changedOwnerList = new List<Case>();
					List<Case> completedList = new List<Case>();
                    List<Case> USRregroupWIs = new List<Case>(); // mxyq - added 7/24/2015
                    // Modified by YXS7 on 2015-02-19 - PCR 140278 - MBT Reassignment - call groupWorkItems() AFTER UPDATE when Owner changed
                    //                  from MBT Queue to Billing Exceptions queue or from ANY to Duplicate Exceptions queue - added below
//Id billingExceptionQueueId = WorkItemAssignmentUtility.getBillingExceptionQueueId();
//Id MBTQueueId = WorkItemAssignmentUtility.getMBTQueueId();
                    Id FastSlowQueueId = WorkItemAssignmentUtility.getFastSlowToDoQueueId();
                    Id FloorSupportQueueId = WorkItemAssignmentUtility.getFloorSupportQueueId();
                    Id duplicateExceptionQueueId = WorkItemAssignmentUtility.getDuplicateExceptionQueueId();
                    List<Case> regroupWIs = new List<Case>();
                    List<Case> regroupWIsFromQueue = new List<Case>();
                    cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                    System.debug('after update for loop (before) - CPUTime: ' + cpuTime);
                    System.debug('Total CPUTime: ' + Limits.getCPUTime());
                	//System.debug('after update for loop (before) - LimitCPUTime: ' + Limits.getLimitCPUTime());
                    // Loop updated work items
                    for(Case c : newCaseList){
                            
                        // Retrieve old values
                        Case oldMap = oldCaseMap.get(c.Id);
                        //Commented by SWetha
						// If the Status OR Floor Support Request Completed changed,
						// add work item to statTimeList
                        if((c.Status != oldMap.Status) || (c.Floor_Support_Request_Completed__c && !oldMap.Floor_Support_Request_Completed__c)){
                            statTimeList.add(c);
                        }
						// If the work item has been completed
                        if(c.Status == 'Completed' /*&& c.IsClosed != oldMap.IsClosed*/){
							// If the Create Customer Contact in CC&B is checked 
							// and sub status is 'Completed by Assigned User',
							// add work item to custContList
                            if(c.Create_Customer_Contact_in_CC_B__c && c.Sub_Status__c == 'Completed by Assigned User'){
                              custContList.add(c);    
                            }
                            else if(c.Add_to_CC_B_Case_Log__c && c.Sub_Status__c == 'Completed by Assigned User'){
                            	closedWorkItemsCL.add(c);
                            }
							// Add work item to postponeList
                            postponeList.add(c);
                        }
						// If the owner has been changed
                        if(c.OwnerId != oldMap.OwnerId){
							// retrieve the CSR Profile Id
							Id csrId = WorkItemAssignmentUtility.getCSRProfileId();
							// If new owner is Billing Exceptions or is a User
							// and old owner is not a queue,
							// and current user is not a CSR,
							// add work item to changedOwnerList
                            if(((c.OwnerId == billingExceptionQueueId) || (!String.valueOf(oldMap.OwnerId).startsWith('00G') && String.valueOf(oldMap.OwnerId) != billingExceptionQueueId) || String.valueOf(c.OwnerId).startsWith('005'))){
                                system.debug('******Owner Changed*******');
                                changedOwnerList.add(c);
                            }
							// If the old owner is the MBT or Fast Slow Queue 
							// and new owner is Billing Exceptions,
							// add work item to regroupWIsFormQueue
                            if((oldMap.OwnerId == MBTQueueId || oldMap.OwnerId == FastSlowQueueId) && c.OwnerId == billingExceptionQueueId){
                                regroupWIsFromQueue.add(c);
                            }
							// If the work item is a Parent 
							// and new owner is the Duplicate Exceptions Queue
							// or the work item has been Canceled,
							// add work item to regroupWIs
                            if(c.OwnerId == duplicateExceptionQueueId && c.IsParent__c){
                                regroupWIs.add(c);
                            }
                        }
                        if(c.Status == 'Canceled' && c.IsParent__c){
                             system.debug('******PARENT CANCELED*******');
                            regroupWIs.add(c);
                        }
						/*// Janella Espiritu - collect work items that changed owner
						if(c.OwnerId != oldMap.OwnerId && ){
                            
                        }
                        // Modified by YXS7 on 2015-02-19 - PCR 140278 - MBT Reassignment - call groupWorkItems() AFTER UPDATE when Owner changed
                        //                  from MBT Queue to Billing Exceptions queue or from ANY to Duplicate Exceptions queue - added below
                        if (c.OwnerId != oldMap.OwnerId &&  ||
                                                            ) {
                           regroupWIs.add(c);
                        }*/
                        //mxyq - if USR changes regroup WI's
                        if (c.Status == 'Unassigned' && c.Work_Item_Type__c == 'BSEG' && c.User_Skill_Rule__c != oldMap.User_Skill_Rule__c){
                            USRregroupWIs.add(c);
                        }
                    }
                    cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                    System.debug('after update for loop (after) - CPUTime: ' + cpuTime);
                    System.debug('Total CPUTime: ' + Limits.getCPUTime());
                	//System.debug('after update for loop (after) - LimitCPUTime: ' + Limits.getLimitCPUTime());
					//mxyq - if USR changes, regroup WIs
                    if (USRregroupWIs.size()>0){
                       GroupingEngine.GroupingEngine(newCaseList, 'Update', newCaseMap);
                    }
                    // If regroupWIsFromQueue is not empty
					// Call GroupingEngine.GroupingEngine
					// 'Insert' means it will regroup similar 
					// to when work items have been inserted
                    if(regroupWIsFromQueue.size() > 0){
                        //GroupingEngine2.GroupingEngine(regroupWIsFromQueue, 'Insert'); // j1eu 05/06/2015
                        GroupingEngine.GroupingEngine(newCaseList, 'Insert', newCaseMap); // j1eu 05/06/2015
                        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                        System.debug('GroupingEngine regroupWIsFromQueue - CPUTime: ' + cpuTime);
                        System.debug('Total CPUTime: ' + Limits.getCPUTime());
                		//System.debug('GroupingEngine regroupWIsFromQueue - LimitCPUTime: ' + Limits.getLimitCPUTime());
                    }
                    // Modified by YXS7 on 2015-02-19 - PCR 140278 - MBT Reassignment - call groupWorkItems() AFTER UPDATE when Owner changed
                    //                  from MBT Queue to Billing Exceptions queue or from ANY to Duplicate Exceptions queue - added below
                    
					// If regroupWIs is not empty
					// Call GroupingEngine.GroupingEngine
					// 'Update' means it will regroup similar 
					// to when work items have been updated
					// and will look only at Unassigned status
					if(regroupWIs.size() > 0) {
                      // Modified by YXS7 on 2015-05-13 - R2 - assignmentEnabledWITypes are no longer used - commented out below - new version is 1.1
                      //Set<String> assignmentEnabledWITypes = UserSkillRuleUtility.assignmentEnabled();
                      //GroupingEngine.GroupingEngine(regroupWIs, 'Update'); // j1eu 05/06/2015
                      //GroupingEngine.GroupingEngine(newCaseList, 'Update', newCaseMap); // j1eu 05/06/2015
                      cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                      System.debug('GroupingEngine regroupWIs - CPUTime: ' + cpuTime);
                      System.debug('Total CPUTime: ' + Limits.getCPUTime());
                	  //System.debug('GroupingEngine regroupWIs - LimitCPUTime: ' + Limits.getLimitCPUTime());
                      //Set<String> groupingEnabledWITypes = GroupingUtility.groupingEnabled();
                      //CaseTriggerHandler.groupWorkItems(regroupWIs, groupingEnabledWITypes, assignmentEnabledWITypes);
                    }
                    // If custContList is not empty,
					// call CreateCustomerContact
                    if(custContList.size() > 0){
                        CaseTriggerHandler_DEV.CreateCustomerContact(custContList);
                        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                        System.debug('CreateCustomerContact- CPUTime: ' + cpuTime);
                        System.debug('Total CPUTime: ' + Limits.getCPUTime());
                	  	//System.debug('CreateCustomerContact - LimitCPUTime: ' + Limits.getLimitCPUTime());
                    }
                    // If closedWorkItemsCL is not empty,
					// call CreateCaseLog
                    if(closedWorkItemsCL.size() > 0){
                        CreateCaseLog(closedWorkItemsCL);
                        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                        System.debug('CreateCaseLog- CPUTime: ' + cpuTime);
                        System.debug('Total CPUTime: ' + Limits.getCPUTime());
                	  	//System.debug('CreateCaseLog - LimitCPUTime: ' + Limits.getLimitCPUTime());
                    }
                    
                   // commented by ;swetha 
				    // If statTimeList is not empty,
					// call createStatusTimes
                    if(statTimeList.size() > 0){
                        //CaseTriggerHandler.createStatusTimes(statTimeList, oldCaseMap);
                        
                        // Modified by YXS7 on 2015-07-28 - replace DLRS - commented out below and replaced - new version is 1.2
                        //CaseTriggerHandler_DEV.createStatusTimes(statTimeList, oldCaseMap);
                        CaseTriggerHandler_DEV.createStatusTimes(statTimeList, oldCaseMap, isUpdate);
                        
                        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                        System.debug('createStatusTimes- CPUTime: ' + cpuTime);
                        System.debug('Total CPUTime: ' + Limits.getCPUTime());
                	  	//System.debug('createStatusTimes - LimitCPUTime: ' + Limits.getLimitCPUTime());
                    }
					// If postponeList is not empty,
					// call populatePostponeCredit
                    if(postponeList.size() > 0){
                        CaseTriggerHandler_DEV.populatePostponeCredit(postponeList);
                        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                        System.debug('populatePostponeCredit- CPUTime: ' + cpuTime);
                        System.debug('Total CPUTime: ' + Limits.getCPUTime());
                	  	//System.debug('populatePostponeCredit - LimitCPUTime: ' + Limits.getLimitCPUTime());
                    }
					// If changedOwnerList is not empty,
					// call assignTheWholeGroup
					if(changedOwnerList.size() > 0){
						assignTheWholeGroup(changedOwnerList);
                        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
                        System.debug('assignTheWholeGroup- CPUTime: ' + cpuTime);
                        System.debug('Total CPUTime: ' + Limits.getCPUTime());
                	  	//System.debug('assignTheWholeGroup - LimitCPUTime: ' + Limits.getLimitCPUTime());
					}
                }
        
        // Modified by YXS7 on 2015-07-29 - R2S4 - replace DLRS - new version is 1.2
        WorkItemRollupSummary.recalculateChildtoParent(newCaseMap, oldCaseMap, isUpdate, isDelete);
        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
        System.debug('WorkItemRollupSummary.recalculateChildtoParent - CPUTime: ' + cpuTime);
        System.debug('Total CPUTime: ' + Limits.getCPUTime());
        
        // Modified by YXS7 on 2015-07-29 - R2S4 - replace DLRS - new version is 1.2 - commented out below and replaced
        //dlrs.RollupService.triggerHandler();
        RecalculateWorkItemAssignment.recalculate(newCaseMap, oldCaseMap, isUpdate, isDelete);
        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
        System.debug('RecalculateWorkItemAssignment.recalculate - CPUTime: ' + cpuTime);
        System.debug('Total CPUTime: ' + Limits.getCPUTime());
      }
      
      // If the trigger is after Delete
      if(isDelete){
        // Modified by YXS7 on 2015-07-29 - R2S4 - replace DLRS - new version is 1.2
        WorkItemRollupSummary.recalculateChildtoParent(newCaseMap, oldCaseMap, isUpdate, isDelete);
        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
        System.debug('WorkItemRollupSummary.recalculateChildtoParent - CPUTime: ' + cpuTime);
        System.debug('Total CPUTime: ' + Limits.getCPUTime());
        
        // Modified by YXS7 on 2015-07-29 - R2S4 - replace DLRS - new version is 1.2 - commented out below and replaced
        //dlrs.RollupService.triggerHandler();
        RecalculateWorkItemAssignment.recalculate(newCaseMap, oldCaseMap, isUpdate, isDelete);
        
        cpuTime = WorkItemAssignmentUtility.getCPUTime(Limits.getCPUTime());
        System.debug('RecalculateWorkItemAssignment.recalculate - CPUTime: ' + cpuTime);
        System.debug('Total CPUTime: ' + Limits.getCPUTime());
      }

        }
        
        //Diags.Info('CaseTriggerHandler - DMLStatements: ' + Limits.getDMLStatements());
		//Diags.Info('CaseTriggerHandler - LimitDMLStatements: ' + Limits.getLimitDMLStatements());
		//Diags.Info('CaseTriggerHandler - CPUTime: ' + Limits.getCPUTime());
		//Diags.Info('CaseTriggerHandler - LimitCPUTime: ' + Limits.getLimitCPUTime());
		//Diags.Info('CaseTriggerHandler - HeapSize: ' + Limits.getHeapSize());
		//Diags.Info('CaseTriggerHandler - LimitHeapSize: ' + Limits.getLimitHeapSize());
		//Diags.Info('CaseTriggerHandler - Queries: ' + Limits.getQueries());
		//Diags.Info('CaseTriggerHandler - LimitQueries: ' + Limits.getLimitQueries());
        Diags.Save();
        Diags.Clear();
     }
     catch(Exception e){
       System.debug('***Error in CaseTriggerHandler_DEV.handle(): ' + e.getMessage());
       Diags.SaveException(e);
       Diags.ClearAll();
       throw e;
     }
   }
}