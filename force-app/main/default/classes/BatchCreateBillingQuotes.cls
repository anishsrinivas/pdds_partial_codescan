/************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Status           Development Completed
* @description      This  Batch class is Invoked from Batch class 'BatchCreateBillOpportunities' to create Quotes
                    and Quotelines for the Billing opportunities created by Batch class 'BatchCreateBillOpportunities'
                   
***************************************************************************************************************************
Version    	Date        	Team    	Comments
*********************************************************************************************
* 1         20 Nov 2020     Ramana     Batch Class for creating Billing Quotes
*********************************************************************************************/
global class BatchCreateBillingQuotes implements Database.Batchable<sObject>,Database.Stateful {
    Set<Id> BillOppIds=new Set<Id>();
    Map<ID,SBQQ__Quote__c> opbookquotemap = new Map<ID,SBQQ__Quote__c>();
    Map<Id,Id> oppLinkedBkoppMap = new Map<Id,Id>();
    list<SBQQ__Quote__c> BillingQuotes = new list<SBQQ__Quote__c>();
    Map<String,list<SBQQ__Quoteline__c>> QuotelineMap = new Map<String,list<SBQQ__Quoteline__c>>();
    global  Integer Ind=1 ;
    global BatchCreateBillingQuotes(Set<Id> BillOppIds,Map<ID,SBQQ__Quote__c> opbookquotemap,
       Map<String,list<SBQQ__Quoteline__c>> QuotelineMap ){
                                     
        this.BillOppIds= BillOppIds;
        this.opbookquotemap=opbookquotemap;
        this.QuotelineMap=QuotelineMap;                                                                                                                                      
                                        
    }

    global database.QueryLocator Start(database.BatchableContext bc){
        
        String query ='SELECT id ,AccountId,Linked_Booking_Opportunity__c FROM Opportunity where Id in :BillOppIds'; 

        RETURN database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Opportunity> Billops){

      
        list<SBQQ__Quote__c> BillQuotes = new list<SBQQ__Quote__c>();
        for(Opportunity op : Billops){
            oppLinkedBkoppMap.put(op.Id,op.Linked_Booking_Opportunity__c);
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Opportunity2__c=op.Id;
            Quote.SBQQ__Account__c=op.AccountId;
            Quote.SBQQ__StartDate__c=opbookquotemap.get(op.Linked_Booking_Opportunity__c).SBQQ__StartDate__c;
            Quote.SBQQ__PrimaryContact__c=opbookquotemap.get(op.Linked_Booking_Opportunity__c).SBQQ__PrimaryContact__c;
            Quote.SBQQ__SubscriptionTerm__c=opbookquotemap.get(op.Linked_Booking_Opportunity__c).SBQQ__SubscriptionTerm__c;
            Quote.SBQQ__Primary__c=true;
            BillQuotes.add(Quote);
        }
        

        if(BillQuotes.size()>0){
            Insert BillQuotes;
        }
        
        
         SBQQ.TriggerControl.disable();
        
        try{
        list<SBQQ__QuoteLine__c> Quotelineheader = new list<SBQQ__QuoteLine__c>();
        
        String OPBKId =oppLinkedBkoppMap.get(BillQuotes[0].SBQQ__Opportunity2__c);
        String OPQID=Ind+OPBKId;
        
        for(SBQQ__QuoteLine__c qtline: QuotelineMap.get(OPQID)){
                       
            If(qtline.SBQQ__Bundle__c==true ){
                
               SBQQ__QuoteLine__c QL = new SBQQ__QuoteLine__c();
               QL.SBQQ__Quote__c=BillQuotes[0].Id;
               QL.SBQQ__Product__c=qtline.SBQQ__Product__c;
               Ql.SBQQ__Quantity__c=1;
               Ql.SBQQ__Bundle__c=True;
               Ql.SBQQ__ProductSubscriptionType__c=qtline.SBQQ__ProductSubscriptionType__c;
               Ql.SBQQ__SubscriptionType__c=qtline.SBQQ__SubscriptionType__c;
               QL.SBQQ__ListPrice__c=qtline.SBQQ__ListPrice__c;
               QL.DDS_Bundle_Net_Total_Monthly__c=qtline.DDS_Bundle_Net_Total_Monthly__c;
               QL.DDS_Product_Category__c=qtline.DDS_Product_Category__c;
               QL.DDS_Quote_Account__c=qtline.DDS_Quote_Account__c;
               QL.SBQQ__DefaultSubscriptionTerm__c=qtline.SBQQ__DefaultSubscriptionTerm__c;
               QL.SBQQ__Description__c=qtline.SBQQ__Description__c;
               QL.SBQQ__OriginalPrice__c=qtline.SBQQ__OriginalPrice__c;
               QL.SBQQ__PricebookEntryId__c=qtline.SBQQ__PricebookEntryId__c;
               QL.SBQQ__SubscriptionPricing__c=qtline.SBQQ__SubscriptionPricing__c;
               QL.SBQQ__Discount__c=qtline.SBQQ__Discount__c;
               QL.SBQQ__Number__c=qtline.SBQQ__Number__c;
               Quotelineheader.add(QL) ;
                           
            }      
            
        }
        
        
        Insert Quotelineheader;       
        
        list<SBQQ__QuoteLine__c> Quotelinechilds = new list<SBQQ__QuoteLine__c>();
            

         for(SBQQ__QuoteLine__c quoteline: QuotelineMap.get(OPQID)){
                       
            If(quoteline.SBQQ__Bundle__c==false && quoteline.SBQQ__RequiredBy__c!=NULL ){
                
               SBQQ__QuoteLine__c QL = new SBQQ__QuoteLine__c();
               QL.SBQQ__Quote__c=BillQuotes[0].Id;
               QL.SBQQ__Product__c=quoteline.SBQQ__Product__c;
               Ql.SBQQ__Quantity__c=1;
               Ql.SBQQ__ProductSubscriptionType__c=quoteline.SBQQ__ProductSubscriptionType__c;
               Ql.SBQQ__SubscriptionType__c=quoteline.SBQQ__SubscriptionType__c;
               QL.SBQQ__ListPrice__c=quoteline.SBQQ__ListPrice__c;
               QL.SBQQ__RequiredBy__c=Quotelineheader[0].Id;
               QL.SBQQ__Discount__c=quoteline.SBQQ__Discount__c;
               QL.DDS_Product_Category__c=quoteline.DDS_Product_Category__c;
               QL.SBQQ__BundledQuantity__c=quoteline.SBQQ__BundledQuantity__c;
               QL.SBQQ__DefaultSubscriptionTerm__c=quoteline.SBQQ__DefaultSubscriptionTerm__c;
               QL.SBQQ__Description__c=quoteline.SBQQ__Description__c;
               QL.SBQQ__NetPrice__c=quoteline.SBQQ__NetPrice__c;
               QL.SBQQ__OptionType__c=quoteline.SBQQ__OptionType__c;
               QL.SBQQ__OptionLevel__c=quoteline.SBQQ__OptionLevel__c;
               QL.SBQQ__OriginalPrice__c=quoteline.SBQQ__OriginalPrice__c;
               QL.SBQQ__PartnerPrice__c=quoteline.SBQQ__PartnerPrice__c;
               QL.SBQQ__PricebookEntryId__c=quoteline.SBQQ__PricebookEntryId__c;
               QL.SBQQ__PriceEditable__c=quoteline.SBQQ__PriceEditable__c;
               QL.SBQQ__PricingMethodEditable__c=quoteline.SBQQ__PricingMethodEditable__c;
               QL.SBQQ__ProductOption__c=quoteline.SBQQ__ProductOption__c;
               QL.SBQQ__ProratedListPrice__c=quoteline.SBQQ__ProratedListPrice__c;
               QL.SBQQ__ProrateMultiplier__c=quoteline.SBQQ__ProrateMultiplier__c;
               QL.SBQQ__ProratedPrice__c=quoteline.SBQQ__ProratedPrice__c;
               QL.SBQQ__RegularPrice__c=quoteline.SBQQ__RegularPrice__c;
               QL.SBQQ__SubscriptionPricing__c=quoteline.SBQQ__SubscriptionPricing__c;
               QL.SBQQ__Number__c=quoteline.SBQQ__Number__c;
               QL.SBQQ__ComponentDiscountedByPackage__c=quoteline.SBQQ__ComponentDiscountedByPackage__c;

               Quotelinechilds.add(QL);
                           
            }      
            
        }
        
        Insert Quotelinechilds;       
  
        Ind=Ind+1;
         
        }
        Finally{
            
           SBQQ.TriggerControl.enable();
            
          
        } 

    }
    global void finish(database.BatchableContext bc){
      

        
}
}