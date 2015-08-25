/*
    @Company        Slalom Consulting
    @Author         Swetha Tonupunuri
    @Date           26.August.2014
    @Description    Test Class for the UserSkillSelectionExtension
    @Revision(s)    Janella Espiritu - Sprint 3 Update
*/
@
isTest(seealldata=true)
private class UserSkillSelectionExtensionTest {
    static testMethod void testUserskillSelection(){
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        
        Work_Item_Assignment__c wia = new Work_Item_Assignment__c(user__r=thisUser ,WI_Assigned__c=10,Limit__c=20 );
        insert wia;  
        
        test.starttest();
        PageReference pageRef = Page.UserSkillsSelection;
        Test.setCurrentPage(pageRef);  
          
        ApexPages.StandardController sc= new ApexPages.StandardController(wia);
        UserSkillSelectionExtension usse= new UserSkillSelectionExtension(sc);
        //List<SelectOption> so1 = usse.workItemTypesSelection;
        List<SelectOption> so2 = usse.grpClassSelection;
        List<SelectOption> so3 = usse.recordTypesSelection;
        
        // Filter DA CCA
        
        List<User_Skill_Rule__c> usrList = [Select id from User_Skill_Rule__c] ;
        
        String insertIds = usrList[0].id+','+usrList[1].id+','+usrList[2].id;
        String deleteIds = ',';
        ApexPages.currentPage().getParameters().put('FilterInsertRecordsStr',insertIds  );
        ApexPages.currentPage().getParameters().put('DeletedPredefinedSkillsStr', deleteIds );
        usse.save();
        
        insertIds = usrList[3].id+','+usrList[4].id+','+usrList[5].id;
        deleteIds = usrList[0].id+','+usrList[1].id;
        ApexPages.currentPage().getParameters().put('FilterInsertRecordsStr',insertIds  );
        ApexPages.currentPage().getParameters().put('DeletedPredefinedSkillsStr', deleteIds );
        List<RecordType> rec = [Select id,Name from recordtype where sobjecttype = 'User_Skill_Rule__c'];
        usse.selectedFilter='DA CCA';
        usse.selectedwit='Mailbox';
        //usse.selectedGrpClass = gc.id;
        usse.populatePageHelperList();
        // Select Mailbox
        usse.selectedwit='Mailbox';
        usse.selectedFilter='';
        usse.populatePageHelperList();
        // Select BSEG Interval
        usse.selectedwit='BSEG';
        usse.selectedFilter = 'Interval';
        usse.satypeEntered = null;
        //usse.pageHelperList[1].selected = true;
        usse.populatePageHelperList();
        usse.satypeEntered = 'E';
        usse.populatePageHelperList();
        
        usse.selectedRctype = rec[0].id;
        usse.populatePageHelperList();
        usse.cancel();
        test.stoptest();
        
    }

/*
    static testMethod void testUserskillSelection() {
        List < UserSkillRulesAndCaseMap__c > usrList = new List < UserSkillRulesAndCaseMap__c > ();

        UserSkillRulesAndCaseMap__c cs = TestUtility.userSkillCustomSetting('SA_Type__c', 'validateStringContains', 'SA_Type__c', 'String', 'String');
        usrList.add(cs);

        cs = TestUtility.userSkillCustomSetting('Age_Bucket_Start__c', null, 'Age__c', 'Decimal', 'Decimal');
        usrList.add(cs);

        cs = TestUtility.userSkillCustomSetting('Age_Bucket_End__c', null, null, 'Decimal', 'Decimal');
        usrList.add(cs);

        cs = TestUtility.userSkillCustomSetting('Commencing_Bill__c', 'validateBoolean', 'Commencing_Bill__c', 'String', 'Boolean');
        usrList.add(cs);

        cs = TestUtility.userSkillCustomSetting('Days_Late_Age_Evaluator__c', null, null, 'Decimal', null);
        usrList.add(cs);

        cs = TestUtility.userSkillCustomSetting('DA_CCA_Indicator__c', 'validateBoolean', 'DA_CCA_IND__c', 'String', 'Boolean');
        usrList.add(cs);

        cs = TestUtility.userSkillCustomSetting('Interval__c', 'validateBoolean', 'Interval__c', 'String', 'Boolean');
        usrList.add(cs);

        cs = TestUtility.userSkillCustomSetting('Max_Billing_Threshold_MBT__c', 'validateBoolean', 'Max_Billing_Threshold_MBT__c', 'String', 'Boolean');
        usrList.add(cs);

        cs = TestUtility.userSkillCustomSetting('Message_Category__c', 'validateEqualStrings', 'Message_Category__c', 'String', 'String');
        usrList.add(cs);

        cs = TestUtility.userSkillCustomSetting('Message_Number__c', 'validateEqualStrings', 'Message_Number__c', 'String', 'String');
        usrList.add(cs);

        cs = TestUtility.userSkillCustomSetting('Metered__c', 'validateBoolean', 'Metered__c', 'String', 'Boolean');
        usrList.add(cs);

        cs = TestUtility.userSkillCustomSetting('Multi_Family__c', 'validateBoolean', 'Multi_Family__c', 'String', 'Boolean');
        usrList.add(cs);

        cs = TestUtility.userSkillCustomSetting('SA_Status__c', 'validateStringContains', 'SA_Status__c', 'String', 'String');
        usrList.add(cs);

        cs = TestUtility.userSkillCustomSetting('SMSPST__c', 'validateStringContains', 'SMSPST__c', 'String', 'String');
        usrList.add(cs);

        cs = TestUtility.userSkillCustomSetting('Work_Item_Type__c', 'validateStringContains', 'Work_Item_Type__c', 'String', 'String');
        usrList.add(cs);

        insert usrList;
        
        user CSR;
        Grouping_Class__c gc = new Grouping_Class__c (Name= 'Interval') ;
        insert gc;
        Work_Item_Assignment__c wia;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        
        Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
    
        
        wia= new Work_Item_Assignment__c(user__r=thisUser ,WI_Assigned__c=10,Limit__c=20 );
        insert wia;  
        
        test.starttest();
        PageReference pageRef = Page.UserSkillsSelection;
        Test.setCurrentPage(pageRef);  
          
        ApexPages.StandardController sc= new ApexPages.StandardController(wia);
        UserSkillSelectionExtension usse= new UserSkillSelectionExtension(sc);
        List<SelectOption> so1 = usse.workItemTypesSelection;
        List<SelectOption> so2 = usse.grpClassSelection;
        List<SelectOption> so3 = usse.recordTypesSelection;
        
        // Filter DA CCA
        
               
        String insertIds = usrList[0].id+','+usrList[1].id+','+usrList[2].id;
        String deleteIds = ',';
        ApexPages.currentPage().getParameters().put('FilterInsertRecordsStr',insertIds  );
        ApexPages.currentPage().getParameters().put('DeletedPredefinedSkillsStr', deleteIds );
        usse.save();
        
        insertIds = usrList[3].id+','+usrList[4].id+','+usrList[5].id;
        deleteIds = usrList[0].id+','+usrList[1].id;
        ApexPages.currentPage().getParameters().put('FilterInsertRecordsStr',insertIds  );
        ApexPages.currentPage().getParameters().put('DeletedPredefinedSkillsStr', deleteIds );
        List<RecordType> rec = [Select id,Name from recordtype where sobjecttype = 'User_Skill_Rule__c'];
        usse.selectedFilter='DA CCA';
        usse.selectedwit='Mailbox';
        usse.selectedGrpClass = gc.id;
        usse.populatePageHelperList();
        // Select Mailbox
        usse.selectedwit='Mailbox';
        usse.selectedFilter='';
        usse.populatePageHelperList();
        // Select BSEG Interval
        usse.selectedwit='BSEG';
        usse.selectedFilter = 'Interval';
        usse.satypeEntered = null;
        //usse.pageHelperList[1].selected = true;
        usse.populatePageHelperList();
        usse.satypeEntered = 'E';
        usse.populatePageHelperList();
        
        usse.selectedRctype = rec[0].id;
        usse.populatePageHelperList();
        test.stoptest();
    

    }
    */
    
}