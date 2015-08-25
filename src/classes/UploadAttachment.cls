public class UploadAttachment {
  public ContentVersion file {get;set;}
  public String title {get;set;}
  public Id parentId {get;set;}
  public String attachmentString {get;set;}
  public List<String> attachmentNames {get;set;}
  public List<ContentVersion> files {
    get {
      if (files == null) {
        files = new List<ContentVersion>();
        for (Integer i=0; i<5; i++) {
          files.add(new ContentVersion());
        } 
      }
      return files;
    }
    set;
  }
  public List<ContentDocument> contentDocs {get;set;}
  public List<Attachment> atts {get;set;}


 // public UploadAttachment(List<ContentVersion> chatterFiles) {
 //   this.files = chatterFiles;
    
 // if (attachment != null) {
 //   attachmentString = attachment.toString();
 // }
 // file = new ContentVersion();
 // file.Origin = 'C';
 // file.PathOnClient = 'myFile.txt';
 // file.VersionData = attachment;
 // //this.ParentId = '500q0000002o4I8AAI';
  

 //// files = new List<ContentVersion>();

 //// for (Integer i=0; i<5; i++) {
 ////   files.add(new ContentVersion());
 //// }
 //}
 public UploadAttachment() {
 }
   
 public PageReference uploadFile() {
    System.debug('============new chatter file: ===========' + files);
     //insert file;
    // make a new list to hold attachments that will be inserted later
    List<ContentVersion> listToInsert = new List<ContentVersion>();
    //for (ContentVersion c : files) {
    //    listToInsert.add(new ContentVersion(Origin='C', PathOnClient=c.PathOnClient, VersionData=c.VersionData, Title=c.Title));  
    //}

    //if (listToInsert.size()>0) {

    for (ContentVersion c : files) {
      if (c.VersionData != null ) {
        String s = c.VersionData.toString();
        System.debug('Blob String ' + s);
        c.Title = s;
        c.PathOnClient = s;
        listToInsert.add(c);
      }
    }
    System.debug('Files ' + files);
    try {
      insert listToInsert;
    } catch (Exception e) {
      System.debug('Insert Attachment Error ' + listToInsert);
    }

    if (listToInsert.size() > 0) {
      List<String> supportingDocument = new List<String>();
      List<String> fileIds = new List<String>();
      for (ContentVersion c : listToInsert) {
        String fileUrl = c.Title +  ': ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + c.Id;
        supportingDocument.add(fileUrl);
        fileIds.add(c.Id);
      }
      String documentLinks = String.join(supportingDocument, '\n');
      String documentIds = String.join(fileIds, ',');
      System.debug('Supporting Document ' + documentLinks + ' fileIds' + documentIds); 
    }
    return null;
 }

}