@Istest
public class TestQuoteApprovalProcessController {
    
    @testsetup
    public static void Testsubmit(){
         
         Profile p = [select Id,name from Profile where Name='VP Sales'];
        UserRole ur = [select Id,name from UserRole where Name='Account Executive - Imaging'];
        User newUser = new User(
                profileId = p.Id,
                username = 'testVPSalesuser@test.com',
                email = 'testvpsales@test.com',
            	UserRoleId = ur.Id,
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='test',
                lastname='testvpsales');
        
        Insert newUser;
   
        }
    
    public testmethod static void testApprovalProcess(){
        
        User newuser = [Select Id From User Where lastname='testvpsales'];
         system.runAs(newuser){
        Product2 prod = new Product2();
        prod.Name = 'Denticon Platinum Standard';
        prod.ProductCode = 'Test';
        prod.isActive = true;
        Insert prod;
      
        SBQQ__Quote__c Quote1 = new SBQQ__Quote__c();
        Quote1.SBQQ__StartDate__c=System.today();
        Quote1.SBQQ__SubscriptionTerm__c=12;
        Insert Quote1;  
        
        SBQQ__Quoteline__c Ql1 =  new SBQQ__Quoteline__c();
        Ql1.SBQQ__Quote__c=Quote1.Id;
        Ql1.SBQQ__Product__c=prod.Id;
        Ql1.SBQQ__Quantity__c=1;
        Insert Ql1; 
            
        SBQQ__Quote__c Quote2 = new SBQQ__Quote__c();
        Quote2.SBQQ__StartDate__c=System.today();
        Quote2.SBQQ__SubscriptionTerm__c=12;
        Quote2.DDS_Proposal_Notes__c='test';
        Insert Quote2; 
        
        SBQQ__Quoteline__c Ql2 =  new SBQQ__Quoteline__c();
        Ql2.SBQQ__Quote__c=Quote2.Id;
        Ql2.SBQQ__Product__c=prod.Id;
        Ql2.SBQQ__Quantity__c=1;
        Insert Ql2; 
        
        SBQQ__Quote__c Quote3 = new SBQQ__Quote__c();
        Quote3.SBQQ__StartDate__c=System.today();
        Quote3.SBQQ__SubscriptionTerm__c=12;
        Quote3.DDS_Proposal_Notes__c='test';
        Quote3.SBQQ__Status__c='Approved';
        Insert Quote3;
        
        SBQQ__Quoteline__c Ql3 =  new SBQQ__Quoteline__c();
        Ql3.SBQQ__Quote__c=Quote2.Id;
        Ql3.SBQQ__Product__c=prod.Id;
        Ql3.SBQQ__Quantity__c=1;
        Insert Ql3;
        
        SBQQ__Quote__c Quote4 = new SBQQ__Quote__c();
        Quote4.SBQQ__StartDate__c=System.today();
        Quote4.SBQQ__SubscriptionTerm__c=12;
        Quote4.SBQQ__Status__c='Draft';
        Quote4.DDS_Proposal_Notes__c='test';
        Quote4.DDS_DenticonPlatinumRequireDiscount__c=1;
        Insert Quote4; 
        
        SBQQ__Quoteline__c Ql4 =  new SBQQ__Quoteline__c();
        Ql4.SBQQ__Quote__c=Quote4.Id;
        Ql4.SBQQ__Product__c=prod.Id;
        Ql4.SBQQ__Discount__c=0.5;
        Insert Ql4; 
       
        test.startTest();
        QuoteApprovalProcessController.validateQuote(Quote1.Id);
       
        QuoteApprovalProcessController.submitForApproval(Quote2.Id,'test');
        QuoteApprovalProcessController.submitForApproval(Quote3.Id,'test');
        QuoteApprovalProcessController.submitForApproval(Quote4.Id,'test');
        }
        test.stopTest();
        
    }

        }