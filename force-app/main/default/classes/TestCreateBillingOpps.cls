@Istest
public class TestCreateBillingOpps {
        @testSetup static void setup() {
       
        Account acc = new Account();
        acc.Name ='Test Acc';
        Insert acc;
        
            
        Id bookingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        Id billingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Opportunity op = new Opportunity();
        op.RecordTypeId=bookingRecordTypeId;
        op.Name='Test Opp';
        op.closeDate=system.today();
        op.stagename='Investigating';
        op.Type='New Business';
        op.DDS_Proposal_Notes__c='Notes';
        op.Current_Imaging_Solution_Software__c='Apteryx DrSuni *';
        op.Services_Performed__c='Dentist';
        op.Other_Notes_for_Onboarding__c='testing imp';
        op.LeadSource='Refferal';
        op.Sales_Qualified_Appointment__c=true;
        Insert op;
        
        Current_Software__c cs= new Current_Software__c();
        cs.Current__c='ACE';
        cs.Quantity__c=1;
        cs.Opportunities__c=op.Id;
        Insert cs;
        
            
        


                    
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = new Product2(
             Name = 'Product X',
             ProductCode = 'Pro-X',
             isActive = true
        );
        insert prod;
        
        PricebookEntry pbEntry = new PricebookEntry(
             Pricebook2Id = pricebookId,
             Product2Id = prod.Id,
             UnitPrice = 100.00,
             IsActive = true
        );
        insert pbEntry;
        
                Test.startTest();
        
        OpportunityLineItem oli = new OpportunityLineItem(
             OpportunityId = op.Id,
             Quantity = 5.0,
             PricebookEntryId = pbEntry.Id,
             TotalPrice = 5 * (pbEntry.UnitPrice)
        );
        insert oli;

        SBQQ__Quote__c Quote =  new SBQQ__Quote__c();
        Quote.SBQQ__Account__c=acc.Id;
        Quote.SBQQ__Opportunity2__c=op.Id;
        Quote.SBQQ__StartDate__c=System.today();
        Quote.SBQQ__Primary__c=True;
        Quote.SBQQ__PricebookId__c=pricebookId;
        Quote.SBQQ__PriceBook__c=pricebookId;
        insert Quote;
        
         
        SBQQ__Quoteline__c Quoteline =  new SBQQ__Quoteline__c();
        Quoteline.SBQQ__Quote__c=Quote.Id;
        Quoteline.SBQQ__Product__c=prod.Id;
        Quoteline.SBQQ__Bundle__c=true;
        Quoteline.SBQQ__ProductSubscriptionType__c='Renewable';
        Quoteline.SBQQ__SubscriptionType__c='Renewable';
        Quoteline.SBQQ__Quantity__c=2;
        Quoteline.DDS_Location__c='Test Loc';
        Insert Quoteline; 
            
        
        
        Test.stopTest();
      
  
    }
    
    @Istest
    Public Static Void CreateOpps(){
       
       Opportunity opp = [select id,SBQQ__PrimaryQuote__c,stagename from opportunity where name ='Test Opp' LIMIT 1];
        opp.stagename='Closed Won';
        
        Test.startTest();
        Update opp;
        Test.stopTest();
        
            }
    

}