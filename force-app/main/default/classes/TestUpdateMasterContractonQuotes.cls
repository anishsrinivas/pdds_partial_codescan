/************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Status           Development Completed
* @description      Test Class for 'UpdateMasterContractonQuotes'
                   
***************************************************************************************************************************
Version    	Date        	Team    	Comments
***************************************************************************************************************************
* 1         20 Nov 2020     Ramana     Test Class for 'UpdateMasterContractonQuotes'
***************************************************************************************************************************/
@Istest
public class TestUpdateMasterContractonQuotes {
    @Istest
    public static void UpdateMasterContract(){
       
       
        Account acc = new Account();
        acc.Name='Test';
        Insert acc;
        
        BillingOppsAutomation__c cs = new BillingOppsAutomation__c();
        cs.name='Automation';
        cs.IsActive__c=true;
        Insert cs;
        
        Opportunity Bookopp = new Opportunity();
        Bookopp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        Bookopp.name='Testopp';
        Bookopp.Stagename='Investigating';
        Bookopp.closeDate=System.today();
        Bookopp.AccountId=acc.Id;

       Insert Bookopp;
        
        Opportunity Billopp = new Opportunity();
        Billopp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Billopp.name='Testop';
        Billopp.Stagename='Investigating';
        Billopp.closeDate=System.today();
        Billopp.AccountId=acc.Id;
        Billopp.DDS_OID__c='101';
        Billopp.DDS_Practice_Location__c='Test';
        Billopp.ia_crm__Change_Type__c='New MRR';
        Billopp.Linked_Booking_Opportunity__c=Bookopp.Id;

        Insert Billopp;
        
        Test.startTest();
        Opportunity Addonopp = new Opportunity();
        Addonopp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Addonopp.name='Testop2';
        Addonopp.Stagename='Investigating';
        Addonopp.closeDate=System.today();
        Addonopp.ia_crm__Change_Type__c='Add on MRR';
        Addonopp.Linked_Booking_Opportunity__c=Bookopp.Id;
        Addonopp.AccountId=acc.Id;
        
        Insert Addonopp;
        
        
        SBQQ__Quote__c addonQuote =  new SBQQ__Quote__c();
        addonQuote.SBQQ__Account__c=acc.Id;
        addonQuote.SBQQ__Opportunity2__c=Addonopp.Id;
        addonQuote.SBQQ__Primary__c=True;
        
        Insert addonQuote;
        
       Contract con = new Contract();
       con.SBQQ__Opportunity__c=Billopp.ID;
       con.AccountId=acc.Id;
       con.Status='Draft';

        Insert Con;

       Test.stopTest();
    }

}