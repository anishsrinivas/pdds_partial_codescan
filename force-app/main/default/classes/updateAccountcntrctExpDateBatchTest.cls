@istest
global class updateAccountcntrctExpDateBatchTest {
    @istest 
    static void execute()
    {
        
        Test.startTest();
        //Invoking the Scheduler class
        SchedulableContext sc = null;
        updateAccountcntrctExpDateBatchSchedule schedule=new updateAccountcntrctExpDateBatchSchedule();
        schedule.execute(sc);
        
        //Invoking the Batch class
        Account acc = new Account();
        acc.Name='Test';
        Insert acc;
        
        BillingOppsAutomation__c cs = new BillingOppsAutomation__c();
        cs.name='Automation';
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
        Billopp.AccountId=acc.Id;
        Billopp.DDS_OID__c='101';
        Billopp.DDS_Practice_Location__c='Test';
        Billopp.ia_crm__Change_Type__c='New MRR';
        Billopp.Linked_Booking_Opportunity__c=Bookopp.Id;
        
        Insert Billopp;
        
         List<Contract> contList = new List<Contract>();
        Contract con2 = new Contract();
        con2.SBQQ__Opportunity__c=Billopp.ID;
        con2.AccountId=acc.Id;
        con2.Status='Draft';
        con2.StartDate= system.today();
        con2.EndDate = system.today()+1;
       contList.add(con2);
        insert contList;
      
         updateAccountcntrctExpDateBatch bc = new updateAccountcntrctExpDateBatch();
        Id batchId = Database.executeBatch(bc,200);
        
        //updateAccountcntrctExpDateBatch schedulebatch=new updateAccountcntrctExpDateBatch();
        //Database.executeBatch(schedulebatch,200);
       // updateAccountcntrctExpDateBatch.execute(schedulebatch, contList);
       Test.stopTest();
     
    }

}