// ---> Test Class for Batch class 'Update_Notes_Description' to Populate Account Notes and Description to all related Open Opportunities.

//---->Author: Ramana 

//---->Date : 30/04/2020
@Istest
public class Update_Notes_Description_Test {
    @Istest
    
    Public static void Method1(){
      //  List<Account> acc=new List<Account>()
        
        Account acc=new Account();
        acc.Name='Test ';
        acc.Notes__c ='Notes';
        acc.Description='Description';
         INSERT acc;
        
       List<Opportunity> opportunityList=new List<Opportunity>();     
        for(Integer i=1;i<=10;i++){
          Opportunity opp = new Opportunity();
            opp.name='Test'+i;
            opp.Stagename='Investigating';
            opp.closeDate=System.today();
            opp.AccountId=acc.Id;
            opportunityList.add(opp);
        } 
        INSERT opportunityList;
        Test.startTest();
        
        database.executeBatch(new Update_Notes_Description(new List<String>()));
        Test.stopTest();
        List<opportunity> updatedopp=[Select Id ,DDS_Description__c,DDS_Notes__c from opportunity];
        system.assertEquals('Notes',updatedopp[9].DDS_Notes__c);
        
    }
    

}