public without sharing class LoggedinUsersController {
    
    public list<AuthSession> currentsessions;
    public list<User> CurrentUsers;
    public list<User> UpdatedCurrentUsers;
    public list<UserRole> billingOpsRoleID;
    public Set<ID> currentbillingOpsRoleID;
    Map<Id, AuthSession> authSessionMap = new Map<Id, AuthSession>();
    public List<PageHelper> pageHelperList;
    public LoggedinUsersController(){
        
       
    }
    
    public list<PageHelper> getpageHelperList(){
        //List<User> UpdatedCurrentUsers = new List<User>();
        pageHelperList = new List<PageHelper>();
        //List of all subroles for Billing ops team
         //billingOpsRoleID= [Select Id from UserRole where Name='Meter to Cash'];
        List<UserRole> allUserRoles = [select Id, Name, ParentRoleId from UserRole];
        Id billingOpsRoleId;
        for(UserRole ur : allUserRoles){
				// Get main UserRole which is Meter to Cash
                if(ur.Name == 'Billing Operations'){
                	billingOpsRoleId = ur.Id;
                }
            }
        
        //Converting List of User roles into set of User role IDs
         //currentbillingOpsRoleID = new Set<ID>();        
         //currentbillingOpsRoleID= (new Map<Id,UserRole>(billingOpsRoleID)).keySet();       
      
        //Grabbing all the subroles under Billing ops 
        /*Set<Id> allSubRoleIds = getAllSubRoleIds(currentbillingOpsRoleID);
   		system.debug('***allSubRoleIds1: '+allSubRoleIds);*/
        Set<Id> allSubRoleId = getallSubRoles(allUserRoles, new Set<Id> {billingOpsRoleId});
        allSubRoleId.add(billingOpsRoleId);
   		system.debug('***allSubRoleIds2: '+allSubRoleId);
        
        
        //List of current user sessions
        /*Currentsessions = new list<AuthSession>();
        Currentsessions = [select id, UsersId, UserType,SourceIp,SessionType,SessionSecurityLevel,ParentId,LoginType  from AuthSession];
        System.debug('List of Current Sessions:' + Currentsessions.size());
        
        //Creating set of user IDs from  Currentsessions
        Set<ID> userIds = new Set<ID>();
		       
        for(integer i=0; i<currentsessions.size(); i++){
         userIds.add(Currentsessions[i].UsersId);
        }*/
        Set<ID> userIds = new Set<ID>(); 
        for(AuthSession auth : [select id, UsersId, UserType,SourceIp,SessionType,SessionSecurityLevel,ParentId,LoginType,CreatedDate, NumSecondsValid, LastModifiedDate from AuthSession where ParentId = null and (NOT SessionType LIKE 'Temp%')]){
            system.debug('auth.UsersId: ' + auth.UsersId + '|| auth.SessionType: ' + auth.SessionType);
            userIds.add(auth.UsersId);
            if(authSessionMap.containsKey(auth.UsersId)){
                if(authSessionMap.get(auth.UsersId).CreatedDate < auth.CreatedDate ){
                    authSessionMap.put(auth.UsersId, auth);
                }
            }
            else{
                authSessionMap.put(auth.UsersId, auth);
            }
        }
          System.debug('List of UserIDs'+ userIds);
        system.debug('**authSessionMap : ' + authSessionMap);
        //List of current users
        CurrentUsers = new list<User>();
        CurrentUsers = [Select id,Name, Supervisor__r.name,Profile.name,UserRole.name,Email,LastLoginDate  from User where id in :userIds AND UserRole.id in: allSubRoleId order by LastLoginDate DESC];
        for(User u : CurrentUsers){
            if(authSessionMap.containsKey(u.Id)){
                Integer numSecondsValid = authSessionMap.get(u.Id).NumSecondsValid;
                if(numSecondsValid > 0){
                    //Integer numMinutesValid = authSessionMap.get(u.Id).NumSecondsValid / 60;
                	//Integer numHoursValid = numMinutesValid / 60;
                    DateTime validUntil = authSessionMap.get(u.Id).LastModifiedDate.addSeconds(numSecondsValid);
                    if(validUntil > datetime.now()){
                        system.debug('validUntil > datetime.now(): '+validUntil+' '+datetime.now());
                        pageHelperList.add(new PageHelper(authSessionMap.get(u.Id), u, validUntil));
                    }
                }
            }
        }
        //System.debug('List of user records:' + UpdatedCurrentUsers );
        
        return pageHelperList;
             
    }
    /*private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {

    Set<ID> currentRoleIds = new Set<ID>();

    // get all of the roles underneath the passed roles
    for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null])
    currentRoleIds.add(userRole.Id);

    // Fetching Sibroles
    if(currentRoleIds.size() > 0)
      currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));

   
      System.debug('list of all current role IDs :' + currentRoleIds);  
 return currentRoleIds;
  }*/
    public Set<Id> getallSubRoles (List<UserRole> allUserRoles, Set<Id> roleIds){
        Set<Id> updatedRoleIds = new Set<Id>();
        List<UserRole> newUserRoles = new List<UserRole>();
        for(UserRole ur : allUserRoles){
            if(roleIds.contains(ur.ParentRoleId) && !roleIds.contains(ur.Id)){
                updatedRoleIds.add(ur.Id);
            }
            else{
                newUserRoles.add(ur);
            }
        }
        if(updatedRoleIds.size() > 0){
             updatedRoleIds.addAll(getallSubRoles(newUserRoles, updatedRoleIds));
        }
        return updatedRoleIds;
    }
    public class PageHelper{
        public AuthSession auth {get;set;}
        public User userRec {get;set;}
        public DateTime validUntil {get;set;}
        public PageHelper(AuthSession auth, User userRec, DateTime validUntil){
            this.auth = auth;
            this.userRec = userRec;
            this.validUntil = validUntil;
        }
    }
}