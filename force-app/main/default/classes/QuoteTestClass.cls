@isTest
public class QuoteTestClass {
    public static testMethod void TestDisplayQuote1() {
        
        
      BillingOppsAutomation__c bcs = new BillingOppsAutomation__c();
      bcs.name='Automation';
      bcs.IsActive__c=false;
      Insert bcs;
        
      Opportunity op = new Opportunity();
      op.name='Testop';
      op.StageName='Investigating';
      op.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
      op.CloseDate=system.today();
      insert op;
      SBQQ__Quote__c quote = new SBQQ__Quote__c();
      quote.SBQQ__Opportunity2__c=op.Id;
      quote.SBQQ__Type__c='Quote';
      insert quote;
        
      SBQQ__Quote__c quote2 = new SBQQ__Quote__c();
      quote2.SBQQ__Type__c='Amendment';
      quote2.SBQQ__Opportunity2__c=op.Id;
      insert quote2;
    }
}