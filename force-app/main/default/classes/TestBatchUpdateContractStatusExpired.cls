/*
 Description : Test class for the Batch Class 'BatchUpdateContractStatusExpired' 

 Author      : Ramana 

 Created Date: 07/30/2020
*/
@Istest
Private class TestBatchUpdateContractStatusExpired {   
    @Istest
     Private static void TestupdateStatus(){
         
        Test.startTest();
        Account acc=new Account();
        acc.Name='Test ';
        acc.Notes__c='test Notes';
        acc.Description='test desc';
        acc.SBQQ__RenewalModel__c='Contract Based';
        acc.SBQQ__RenewalPricingMethod__c='Uplift';
        insert acc;
        
        list<Opportunity> oplist  = new list<Opportunity>();
        integer k=0;
        for(k=1;k<=5;K++){
        Opportunity op = new Opportunity();
        op.AccountId=acc.Id;
        op.name='Test';
        op.StageName='Investigating';
        op.CloseDate=System.today();
        op.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        op.ia_crm__Change_Type__c='New MRR';
        oplist.add(op);
         }
        Insert oplist;
         
       list<Contract> conlist = new list<Contract>();

       for (Opportunity opp: oplist)    
       {  
       Contract con = new Contract();
       con.SBQQ__Opportunity__c=opp.ID;
       con.AccountId=acc.Id;
       con.Status='Draft';
       con.StartDate= date.parse('7/29/2019');
       con.EndDate= date.parse('7/28/2020');
       con.SBQQ__RenewalOpportunityRecordTypeId__c=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
       con.SBQQ__AmendmentOpportunityRecordTypeId__c=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
       conlist.add(con);
         }
      
         Insert conlist;

        database.executeBatch(new BatchUpdateContractStatusExpired(new List<String>()),5);
        
        Test.stopTest();
        
        list<Contract> cnt =[select id,status from  Contract ];
         for (Contract cn :cnt){
           System.assertEquals('Expired', cn.status);   
         }
       

    }
}