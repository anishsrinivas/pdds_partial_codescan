// ---> Test Class for Batch class 'Update_Old_MRR_Amount' to Copy Amount to 'Old MRR amount'  for all closed Won Opportunities.

//---->Author: Ramana 

//---->Date : 19/05/2020
@Istest
public class Update_Old_MRR_Amount_Test{
    @Istest
    
    Public static void Method1(){
        
        Account acc=new Account();
        acc.Name='Test ';
         INSERT acc;
        
       List<Opportunity> opportunityList=new List<Opportunity>();     
        for(Integer i=1;i<=100;i++){
          Opportunity opp = new Opportunity();
            opp.name='Test'+i;
            opp.Stagename='Closed Won';
            opp.DDS_Proposal_Notes__c='Test Notes';
            opp.Amount=5000+i;
            opp.closeDate=System.today();
            opp.AccountId=acc.Id;
            opportunityList.add(opp);
        } 
        INSERT opportunityList;
        Test.startTest();
        
        database.executeBatch(new Update_Old_MRR_Amount(new List<String>()));
        Test.stopTest();
        List<opportunity> updatedopp=[Select Id ,Amount,Old_MRR_amount__c from opportunity];
        system.assertEquals(5002,updatedopp[1].Old_MRR_amount__c);
        
    }
    

}