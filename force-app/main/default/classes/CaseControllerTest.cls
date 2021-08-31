/*******************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Status           Development Completed
* @description      This Test class is for populating default values for case
*********************************************************************************************
Version    	Date        	Team    	Comments
*********************************************************************************************
* 1         9 Nov 2020     Pradeep     Test Class for CaseTrigger and CaseController
*********************************************************************************************/

@istest
public class CaseControllerTest {
    @istest
    public static void CasecreationTest()
    {  
        //Assigning default owner as Mike Huffaker
        User userrecord=[select id from user where name='Mike Huffaker'];
        List<Case> Caselist=new list <Case>();
        Case caseobject=new case();
        caseobject.Origin='Implementation';              //Default to Implementation 
        caseobject.Status='New';                         //Default to New 
        caseobject.type='Billing';                       //Default to Billing 
        caseobject.Case_Owner__c=userrecord.id;
        //Defaulting the Description
        caseobject.Description= 'Subject:[PGID/OID] [Practice Name] – Custom Programming Pricing Request \r\nBrief Description of Request:\r\nEstimated number of hours:\r\nCustomer Disposition:\r\n';
        //Default value if Case Reason is not empty
        if(caseobject.Case_Reason__c!=null)
        {
            caseobject.Subject=caseobject.Account_name_formula__c +' '+ caseobject.Case_Reason__c +' '+'Pricing Request';
        }
        else            //Default value if Case Reason is empty
        {
            caseobject.Subject=caseobject.Account_name_formula__c + ' ' +'Pricing Request';   
        }
        Caselist.add(caseobject);
        
        insert Caselist;   //Insert Case
    }
    
}