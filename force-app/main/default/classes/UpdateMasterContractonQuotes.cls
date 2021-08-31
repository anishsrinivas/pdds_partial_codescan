/*******************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Status           Development Completed
* @description      This  class is Invoked from Contract_Trigger when ever a Contract is Created for Billing Opportunity
                    and find out all related Add on Opportunity Quotes and Invokes Batch Class 'BatchUpdateMasterContractonQuotes'
                    to update the Master Contract field on Add on Opportunity Quotes.
********************************************************************************************************************************
Version    	Date        	Team    	Comments
*******************************************************************************************************************************
* 1         20 Nov 2020     Ramana      Class for updating Master Contract on Quotes
********************************************************************************************************************************/
public class UpdateMasterContractonQuotes {

    Public static void UpdateMasterContract(list<Contract> conlist){
    Id billingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
         Map<Id,Id> OppsContractMap = new Map<Id,Id>();
            
        for(contract c : conlist){
         
            if(c.SBQQ__Opportunity__c!=NULL  && c.Renewal_Contract__c!=true){
                   
                    OppsContractMap.put(c.SBQQ__Opportunity__c,c.Id);     
                
            }
         }    
        Map<Id,Id> OppsBookBillMap = new Map<Id,Id>();
        list<Opportunity> Opplist= new list<Opportunity>();
        If(OppsContractMap.Size()>0){
              Opplist =[select Id,Linked_Booking_Opportunity__c,ContractId from Opportunity
                        where ia_crm__Change_Type__c='New MRR' and RecordtypeId=:billingRecordTypeId
                        and Id in :OppsContractMap.keySet()];
            
                for(opportunity opp : Opplist){
                
                OppsBookBillMap.put(opp.Linked_Booking_Opportunity__c,opp.Id);

              }
            
        }

     list<Opportunity> AddOnoplist = new list<Opportunity>();
    if(OppsBookBillMap.size()>0){
         AddOnoplist= [select id,Linked_Booking_Opportunity__c,SBQQ__PrimaryQuote__c from Opportunity where 
                                  ia_crm__Change_Type__c='Add on MRR' and Linked_Booking_Opportunity__c!=NULL
                                  and RecordtypeId=:billingRecordTypeId
                                  and Linked_Booking_Opportunity__c in :OppsBookBillMap.keySet()];
    }
        
     set<Id> AddonQuoteIds = new set<Id>();
    for(Opportunity op:AddOnoplist ){
        AddonQuoteIds.add(op.SBQQ__PrimaryQuote__c);
    }
     

    If(AddonQuoteIds.Size()>0){
        
          database.executeBatch(new BatchUpdateMasterContractonQuotes(AddonQuoteIds,OppsContractMap,OppsBookBillMap),1);
    }


}
}