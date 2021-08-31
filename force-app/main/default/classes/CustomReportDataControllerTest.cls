@isTest
public class CustomReportDataControllerTest {
    
    @testSetup
    public static void createTestAccounts(){ 
        //XVLite data 
      
        Account xvliteAcct = new Account(Name='XVLite Acct',Notes__c='Test',Description='Test');
        Insert xvliteAcct;
        Product2 xvLiteProduct = new Product2(Name='XVLite Product', ProductCode='Test',isActive=true, Product_License_Categories__c='XVLite');
        insert xvLiteProduct;
        Asset xvLiteAsset = new Asset(Name='XVLite Asset', AccountId=xvliteAcct.Id, Product2Id=xvLiteProduct.Id);
        insert xvLiteAsset; 
        
        //XV3 data 
      
        Account xv3Acct = new Account(Name='XV3 Acct',Notes__c='Test',Description='Test');
        Insert xv3Acct;
        Product2 xv3Product = new Product2(Name='XV3 Product', ProductCode='Test',isActive=true, Product_License_Categories__c='XV3');
        insert xv3Product;
        Asset xv3Asset = new Asset(Name='XV3 Asset', AccountId=xv3Acct.Id, Product2Id=xv3Product.Id);
        insert xv3Asset; 
        
        //XV4,XVWeb,DV34,DCV35 data 
      
        Account xv4Acct = new Account(Name='XV4 Acct',Notes__c='Test',Description='Test');
        Insert xv4Acct;
        Product2 xv4Product = new Product2(Name='XV4 Product', ProductCode='Test',isActive=true, Product_License_Categories__c='XV4');
        insert xv4Product;
        Asset xv4Asset = new Asset(Name='XV4 Asset', AccountId=xv4Acct.Id, Product2Id=xv4Product.Id);
        insert xv4Asset; 
        
        Product2 DCV35Product = new Product2(Name='DCV35 Prod', ProductCode='Test',isActive=true, Product_License_Categories__c='DCV 3.5');
        insert DCV35Product;
        Asset dcv35Asset = new Asset(Name='DCV35 Asset', AccountId=xv4Acct.Id, Product2Id=DCV35Product.Id);
        insert dcv35Asset;
        
        Product2 DV34Product = new Product2(Name='DV34 Prod',  ProductCode='Test',isActive=true,Product_License_Categories__c='DCV 3.4');
        insert DV34Product;
        Asset DV34Asset = new Asset(Name='DV34 Asset', AccountId=xvliteAcct.Id, Product2Id=DV34Product.Id);
        insert DV34Asset; 
        Product2 xvWebProduct = new Product2(Name='XVWeb Prod', ProductCode='Test',isActive=true, Product_License_Categories__c='XVWeb');
        insert xvWebProduct;
        Asset xvWebAsset = new Asset(Name='XVWeb Asset', AccountId=xv3Acct.Id, Product2Id=xvWebProduct.Id);
        insert xvWebAsset; 
      

    }
    
    @isTest
    public static void runReportsForTest(){
        test.startTest();
        
        CustomReportDataController.fetchReportDataForDenticon();
        CustomReportDataController.fetchReportDataForXVLite();
        CustomReportDataController.fetchReportDataForXV3();
        CustomReportDataController.fetchReportDataForXV4();
        CustomReportDataController.fetchReportDataForXVWeb();
        CustomReportDataController.fetchReportDataForDV34();
        CustomReportDataController.fetchReportDataForDCV35();
        
        test.stopTest();
    }

}