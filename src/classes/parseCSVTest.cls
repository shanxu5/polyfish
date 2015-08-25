@isTest
public class parseCSVTest{
    
    public static testmethod void testParseCSV()
    {
        string csvContent = 'firstname,lastname,CC_B_Person_ID__c\nTest,Guy,2223232';
        List<List<String>> parsedContent = parseCSV1.parseCSV(csvContent,false);
        list<contact> contactList = (list<contact>) parseCSV1.csvTosObject(parsedContent, 'contact');
        system.assertEquals(contactList.size(),1);
        system.assertEquals(contactList[0].firstname,'Test');
        system.assertEquals(contactList[0].lastname,'Guy');
        system.assertEquals(contactList[0].CC_B_Person_ID__c,'2223232');
    
    }

}