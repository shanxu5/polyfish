/**********************************************************************************************
* @author       Yefim Shuster
* @date         04/21/2015
* @description  Create diagnostics information in Diagnostics__c custom object
* @version      1.2
* @revision(s)  Created
*               Modified by YXS7 on 2015-05-28 - truncate to max length - new version is 1.1
*               Modified by YXS7 on 2015-06-03 - stop appending to list when total diags length grows over field length
*                 - this fixes Total Heap Size governor limit issue when loading WIs in bulk - new version is 1.2
**********************************************************************************************/
public class Diags {

private static Boolean diagsEnabled = Boolean.valueOf(System.Label.Is_Diagnostics_Enabled);  // if set to False, no diagnostics info will be generated
private static List<DiagEntry> entries;
private static Integer clevel = 0;
private static final Integer MAX_FIELD_LENGTH = 32768;
private static Integer currentDiagsLength = 0;

private class DiagEntry {
  Integer level;
  String text;
  
  public DiagEntry(String ctext) {
    level = clevel;
    text = ctext;
  }
}

private static String CurrentDiags(){
  String r = '';
  if (!diagsEnabled || entries == null) return r;
  
  String s = ' '.repeat(40);
  Integer len = s.length();
  
  for (DiagEntry e : entries) {
    Integer idx = 3 * e.level;
    if (idx >= len) idx = len - 1;
    r += s.substring(0, idx) + e.text + '\n';
  }
  return r;
}

private static void Write(String diagstring) {
  if (!diagsEnabled) return;
  
  if (diagstring == null || String.isEmpty(diagstring)) return;
  
  if (diagstring.length() + currentDiagsLength > MAX_FIELD_LENGTH){
     return;
  }
  else {
    currentDiagsLength = currentDiagsLength + diagstring.length();
  }
  
  if (entries == null) {
    entries = new List<DiagEntry>();
  }
  entries.Add(new DiagEntry(diagstring));
}

public static void Enter(String funcname) {
  if (!diagsEnabled) return;
  Write('Entering: ' + funcname);
  clevel++;
}

public static void Info(String info) {
  Write(info);
}

public static void Clear() {
  if (!diagsEnabled) return;
  if (clevel > 0) clevel--;
  
  if (clevel == 0) {
     System.debug(LoggingLevel.Info, 'Diagnostics\n' + CurrentDiags()); 
  }
}

public static void ClearAll(){
  clevel = 0;
  Clear();
}

public static void Save() {
  if (!diagsEnabled) return;
  
  String entry = CurrentDiags();
  if (String.isEmpty(entry)) return;
  
  //Modified by YXS7 on 2015-05-28 - truncate to max length - added below - new version is 1.1
  //Modified by YXS7 on 2015-06-03 - truncate to max length - use static constant - replaced below - new version is 1.2
  entry = entry.left(MAX_FIELD_LENGTH);
  
  Diagnostics__c d = new Diagnostics__c(Entry__c = entry);
  insert d;
}

public static void SaveException(Exception e) {
  if (!diagsEnabled) return;
  
  String info = 'Exception on line ' + e.getLineNumber() + ' - ' + e.getMessage() + ' stack: ' + e.getStackTraceString();
  Info(info);
  Save();
}
}