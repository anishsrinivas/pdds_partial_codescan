/************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Status           Development Completed
* @description      Test Class for 'BatchCreateBillOpportunities'
                   
***************************************************************************************************************************
Version    	Date        	Team    	Comments
***************************************************************************************************************************
* 1         20 Nov 2020     Ramana     Test Class for 'BatchCreateBillOpportunities'
***************************************************************************************************************************/
@Istest
public class TestBatchCreateBillOpportunities {
    @Istest
    public Static Void CreateOpps(){
       
        Account acc = new Account();
        acc.Name ='Test Acc';
        Insert acc;
        
        BillingOppsAutomation__c bcs = new BillingOppsAutomation__c();
        bcs.name='Automation';
        bcs.IsActive__c=true;
        bcs.Product_Codes__c = '78111-Bundle,Copy of 78111';
        Insert bcs;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        list<Product2> prodlist = new list<Product2>();
        for( integer i=1;i<=3;i++){
            Product2 prod = new Product2();
            prod.Name = 'Testp'+i;
            prod.ProductCode = 'TP'+i;
            prod.isActive = true;
            prodlist.add(prod);
        }

        insert prodlist;
       
        list<PricebookEntry> pbelist = new list<PricebookEntry>();
        
        for(Product2 pd :prodlist){
            
             PricebookEntry pbEntry = new PricebookEntry();
             pbEntry.Pricebook2Id = pricebookId;
             pbEntry.Product2Id = pd.Id;
             pbEntry.UnitPrice = 100.00;
             pbEntry.IsActive = true;
             pbelist.add(pbEntry);
       
        }

        insert pbelist;
        
            
        Id bookingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        Opportunity op = new Opportunity();
        op.RecordTypeId=bookingRecordTypeId;
        op.AccountId=acc.Id;
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
        op.Pricebook2Id=pricebookId;
        op.Needs_Implementation__c='No';
        Insert op;
        
       
        Current_Software__c cs= new Current_Software__c();
        cs.Current__c='ACE';
        cs.Quantity__c=1;
        cs.Opportunities__c=op.Id;
        Insert cs;
        
        Test.startTest();  
        SBQQ__Quote__c Quote =  new SBQQ__Quote__c();
        Quote.SBQQ__Account__c=acc.Id;
        Quote.SBQQ__Opportunity2__c=op.Id;
        Quote.SBQQ__StartDate__c=System.today();
        Quote.SBQQ__Primary__c=True;
        Quote.SBQQ__PricebookId__c=pricebookId;
        Quote.SBQQ__PriceBook__c=pricebookId;
        insert Quote;
        
        SBQQ.TriggerControl.disable();
        
        try{
        SBQQ__Quoteline__c QlHeader =  new SBQQ__Quoteline__c();
        QlHeader.SBQQ__Quote__c=Quote.Id;
        QlHeader.SBQQ__Product__c=prodlist[0].Id;
        QlHeader.SBQQ__Bundle__c=true;
        QlHeader.SBQQ__ProductSubscriptionType__c='Renewable';
        QlHeader.SBQQ__SubscriptionType__c='Renewable';
        QlHeader.SBQQ__Quantity__c=1;
        QlHeader.DDS_Location__c='Test Loc';
        Insert QlHeader; 
        
         
        SBQQ__Quoteline__c Qlchild =  new SBQQ__Quoteline__c();
        Qlchild.SBQQ__Quote__c=Quote.Id;
        Qlchild.SBQQ__Product__c=prodlist[1].Id;
        Qlchild.SBQQ__RequiredBy__c=QlHeader.Id;
        Qlchild.SBQQ__ProductSubscriptionType__c='Renewable';
        Qlchild.SBQQ__SubscriptionType__c='Renewable';
        Qlchild.SBQQ__Quantity__c=1;
        Insert Qlchild; 
        
        //changes for PLAN-1012 starts
        SBQQ__Quoteline__c Qlchild2 =  new SBQQ__Quoteline__c();
        Qlchild2.SBQQ__Quote__c=Quote.Id;
        Qlchild2.SBQQ__Product__c=prodlist[2].Id;
        Qlchild2.SBQQ__ProductSubscriptionType__c='One-time';
        Qlchild2.SBQQ__SubscriptionType__c='One-time';
        Qlchild2.SBQQ__Quantity__c=1;
        Insert Qlchild2; 
		//changes for PLAN-1012 ends 
		//           
        }
        Finally{
            
           SBQQ.TriggerControl.enable();
            
          
        } 
        
         OpportunityLineItem oli = new OpportunityLineItem(
             OpportunityId = op.Id,
             Quantity = 5.0,
             PricebookEntryId = pbelist[0].Id,
             TotalPrice = 5 * (pbelist[0].UnitPrice)
        );
        insert oli;

       
        Opportunity opp = [select id,stagename from opportunity where Id=:op.Id];
        opp.stagename='Closed Won';
        RecursiveTriggerHandler.isFirstTime=true;
        Update opp;
        
        Test.stopTest();
        

        
            }

}