global class BatchUpdateFieldsOnEmptyQuotelines implements Database.Batchable<sObject> {
    List<Opportunity> opportunityList=new List<Opportunity>();
    Map<Id,Opportunity> OldOpportunityMap=new Map<Id,Opportunity>();
    global Set<Id> quoteLinesSet = new Set<Id>();
     List<SBQQ__QuoteLine__c> updateQuoteLines = new List<SBQQ__QuoteLine__c>();
     List<SBQQ__Quote__c> updateQuote = new List<SBQQ__Quote__c>();
     Set<Id> primaryQuoteId = new Set<Id>();
     Id billingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();     
    
    global BatchUpdateFieldsOnEmptyQuotelines(List<Opportunity> opportunityList,Map<Id,Opportunity> OldOpportunityMap){
        this.opportunityList= opportunityList;
        this.OldOpportunityMap=OldOpportunityMap;
    }    
global Database.QueryLocator start(Database.BatchableContext BC) {
            for(Opportunity opp:opportunityList){
                if(opp.StageName != OldOpportunityMap.get(opp.Id).StageName && opp.StageName == 'Closed Won' && opp.RecordTypeId == billingRecordTypeId)
                    primaryQuoteId.add(opp.SBQQ__PrimaryQuote__c);
            }
		String query = 'Select Id,Name,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.End_Customer_Ship_To_Account__c,SBQQ__Opportunity2__r.DDS_OID__c,SBQQ__Opportunity2__r.DDS_Practice_Location__c,                                                           (Select Id,OID__c,MEMO_LINE__c,End_Customer_Ship_To_Account__c,SBQQ__RenewedSubscription__c From SBQQ__LineItems__r Where DDS_Location__c = null OR MEMO_LINE__c = null OR End_Customer_Ship_To_Account__c = null) From SBQQ__Quote__c Where Id=:primaryQuoteId';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> quoteAndQuoteLinesList) {
        system.debug('quoteAndQuoteLinesList====>'+quoteAndQuoteLinesList);
            for(SBQQ__Quote__c qt: quoteAndQuoteLinesList){
                SBQQ__Quote__c updateQT = new SBQQ__Quote__c();
                updateQT.Id = qt.Id;
                updateQT.SBQQ__Status__c = 'Approved';
                updateQuote.add(updateQT);
                
                if(qt.SBQQ__LineItems__r.size() > 0){
                    for(SBQQ__QuoteLine__c ql:qt.SBQQ__LineItems__r){
                        SBQQ__QuoteLine__c updateQL = new SBQQ__QuoteLine__c();
                        updateQL.Id = ql.Id;
                        if(ql.End_Customer_Ship_To_Account__c == null && ql.SBQQ__RenewedSubscription__c == null){
                            updateQL.End_Customer_Ship_To_Account__c = qt.SBQQ__Opportunity2__r.End_Customer_Ship_To_Account__c;
                        }
                        if(ql.MEMO_LINE__c == null && ql.SBQQ__RenewedSubscription__c == null){
                            updateQL.MEMO_LINE__c = qt.SBQQ__Opportunity2__r.DDS_Practice_Location__c;
                        }
                        if(ql.OID__c == null && ql.SBQQ__RenewedSubscription__c == null){
                            updateQL.OID__c = qt.SBQQ__Opportunity2__r.DDS_OID__c;
                        }
                        updateQuoteLines.add(updateQL);
                        quoteLinesSet.add(ql.Id);
                    }
                }
            }
        try {

            
            SBQQ.TriggerControl.disable();
            
            if(!updateQuoteLines.isEmpty()){
                Database.Update (updateQuoteLines,false);
            }
            
            if(!updateQuote.isEmpty()){
                Database.Update (updateQuote,false);
            }
         
        } 
        
        catch(Exception e) {
            System.debug(e);
        }
        
        Finally{
            SBQQ.TriggerControl.enable();
            
            List<OpportunityLineItem> oppLineItemsList = [Select Id,Memo_Line__c,OID__c,End_Customer_Ship_To_Account__c,
                                                          SBQQ__QuoteLine__r.MEMO_LINE__c,SBQQ__QuoteLine__r.OID__c,SBQQ__QuoteLine__r.End_Customer_Ship_To_Account__c
                                                          From OpportunityLineItem Where SBQQ__QuoteLine__c=:quoteLinesSet];
            for(OpportunityLineItem oli:oppLineItemsList){
                oli.Memo_Line__c = oli.SBQQ__QuoteLine__r.MEMO_LINE__c;
                oli.OID__c = oli.SBQQ__QuoteLine__r.OID__c;
                oli.End_Customer_Ship_To_Account__c = oli.SBQQ__QuoteLine__r.End_Customer_Ship_To_Account__c;
            }
            if(!oppLineItemsList.isEmpty()){
                Database.Update (oppLineItemsList,false);
            }
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {

    }
}