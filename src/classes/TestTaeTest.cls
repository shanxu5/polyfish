@isTest
private class TestTaeTest
{
     static testMethod void test_field_set()
    {         
        //Tae_Test.test_string_contain(); 
        //List<CaseRecordTypeMap__c> caserecord_map = CaseRecordTypeMap__c.getAll();
		List<UserSkillRulesAndCaseMap__c> mcs = UserSkillRulesAndCaseMap__c.getAll().values();
        //Map<String_dataset_name, CaseRecordTypeMap__c> caserecord_map = CaseRecordTypeMap__c.getAll();
        //
        //select Id, Name, Work_Item_Type__c from User_Skill_Rule__c where Work_Item_Type__c in :'BSEG'
        List<User_Skill_Rule__c> rulesList = new List<User_Skill_Rule__c>();
       // rulesList = Database.query('select Id, Name, ' + queryFields + ' Recordtype.Name from User_Skill_Rule__c where Work_Item_Type__c IN: workItemTypes);
        //System.debug(logginglevel.INFO,'give me a list damit!!! ' + rulesList);
        //System.debug(logginglevel.INFO,'&&&&&&&&&&&& newWorkItem &&&...' + newWorkItem);
    }
    /*
    static testMethod void test_get_id_of_postpone_credit_field() {
        /*
        // Constructs the Tooling API wrapper (default constructor uses user session Id)
        ToolingAPI toolingAPI = new ToolingAPI();
               
        // Query CustomObject object by DeveloperName (note no __c suffix required)
        List<ToolingAPI.CustomObject> customObjects = (List<ToolingAPI.CustomObject>)
             toolingAPI.query('Select Id, DeveloperName, NamespacePrefix From CustomObject Where DeveloperName = \'\'').records;
         
        // Query CustomField object by TableEnumOrId (use CustomObject Id not name for Custom Objects)
        ToolingAPI.CustomObject customObject = customObjects[0];
        Id customObjectId = customObject.Id;
        List<ToolingAPI.CustomField> customFields = (List<ToolingAPI.CustomField>)
             toolingAPI.query('Select Id, DeveloperName, NamespacePrefix, TableEnumOrId From CustomField Where TableEnumOrId = \'' + customObjectId + '\'').records;
         
        // Dump field names (reapply the __c suffix) and their Id's
        System.debug(customObject.DeveloperName + '__c : ' + customObject.Id);
        for(ToolingAPI.CustomField customField : customFields)
             System.debug(
                  customObject.DeveloperName + '__c.' +
                  customField.DeveloperName + '__c : ' +
                  customField.Id);
        */
        /*
        Case newWorkItem = new Case();
        System.debug(logginglevel.INFO,'&&&&&&&&&&&& newWorkItem &&&...' + newWorkItem);
        System.debug(logginglevel.INFO,'&&&&&&&&&&&& workItmeObject &&&...' + Case.Postpone_Credit_Date__c.Id);
        
        
        Tae_Test.joe_test();
        
        //ToolingAPI toolingAPI = new ToolingAPI();
        //List<Case> workItemObject = (List<Case>)toolingAPI.query('Select Id, Postpone_Credit_Date__c from Case where Id = "{!User.Id}" ');
		//System.debug(logginglevel.INFO,'&&&&&&&&&&&& workItemObject &&&...' + workItemObject);
    }
    
    /*
    static testMethod void test_field_set()
    {         
        //Tae_Test.tae_test();        
   		String var = ' ';
        String tae = ' ';
    	UserSkillRulesAndCaseMap__c cs = new UserSkillRulesAndCaseMap__c();
        cs.Name  = 'first!';
        cs.Validation_Method__c  = 'validate something!';
        cs.Work_Item_Field_Name__c  = 'WHATEVER';
        insert cs;

    	UserSkillRulesAndCaseMap__c ap = new UserSkillRulesAndCaseMap__c();
        ap.Name  = 'second!';
        ap.Validation_Method__c  = 'yo ho! validate';
        ap.Work_Item_Field_Name__c  = 'yo ho work it';
        insert ap;
        
        Map<String, UserSkillRulesAndCaseMap__c> countries = UserSkillRulesAndCaseMap__c.getAll();
        // Sort them by name
        List<String> filenames = new List<String>();
        filenames.addAll(countries.keySet());
        filenames.sort();
        
        // Create the Select Options.
        for (String filename : filenames) {
            UserSkillRulesAndCaseMap__c country = countries.get(filename);
            //tions.add(new SelectOption(country.Validation_Method__c, country.Name));
            String var1 =  country.Name;
            System.debug(Logginglevel.info,'list of fields name -' + var1);
        }
         
        
        List<UserSkillRulesAndCaseMap__c> mcs = UserSkillRulesAndCaseMap__c.getAll().values();
        
        
        for (UserSkillRulesAndCaseMap__c m : mcs)
        {
            var += m.name + ' , ';
            System.debug(Logginglevel.info,'INSIDE LOOP%%%%%%%%%%%%%%%usrMaps' + mcs);      
        }
        
        // testing to break out the loop
        for(UserSkillRulesAndCaseMap__c a: mcs){
  			tae += a.name + ' , ';
            for(UserSkillRulesAndCaseMap__c v: mcs){
  				tae += v.name + ' , ';
                //continue;
            }
            System.debug(Logginglevel.info,'inside bottom loop should not print out' + tae);       
            
		}
		System.debug(Logginglevel.info,'only print out first iteration than break out' + tae);       
  
        System.debug(Logginglevel.info,'this is the string that prints outs' + var);       
      	Map<String, UserSkillRulesAndCaseMap__c> mco = UserSkillRulesAndCaseMap__c.getAll();
        System.debug(Logginglevel.info,'give me something OUTSIDE LOOP!!!%%%%%%%%%%%%%%%%%%%%usrMaps' + mco);       
    }
	*/
}  
        
    /*   
	 Tae_Test.tae_test();
       String a = '';
       String b = '';
       String c = '';
       String d = '';
       bOOLEAN e = true;
       String f = 'false';
       bOOLEAN ANSWER1 =  UserSkillRuleUtility.validateStringContains(a, b);
       bOOLEAN ANSWER2 =  UserSkillRuleUtility.validateEqualStrings(c,d);  
       bOOLEAN ANSWER3 =  UserSkillRuleUtility.validateBoolean(e,f);
       
        // no null blanks okay
        system.debug(Logginglevel.info,'**********TAE TEST RESULTS ValidateStringcontain: ' + ANSWER1 );
        system.debug(Logginglevel.info,'**********TAE TEST RESULTS Validatequalstring: ' + ANSWER2 );
        
        // first field must be boolean second can be null or blank and will work
        system.debug(Logginglevel.info,'**********TAE TEST RESULTS validate boolean: ' + ANSWER3 );
        ///--------------------------------------------------------------
        //validateEquals(Decimal decimalVal1, Decimal decimalVal2){
        //validateNotEqualTo(Decimal decimalVal1, Decimal decimalVal2){
		//validateLessThan(Decimal decimalVal1, Decimal decimalVal2){
        //validateGreaterThan(Decimal decimalVal1, Decimal decimalVal2){
        //validateLessOrEqual(Decimal decimalVal1, Decimal decimalVal2){
        //validateGreaterOrEqual(Decimal decimalVal1, Decimal decimalVal2){
        //validateBetween(Decimal decimalVal1, Decimal decimalVal2, Decimal decimalVal3){
        Decimal g = null;
        Decimal h = NULL;
        bOOLEAN ANSWER4 =  UserSkillRuleUtility.validateNotEqualTo(g,h);
         system.debug(Logginglevel.info,'**********TAE TEST RESULTS validate equals decimal: ' + ANSWER4 );
        
    } 

        /*************************************************************************
    * @author         Yefim Shuster and Janella Espiritu
    * @date           January, 2015
    * @description    This method tests Re-create of WI
    * @parameters     None
    * 
    * Modified by YXS7 on 02/18/2015 - new version is 1.1
    **************************************************************************/
    /*static testMethod void testReopenWorkItems() {
      Test.startTest();
         
        Work_Item_Assignment__c wia;
        Work_Item_Assignment__c wia2;
        
        //User skill rule records
        User_Skill_Rule__c  usr_BSEG_Interval;
        User_Skill_Rule__c  usr_PSSTL_Interval;
  
        
        //User Skill records
        User_Skill__c  userSkill1;
        User_Skill__c  userSkill2;

        Group testGroup;
        QueuesObject testQueue;
        // Query Queue
        Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        Id recordtypeId = [select Id from RecordType where Name='Billing Exceptions' and sObjectType = 'Case'].Id;
        Id closedRecordtypeId = [select Id from RecordType where Name='Closed Work Item - Billing Exceptions' and sObjectType = 'Case'].Id;
        
        // Modified by YXS7 on 02/18/2015 - commented out below and replaced - new version is 1.1
        //Id USRrecordtypeId = [select Id from RecordType where DeveloperName=: 'Billing_Operations_Exceptions' and sObjectType = 'User_Skill_Rule__c'].Id;
        Id USRrecordtypeId = [select Id from RecordType where DeveloperName='Billing_Operations_Exceptions' and sObjectType = 'User_Skill_Rule__c'].Id;
        
        //User to create test data
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,1); admin.Lan_ID__c = 'ADM1'; insert admin;
        
        // Query Profile and User Role
        Profile p = [select id from profile where name='CSR'];
        Profile p2 = [select id from profile where name='SSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        // Create Test User
        User testuser2= TestUtility.createUser(p2.id,r.id, 2); testuser2.Lan_ID__c = 'USR2'; insert testuser2;
        User testuser= TestUtility.createUser(p.id,r.id, 3); testuser.Lan_ID__c = 'USR3'; testuser.Supervisor__c = testuser2.Id; insert testuser;
        
        System.runAs(admin){  
            // Create Work Item Assignment record  
            wia = TestUtility.createWorkItemAssignment(testUser.Id, false); insert wia;  
            // Create User Skill Rule
            usr_BSEG_Interval = TestUtility.createUserSkillRule(1, 'BSEG' , '', 'True', '', '', '', '', '', 'less than', 70, '', ''); usr_BSEG_Interval.RecordtypeId = USRrecordtypeId; Insert usr_BSEG_Interval;
            usr_PSSTL_Interval = TestUtility.createUserSkillRule(2, 'PSSTL' , '', 'True', '', '', '', '', '', 'less than', 60, '', ''); usr_PSSTL_Interval.RecordtypeId = USRrecordtypeId; Insert usr_PSSTL_Interval;
            // Create User Skill
            userSkill1=TestUtility.createUserSkill(usr_BSEG_Interval.id,wia.id, wia); Insert userSkill1;
            userSkill2=TestUtility.createUserSkill(usr_PSSTL_Interval.id,wia.id, wia); Insert userSkill2;
            system.debug('******userSkill1'+userSkill1);
          // Create Account
            Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); insert acc;
            Account acc2 = TestUtility.createAccount(date.today() - 60, 'Account 2', '0007652387'); insert acc2;
            // Create Service Agreement
            Service_Agreement__c sa = TestUtility.createServiceAgreement(acc.Id); insert sa;
            // Create Premise
            Premise__c prem = TestUtility.createPremise(); insert prem;
            // Create Service Point
            Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
            // Create TurnOnAssignmentandGrouping__c
            TurnOnAssignmentandGrouping__c turnOnBSEG = TestUtility.createTurnOnAssignmentandGrouping('BSEG', true, true); insert turnOnBSEG;
            TurnOnAssignmentandGrouping__c turnOnPSSTL = TestUtility.createTurnOnAssignmentandGrouping('PSSTL', true, true); insert turnOnPSSTL;
            TurnOnAssignmentandGrouping__c turnOnRetroCommencing = TestUtility.createTurnOnAssignmentandGrouping('Retro Commencing', false, true); insert turnOnRetroCommencing;
            // Create Lookup Rollup Summary
            dlrs__LookupRollupSummary__c dlrs = TestUtility.createLookupRollupSummary(); insert dlrs;
            // Create Work Items
            List<Case> workItems = new List<Case>(); 
            
            // Date in 2 days
            //date d = date.today().addDays(Integer.valueOf(System.Label.SLA_Notification_Days)); // j1eu added for PCR 139854
            date d = date.today();
        
            // Group 1
            Case WorkItem1 = TestUtility.CreateWorkItem('40', 'QAS8', '', d - 60, '', '', acc.Id, sa.Id, true, prem.Id, sp.Id, queueId, recordtypeId);
            workItem1.OwnerId = testuser.Id;
            workItems.add(WorkItem1); //parent
            
            Case WorkItem2 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', d - 60, '', '', acc.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId);
            workItem2.OwnerId = testuser.Id;
            workItems.add(WorkItem2);
            
            Case WorkItem3 = TestUtility.CreateWorkItem('40', 'PSSTL', '', d - 60, '', '', acc.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId);
            workItem3.OwnerId = testuser.Id;
            workItems.add(WorkItem3);
            
            // Group 2
            Case WorkItem4 = TestUtility.CreateWorkItem('40', 'PSSTL', '', d - 60, '', '', acc2.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId);
            workItem4.OwnerId = testuser.Id;
            workItems.add(WorkItem4); 
            
            Case WorkItem5 = TestUtility.CreateWorkItem('40', 'BSEG', '', d - 60, '', '', acc2.Id, sa.Id, true, prem.Id, sp.Id, queueId, recordtypeId);
            workItem5.OwnerId = testuser.Id;
            workItems.add(WorkItem5); //parent
            
            Case WorkItem6 = TestUtility.CreateWorkItem('40', 'Retro Commencing', '', d - 60, '', '', acc2.Id, sa.Id, false, prem.Id, sp.Id, queueId, recordtypeId);
            workItem6.OwnerId = testuser.Id;
            workItems.add(WorkItem6);
            
            insert workItems;
            
            //WorkItem1 = [select SLA_Date__c, Event_Date__c from Case where Id =: WorkItem1.Id];
            //system.assertEquals(date.today().addDays(Integer.valueOf(System.Label.SLA_Notification_Days)), WorkItem1.SLA_Date__c);
            
            for (Case wi : workItems) {
                wi.Customer_Contact_Class__c = 'Records Dept Note';
                wi.Customer_Contact_Type__c = 'RECORDS';
                wi.As_Billed_Amount__c = 123;
                wi.As_Corrected_Amount__c = 123;
                wi.Billed_To_Amount__c = 123;
                wi.As_Billed_Corrected_From__c = date.today();
                wi.As_Billed_Corrected_To__c = date.today();
                wi.Billed_From_Date__c = date.today();
                wi.Billed_To_Date__c = date.today();
                wi.Root_Cause__c = 'Other';
                wi.Root_Cause_Other__c = 'Root Cause Other';
                wi.Additional_Customer_Contact_Comments__c = 'Additional Comments';
                wi.OwnerId = testuser.Id;
                wi.QAS8_Date__c = date.today();
                wi.Status = 'Completed';
                wi.Sub_Status__c = 'Completed by Assigned User';
                wi.Add_l_pending_start_stops_at_premise__c = true;
                wi.Clear_related_ToDos_for_Acct_Premise__c = true;
                wi.Is_the_account_billed_current__c = true;
                wi.Is_the_other_commodity_active__c = true;
                wi.Root_Cause__c ='CIF';
                wi.Root_Cause_Other__c = null;
                wi.Postpone_Credit_if_applicable__c = 'Yes';
                wi.Postpone_Credit_Date__c = date.today() + 10;
                wi.RecordTypeId = closedRecordtypeId;
            }          
            update workItems;      
            workItem1.Reopened__c = true;
            update workItem1; // will call case trigger to run the case trigger handler            
            Test.stopTest();
        }
    } 
}
*/

/*
    		c.Sub_Status__c = null; YES
            c.Pending_Other_Reason__c = null; YES
            c.Net_Variance_Approval_Status__c = null; YES
            c.Create_Customer_Contact_in_CC_B__c = false;YES
            c.Customer_Contact_Class__c = '';SET TO NULL?
            c.Customer_Contact_Type__c = '';SET TO NULL?
            c.As_Billed_Corrected_From__c = null; YES
            c.As_Billed_Corrected_To__c = null; YES
            c.As_Billed_Amount__c = null; YES
            c.Billed_To_Amount__c = null;YES
            c.Billed_To_Date__c = null; YES
            c.Billed_From_Date__c = null;YES
            c.As_Billed_Amount__c = null;// DUPLICATE
            c.As_Corrected_Amount__c = null;YES
            c.Postpone_Credit_Date__c = null;YES
            c.Postpone_Credit_if_applicable__c = null;YES
            c.Root_Cause__c = null;YES
            c.Root_Cause_Other__c = null;YES
            c.Clear_related_ToDos_for_Acct_Premise__c = false;YES
            c.Bill_in_compliance_with_Rule_17__c = false;YES
            c.If_start_cancelled_was_CC_created__c = false;YES
            c.Is_the_account_billed_current__c = false;YES
            c.Add_l_pending_start_stops_at_premise__c = false;YES
            c.Is_the_other_commodity_active__c = false;YES
            c.Customer_Contact_Comments__c = null;
            c.Additional_Customer_Contact_Comments__c = null;
*/