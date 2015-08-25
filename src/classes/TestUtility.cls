/**********************************************************************************************
* @author       Slalom Consulting - Swetha Tonupunuri
* @date         26.August.2014
* @description  Utility Class for Test Classes
* 
* @version      1.1
*
* @revision(s)  Janella Espiritu - Sprint 2 Update
*               Modified by YXS7 on 2015-06-01 - added createBillCycleWindowForBillCycle() - new version is 1.1 
**********************************************************************************************/
@isTest 
public with sharing class TestUtility {
    
    //create static set than check to make sure it's already set
    private static List<UserSkillRulesAndCaseMap__c> userSkillCustomSetting = new List<UserSkillRulesAndCaseMap__c>();
    private static Boolean userSkillCustomSetting_cached = false;
        
    
    // Create Test User record
    public static User createUser(Id profileId, Id roleId, Integer num){
        string randomName = string.valueof(Datetime.now()).replace('-','').replace(':','').replace(' ','');
        User u = new User();
        u.ProfileId = profileId;
        u.FirstName = 'Test Admin';
        u.LastName = 'Admin';
        u.Alias = 'alias';
        u.Email = 'testadmin@email.com';
        u.Username = 'testadmin@email.com'+randomName+num;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey='UTF-8';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.UserRoleId = roleId;
        return u;
    }
    // Create Test Account record
    public static Account createAccount(date lastBillDate, string accName, string accId){
        Account a = new Account();
        a.Name = accName;   
        a.ACCT_ID__c = accId;
        a.BillingStreet = 'PO BOX 1619';
        a.BillingCity = 'SAUSALITO';
        a.BillingState = 'CA';
        a.BillingPostalCode = '94966';
        a.BillingCountry = 'USA';
        a.Entity_Name__c = 'KOONS,TODD L';
        a.BusinessPhone__c = '(999) 622-5901';
        a.MobilePhone__c = '(999) 622-5902';
        a.Cust_Cl_Cd__c = 'COM/IND';
        a.Bill_Cyc_Cd__c = 'R';
        a.Last_Bill_Date__c = lastBillDate;
        return a;
    }
    // Create Test Service Agreement record
    public static Service_Agreement__c createServiceAgreement(Id accountId){
        Service_Agreement__c sa = new Service_Agreement__c();
        sa.SFDC_Acct_Id__c = accountId;
        sa.Name = '5908035579';
        sa.SA_Status__c = 'Active';
        sa.Start_Dt__c = date.newInstance(2011, 12, 29);
        sa.SA_ID__c = '5908035579';
        sa.SA_Type_CD__c = 'HE-AG';
        sa.SA_Type_Descr__c = 'SM E Agricultural';
        sa.Rate_Schedule__c = 'HAG5C';
        sa.Commodity__c = 'E';
        sa.Last_BSEG_End_Dt__c = date.newInstance(2014, 5, 15);
        sa.SPR_Descr__c = 'PG&E, ESP, Bundled Service';
        sa.SPR_CD__c = 'PGE-FS';
        return sa;
    }
    // Create Test Service Agreement record
    public static Service_Agreement__c createServiceAgreementwithSAType(Id accountId, String SAType, String SAID){
        Service_Agreement__c sa = new Service_Agreement__c();
        sa.SFDC_Acct_Id__c = accountId;
        sa.Name = SAID;
        sa.SA_Status__c = 'Active';
        sa.Start_Dt__c = date.newInstance(2011, 12, 29);
        sa.SA_ID__c = SAID;
        sa.SA_Type_CD__c = SAType;
        sa.SA_Type_Descr__c = 'SM E Agricultural';
        sa.Rate_Schedule__c = 'HAG5C';
        sa.Commodity__c = 'E';
        sa.Last_BSEG_End_Dt__c = date.newInstance(2014, 5, 15);
        sa.SPR_Descr__c = 'PG&E, ESP, Bundled Service';
        sa.SPR_CD__c = 'PGE-FS';
        return sa;
    }
    // Create Test Service Point record
    public static Service_Point__c createServicePoint(Id premiseId){
        Service_Point__c sp = new Service_Point__c();
        sp.Name = '7705725181';
        sp.SP_Type_Cd__c = 'EMA-3PTR';
        sp.SP_ID__c = '7705725181';
        sp.SP_Status_Flg__c = 'R';
        sp.Service_Point_Type_Descr__c = 'Ele-Mtr-Agr-3P-Transformerated';
        sp.SMSPST__c = '40';
        sp.SMSPST_Descr__c = 'SM- Billed';
        sp.SP_Src_Status__c = 'C - Connected';
        sp.SMSPST_EffDt__c = date.newInstance(2011, 12, 29);
        sp.Prem_ID__c = premiseId;
        sp.Op_Area_Cd__c = 'TX';
        sp.Op_Area_Descr__c = 'Wasco';
        sp.Mr_Cyc_Cd__c = 'W';
        sp.Mr_Rte_Cd__c = 'WTX82SM';
        sp.Mtr_Config_Ty_Cd__c = 'SM-15-SIMPLE';
        return sp;
    }
    
    // Create Test SA_SP record
    // Modified by yxs7 on 2014-11-13 - externalId is String, not Id
    public static SA_SP__c createSASP(String externalId, Id serviceAgreement, Id servicePoint){
        SA_SP__c sasp = new SA_SP__c();
        sasp.SA_SP_ID__c = externalId;
        sasp.SFDC_SA_ID__c = serviceAgreement;
        sasp.SFDC_SP_ID__c = servicePoint;
        return sasp;
    }
    // Create Test Premise record
    public static Premise__c createPremise(){
        Premise__c p = new Premise__c();
        p.Prem_Id__c = '0013026269';
        p.Name = '0013026269';
        p.City__c = 'FREMONT';
        p.Zip__c = '94539';
        p.State__c = 'CA';
        p.Address__c = '12750 CALAVERAS RD';
        return p;
    }
    // Create Test Work Item Assignment record
    public static Work_Item_Assignment__c createWorkItemAssignment(Id userId, Boolean availability){
        Work_Item_Assignment__c wia = new Work_Item_Assignment__c();
        wia.Availability__c = availability;
        wia.Limit__c = 1;
        wia.WI_Assigned__c = 0;
        wia.User__c = userId;
        return wia;
    }
    // Create Test User Skill Rule record
    public static User_Skill_Rule__c createUserSkillRule(Integer sortOrder, 
                                                         String workItemType, 
                                                         String metered, 
                                                         String interval,
                                                         String saType,
                                                         String daCCA,
                                                         String msgCategory,
                                                         String msgNumber,
                                                         String maxBilling,
                                                         String DaysLateEvaluator,
                                                         Decimal AgeBucket,
                                                         String CommencingBill,
                                                         String SAStatus,
                                                         ID Classc
                                                        ){
        User_Skill_Rule__c usr = new User_Skill_Rule__c();
        usr.Sort_Order__c = sortOrder;
        usr.Name = 'Rule: '+sortOrder;
        usr.Description__c = 'Test Description ' + sortOrder;
        usr.Work_Item_Type__c = workItemType;
        usr.Metered__c = metered;
        usr.Interval__c = interval;
        usr.SA_Type__c = saType;
        usr.DA_CCA_Indicator__c = daCCA;
        usr.Message_Category__c = msgCategory;
        usr.Message_Number__c = msgNumber;
        usr.Max_Billing_Threshold_MBT__c = maxBilling;
        usr.Days_Late_Age_Evaluator__c = DaysLateEvaluator;
        usr.Age_Bucket_Start__c = AgeBucket;
        usr.Commencing_Bill__c = CommencingBill;
        usr.SA_Status__c = SAStatus;
        usr.Class__c = Classc;
        
		populatecustomuserskill(); 	//mxyq 7/29/15 separating create USR and USR custom setting
        return usr;
    }
    
    // Modified by yxs7 on 2014-11-13 - changed wi.SA_Status__c = saStatus
    // Create Test Work Item record
    public static Case CreateWorkItem(String smSpStatus,
                                      String workItemType,
                                      String saStatus,
                                      Date eventDate,
                                      String msgNumber,
                                      String msgCategoryNumber,
                                      Id accountId,
                                      Id serviceAgreementId,
                                      Boolean DACCAIndicator,
                                      Id premiseId,
                                      Id servicePointId,
                                      Id ownerId,
                                      Id recordTypeId
                                      ){
        Case wi=new Case();
        wi.Status = 'Unassigned';
        wi.Work_Item_Type__c = workItemType;    
        wi.Create_Customer_Contact_in_CC_B__c = true;
        wi.AccountId = accountId;
        wi.SFDC_SA_ID__c = serviceAgreementId;
        wi.SA_Status__c = saStatus;
        wi.Bill_Cycle__c = 'A'; 
        wi.Rate_Schedule__c = 'G1';
        wi.SMSPST_EffDt__c = date.newInstance(2008, 09, 16);
        wi.SMSPST__c = smSpStatus;
        wi.SmartMeter_SP_Status_Description__c = 'SM- Read'; 
        wi.DA_CCA_IND__c = DACCAIndicator;
        wi.SFDC_Prem_ID__c = premiseId; 
        wi.SFDC_SP_ID__c = servicePointId; 
        wi.Local_Office__c = 'Sacramen'; 
        wi.Meter_Read_Cycle__c = 'N';
        wi.Mtr_Config_Ty_Cd__c = 'SM-1440-CCFG';
        wi.Event_Date__c = eventDate;
        wi.Message_Number__c = msgNumber;
        wi.Message_Category_Number__c = msgCategoryNumber;
        wi.OwnerId = ownerId;
        wi.RecordTypeId = recordtypeId;
        return wi;
    } 
    // Create Test User Skill record
    public Static User_Skill__c createUserSkill (Id UserSkillRuleID, Id WorkItemAssignmentID, Work_Item_Assignment__c wia){
        User_Skill__c us= new User_Skill__c();
        us.User_Skill_Rule__c=UserSkillRuleID;
        us.Work_Item_Assignment__c = WorkItemAssignmentID;
        us.Work_Item_Assignment__r = wia;
        return us;    
    }   
    // Create Test TurnOnAssignmentAndGrouping custom setting record
    public Static TurnOnAssignmentandGrouping__c createTurnOnAssignmentandGrouping (String workItemType, Boolean assignmentEnabled, Boolean groupingEnabled){
        TurnOnAssignmentandGrouping__c toag= new TurnOnAssignmentandGrouping__c();
        toag.Name = workItemType;
        toag.AssignmentEnabled__c = assignmentEnabled;
        toag.GroupingEnabled__c = groupingEnabled;
        return toag; 
    }
    // Create Test Lookup Rollup Summary record
    public static dlrs__LookupRollupSummary__c createLookupRollupSummary(){
        dlrs__LookupRollupSummary__c dlrs = new dlrs__LookupRollupSummary__c();
        dlrs.Name = 'WIAssigned';
        dlrs.dlrs__ParentObject__c = 'Work_Item_Assignment__c';
        dlrs.dlrs__ChildObject__c = 'Case';
        dlrs.dlrs__RelationshipField__c = 'Work_Item_Assignment__c';
        dlrs.dlrs__RelationshipCriteria__c = '(Status = \'Assigned\' OR Status = \'Being worked on\')';
        dlrs.dlrs__RelationshipCriteriaFields__c = 'Status';
        dlrs.dlrs__FieldToAggregate__c = 'CreatedDate';
        dlrs.dlrs__AggregateResultField__c = 'WI_Assigned__c';
        dlrs.dlrs__AggregateOperation__c = 'Count';
        dlrs.dlrs__Active__c = true;
        dlrs.dlrs__CalculationMode__c = 'Realtime';
        return dlrs;
    }
    // Create Test Bill Cycle Window record
    public static Bill_Cycle_Window__c createBillCycleWindow(){
        Bill_Cycle_Window__c bcw = new Bill_Cycle_Window__c();
        bcw.Primary_Bill_Cycle__c = 'A';
        bcw.Window_Start_Date__c = date.today();
        bcw.Window_Close_Date__c = date.today() + 5;
        return bcw;
    }
    // Create Customer Contact Related Records
    public static Related_Records__c createCustomerContact(Id workItemId){
        Id ccRecordTypeId = Schema.SObjectType.Related_Records__c.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
        Related_Records__c rr = new Related_Records__c();
        rr.RecordTypeId = ccRecordTypeId;
        rr.Customer_Contact_Class__c = 'Records Dept Note';
        rr.Customer_Contact_Type__c = 'RECORDS';
        rr.Comments__c = 'Comments';
        rr.Completion_Comments__c = 'Completion Comments';
        rr.SFDC_Work_Item__c = workItemId;
        return rr;
    }
    // Create Customer Contact Class Custom Setting
    public static CustomerContactClass__c createCustContClassCustSetting(String name, String code){
        CustomerContactClass__c cc = new CustomerContactClass__c();
        cc.Name = name;
        cc.Code__c = code;
        return cc;
    }
    //Create Customer Contact Type Custom Setting
    public static CustomerContactType__c createCustContTypeCustSetting(String name, String code, boolean accid, boolean said, boolean premid){
        CustomerContactType__c cc = new CustomerContactType__c();
        cc.Name = name;
        cc.Code__c = code;
        cc.ACCT_ID__c = accid;
        cc.SA_ID__c = said;
        cc.PREM_ID__c = premid;
        return cc;
    }

    //Tae - R2S1 - create the custom fields for testing purpose for custom settings
    //Create User skill custom setting to use for testing 
    public static UserSkillRulesAndCaseMap__c userSkillcustomsetting(String name, String vaildation, String wifn, String usrfieldtyp, String  wifieldtyp){
        UserSkillRulesAndCaseMap__c cs1 = new UserSkillRulesAndCaseMap__c();
        cs1.Name  = name;
        cs1.Validation_Method__c = vaildation;
        cs1.Work_Item_Field_Name__c  = wifn;
        cs1.USR_Field_Type__c = usrfieldtyp;
        cs1.WI_Field_Type__c = wifieldtyp;
        return cs1;           
    }
    
    //Tae - R2S1 - create the custom fields for testing purpose for custom settings
    public static void populatecustomuserskill ()
    {
		if (!userSkillCustomSetting_cached)
        {
            // Name(USR Field Name), Validation_Method, Work_Item_Field_Name, USR_Field_Type, WI_Field_Type
            UserSkillRulesAndCaseMap__c cs1 = userSkillcustomsetting('Age_Bucket_End__c', '', '', 'Decimal', '');
            userSkillCustomSetting.add(cs1);
            
            UserSkillRulesAndCaseMap__c cs2 = userSkillcustomsetting('Age_Bucket_Start__c', '', 'Age__c', 'Decimal', 'Decimal');
            userSkillCustomSetting.add(cs2);
            
			UserSkillRulesAndCaseMap__c cs3 = userSkillcustomsetting('Commencing_Bill__c', 'validateBoolean', 'Commencing_Bill__c', 'String', 'Boolean');
            userSkillCustomSetting.add(cs3);
            
            UserSkillRulesAndCaseMap__c cs4 = userSkillcustomsetting('Days_Late_Age_Evaluator__c', '', '', 'Decimal', '');
            userSkillCustomSetting.add(cs4);
            
            UserSkillRulesAndCaseMap__c cs5 = userSkillcustomsetting('DA_CCA_Indicator__c', 'validateBoolean', 'DA_CCA_IND__c', 'String', 'Boolean');
            userSkillCustomSetting.add(cs5);

            UserSkillRulesAndCaseMap__c cs6 = userSkillcustomsetting('Interval__c', 'validateBoolean', 'Interval__c', 'String', 'Boolean');
            userSkillCustomSetting.add(cs6);
            
            UserSkillRulesAndCaseMap__c cs7 = userSkillcustomsetting('Max_Billing_Threshold_MBT__c', 'validateBoolean', 'Max_Billing_Threshold_MBT__c', 'String', 'Boolean');
            userSkillCustomSetting.add(cs7);
            
            UserSkillRulesAndCaseMap__c cs8 = userSkillcustomsetting('Message_Category__c', 'validateEqualStrings', 'Message_Category_Number__c', 'String', 'String');
            userSkillCustomSetting.add(cs8);
            
            UserSkillRulesAndCaseMap__c cs9 = userSkillcustomsetting('Message_Number__c', 'validateEqualStrings', 'Message_Number__c', 'String', 'String');
            userSkillCustomSetting.add(cs9);
    
			UserSkillRulesAndCaseMap__c cs10 = userSkillcustomsetting('Metered__c', 'validateBoolean', 'Metered__c', 'String', 'Boolean');
			userSkillCustomSetting.add(cs10);
            
			UserSkillRulesAndCaseMap__c cs11 = userSkillcustomsetting('SA_Status__c', 'validateStringContains', 'SA_Status__c', 'String', 'String');
            userSkillCustomSetting.add(cs11);
			
            UserSkillRulesAndCaseMap__c cs12 = userSkillcustomsetting('SA_Type__c', 'validateStringContains', 'SA_Type__c', 'String', 'String');
            userSkillCustomSetting.add(cs12);
            
            UserSkillRulesAndCaseMap__c cs13 = userSkillcustomsetting('SMSPST__c', 'validateStringContains', 'SMSPST__c', 'String', 'String');
            userSkillCustomSetting.add(cs13);
            
            UserSkillRulesAndCaseMap__c cs14 = userSkillcustomsetting('Work_Item_Type__c', 'validateStringContains', 'Work_Item_Type__c', 'String', 'String');
			userSkillCustomSetting.add(cs14);

            UserSkillRulesAndCaseMap__c cs15 = userSkillcustomsetting('Medical_Allotment__c', '', 'Medical_Allotment__c', 'Double', 'Double');
            userSkillCustomSetting.add(cs15);
                   
            UserSkillRulesAndCaseMap__c cs16 = userSkillcustomsetting('Medical_Allotment_Evaluator__c', '', 'Medical_Allotment_Evaluator__c', 'String', 'String');
            userSkillCustomSetting.add(cs16);

            insert userSkillCustomSetting;
            userSkillCustomSetting_cached = true;

        }	     
    	
    }
    
    //mxyq R2S1 - create Grouping Rules record
    public static Grouping_Rules__c populateGroupingRules(double sequence, String ruleName, String groupingType, Id controllingClass, String groupBy){
        Grouping_Rules__c gr = new Grouping_Rules__c();
        gr.Sequence__c = sequence;
        gr.Name = ruleName;
        gr.Grouping_Type__c = groupingType;
        gr.Controlling_Class__c = controllingClass;
        gr.Group_By_API_Name__c = groupBy;
        
        return gr;
    }
    
    //mxyq R2S1 - create Grouping Class record
    public static Grouping_Class__c populateGroupingClass(String groupingClassName){
        Grouping_Class__c gc = new Grouping_Class__c();
        gc.Name = groupingClassName;
        return gc;
        
    }
    
    //mxyq R2S1 - create Related Class records
    public static Related_Class__c relatedClass(Id groupingClassId, Id groupingRuleId){
        Related_Class__c rc = new Related_Class__c();
        rc.Grouping_Class__c = groupingClassId;
        rc.Grouping_Rule__c = groupingRuleId;
        
        return rc;
    }
    
    //mxyq R2S1 -  create Custom Setting Grouping Type
    public static GroupingTypes__c createGroupingTypes(String groupingTypeName, String APEXClass){
        GroupingTypes__c gt = new GroupingTypes__c();
        gt.Name = groupingTypeName;
        gt.APEXClass__c = APEXClass;
        return gt;
    }
    
    // j1eu R2S1 - create Custom Setting Required Fields on Close WI Page
	public static Work_Item_Required_Fields__c createWorkItemRequiredFields(String workitemtype){
        Work_Item_Required_Fields__c rf = new Work_Item_Required_Fields__c();
		rf.Name = workitemtype;
        rf.Add_account_D_C_number__c = true;
		rf.Add_Person_ID__c = true;
		rf.Add_RA_Acct_SA_ID_in_RAP__c = true;
		rf.Advised_Customer_Approval_or_Denial__c = true;
		rf.Alerts_added_to_CC_B__c = true;
		rf.Bill_completed_in_CC_B__c = true;
		rf.Bill_in_compliance_with_Rule_17__c = true;
		rf.Check_SM_Status__c = true;
		rf.Clear_related_ToDos_for_Acct_Premise__c = true;
		rf.Comment_Code_Added__c = true;
		rf.Completed_letter__c = true;
		rf.Cust_Follow_up_Required__c = true;
		rf.Did_you_clear_MDMS_Flags__c = true;
		rf.Did_you_increase_Threshold__c = true;
		rf.Drive_Rate_Added__c = true;
		rf.If_start_cancelled_was_CC_created__c = true;
		rf.Interval_SA_set_up__c = true;
		rf.IsActive__c = true;
		rf.Is_the_account_billed_current__c = true;
		rf.Is_the_other_commodity_active__c = true;
		rf.New_Active_SA__c = true;
		rf.Opt_Out_Customer_Stop_Date_in_the_Past__c = true;
		rf.Postpone_Credit__c = true;
		//rf.Removed_SM_designation_from_MR_route__c = true;
		//rf.Remove_Wanted_SM_Chars__c = true;
		rf.Send_RAP_bill__c = true;
		rf.SP_characteristics_updated__c = true;
		rf.Updated_Premise_characteristics__c = true;
		rf.Updated_SP_characteristics__c = true;
		rf.Update_RAP_notes__c = true;
		rf.Verified_no_SMOO_Delay_Billing_Fee_char__c = true;
		rf.Verify_total_billed_same_for_RAP_CC_B__c = true;
		return rf;
    }
    
    // Create Test Bill Cycle Window record
    public static Bill_Cycle_Window__c createBillCycleWindowForBillCycle(String primary_bill_cycle, Date start_date, Date end_date, Id recordTypeId){
        Bill_Cycle_Window__c bcw = new Bill_Cycle_Window__c();
        bcw.RecordTypeId = recordTypeId;
        bcw.Primary_Bill_Cycle__c = primary_bill_cycle;
        bcw.Window_Start_Date__c = start_date;
        bcw.Window_Close_Date__c = end_date;
        return bcw;
    }
    
    // Create Test Shift Time record
    public static Shift_Time_Change__c createShiftTimeChangeRecord(Id wia, Date from_date, Date to_Date, Id businessHour){
        Shift_Time_Change__c stc = new Shift_Time_Change__c();
        stc.Work_Item_Assignment__c = wia;
        stc.From_Date__c = from_date;
        stc.To_Date__c = to_date;
        stc.Business_Hours__c = businessHour;
        return stc;
    }
      
}