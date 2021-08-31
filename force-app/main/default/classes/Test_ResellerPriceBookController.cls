@istest
public class Test_ResellerPriceBookController {
    
    public static testmethod void createRecords(){
        
        Reseller_Portal_Values__c resellerPortalValues = new Reseller_Portal_Values__c();
        resellerPortalValues.Reseller_Portal_Name__c = 'Planet DDS Reseller Portal';
        resellerPortalValues.Reseller_Portal_Org_wide_Address__c ='sfadmin@demandblue.com';
        resellerPortalValues.Name = 'Reseller Portal Defaults';
        Insert resellerPortalValues;

Pricebook2 testPB = new Pricebook2();
        testPB.Name = 'Test';
        Insert testPB;
        
        //create account
      
        Account acc = new Account();
        acc.Name='test';
        acc.Notes__c='test data';
        acc.Description='test description';
        acc.ordertype__c='Reseller';
        acc.Price_Book__c = testPB.Id;
        Insert acc;
        system.debug('acc-->'+acc.Price_Book__c);
        Contact partnerContact = new Contact (LastName='TestContact',
                                              AccountId = acc.Id,
                                              MobilePhone='0987654323',
                                              Phone='8967452312',
                                              LID__LinkedIn_Company_Id__c='987654677');
        Insert partnerContact;
        
        
       Profile p1 = [select Id,name from Profile where Name='Reseller Partner Community'];
        User testUser = new User(
            profileId = p1.id,
            username = 'Test123SFUsertest@test.com',
            email = 'testSF@test.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='testSF',
            lastname='SFUser',
        ContactId = partnerContact.Id);
        
        Insert testUser;
        
        ResellerPriceBookController.getBaseURL();
        system.runAs(testUser){
        ResellerPriceBookController.getPriceBook();
        }
    }
}