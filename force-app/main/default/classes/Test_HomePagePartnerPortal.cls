@istest
public class Test_HomePagePartnerPortal {
    
    
    public static testmethod void createLeadRecords(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='newuse123r@testorg.com');        
        
        List<Lead> leadListInsert = new List<Lead>();
        
        for(integer i=0;i<10;i++){
            Lead ld = new Lead(LastName='TestLead'+i,Company='Test Company'+i,Budget__c ='Yes',Budget_month__c='$500',LeadSource='Reseller');
            leadListInsert.add(ld);
        }
        // Create lead as a Portal User
        
        System.runAs(u2) {
            Insert leadListInsert;
        }
        
        Boolean isrecordNotavailable = HomePagePartnerPortal.getLeadRecordsCount();
    }
    
    public static testmethod void createQuoteRecords(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='newuse123r@testorg.com');        
        
        List<SBQQ__Quote__c> quoteListInsert = new List<SBQQ__Quote__c>();
        
        for(integer i=0;i<1;i++){
            SBQQ__Quote__c Quote = new SBQQ__Quote__c(SBQQ__StartDate__c = System.today());
            quoteListInsert.add(Quote);
        }
        // Create lead as a Portal User
        
        System.runAs(u2) {
           // Insert quoteListInsert;
        }
        
        Boolean isrecordNotavailable = HomePagePartnerPortal.getQuoteRecordsCount();
    }
    
    public static testmethod void createOpportinityRecords(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='newuse123r@testorg.com');        
        
        List<Opportunity> oppListInsert = new List<Opportunity>();
        Account portalUserAccount = new Account (Name ='Test',ordertype__c='Reseller');
        Insert portalUserAccount;
        
        for(integer i=0;i<1;i++){
            Opportunity opp = new Opportunity(CloseDate = System.today(),StageName='Investigating',Name='Opp',AccountId =portalUserAccount.Id );
            oppListInsert.add(opp);
        }
        // Create lead as a Portal User
        
        System.runAs(u2) {
           // Insert oppListInsert;
        }
        
        Boolean isrecordNotavailable = HomePagePartnerPortal.getOpportunityRecordsCount();
    }
}