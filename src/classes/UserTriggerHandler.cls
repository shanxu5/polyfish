/**********************************************************************************************
* @author       Joe Kowalsky
* @date         06/17/2015
*
* @version      1.0
*
* @description  This class holds all the processes for UserTrigger
*               
* @revision     
*               
**********************************************************************************************/
public without sharing class UserTriggerHandler {

    /*************************************************************************
    * @author           Joe Kowalsky
    * @date             06/17/15
    * @description      This method loops through User records to:
    *                       // Find all User owned Work Items in Assigned/Being Worked On/Pending status.
    *                       // Update each Work Item's Approver Reviewer Supervisor Email field with the Supervisor's email.
    * @parameters       List of Users where the Supervisor was updated.
    **************************************************************************/
    public static void updateUsersWorkItemsWithSupervisorsEmail(List<User> userList){
      try {

        Set<Id> usersToUpdate = new Set<Id>();            // Users passed in that will be updated.

        Set<Id> usersSupervisorsIds = new Set<Id>();      // Ids of the supervisors that were updated for each User.  Only one Sup Id is kept.
        Map<Id, User> supervisorsMap = new Map<Id, User>();           // Map of Supervisor's Id to Supervisor's User object.

        Map<Id, Id> usersSupervisorsMap = new Map<Id, Id>();          // Map of Users Id to Supervisor's User Id.
        Map<Id, User> userToSupervisorMap = new Map<Id, User>();      // Map of User Id to Supervisor User object.

        List<Case> allUsersWorkableWorkItems = new List<Case>();      // List of all Workable Work Items for all Users passed in with an updated supervisor
        Map<Id, List<Case>> userToWorkItemMap = new Map<Id, List<Case>>();    // Map of User to Workable Work Items.


        // Build Sets/Maps to query on later        
        for (User u : userList){
            usersToUpdate.add(u.Id);                            
            usersSupervisorsIds.add(u.Supervisor__c);
            usersSupervisorsMap.put(u.Id,u.Supervisor__c);      // Map User Id to Supervisor Id
        }
        System.debug(Logginglevel.INFO,'In UserTriggerHandler.updateUsersWorkItemsWithSupervisorsEmail()...usersToUpdate...' + usersToUpdate);
        System.debug(Logginglevel.INFO,'In UserTriggerHandler.updateUsersWorkItemsWithSupervisorsEmail()...usersSupervisorsIds...' + usersSupervisorsIds);
        System.debug(Logginglevel.INFO,'In UserTriggerHandler.updateUsersWorkItemsWithSupervisorsEmail()...usersSupervisorsMap...' + usersSupervisorsMap);

        
        // Get new supervisor for all user's with an updated supervisor
        supervisorsMap = new Map<Id, User>([Select Id, Email from User where Id In :usersSupervisorsIds]);
        System.debug(Logginglevel.INFO,'In UserTriggerHandler.updateUsersWorkItemsWithSupervisorsEmail()...supervisorsMap...' + supervisorsMap);

        
        // Map User Id to Supervisor User object.
        for (User u : userList) {
            Id tempSupId = usersSupervisorsMap.get(u.Id);
            User tempSupUser = supervisorsMap.get(tempSupId);
            userToSupervisorMap.put(u.Id,tempSupUser);
        }
        System.debug(Logginglevel.INFO,'In UserTriggerHandler.updateUsersWorkItemsWithSupervisorsEmail()...userToSupervisorMap...' + userToSupervisorMap);


        // Map workable work items to User who owns them
        allUsersWorkableWorkItems = [Select Id, Approver_Reviewer_Email__c, OwnerId from Case where OwnerId In :usersToUpdate and Status In ('Assigned','Being Worked On','Pending')];
        for (Case c : allUsersWorkableWorkItems) {
            if(userToWorkItemMap.containsKey(c.OwnerId)){
                List<Case> temp = userToWorkItemMap.get(c.OwnerId);
                temp.add(c);
                userToWorkItemMap.put(c.OwnerId, temp);
            }
            else{
                List<Case> temp = new List<Case>();
                temp.add(c);
                userToWorkItemMap.put(c.OwnerId, temp);
            }
        }

        // Main loop
        for (User u : userList){

            System.debug(Logginglevel.info,'In UserTriggerHandler.updateUsersWorkItemsWithSupervisorsEmail()...Curr User Id/Sup ID=' + u.Id + '/' + u.Supervisor__c);
            
            // Get all User's Work Items that are in Pending/Being Worked On/Assigned status
            List<Case> usersWorkableWorkItems = new List<Case>();
            usersWorkableWorkItems = userToWorkItemMap.get(u.Id);

            Diags.Enter('In UserTriggerHandler.updateUsersWorkItemsWithSupervisorsEmail()...usersWorkableWorkItems=' + usersWorkableWorkItems);
            System.debug(Logginglevel.info,'In UserTriggerHandler.updateUsersWorkItemsWithSupervisorsEmail()...usersWorkableWorkItems=' + usersWorkableWorkItems);

            if (usersWorkableWorkItems != null && !usersWorkableWorkItems.isEmpty()){
                // Workable Work Items found to update
                // Get User's Supervisor
                User supervisor = userToSupervisorMap.get(u.Id);

                Diags.Enter('In UserTriggerHandler.updateUsersWorkItemsWithSupervisorsEmail()...User\'s supervisor=' + supervisor);
                System.debug(Logginglevel.info,'In UserTriggerHandler.updateUsersWorkItemsWithSupervisorsEmail()...User\'s supervisor=' + supervisor);

                if (supervisor != null){
                    // User has a supervisor, update the Workable Work Items with Supervisor email/id
                    for (Case uwwi : usersWorkableWorkItems){
                        uwwi.Approver_Reviewer_Email__c = supervisor.Email;
                        uwwi.Approver_Reviewer__c = supervisor.Id;
                    }
                    
                    Diags.Enter('In UserTriggerHandler.updateUsersWorkItemsWithSupervisorsEmail()...before update...usersWorkableWorkItems:' + usersWorkableWorkItems);
                    System.debug(Logginglevel.info,'In UserTriggerHandler.updateUsersWorkItemsWithSupervisorsEmail()...before update...usersWorkableWorkItems:' + usersWorkableWorkItems);
                    update usersWorkableWorkItems;
                    
                } else {
                    // User's supervisor not assigned, not found or doesn't exist. Don't update the Workable Work Items.
                    Diags.Enter('In UserTriggerHandler.updateUsersWorkItemsWithSupervisorsEmail()...No Supervisor User found for User=' + u);
                    System.debug(Logginglevel.info,'In UserTriggerHandler.updateUsersWorkItemsWithSupervisorsEmail()...No Supervisor User found for User=' + u);
                }
            } else {
                // No workable Work Items found for User

                System.debug(Logginglevel.info,'In UserTriggerHandler.updateUsersWorkItemsWithSupervisorsEmail()...No Workable Work Items found for User=' + u);
            }
        }
      } 
      catch(Exception e){
        System.debug('***Error in UserTriggerHandler.updateUsersWorkItemsWithSupervisorsEmail(): ' + e.getMessage());
        Diags.SaveException(e);
        Diags.ClearAll();
        throw e;
      }
    }


    /*************************************************************************
    * @author       Joe Kowalsky
    * @date         06/17/2015
    * @description  This method is called from User Trigger and handle all trigger processing
    * @parameters   newUserList - Trigger.new
    *               newUserMap - Trigger.newMap
    *               oldUserList - Trigger.old
    *               oldUserMap - Trigger.oldMap
    *               isBefore - Trigger.isBefore
    *               isUpdate - Trigger.isUpdate
    *               isInsert - Trigger.isInsert
    **************************************************************************/
    public static void handle(List<User> newUserList,
                              Map<Id, User> newUserMap,
                              List<User> oldUserList,
                              Map<Id, User> oldUserMap,
                              Boolean isBefore,
                              Boolean isUpdate,
                              Boolean isInsert,
                              Boolean isDelete){
      
      List<User> userList = new List<User>();
      List<User> usersWithUpdatedSupervisors = new List<User>();
      
      try {
      
        System.debug(Logginglevel.info,'UserTriggerHandler.handle():IsBefore=' + isBefore + ':IsUpdate=' + isUpdate + ':IsDelete=' + isDelete);
        // Before DML
        if(isBefore){
            // If trigger is Before Insert
            if(isInsert){

            }
            // If trigger is Before Update
            if(isUpdate){
                for (User u : newUserList){
                    User oldMap = oldUserMap.get(u.Id);
                    System.debug(Logginglevel.info,'%%% Before Update %%%...oldMap...Lan ID|Supervisor Id...' + oldMap.Lan_ID__c + '::::' + oldMap.Supervisor__c);
                    System.debug(Logginglevel.info,'%%% Before Update %%%...newMap...Lan ID|Supervisor Id...' + u.Lan_ID__c + '::::' + u.Supervisor__c);
                    // if the supervisor field for the old User object is different than the new User object.
                    //  This could mean the supervisor was changed or the supervisor was assigned for the first time.
                    if (oldMap.Supervisor__c != u.Supervisor__c){
                        usersWithUpdatedSupervisors.add(u);
                    }

                    System.debug(Logginglevel.info,'%%% Before Update %%%...UserTriggerHandler.handle(): usersWithUpdatedSupervisors.size()=' + usersWithUpdatedSupervisors.size() + ' :usersWithUpdatedSupervisors=' + usersWithUpdatedSupervisors);
                    if (usersWithUpdatedSupervisors.size() > 0){
                        updateUsersWorkItemsWithSupervisorsEmail(usersWithUpdatedSupervisors);
                    }
                }
                
            }
        }
        // After DML
        if(!isBefore){
            
        }
      }
      catch(Exception e){
        System.debug('***Error in UserTriggerHandler.handle(): ' + e.getMessage());
        throw e;
      }
   }

}