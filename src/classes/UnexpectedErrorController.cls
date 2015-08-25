public with sharing class UnexpectedErrorController {
    
    public String getPGELogoURL(){
        // Fetching the resource        
        List<Document> resourceList = [SELECT Id, DeveloperName, Name FROM Document WHERE DeveloperName = 'PGE_Logo'];        
        
        if(resourceList.size() == 1){
            // Get instance from instance url.  Below resolves to <instance>.salesforce.com.
            String PGEOrgInstance = ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To');
            String SfdcInstance = PGEOrgInstance.substringBefore('.');
           	
            // Get Ids and format from length 18 to 15.
            String ExternalLogoId = formatID(resourceList[0].Id);
            String orgID = formatID(UserInfo.getOrganizationId());               
            
            // Build url of external logo
            String fullExternalLogoURL = 'https://c.' + SfdcInstance + '.content.force.com/servlet/servlet.ImageServer?id=' + ExternalLogoId + '&oid=' + orgId;            
            //String fulllogoURL = 'https://'+ PGEOrgInstance + '/' + 'resource/' + resourceList[0].DeveloperName ;       
            
            return fullExternalLogoURL;
        } 
        else {
            // if no external logo found
    		return null;   
        }
    }

	// Format id from length of 18 to 15.    
    public String formatID(Id id_to_format){
        String temp = (String)id_to_format;
        temp = temp.substring(0,15);
        return temp;
    }
}