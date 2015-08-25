@isTest
public class CSVreaderTest{
    
    public static testmethod void testParseCSV()
    {   
        // Insert records in Webform_Field_Settings__c  object. It would be done in the test calss for mail page. use those data.
        //enter data in this format 
        string csvContent = 'Service Point ID,Account ID,Premise ID\n1234567890,1234567890,1234567890';
        Blob data = Blob.valueof(csvContent);
        //enter work item
        string workitemtype = '';
        csvFileReader controller = new csvFileReader(data ,workitemtype);
        controller.readcsvFile();
       
       // repeat the same code in different test methods having different data in csvcontent and work item type
    
    }

}