/*******************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Status           Development Completed
* @description      This  class is for populating default values for case
*********************************************************************************************
Version    	Date        	Team    	Comments
*********************************************************************************************
* 1         9 Nov 2020     Pradeep     Class for defaulting Case field values
*********************************************************************************************/

public class CaseController {
    public static void Casecreation(List<Case> Caselistobject)
    {
        
        for(Case caseloop:Caselistobject)
        {
                       
            caseloop.Status='New';                      //Default to New 
            
            if(caseloop.Type=='Billing' && caseloop.Case_Owner__c != null)
            {         
             caseloop.OwnerId= caseloop.Case_Owner__c;
            }
            else if(caseloop.Type=='Refund')
            {
              caseloop.OwnerId=System.label.User_for_Refund;   
            }
            
            //Defaulting the Record type
            caseloop.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Case_Record_Type_After').getRecordTypeId();
            
            //Defaulting the Description
            caseloop.Description='Brief Description of Request:'+'\r'+'\n'+'Estimated number of hours:'+'\r'+'\n'+'Customer Disposition:'+'\r'+'\n';
            
            //Default value if Case Reason is not empty
            if(caseloop.Case_Reason__c!=null)
            {
                caseloop.Subject=caseloop.Account_name_formula__c +' '+ caseloop.Case_Reason__c +' '+'Pricing Request';
            }
            else  //Default value if Case Reason is empty
            {
                caseloop.Subject=caseloop.Account_name_formula__c + ' ' +'Pricing Request';   
            }
            
        }
        
        
    }
}