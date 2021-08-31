@isTest(SeeAllData=false)
Public class UpdateAccountContractEndDateBatch_Test {
    public static testMethod void testExpDate(){
       
        
        Account acc = new Account();
        acc.Name='Test';
        acc.BillingStreet = 'Burlington';
        acc.BillingCity = 'Miami';
        acc.BillingState = 'Florida';
        acc.BillingPostalCode = '12345';
        acc.BillingCountry ='US';
        acc.SBQQ__RenewalModel__c='Contract Based';
        acc.SBQQ__RenewalPricingMethod__c='Uplift';
        Insert acc;
        
        Account acc2 = new Account();
        acc2.Name='Test';
        acc2.BillingStreet = 'Burlington';
        acc2.BillingCity = 'Miami';
        acc2.BillingState = 'Florida';
        acc2.BillingPostalCode = '12345';
        acc2.BillingCountry ='US';
        acc2.SBQQ__RenewalModel__c='Contract Based';
        acc2.SBQQ__RenewalPricingMethod__c='Uplift';
        Insert acc2;
        
        BillingOppsAutomation__c cs = new BillingOppsAutomation__c();
        cs.name='Automation';
        cs.IsActive__c=true;
        Insert cs;
        
        Opportunity Bookopp = new Opportunity();
        Bookopp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Bookopp.name='Testopp';
        Bookopp.Stagename='Investigating';
        Bookopp.closeDate=System.today();
        Bookopp.DDS_OID__c='102';
        Bookopp.DDS_Practice_Location__c='Test';
        Bookopp.Current_Imaging_Solution_Software__c = 'Apteryx *';
        Bookopp.Services_Performed__c = 'Dentist';
        Bookopp.Other_Notes_for_Onboarding__c = 'Test';
        Bookopp.DDS_Proposal_Notes__c = 'Test Proposal';
        Bookopp.Type = 'New Business';
        Bookopp.ia_crm__Change_Type__c='New MRR';
        Bookopp.AccountId=acc.Id;
        
        Insert Bookopp;
        
        
        Opportunity Billopp = new Opportunity();
        Billopp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Billopp.name='Testop';
        Billopp.Stagename='Investigating';
        Billopp.closeDate=System.today();
        Billopp.AccountId=acc2.Id;
        Billopp.DDS_OID__c='101';
        Billopp.DDS_Practice_Location__c='Test'; 
        Bookopp.Current_Imaging_Solution_Software__c = 'Apteryx *';
        Bookopp.Services_Performed__c = 'Dentist';
        Bookopp.Other_Notes_for_Onboarding__c = 'Test';
        Bookopp.DDS_Proposal_Notes__c = 'Test Proposal';
        Bookopp.Type = 'New Business';        
        Billopp.ia_crm__Change_Type__c='New MRR';
        //Billopp.Linked_Booking_Opportunity__c=Bookopp.Id;        
        Insert Billopp;
        
        Contract con = new Contract();
        con.SBQQ__Opportunity__c=Bookopp.ID;
        con.AccountId=acc.Id;
        con.Status='Draft';
        con.StartDate= system.today()-2;
        con.EndDate = system.today()-1;
        con.SBQQ__RenewalOpportunityRecordTypeId__c=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
       con.SBQQ__AmendmentOpportunityRecordTypeId__c=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
       
        insert con;

       Contract con1 = new Contract();
        con1.SBQQ__Opportunity__c=Billopp.ID;
        con1.AccountId=acc.Id;
        con1.Status='Draft';
        con1.StartDate= system.today()-1;
        con1.EndDate = system.today()+30;
        con.SBQQ__RenewalOpportunityRecordTypeId__c=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
       con.SBQQ__AmendmentOpportunityRecordTypeId__c=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
       insert con1;
       
        Test.startTest();
        try{
            
            Database.executeBatch(new updateAccountContractEndDateBatch(), 200); 
        }
        catch(exception ex){
            system.debug('exception is '+ex.getMessage());
        }
        
        Test.stopTest();
    }
}