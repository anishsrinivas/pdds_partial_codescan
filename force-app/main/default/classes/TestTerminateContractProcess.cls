// ---> Test Class for Class 'TerminateContractProcess'

//---->Author: Ramana 

//---->Date : 06/22/2020
@Istest
public class TestTerminateContractProcess {
    @Istest
    public static void TestCall(){
        Account acc = new Account();
        acc.Name='Test Account';
        Insert acc;
        
        Opportunity opp1 = new Opportunity();
        opp1.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        opp1.name='Testopp';
        opp1.Stagename='Investigating';
        opp1.closeDate=System.today();
        opp1.AccountId=acc.Id;
        opp1.DDS_OID__c='101';
        opp1.DDS_Practice_Location__c='Test';
        opp1.ia_crm__Change_Type__c='New MRR';
        Insert opp1;
        
        List<Contract> contractList=new List<Contract>();
        for(Integer i=1;i<=10;i++){
        Contract con = new Contract();
        con.AccountId=acc.Id;
        con.SBQQ__Opportunity__c=opp1.Id;
        con.Status='Draft';
        con.StartDate=System.today();
        contractList.add(con);    
        
    }
        Insert contractList;
        //for(Contract con:contractList){
        TerminateContractProcess.Invoke(contractList[0].Id,'Support');
        //}
        }

}