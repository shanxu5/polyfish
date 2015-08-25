/**********************************************************************************************
* @author       Yefim Shuster
* @date         04/20/2015
* @description  Test Diags class that creates diagnostics information in Diagnostics__c custom object
* @version      1.0
* @revision(s)  Created
**********************************************************************************************/
@isTest
public class TestDiags {

private class MyException extends Exception {}

public static TestMethod void TestSave() {
  Diags.Enter('TestSave');
  Diags.Info('About to call Diags.Save()');
  Diags.Save();
  Diags.ClearAll();
}

public static TestMethod void TestSaveException() {
  Diags.Enter('TestSaveException');
  Diags.Info('About to call Diags.SaveException()');
  Diags.SaveException(new MyException());
  Diags.ClearAll();
}
}