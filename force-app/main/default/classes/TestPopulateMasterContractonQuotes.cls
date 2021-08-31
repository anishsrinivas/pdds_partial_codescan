@Istest
public class TestPopulateMasterContractonQuotes {
    @Istest
    public static void call(){
       
       
        Account acc = new Account();
        acc.Name='Test';
        Insert acc;
        
        //list<Opportunity> oplist = new list<Opportunity>(); 
        Opportunity Bookopp = new Opportunity();
        Bookopp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        Bookopp.name='Testopp';
        Bookopp.Stagename='Investigating';
        Bookopp.closeDate=System.today();
        Bookopp.AccountId=acc.Id;
       // oplist.add(Bookopp);
       Insert Bookopp;
        
        Opportunity Billopp = new Opportunity();
        Billopp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Billopp.name='Testop';
        Billopp.Stagename='Investigating';
        Billopp.closeDate=System.today();
        Billopp.AccountId=acc.Id;
        Billopp.DDS_OID__c='101';
        Billopp.DDS_Practice_Location__c='Test';
        Billopp.ia_crm__Change_Type__c='New MRR';
        Billopp.Linked_Booking_Opportunity__c=Bookopp.Id;
        //oplist.add(Billopp);
        Insert Billopp;
        
        Opportunity Addonopp = new Opportunity();
        Addonopp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Addonopp.name='Testop2';
        Addonopp.Stagename='Investigating';
        Addonopp.closeDate=System.today();
        Addonopp.ia_crm__Change_Type__c='Add on MRR';
        Addonopp.Linked_Booking_Opportunity__c=Bookopp.Id;
        Addonopp.AccountId=acc.Id;
        
        Insert Addonopp;
        
        //list<SBQQ__Quote__c> QuoteList = new list<SBQQ__Quote__c>();
        SBQQ__Quote__c Quote =  new SBQQ__Quote__c();
        Quote.SBQQ__Account__c=acc.Id;
        Quote.SBQQ__Opportunity2__c=Billopp.Id;
        Quote.SBQQ__Primary__c=True;
        //QuoteList.add(Quote);
        Insert Quote;
        
        SBQQ__Quote__c addonQuote =  new SBQQ__Quote__c();
        addonQuote.SBQQ__Account__c=acc.Id;
        addonQuote.SBQQ__Opportunity2__c=Addonopp.Id;
        addonQuote.SBQQ__Primary__c=True;
        
        Insert addonQuote;
        
       Contract con = new Contract();
       con.SBQQ__Opportunity__c=Billopp.ID;
       con.AccountId=acc.Id;
       con.Status='Draft';
       Test.startTest();
       Insert Con;
        
      /* Opportunity op =[select ContractId from opportunity where Id=:Billopp.Id];
       op.ContractId=Con.Id;
       Update op;*/
        
       Test.stopTest();
    }

}