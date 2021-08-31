@isTest(SeeAllData=false)
public class updateAccountcntrctExpDate_Test {
    
    public static testMethod void testExpDate(){
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
        
        Test.startTest();
        Opportunity Addonopp = new Opportunity();
        Addonopp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Addonopp.name='Testop2';
        Addonopp.Stagename='Investigating';
        Addonopp.closeDate=System.today();
        Addonopp.ia_crm__Change_Type__c='Add on MRR';
        Addonopp.Linked_Booking_Opportunity__c=Bookopp.Id;
        Addonopp.AccountId=acc.Id;
        
        Insert Addonopp;
        
        
        SBQQ__Quote__c addonQuote =  new SBQQ__Quote__c();
        addonQuote.SBQQ__Account__c=acc.Id;
        addonQuote.SBQQ__Opportunity2__c=Addonopp.Id;
        addonQuote.SBQQ__Primary__c=True;
        
        Insert addonQuote;
        
        Contract con2 = new Contract();
        con2.SBQQ__Opportunity__c=Billopp.ID;
        con2.AccountId=acc.Id;
        con2.Status='Draft';
        con2.StartDate= system.today()-2;
        con2.EndDate = system.today()-1;
        
        Contract con = new Contract();
        con.SBQQ__Opportunity__c=Billopp.ID;
        con.AccountId=acc.Id;
        con.Status='Draft';
        con.StartDate= system.today()-1;
        con.EndDate = system.today()+2;
        
        Contract con1 = new Contract();
        con1.SBQQ__Opportunity__c=Billopp.ID;
        con1.AccountId=acc.Id;
        con1.Status='Draft';
        con1.StartDate= system.today()+1;
        con1.EndDate = system.today()+30;
        
        List<Contract> contList = new List<Contract>();
        contList.add(con);
        contList.add(con1);
        contList.add(con2);
        
        Account acc1 = new Account();
        acc1.Name='Test1';
        
        Account acc2 = new Account();
        acc2.Name='Test2';
        
        Account acc3 = new Account();
        acc3.Name='Test3';
        
        Account acc4 = new Account();
        acc4.Name='Test4';
        
        List<Account> accList = new List<Account>();
        accList.add(acc1);
        accList.add(acc2);
        accList.add(acc3);
        accList.add(acc4);
        Insert accList;
        
        Contract con3 = new Contract();
        con3.SBQQ__Opportunity__c=Billopp.ID;
        con3.AccountId=accList[0].Id;
        con3.Status='Draft';
        con3.StartDate= system.today()-2;
        con3.EndDate = system.today()-1;
        contList.add(con3);
        
        Contract con4 = new Contract();
        con4.SBQQ__Opportunity__c=Billopp.ID;
        con4.AccountId=accList[0].Id;
        con4.Status='Draft';
        con4.StartDate= system.today()+10;
        con4.EndDate = system.today()+20;
        contList.add(con4);
        
        Contract con5 = new Contract();
        con5.AccountId=accList[2].Id;
        con5.Status='Activated';
        con5.StartDate= system.today()+30;
        con5.EndDate = system.today()+50;
        contList.add(con5);
        
        Contract con6 = new Contract();
        con6.AccountId=accList[2].Id;
        con6.Status='Activated';
        con6.StartDate= system.today();
        con6.EndDate = system.today().addYears(1);
        contList.add(con6);
        
        Contract con7 = new Contract();
        con7.AccountId=accList[3].Id;
        con7.Status='Activated';
        con7.ia_crm__End_Customer__c=accList[2].Id;
        con7.StartDate= system.today();
        con7.EndDate =  system.today().addYears(2);
        contList.add(con7);
        
        try{
            Insert contList; 
                       
        }
        catch(exception ex){
            system.debug('exception is '+ex.getMessage());
        }
        
        
        
        Test.stopTest();
    }
}