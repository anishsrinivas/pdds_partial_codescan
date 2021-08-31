@isTest(SeeAllData=false)
public class Batch_UpdateSupportEndDateTest {

       
    @testsetup
    public static void createData(){
        Account acc = new Account();
        acc.Name='Test';
        acc.Notes__c = 'Test';
        acc.Description = 'Test';
        Insert acc;
        
        Account EndCustomerAccount = new Account();
        EndCustomerAccount.Name = 'EndCustomer Account';
        Insert EndCustomerAccount;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        BillingOppsAutomation__c cs = new BillingOppsAutomation__c();
        cs.name='Automation';
        cs.Product_Codes__c = 'Test Product Code';
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
        Billopp.New_Record_Type__c = 'Billing';
        Billopp.AccountId=acc.Id;
        Billopp.DDS_OID__c='101';
        Billopp.DDS_Practice_Location__c='Test';
        Billopp.ia_crm__Change_Type__c='New MRR';
        Billopp.Linked_Booking_Opportunity__c=Bookopp.Id;
        Billopp.Pricebook2Id = pricebookId;
        
        Test.startTest();
        Insert Billopp;
        
        
        
        Product2 prod = new Product2();
        prod.name='TestProd';
        prod.ProductCode = '12345';
        prod.IsActive = true;
        prod.Product_License_Categories__c = 'Support';
        Insert prod;
        
        PriceBookEntry pbEntry = new PriceBookEntry();
        pbEntry.Pricebook2Id = pricebookId;
        pbEntry.IsActive = True;
        pbEntry.Product2Id =prod.Id;
        pbEntry.UnitPrice = 20;
        Insert pbEntry;
        
        SBQQ__Quote__c Quote =  new SBQQ__Quote__c();
        Quote.SBQQ__Account__c=acc.Id;
        Quote.SBQQ__Opportunity2__c=Billopp.Id;
        Quote.SBQQ__Primary__c=True;
        
        Insert Quote;
        
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Quote__c = Quote.Id;
        ql.SBQQ__Quantity__c  = 1;
        ql.SBQQ__Product__c = prod.Id;
        ql.End_Customer_Ship_To_Account__c =  EndCustomerAccount.Id;
        
        Insert ql;
        Test.stopTest();  
        
        
    }
    
    public testmethod static void closeOpp(){
        Test.startTest();  
        Opportunity Billopp = [Select Id,StageName,AccountId,End_Customer_Ship_To_Account__c From Opportunity Where  Name ='Testop' limit 1];
        
        Billopp.SBQQ__Contracted__c = True;
        Billopp.StageName = 'Closed Won';
        
        Update Billopp;
        
        
        Contract con = new Contract();
        con.AccountId = Billopp.AccountId;
        con.Status = 'Draft';
        con.StartDate = system.today();
        con.EndDate = system.today() + 30;
        //con.SBQQ__Opportunity__c = Billopp.Id;
        
        Insert con;
        
        con.Status = 'Activated';
        Update con;
        Test.stopTest();
        system.debug('TESTCLASSContract-->'+con.Status);
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Account__c = Billopp.AccountId;
        sub.End_Customer_Ship_To_Account__c = Billopp.End_Customer_Ship_To_Account__c;
        sub.SBQQ__Product__c = [Select Id From Product2 Where Name = 'TestProd' limit 1].Id;
        sub.SBQQ__QuoteLine__c = [Select Id from SBQQ__QuoteLine__c Where SBQQ__Product__r.Name = 'TestProd' limit 1].Id;
        sub.SBQQ__Quantity__c = 1;
        sub.SBQQ__Contract__c = con.Id;
        
        Insert sub;
        
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c();
        sub1.SBQQ__Account__c = Billopp.AccountId;
        sub1.End_Customer_Ship_To_Account__c = Billopp.End_Customer_Ship_To_Account__c;
        sub1.SBQQ__Product__c = [Select Id From Product2 Where Name = 'TestProd' limit 1].Id;
        sub1.SBQQ__QuoteLine__c = [Select Id from SBQQ__QuoteLine__c Where SBQQ__Product__r.Name = 'TestProd' limit 1].Id;
        sub1.SBQQ__Quantity__c = 2;
        sub1.SBQQ__RevisedSubscription__c = sub.Id;
        sub1.SBQQ__Contract__c = con.Id;
        
        Insert sub1;
        
        Batch_UpdateSupportEndDate bc = new Batch_UpdateSupportEndDate();
        Id batchId = Database.executeBatch(bc,200);
        
    }

}