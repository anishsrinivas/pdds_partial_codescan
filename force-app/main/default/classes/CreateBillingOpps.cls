public class CreateBillingOpps {
    
    Public static void CreateOpp(Map<Id,Opportunity> oldmap,Map<Id,Opportunity> newmap){
        Id bookingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        Id billingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        set<Id> QuoteIds = new set<Id>();
        Map<Id,Opportunity> updatedOpps = new Map<Id,Opportunity>();
        Map<Id,Id> BookBillMap = new Map<Id,Id>();
        for(opportunity opp : newmap.values()){
            if(oldMap.get(opp.Id).Stagename != newmap.get(opp.Id).Stagename && newmap.get(opp.Id).Stagename=='Closed Won' &&
              newmap.get(opp.Id).RecordTypeID==bookingRecordTypeId && newmap.get(opp.Id).Type !='Existing Business'
              && newmap.get(opp.Id).Claw_Back__c==false){
                updatedOpps.put(opp.Id,opp);
            }
            
        }
        if(updatedOpps.size()>0){
            list<Opportunity> Billingopps=[select Id,Linked_Booking_Opportunity__c from Opportunity where RecordTypeId=:billingRecordTypeId
                                      and Linked_Booking_Opportunity__c in : updatedOpps.keyset()];
              for(Opportunity op: Billingopps){
            BookBillMap.put(op.Linked_Booking_Opportunity__c,op.Id);
        }
        }
        
      
        for(opportunity opp : updatedOpps.values() ){
            if(!BookBillMap.containskey(opp.Id) ){
              QuoteIds.add(opp.SBQQ__PrimaryQuote__c);  
            }
            
        }

        Map<Id,list<SBQQ__Quoteline__c>> oppQuoteMap = new Map<Id,list<SBQQ__Quoteline__c>>();
        Map<Id,list<SBQQ__Quoteline__c>> oppQuoteMap2 = new Map<Id,list<SBQQ__Quoteline__c>>();
        list<SBQQ__Quote__c> Quotelist = new list<SBQQ__Quote__c>();
        list<SBQQ__Quote__c> Quotelist2 = new list<SBQQ__Quote__c>();
        if(QuoteIds.Size()>0){
         Quotelist=[select id,SBQQ__Opportunity2__c,
                                        SBQQ__Account__c,
                                        SBQQ__Opportunity2__r.Name,
                                        SBQQ__Opportunity2__r.LeadSource,SBQQ__Opportunity2__r.Sales_Qualified_Appointment__c,
                                        SBQQ__Opportunity2__r.ABM__c,
                                        SBQQ__Opportunity2__r.Lead_Created_Date__c,SBQQ__Opportunity2__r.Referral_Account__c,
                                        SBQQ__Opportunity2__r.Referral_Contact__c,SBQQ__Opportunity2__r.DDS_Proposal_Notes__c,
                                        SBQQ__Opportunity2__r.DDS_Description__c,SBQQ__Opportunity2__r.DDS_Notes__c,
                                        SBQQ__Opportunity2__r.SalesLoft1__Primary_Contact__c,
                                        SBQQ__Opportunity2__r.Closedate,SBQQ__Opportunity2__r.OwnerId,
                                        SBQQ__StartDate__c,SBQQ__PrimaryContact__c,SBQQ__SubscriptionTerm__c,
                                        (select SBQQ__Quantity__c,SBQQ__Number__c,SBQQ__Discount__c,SBQQ__Product__c,DDS_Location__c,SBQQ__ListPrice__c,DDS_Bundle_Net_Total_Monthly__c,SBQQ__SubscriptionType__c,SBQQ__ProductSubscriptionType__c,DDS_Product_Category__c,DDS_Quote_Account__c,SBQQ__BundledQuantity__c,SBQQ__DefaultSubscriptionTerm__c,SBQQ__Description__c,SBQQ__NetPrice__c,SBQQ__OptionType__c,
                                         SBQQ__OptionLevel__c,SBQQ__OriginalPrice__c,SBQQ__PartnerPrice__c,SBQQ__PricebookEntryId__c,SBQQ__PriceEditable__c,SBQQ__PricingMethodEditable__c,SBQQ__ProductOption__c,SBQQ__ProratedListPrice__c,SBQQ__ProrateMultiplier__c,SBQQ__ProratedPrice__c,
                                         SBQQ__RegularPrice__c,SBQQ__SubscriptionPricing__c from SBQQ__LineItems__r where SBQQ__SubscriptionType__c='Renewable' and SBQQ__Bundle__c=true) from  SBQQ__Quote__c where ID in :QuoteIds];
        
    }
        
        if(QuoteIds.Size()>0){
        Quotelist2=[select id,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Opportunity2__r.Name,SBQQ__Opportunity2__r.Closedate,SBQQ__Opportunity2__r.OwnerId,
                                         SBQQ__StartDate__c,SBQQ__PrimaryContact__c,SBQQ__SubscriptionTerm__c,
                                         (select SBQQ__RequiredBy__r.SBQQ__Product__c,SBQQ__Quantity__c ,SBQQ__RequiredBy__c,SBQQ__Number__c,SBQQ__ComponentDiscountedByPackage__c,SBQQ__Discount__c,SBQQ__Product__c ,DDS_Location__c,SBQQ__ListPrice__c,DDS_Bundle_Net_Total_Monthly__c,SBQQ__SubscriptionType__c,SBQQ__ProductSubscriptionType__c,DDS_Product_Category__c,DDS_Quote_Account__c,SBQQ__BundledQuantity__c,
                                          SBQQ__DefaultSubscriptionTerm__c,SBQQ__Description__c,SBQQ__NetPrice__c,SBQQ__OptionType__c,SBQQ__OptionLevel__c,SBQQ__OriginalPrice__c,SBQQ__PartnerPrice__c,SBQQ__PricebookEntryId__c,SBQQ__PriceEditable__c,SBQQ__PricingMethodEditable__c,SBQQ__ProductOption__c,SBQQ__ProratedListPrice__c,SBQQ__ProrateMultiplier__c,SBQQ__ProratedPrice__c,
                                          SBQQ__RegularPrice__c,SBQQ__SubscriptionPricing__c from SBQQ__LineItems__r where SBQQ__SubscriptionType__c='Renewable' and SBQQ__RequiredBy__c!=NULL) from  SBQQ__Quote__c where ID in :QuoteIds];
            
        }

        list<Opportunity> Billops = new list<Opportunity>();
        Decimal TotalBundleQty=0;
        Map<id,Decimal> QuoteQuantityMap=new Map<id,Decimal>();
        for (SBQQ__Quote__c Qt : Quotelist){
            for(SBQQ__Quoteline__c q:Qt.SBQQ__LineItems__r){
                TotalBundleQty+= q.SBQQ__Quantity__c;
            }
            QuoteQuantityMap.put(Qt.Id,TotalBundleQty);
            oppQuoteMap.put(Qt.SBQQ__Opportunity2__c,Qt.SBQQ__LineItems__r);
        }
         for (SBQQ__Quote__c q : Quotelist2){
            oppQuoteMap2.put(q.SBQQ__Opportunity2__c,q.SBQQ__LineItems__r);
        }
        Map<ID,SBQQ__Quote__c> opbookquotemap = new Map<ID,SBQQ__Quote__c>();

        for (SBQQ__Quote__c Qt : Quotelist){

            opbookquotemap.put(Qt.SBQQ__Opportunity2__c,Qt);
            Decimal i;
            for(i=1;i<=QuoteQuantityMap.get(Qt.Id);i++){
                Opportunity op = new Opportunity();
                op.AccountId=Qt.SBQQ__Account__c;
                op.RecordTypeId=billingRecordTypeId;
                op.name=Qt.SBQQ__Opportunity2__r.Name+':'+' '+'Location'+ ' '+ i +':' +' '+'Billing';
                op.StageName='Investigating';
                op.Closedate=Qt.SBQQ__Opportunity2__r.Closedate;
                op.Linked_Booking_Opportunity__c=Qt.SBQQ__Opportunity2__c;
                op.OwnerId=Qt.SBQQ__Opportunity2__r.OwnerId; 
                op.SalesLoft1__Primary_Contact__c= Qt.SBQQ__Opportunity2__r.SalesLoft1__Primary_Contact__c;
                op.LeadSource=Qt.SBQQ__Opportunity2__r.LeadSource;
                op.Sales_Qualified_Appointment__c=Qt.SBQQ__Opportunity2__r.Sales_Qualified_Appointment__c;
                op.ABM__c=Qt.SBQQ__Opportunity2__r.ABM__c;
                op.Lead_Created_Date__c=Qt.SBQQ__Opportunity2__r.Lead_Created_Date__c;
                op.Referral_Account__c=Qt.SBQQ__Opportunity2__r.Referral_Account__c;
                op.Referral_Contact__c=Qt.SBQQ__Opportunity2__r.Referral_Contact__c;
                op.DDS_Proposal_Notes__c=Qt.SBQQ__Opportunity2__r.DDS_Proposal_Notes__c;
                op.DDS_Description__c=Qt.SBQQ__Opportunity2__r.DDS_Description__c;
                op.DDS_Notes__c=Qt.SBQQ__Opportunity2__r.DDS_Notes__c;
                if(i>1){
                  op.ia_crm__Change_Type__c='Add on MRR';  
                }else{
                    op.ia_crm__Change_Type__c='New MRR'; 
                }
                            
                Billops.add(op);
            }
            
        }
        Insert Billops;
        Map<Id,Id> oppLinkedBkoppMap = new Map<Id,Id>();
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
        Insert BillQuotes;
        
        list<SBQQ__QuoteLine__c> QuoteLines = new list<SBQQ__QuoteLine__c>();
       IF (BillQuotes.SIZE()>0){
           Integer BillingQuoteIndex =0;
              
            for(SBQQ__QuoteLine__c quoteline : oppQuoteMap.get(oppLinkedBkoppMap.get(BillQuotes[0].SBQQ__Opportunity2__c))){
                system.debug(BillQuotes[BillingQuoteIndex].name+'  '+quoteline.SBQQ__Quantity__c);
                Decimal totalQuantity =quoteline.SBQQ__Quantity__c;
                for(integer index=0;index<totalQuantity;index++){
               SBQQ__QuoteLine__c QL = new SBQQ__QuoteLine__c();
               QL.SBQQ__Quote__c=BillQuotes[BillingQuoteIndex].Id;
                BillingQuoteIndex++;
               QL.SBQQ__Product__c=quoteline.SBQQ__Product__c;
               Ql.SBQQ__Quantity__c=1;
               Ql.SBQQ__ProductSubscriptionType__c=quoteline.SBQQ__ProductSubscriptionType__c;
               Ql.SBQQ__SubscriptionType__c=quoteline.SBQQ__SubscriptionType__c;
               QL.SBQQ__ListPrice__c=quoteline.SBQQ__ListPrice__c;
               QL.DDS_Bundle_Net_Total_Monthly__c=quoteline.DDS_Bundle_Net_Total_Monthly__c;
               QL.DDS_Product_Category__c=quoteline.DDS_Product_Category__c;
               QL.DDS_Quote_Account__c=quoteline.DDS_Quote_Account__c;
               QL.SBQQ__DefaultSubscriptionTerm__c=quoteline.SBQQ__DefaultSubscriptionTerm__c;
               QL.SBQQ__Description__c=quoteline.SBQQ__Description__c;
               QL.SBQQ__OriginalPrice__c=quoteline.SBQQ__OriginalPrice__c;
               QL.SBQQ__PricebookEntryId__c=quoteline.SBQQ__PricebookEntryId__c;
               QL.SBQQ__SubscriptionPricing__c=quoteline.SBQQ__SubscriptionPricing__c;
               QL.SBQQ__Discount__c=quoteline.SBQQ__Discount__c;
               QL.SBQQ__Number__c=quoteline.SBQQ__Number__c;
               QuoteLines.add(QL);

            }
            }
        }
        Insert QuoteLines;
        Map<Id,Id> QuoteLineheadermap = new Map<Id,Id>();
        Map<Id,Id> BundleMap = new Map<Id,Id>();
        
        for (SBQQ__QuoteLine__c qcl :QuoteLines ){
            QuoteLineheadermap.put(qcl.SBQQ__Quote__c,qcl.Id);
            BundleMap.put(qcl.SBQQ__Quote__c,qcl.SBQQ__Product__c);
        }
        
        list<SBQQ__QuoteLine__c> QuoteLines2 = new list<SBQQ__QuoteLine__c>();
        if(BillQuotes.Size()>0){
            for (SBQQ__Quote__c quote: BillQuotes){
               Id ReqQuoteId=QuoteLineheadermap.get(quote.Id);
               Id ReqProdId=BundleMap.get(quote.Id);
            for(SBQQ__QuoteLine__c quoteline : oppQuoteMap2.get(oppLinkedBkoppMap.get(quote.SBQQ__Opportunity2__c)) ){
                IF(ReqProdId==quoteline.SBQQ__RequiredBy__r.SBQQ__Product__c){
               SBQQ__QuoteLine__c QL = new SBQQ__QuoteLine__c();
               QL.SBQQ__Quote__c=quote.Id;
               QL.SBQQ__Product__c=quoteline.SBQQ__Product__c;
               Ql.SBQQ__Quantity__c=1;
               Ql.SBQQ__ProductSubscriptionType__c=quoteline.SBQQ__ProductSubscriptionType__c;
               Ql.SBQQ__SubscriptionType__c=quoteline.SBQQ__SubscriptionType__c;
               QL.SBQQ__ListPrice__c=quoteline.SBQQ__ListPrice__c;
               QL.SBQQ__RequiredBy__c=ReqQuoteId;
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

               QuoteLines2.add(QL);
            }
          }  
        }
    }
        Insert QuoteLines2;
    }
    


}