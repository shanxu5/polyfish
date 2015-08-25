public with sharing class ChatterFileUtilities {
  public ContentVersion file {get;set;}
  public String title {get;set;}
  public Id parentId {get;set;}
  public String attachmentString {get;set;}
  public List<String> attachmentNames {get;set;}
  transient List<ContentVersion> files {get;set;}
  public List<ContentDocument> contentDocs {get;set;}
  public List<Attachment> atts {get;set;}


  public ChatterFileUtilities(List<ContentVersion> chatterFiles) {
    this.files = chatterFiles;

  }
  //public ChatterFileUtilities() {
  // files = new List<ContentVersion>();

  // for (Integer i=0; i<5; i++) {
  //   files.add(new ContentVersion());
  // }
  //}
   
 public Map<String, String> uploadFile() {
     //insert file;
    // make a new list to hold attachments that will be inserted later
    List<ContentVersion> listToInsert = new List<ContentVersion>();
    //for (ContentVersion c : files) {
    //    listToInsert.add(new ContentVersion(Origin='C', PathOnClient=c.PathOnClient, VersionData=c.VersionData, Title=c.Title));  
    //}

    //if (listToInsert.size()>0) {

    for (ContentVersion c : files) {
      if (c.VersionData != null) {
        System.debug('Chatter files ' + c);
        c.PathOnClient = c.Title;
        listToInsert.add(c);
      }
    }
    System.debug('Files ' + files);
    try {
      insert listToInsert;
    } catch (Exception e) {
      System.debug('Insert Attachment Error ' + listToInsert);
    }

    Map<String, String> chatterFileProperties = new Map<String, String>();

    if (listToInsert.size() > 0) {
      List<String> supportingDocument = new List<String>();
      List<String> fileIds = new List<String>();
      for (ContentVersion c : listToInsert) {
        String domainUrl = ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To');
        //String fileUrl = c.Title +  ': ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + c.Id;
        System.debug('domain url ' + domainUrl);
        String fileUrl = '<a href="https://' + domainUrl + '/' + c.Id + '">' + 'https://' + domainUrl + '/' + c.Id + '</a>';
        String fileLink = c.Title + ': ' + fileUrl;
        supportingDocument.add(fileLink);
        fileIds.add(c.Id);
      }
      String documentLinks = String.join(supportingDocument, '\n');
      String documentIds = String.join(fileIds, ',');
      chatterFileProperties.put('documentLinks', documentLinks);
      chatterFileProperties.put('documentIds', documentIds);
      System.debug('Supporting Document ' + documentLinks + ' fileIds' + documentIds); 
    }

    return chatterFileProperties;
 }

}