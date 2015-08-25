/*
	@Company		Slalom Consulting
	@Author			Janella Espiritu
	@Date			06.January.2015
	@Description	Test Class for Build XML
	@Revision(s)	Janella Espiritu - Sprint 2 Update
*/
@isTest
public class TestBuildXML {
	static testMethod void testBuildXML() {
        
        // Query Queue
        Id queueId = [select Id, Name from Group where Name = 'Billing Exceptions' and Type = 'Queue'].Id;
        Id recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Billing Exceptions').getRecordTypeId();
        
    	CustomerContactClass__c ccClass = TestUtility.createCustContClassCustSetting('Records Dept Note', 'RCD'); insert ccClass;
        CustomerContactType__c ccType = TestUtility.createCustContTypeCustSetting('RECORDS', 'RECORDS', true, true, true); insert ccType;
        
        // Create Account
        Account acc = TestUtility.createAccount(date.today() - 60, 'Account 1', '0007652348'); acc.Per_Id__c='1234567890';insert acc;
        // Create Service Agreement
        Service_Agreement__c DASA = TestUtility.createServiceAgreementwithSAType(acc.Id, 'HE-RES', '1234567890'); insert DASA;
        // Create Premise
        Premise__c prem = TestUtility.createPremise(); insert prem;
        // Create Service Point
        Service_Point__c sp = TestUtility.createServicePoint(prem.Id); insert sp;
         // Create Work Items
        Case WorkItemTrue = TestUtility.CreateWorkItem('40', 'PSSTL', 'Pending Start', null, '24164', '90000', acc.Id, DASA.Id, true, prem.Id, sp.Id, queueId, recordtypeId); 
        WorkItemTrue.Mtr_Config_Ty_Cd__c='SM 40'; 
        WorkItemTrue.SMSPST__c = '10';
        WorkItemTrue.Commencing_Bill__c = true;
        Insert WorkItemTrue;
        // Create Related Records
        Related_Records__c cc = TestUtility.createCustomerContact(WorkItemTrue.Id); cc.Status_Description__c='Pending'; insert cc;
        List<Related_Records__c> ccList = [select Id,Name, Customer_Contact_Class__c,Customer_Contact_Type__c, ID__c, Comments__c,Status_Description__c,Completion_Comments__c,SFDC_Work_Item__c,SFDC_Work_Item__r.Work_Item_Type__c, 
                                           SFDC_Work_Item__r.CaseNumber,SFDC_Work_Item__r.Account.Name, SFDC_Work_Item__r.SFDC_Prem_ID__r.Name, SFDC_Work_Item__r.Owner.Name,SFDC_Work_Item__r.Per_ID__c, SFDC_Work_Item__r.SFDC_SA_ID__r.Name 
                                           from Related_Records__c where Id=: cc.Id];
        BuildXML.getDoc('endpoint', ccList, 'jobid');
    }
}