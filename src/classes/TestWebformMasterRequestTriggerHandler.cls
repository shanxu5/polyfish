/*
    @Company        Pacific Gas & Electric  
    @Author         Joe Kowalsky
    @Date           31.July.2015
    @Description    Test Class for WebformMasterRequestTriggerHandler class
    @Revision(s)    
*/

@isTest
public class TestWebformMasterRequestTriggerHandler{
    @testSetup static void setup() {

        /**********************************************************************************************
        * @author       Joe Kowalsky
        * @date         08/03/2015
        * @description  This is Test Setup method that will create test data used in this test class
        * @version      1.0
        * @revision(s)  
        **********************************************************************************************/
    
        
        //create test user to create data
        Profile pfAdmin = [select Id from profile where Name = 'Administrator'];
        UserRole rAdmin = [select Id from userrole where Name = 'Billing Operations'];
        User admin      = TestUtility.createUser(pfAdmin.Id, rAdmin.Id, 1); admin.lan_ID__c = 'ADM1';
        insert admin;

        Profile intProfile = [select id from profile where name='Integration'];
        UserRole intSupervisor = [Select id from userrole where name='Supervisor'];
        User integration = TestUtility.createUser(intProfile.id,intSupervisor.id,3); integration.LAN_ID__c = 'INT1';
        insert integration;
        
        
        System.runAs(integration){
            // Create Webform Master Webform Request
            Webform_Master_Request__c masterWFR = new Webform_Master_Request__c();
            masterWFR.Requestor_s_Name__c = 'Integration Test User';
            masterWFR.Requestor_s_Email__c = 'INT1@pge.com';
            insert masterWFR;
			System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%%% masterWFR %%%%...'+ masterWFR);
            
			// Only system can modify these fields.  No real way to test this in a test class.
            //masterWFR.CreatedDate = Datetime.newInstance(2015, 7, 15);
            //masterWFR.LastModifiedDate = Datetime.newInstance(2015, 7, 31);
            //update masterWFR;

            Webform_Child_Request__c childWFR = new Webform_Child_Request__c();
            childWFR.Webform_Master_Request__c = masterWFR.Id;
            insert childWFR;
			System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%%% childWFR %%%%...'+ childWFR);
            
            masterWFR.Child_Requests_Created__c = true;
            update masterWFR;
       }
    } // end @testSetup


    /**********************************************************************************************
    * @author       Joe Kowalsky
    * @date         08/03/2015
    * @description  Test Update of User's Supervisor from <Old> Supervisor to <New> Supervisor.
    * @version      1.0     
    * @revision(s)  Original
    **********************************************************************************************/
    static testMethod void testDeleteMasterChildWfrOlderThan6Days() {
        User integrationUser = [Select Id from User where Lan_ID__c='INT1'];

        System.runAs(integrationUser){
            Test.startTest();
            System.debug(Logginglevel.info,'>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');

                System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%%% testDeleteMasterChildWfrOlderThan6Days() %%%%');
                
            	// Just call the class.  Can't create test records, for code below, because query fields are system modifiable only.
            	WebformMasterRequestTriggerHandler.removeMasterChildWFRs();
            	/*
                // Find master wfr created in test setup above that should be removed.
                Map<Id, Webform_Master_Request__c> masterWfrToRemove;
                masterWfrToRemove = new Map<Id, Webform_Master_Request__c>(
                    [Select Id,Name from Webform_Master_Request__c where 
                     LastModifiedDate <= :Datetime.now()-7 		and 
                     (LastModifiedNotEqualToCreated__c = true)	and 
                     ((Notification_of_Completion_Required__c = true and Notification_Sent__c = true) or 
                      (Notification_of_Completion_Required__c = false))
                    ]);
            
                // Verify you got master wfr's back from query.                
                System.assert(masterWfrToRemove.size() != 0);
                System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%%% masterWfrToRemove %%%%...'+ masterWfrToRemove);
            
                // If Master WFRs found                                                            
                if(masterWfrToRemove != null) {
                    //List<Id> masterWfrIdsToRemove = masterWfrToRemove.values();
                    Set<Id> masterWfrIdsToRemove = masterWfrToRemove.keySet();
                    //List<Webform_Master_Request__c> masterWfrIdsToRemove = masterWfrToRemove.values();

                    // Get any Child Webform Requests that meet the same criteria and are owned by the master
                    List<Webform_Child_Request__c> childWfrToRemove = [Select Id,Name from Webform_Child_Request__c where 
                                                                            Webform_Master_request__c IN :masterWfrIdsToRemove
                                                                            ];
                    
                    // Verify you got master wfr's back from query.
                    System.assert(childWfrToRemove != null);
					System.debug(Logginglevel.info,'%%%%%%%%%%%%%%%%%%% childWfrToRemove %%%%...'+ childWfrToRemove);
                    
                    // Run test to remove master
                    WebformMaintenance.removeMasterChildWFRs();
                                
                }     
				*/
            System.debug(Logginglevel.info,'<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
            Test.stopTest();
            
        }
            
    } // end test method...testDeleteMasterChildWfrOlderThan6Days()

} // end test class