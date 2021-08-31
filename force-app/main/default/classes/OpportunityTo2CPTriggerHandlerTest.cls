@isTest
public class OpportunityTo2CPTriggerHandlerTest {
    
    @testSetup
    public static void loadTestData()
    {
        Account accountRecord = new Account();
        
        accountRecord.Name = '2CP Demo Account';
        accountRecord.BillingStreet = 'test';
        accountRecord.BillingCity = 'Irvine';
        accountRecord.BillingCountry = 'USA';
        accountRecord.BillingState = 'CA';
        accountRecord.BillingPostalCode = '560123';
        accountRecord.PGID__c = 2244;                                                                
        accountRecord.PGID_OID__c = '2244-888';                                                         
        accountRecord.DBA__c = '2CP Demo Account';                                                      
        accountRecord.ia_crm__IntacctID__c = '2244-000';                                                
        accountRecord.ia_crm__Email_ID__c = 'sfadmin@demandblue.com';   
        accountRecord.Description = 'Test';
        accountRecord.Notes__c = 'Test';

        insert accountRecord;
        
        
        BillingOppsAutomation__c bcs = new BillingOppsAutomation__c();
        bcs.name='Automation';
        bcs.IsActive__c=true;
        Insert bcs;
        
        Id billingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();


        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Name = '2CP Demo Opportunity';                                                                              
        opportunityRecord.CloseDate = system.today();
        opportunityRecord.RecordTypeId = billingOpportunityRecordTypeId;
        opportunityRecord.AccountId = accountRecord.Id;                                                                              
        opportunityRecord.StageName = 'Investigating';                                                                                
        opportunityRecord.Probability = 10;                                                                                           
        opportunityRecord.Amount = 5965.00;   
        opportunityRecord.Is_Created_By_Batch__c = true;
        opportunityRecord.SBQQ__Contracted__c = false;                                                                               
      
    
    insert opportunityRecord;
            
        
    }
    
    public static testmethod void run2CPTrigger()
    {
        Opportunity opportunityRecord = [Select Id from Opportunity LIMIT 1];
        
        test.startTest();
        
        StaticResourceCalloutMock  mock = new StaticResourceCalloutMock ();
        mock.setStaticResource('TProMockResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        
        
        Test.setMock(HttpCalloutMock.class, mock);
        
        opportunityRecord.Payment_Type__c = 'Credit Card';
        opportunityRecord.Card_Holder_Name__c = 'Vignesh';                                                                            
      opportunityRecord.Credit_Card_Number__c = '323456789123456';                                                              
      opportunityRecord.CC_Expiration_Month_Year__c = '12/2022';                                                                              
        opportunityRecord.Amount = 523456;
        
        update opportunityRecord;
        
        
        test.stopTest();
        
        
    }
    
    public static testmethod void run2CPTriggerResponse2()
    {
        Opportunity opportunityRecord = [Select Id from Opportunity LIMIT 1];
        
        test.startTest();
        
        StaticResourceCalloutMock  mock = new StaticResourceCalloutMock ();
        mock.setStaticResource('TProMockResponse2');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        
        
        Test.setMock(HttpCalloutMock.class, mock);
        
        opportunityRecord.Amount = 523456;
        opportunityRecord.Payment_Type__c = 'Account';
      opportunityRecord.TPro_Account_Name__c = 'Vignesh';
      opportunityRecord.ACH_Number__c = '123456789098';
      opportunityRecord.Routing_Number__c = '123456789';
        update opportunityRecord;
        
        
        test.stopTest();
    }

}