/**********************************************************************************************
* @author       Yefim Shuster
* @date         10/20/2014
*
* @version      1.2
*
* @description  This class holds all the processes for UserSkillRuleTrigger
*               Updated on 10/21/2014 - two new fields Age_Bucket_Start__c and Age_Bucket_End__c
* @revision     Yefim Shuster on 2015-06-04 - R2 - add two new fields - Medical_Allotment__c and Medical_Allotment_Evaluator__c 
*                     - new version is 1.1
*               Yefim Shuster on 2015-06-19 - R2 - modified isDuplicateRecord() to use UserSkillRulesAndCaseMap__c Custom Settings
*                     - new version is 1.2
**********************************************************************************************/
public without sharing class UserSkillRuleTriggerHandler {
    
/**********************************************************************************************
* @author       Yefim Shuster
* @date         10/20/2014
*
* @version      1.3
*
* @description  isDuplicateRecord will be called on After Insert and on After Update - throw exception
*                      if duplicate records exist
* @revisions
*               Updated on 10/21/2014 - two new fields Age_Bucket_Start__c and Age_Bucket_End__c
*               Updated by YXS7 on 2015-06-04 - two new fields Medical_Allotment__c and Medical_Allotment_Evaluator__c
*               Updated by YXS7 on 2015-06-08 - added Diags statements for debugging - new version is 1.1
*               Updated by YXS7 on 2015-06-08 - added errors to records that are duplicate - new version is 1.2
*               Updated by YXS7 on 2015-06-19 - use UserSkillRulesAndCaseMap__c Custom Settings - new version is 1.3
**********************************************************************************************/
    private class UnexpectedFieldTypeException extends Exception {}
    
    public static void isDuplicateRecord(List<User_Skill_Rule__c> usrules, Map<Id, User_Skill_Rule__c> usrulesMap){

      Set<String> s1 = new Set<String>();
      Set<String> s2 = new Set<String>();
      Set<String> s3 = new Set<String>();
      Set<String> s4 = new Set<String>();
      Set<String> s5 = new Set<String>();
      Set<String> s6 = new Set<String>();
      Set<String> s7 = new Set<String>();
      Set<String> s8 = new Set<String>();
      Set<String> s9 = new Set<String>();
      Set<String> s10 = new Set<String>();
      Set<String> s11 = new Set<String>();
      Set<String> s12 = new Set<String>();
      Set<String> s13 = new Set<String>();
      Set<String> s14 = new Set<String>();
      Set<String> s15 = new Set<String>();
      
      Set<Decimal> d1 = new Set<Decimal>();
      Set<Decimal> d2 = new Set<Decimal>();
      Set<Decimal> d3 = new Set<Decimal>();
      
      Set<Boolean> b1 = new Set<Boolean>();
      
      Boolean isDup = false;
      
      Diags.Enter('UserSkillRuleTriggerHandler.isDuplicateRecord() - usrules.size() = ' + usrules.size() + ' usrules[0] = ' + usrules[0]);
      
      if (usrules.size() <= 0) return;
      
      Map<String, UserSkillRulesAndCaseMap__c> usrMap = UserSkillRulesAndCaseMap__c.getAll();
      
      Map<String, Object> usrvalueMap = new Map<String, Object>();
      
      String grpcols = '', wherestr = '', allcols = '';
      
      Map<String, Object> groupvalueMap = new Map<String, Object>();
      
      Map <String, Schema.SObjectField> fieldMap = Schema.sObjectType.User_Skill_Rule__c.fields.getMap();
      
      for (String field : usrMap.keySet()) {
         Schema.SOAPType ftype = fieldMap.get(field).getDescribe().getSOAPType();
         
         Diags.Info('field = ' + field + ' ftype = ' + ftype + ' isGroupable() = ' + fieldMap.get(field).getDescribe().isGroupable());
         
         if (ftype == Schema.SOAPType.String){
             usrvalueMap.put(field, new Set<String>());
             if (fieldMap.get(field).getDescribe().isGroupable()){
                grpcols += ', ' + field;
                groupvalueMap.put(field, new Set<String>());
             } 
         }
         else if (ftype == Schema.SOAPType.Integer || ftype == Schema.SOAPType.Double){
             usrvalueMap.put(field, new Set<Decimal>());
         }
         else if (ftype == Schema.SOAPType.Boolean){
             usrvalueMap.put(field, new Set<Boolean>());
         }
         else {
             // handle unexpected field type
             throw new UnexpectedFieldTypeException(ftype + ': unexpected field type in isDuplicateRecord method for field = ' + field);
         }
         
         allcols += ', ' + field;
      }
      
      grpcols = (grpcols.length() > 3 ? grpcols.substring(2) : grpcols);
      allcols = (allcols.length() > 3 ? allcols.substring(2) : allcols);
      
      Set<String> nameSet = new Set<String>();
      
      for (User_Skill_Rule__c r : usrules) {
        nameSet.add(r.Name);
        
        for (String field : usrMap.keySet()) {
          Object v = r.get(field);
          Schema.SOAPType ftype = fieldMap.get(field).getDescribe().getSOAPType();
          if (ftype == Schema.SOAPType.String){
             ((Set<String>)usrvalueMap.get(field)).add((String)v);
          }
          else if (ftype == Schema.SOAPType.Integer || ftype == Schema.SOAPType.Double){
             ((Set<Decimal>)usrvalueMap.get(field)).add((Decimal)v);
          }
          else if (ftype == Schema.SOAPType.Boolean){
             ((Set<Boolean>)usrvalueMap.get(field)).add((Boolean)v);
          }
          else {
             // handle unexpected field type
             throw new UnexpectedFieldTypeException(ftype + ': unexpected field type in isDuplicateRecord method for field = ' + field);
          }
        }
      }
      
      for (AggregateResult d : [SELECT Name,
                          count(Id)
                    from User_Skill_Rule__c
                    WHERE Name IN :nameSet
                     and IsDeleted = false
                    GROUP BY Name
                    HAVING count(Id) > 1]) {
            isDup = true;
            
            for (User_Skill_Rule__c usr : usrules) {
              if (usr.Name == (String)d.get('Name')) usr.addError('Duplicate User Skill Rule Name exists. Please enter another name.');
            }
      }
        
      if (isDup) {
         Diags.Info('Dup Names detected.');
         return;
      }
      
      for (String field : usrvalueMap.keySet()) {
         Schema.SOAPType ftype = fieldMap.get(field).getDescribe().getSOAPType();
         
         if (ftype == Schema.SOAPType.String){
            if (s1.isEmpty()){
             s1.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s1 ';
            }
            else if (s2.isEmpty()){
             s2.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s2 ';
            }
            else if (s3.isEmpty()){
             s3.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s3 ';
            }
            else if (s4.isEmpty()){
             s4.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s4 ';
            }
            else if (s5.isEmpty()){
             s5.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s5 ';
            }
            else if (s6.isEmpty()){
             s6.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s6 ';
            }
            else if (s7.isEmpty()){
             s7.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s7 ';
            }
            else if (s8.isEmpty()){
             s8.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s8 ';
            }
            else if (s9.isEmpty()){
             s9.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s9 ';
            }
            else if (s10.isEmpty()){
             s10.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s10 ';
            }
            else if (s11.isEmpty()){
             s11.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s11 ';
            }
            else if (s12.isEmpty()){
             s12.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s12 ';
            }
            else if (s13.isEmpty()){
             s13.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s13 ';
            }
            else if (s14.isEmpty()){
             s14.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s14 ';
            }
            else if (s15.isEmpty()){
             s15.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s15 ';
            }
         }
         else if (ftype == Schema.SOAPType.Integer || ftype == Schema.SOAPType.Double){
            if (d1.isEmpty()){
             d1.addAll((Set<Decimal>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :d1 ';
            }
            else if (d2.isEmpty()){
             d2.addAll((Set<Decimal>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :d2 ';
            }
            else if (d3.isEmpty()){
             d3.addAll((Set<Decimal>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :d3 ';
            }
         }
         else if (ftype == Schema.SOAPType.Boolean){
            if (b1.isEmpty()){
             b1.addAll((Set<Boolean>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :b1 ';
            }
         }
         else {
             // handle unexpected field type
             throw new UnexpectedFieldTypeException(ftype + ': unexpected field type in isDuplicateRecord method for field = ' + field);
         }
      }
      
      wherestr = (wherestr.length() > 5 ? wherestr.substring(4) : wherestr);
      
      String soql = 'SELECT ' + grpcols + ', count(Id) from User_Skill_Rule__c WHERE ' + wherestr + ' AND IsDeleted = false GROUP BY ' + grpcols;
      soql += ' HAVING count(Id) > 1';
      
      Diags.Info('group soql = ' + soql);
      
      List<AggregateResult> resultList = Database.query(soql);
      
      if (resultList == null) return;
      
      String lfield = '';
      
      for (AggregateResult d : resultList) {
        for (String field : groupvalueMap.keySet()) {
          lfield = field;
          Object v = d.get(field);
          Schema.SOAPType ftype = fieldMap.get(field).getDescribe().getSOAPType();
          if (ftype == Schema.SOAPType.String){
             ((Set<String>)groupvalueMap.get(field)).add((String)v);
          }
          else if (ftype == Schema.SOAPType.Integer || ftype == Schema.SOAPType.Double){
             ((Set<Decimal>)groupvalueMap.get(field)).add((Decimal)v);
          }
          else if (ftype == Schema.SOAPType.Boolean){
             ((Set<Boolean>)groupvalueMap.get(field)).add((Boolean)v);
          }
          else {
             // handle unexpected field type
             throw new UnexpectedFieldTypeException(ftype + ': unexpected field type in isDuplicateRecord method for field = ' + field);
          }
        }
      }
      
      if (lfield == '') return;
      
      Schema.SOAPType ftype = fieldMap.get(lfield).getDescribe().getSOAPType();
      Integer size = 0;
      
      if (ftype == Schema.SOAPType.String){
         size = ((Set<String>)groupvalueMap.get(lfield)).size();
      }
      else if (ftype == Schema.SOAPType.Integer || ftype == Schema.SOAPType.Double){
         size = ((Set<Decimal>)groupvalueMap.get(lfield)).size();
      }
      else if (ftype == Schema.SOAPType.Boolean){
         size = ((Set<Boolean>)groupvalueMap.get(lfield)).size();
      }
      else {
         // handle unexpected field type
         throw new UnexpectedFieldTypeException(ftype + ': unexpected field type in isDuplicateRecord method for field = ' + lfield);
      }
      
      Diags.Info('groupvalueMap.get(' + lfield + ').size() = ' + size);
        
      if (size <= 0) return;
      
      wherestr = '';
      s1.clear();
      s2.clear();
      s3.clear();
      s4.clear();
      s5.clear();
      s6.clear();
      s7.clear();
      s8.clear();
      s9.clear();
      s10.clear();
      s11.clear();
      s12.clear();
      s13.clear();
      s14.clear();
      s15.clear();
      d1.clear();
      d2.clear();
      d3.clear();
      b1.clear();
      
      for (String field : usrMap.keySet()) {
         ftype = fieldMap.get(field).getDescribe().getSOAPType();
         if (ftype == Schema.SOAPType.String){
            if (s1.isEmpty()){
             if (groupvalueMap.containsKey(field))
               s1.addAll((Set<String>)(groupvalueMap.get(field)));
             else
               s1.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s1 ';
            }
            else if (s2.isEmpty()){
             if (groupvalueMap.containsKey(field))
               s2.addAll((Set<String>)(groupvalueMap.get(field)));
             else
               s2.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s2 ';
            }
            else if (s3.isEmpty()){
             if (groupvalueMap.containsKey(field))
               s3.addAll((Set<String>)(groupvalueMap.get(field)));
             else
               s3.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s3 ';
            }
            else if (s4.isEmpty()){
             if (groupvalueMap.containsKey(field))
               s4.addAll((Set<String>)(groupvalueMap.get(field)));
             else
               s4.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s4 ';
            }
            else if (s5.isEmpty()){
             if (groupvalueMap.containsKey(field))
               s5.addAll((Set<String>)(groupvalueMap.get(field)));
             else
               s5.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s5 ';
            }
            else if (s6.isEmpty()){
             if (groupvalueMap.containsKey(field))
               s6.addAll((Set<String>)(groupvalueMap.get(field)));
             else
               s6.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s6 ';
            }
            else if (s7.isEmpty()){
             if (groupvalueMap.containsKey(field))
               s7.addAll((Set<String>)(groupvalueMap.get(field)));
             else
               s7.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s7 ';
            }
            else if (s8.isEmpty()){
             if (groupvalueMap.containsKey(field))
               s8.addAll((Set<String>)(groupvalueMap.get(field)));
             else
               s8.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s8 ';
            }
            else if (s9.isEmpty()){
             if (groupvalueMap.containsKey(field))
               s9.addAll((Set<String>)(groupvalueMap.get(field)));
             else
               s9.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s9 ';
            }
            else if (s10.isEmpty()){
             if (groupvalueMap.containsKey(field))
               s10.addAll((Set<String>)(groupvalueMap.get(field)));
             else
               s10.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s10 ';
            }
            else if (s11.isEmpty()){
             if (groupvalueMap.containsKey(field))
               s11.addAll((Set<String>)(groupvalueMap.get(field)));
             else
               s11.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s11 ';
            }
            else if (s12.isEmpty()){
             if (groupvalueMap.containsKey(field))
               s12.addAll((Set<String>)(groupvalueMap.get(field)));
             else
               s12.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s12 ';
            }
            else if (s13.isEmpty()){
             if (groupvalueMap.containsKey(field))
               s13.addAll((Set<String>)(groupvalueMap.get(field)));
             else
               s13.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s13 ';
            }
            else if (s14.isEmpty()){
             if (groupvalueMap.containsKey(field))
               s14.addAll((Set<String>)(groupvalueMap.get(field)));
             else
               s14.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s14 ';
            }
            else if (s15.isEmpty()){
             if (groupvalueMap.containsKey(field))
               s15.addAll((Set<String>)(groupvalueMap.get(field)));
             else
               s15.addAll((Set<String>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :s15 ';
            }
         }
         else if (ftype == Schema.SOAPType.Integer || ftype == Schema.SOAPType.Double){
           if (d1.isEmpty()){
             d1.addAll((Set<Decimal>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :d1 ';
            }
            else if (d2.isEmpty()){
             d2.addAll((Set<Decimal>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :d2 ';
            }
            else if (d3.isEmpty()){
             d3.addAll((Set<Decimal>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :d3 ';
            }
         }
         else if (ftype == Schema.SOAPType.Boolean){
           if (b1.isEmpty()){
             b1.addAll((Set<Boolean>)(usrvalueMap.get(field)));
             wherestr += 'AND ' + field + ' IN :b1 ';
            }
         }
         else {
            // handle unexpected field type
             throw new UnexpectedFieldTypeException(ftype + ': unexpected field type in isDuplicateRecord method for field = ' + field);
         }
      }
      
      wherestr = (wherestr.length() > 5 ? wherestr.substring(4) : wherestr);
      
      if (allcols.length() > 0) allcols += ', GroupingEnabled__c'; 
      
      soql = 'SELECT ' + allcols + ' from User_Skill_Rule__c WHERE ' + wherestr + ' AND IsDeleted = false';
      
      Diags.Info('all soql = ' + soql);
      
      List<User_Skill_Rule__c> pdups = Database.query(soql);
                      
      size = pdups.size();
             
      if (size > 1) {
       for (Integer i = 0; i < size; i++) {
         for (Integer k = i + 1; k < size; k++) {
           isDup = true;
           for (String field : usrMap.keySet()) {
             Object lv = pdups[i].get(field);
             Object rv = pdups[k].get(field);
             String ls, rs;
             if (usrMap.get(field).USR_Field_Type__c == 'String') {
               ls = (String)lv;
               rs = (String)rv;
               ls = (ls != null ? ls.trim() : null);
               rs = (rs != null ? rs.trim() : null);
               if (ls != rs) {
                 isDup = false;
                 break;
               }
             }
             else {
                if (((lv == null || rv == null) && lv != rv) || (lv !=null && rv != null && !lv.equals(rv))){
                   isDup = false;
                   break;
                }
             }
           }
           if (isDup){
               if (pdups[i].Work_Item_Type__c == 'Unaged Debt' &&
                   pdups[k].Work_Item_Type__c == 'Unaged Debt' &&
                   pdups[i].GroupingEnabled__c != pdups[k].GroupingEnabled__c){
                   isDup = false;
               }
               else {
                 Diags.Info('Dups found. Dup1[' + i + '] = ' + pdups[i] + ' Dup2[' + k + '] = ' + pdups[k]);
                 if (usrulesMap.containsKey(pdups[i].Id)) usrulesMap.get(pdups[i].Id).addError('Duplicate User Skill Rule records exist');
                 if (usrulesMap.containsKey(pdups[k].Id)) usrulesMap.get(pdups[k].Id).addError('Duplicate User Skill Rule records exist');
               }
           }
         }
       }
     }
        
     if (isDup) {
       Diags.Info('Dups detected.');
     }
     else Diags.Info('Dups not detected.');
        
     Diags.Clear();
        
     return;
        
    }
}