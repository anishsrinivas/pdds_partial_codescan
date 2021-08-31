@Istest
public class TestCreateRelatedBookingOpps {
    @Istest
    public static void createBops(){
        BillingOppsAutomation__c billingOppAutomate=new BillingOppsAutomation__c();
        billingOppAutomate.IsActive__c=true;
        billingOppAutomate.Product_Codes__c='Test Product';
        billingOppAutomate.Name='Automation';
        Insert billingOppAutomate;		
        
        Account acc = new Account();
        acc.Name='test';
        Insert acc;
        
        Pricebook2 standardPricebook = new Pricebook2(
        Id = Test.getStandardPricebookId(),
        IsActive = true);
        
        update standardPricebook;
        
        List<Opportunity> Opps = new List<Opportunity>();
        
        Opportunity bookopp = new Opportunity();
        bookopp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        bookopp.name='Testbopp';
        bookopp.StageName='Investigating';
        bookopp.CloseDate=system.today();
        Opps.add(bookopp);
        
         
        Opportunity bookopp2 = new Opportunity();
        bookopp2.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        bookopp2.name='Testbopp2';
        bookopp2.StageName='Investigating';
        bookopp2.CloseDate=system.today();
        Opps.add(bookopp2);
        
        Opportunity Billopp = new Opportunity();
        Billopp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Billopp.name='Testopp';
        Billopp.StageName='Investigating';
        Billopp.CloseDate=system.today();
        Billopp.ia_crm__Change_Type__c='New MRR';
        opps.add(Billopp);
		Insert opps;
     
 Test.startTest();
        Contract con = new Contract();
        con.AccountId=acc.Id;
        con.SBQQ__Opportunity__c=opps[2].Id;
       	con.Status='Draft';
        con.StartDate=system.today();
        Insert Con;
        
  Test.stopTest();
        
        Opportunity opp =[select id,Linked_Booking_Opportunity__c from Opportunity where id=:opps[2].Id];
        opp.Linked_Booking_Opportunity__c=opps[0].Id;
        
        update opp;
        
        Opportunity opp2 =[select id,Linked_Booking_Opportunity__c from Opportunity where id=:opps[2].Id];
        opp2.Linked_Booking_Opportunity__c=bookopp2.Id;
        update opp2;

      
        
        
        
    }

}