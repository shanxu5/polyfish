@isTest
public class TestUserSkillRuleUtility {
	static testMethod void testUserskillRuleUtility() {
        Profile p = [select id from profile where name='CSR'];
        UserRole r = [Select id from userrole where name='CSR'];
        Profile padmin = [select id from profile where name='Administrator'];
        UserRole rbillops = [Select id from userrole where name='Billing Operations'];
        User admin= TestUtility.createUser(padmin.id,rbillops.id,2); admin.LAN_ID__C = 'ADM1'; //insert admin;
        System.runAs(admin){
            User CSR= TestUtility.createUser(p.id,r.id,1); CSR.LAN_ID__C = 'CSR1'; insert CSR;
        	// Validate Equal Strings
            System.assert(UserSkillRuleUtility.validateEqualStrings('equals', 'equals'));
            System.assertEquals(false, UserSkillRuleUtility.validateEqualStrings('false', 'equals'));
            // Validate Boolean
            System.assert(UserSkillRuleUtility.validateBoolean(true, 'True'));
            System.assert(UserSkillRuleUtility.validateBoolean(false, 'False'));
            System.assertEquals(false, UserSkillRuleUtility.validateBoolean(false, 'True'));
            // Validate String Contains
            System.assert(UserSkillRuleUtility.validateStringContains('T', 'True'));
            System.assertEquals(false, UserSkillRuleUtility.validateStringContains('F', 'True'));
            //Validate Equal Decimals
            System.assert(UserSkillRuleUtility.validateEquals(1, 1));
            System.assertEquals(false, UserSkillRuleUtility.validateEquals(1, 2));
            //Validate Not Equal Decimals
            System.assert(UserSkillRuleUtility.validateNotEqualTo(1, 2));
            System.assertEquals(false, UserSkillRuleUtility.validateNotEqualTo(1, 1));
            //Validate Less Than Decimals
            System.assert(UserSkillRuleUtility.validateLessThan(2, 1));
            System.assertEquals(false, UserSkillRuleUtility.validateLessThan(1, 1));
            //Validate Greater Than Decimals
            System.assert(UserSkillRuleUtility.validateGreaterThan(1, 2));
            System.assertEquals(false, UserSkillRuleUtility.validateGreaterThan(1, 1));
            //Validate Less or Equal Decimals
            System.assert(UserSkillRuleUtility.validateLessOrEqual(2, 1));
            System.assertEquals(false, UserSkillRuleUtility.validateLessOrEqual(1, 2));
            //Validate Greater or Equal Decimals
            System.assert(UserSkillRuleUtility.validateGreaterOrEqual(1, 2));
            System.assertEquals(false, UserSkillRuleUtility.validateGreaterOrEqual(2, 1));
            //Validate Between Decimals
            System.assert(UserSkillRuleUtility.validateBetween(1, 3, 2));
            System.assertEquals(false, UserSkillRuleUtility.validateBetween(1, 3, 4));
            
            TurnOnAssignmentandGrouping__c turnOnBSEG = TestUtility.createTurnOnAssignmentandGrouping('BSEG', true, true); insert turnOnBSEG;
            Set<String> assEnabled = UserSkillRuleUtility.assignmentEnabled();
            System.assert(assEnabled.contains('BSEG'));
            
            Set<String> pickValues = UserSkillRuleUtility.getPicklistValues(new Case(), 'Work_Item_Type__c', assEnabled);
            System.assert(assEnabled.contains('BSEG'));
            
            List<Work_Item_Assignment__c> wlist = new List<Work_Item_Assignment__c>();
            Work_Item_Assignment__c wia= new Work_Item_Assignment__c(user__r=CSR,WI_Assigned__c=10,Limit__c=20 ); insert wia; wlist.add(wia);
            List<Work_Item_Assignment__c> wiaList = UserSkillRuleUtility.sortUserSkillsList(wlist, 'ASC', 'Load_Score__c');
            system.assertEquals(wia.Id, wiaList[0].Id);    
        }
    }
}