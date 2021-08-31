public class UpdateSuppCatgOnAcctBatchHelper {

     public void updateAccount(List<Account> accountList){
         System.debug('accountList from args >>'+accountList);
         List<Account> acctListForUpdate = new List<Account>();
         for(Account currAcct : accountList){
             List<String> licenseCategoriesList = new List<String>();
             String supportCatgFromSub = '';
             String supportCatgFromAsset = '';
             String accountId = currAcct.Id;
             Integer subCount = Database.countQuery('select count() from SBQQ__Subscription__c where SBQQ__Account__c= :accountId or End_Customer_Ship_To_Account__c = :accountId');
             Integer assetCount = Database.countQuery('select count() from Asset where (AccountId = :accountId or End_Customer_Ship_To_Account__c = :accountId)  and Status not in (\'Obsolete\')');
             if(subCount > 0){
                 supportCatgFromSub = evaluateSupportCategoryForSub(accountId); 
                 if (supportCatgFromSub != null) licenseCategoriesList.add(supportCatgFromSub);   
                 System.debug('supportCatgFromSub>>'+supportCatgFromSub);
             }
             
             if(assetCount > 0) {
                 supportCatgFromAsset = evaluateSupportCategoryForAsset(accountId);
                 if (supportCatgFromAsset != null) licenseCategoriesList.add(supportCatgFromAsset);   
                 System.debug('supportCatgFromAsset>>'+supportCatgFromAsset);
             }
             if(licenseCategoriesList.size() == 1){
                 currAcct.License_Support_Category__c = licenseCategoriesList.get(0);
             }else if (licenseCategoriesList.size() == 0){
                 currAcct.License_Support_Category__c = null;
             }else if (licenseCategoriesList.size() > 1){
                 currAcct.License_Support_Category__c = String.join(licenseCategoriesList, ';');
             }
             System.debug('licenseCategoriesList>>'+licenseCategoriesList);
             if(!acctListForUpdate.contains(currAcct)) acctListForUpdate.add(currAcct);
         }
         System.debug('acctList>>'+acctListForUpdate);
     	 update acctListForUpdate;   
     }
        
    public static String evaluateSupportCategoryForSub(String accountId){
        
        Integer dentirayCount = 0;
        Integer denticonCount = 0;
        
        denticonCount = Database.countQuery('select count() from Contract where status=\'Activated\' and Id in (select SBQQ__Contract__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c =\'Denticon\' and (SBQQ__Account__c = :accountId or End_Customer_Ship_To_Account__c = :accountId)) and endDate > Today');
        dentirayCount = Database.countQuery('select count() from Contract where status=\'Activated\' and AccountId in (select SBQQ__Account__c   from SBQQ__Subscription__c where SBQQ__ProductName__c like \'%Dentiray%\' and (SBQQ__Account__c = :accountId or End_Customer_Ship_To_Account__c = :accountId)) and  endDate > Today');
        
        System.debug(' dentirayCount>>'+dentirayCount + ' denticonCount>>' +denticonCount);
        
        if(denticonCount > 0 && dentirayCount == 0 ){
            return 'Denticon';
        }else if(dentirayCount > 0 && denticonCount > 0 ){
            return 'DenticonHasDentiray';
        }else{ 
        	return null;
        }
        
    }
    
    public static String evaluateSupportCategoryForAsset(String accountId){
        Integer xvLiteIncludedCount = 0;
        Integer xvLiteExcludedCount = 0;
        Integer xv3IncludedCount = 0;
        Integer xv3ExcludedCount = 0;
        Integer xv4IncludedCount = 0;
        Integer xv4ExcludedCount = 0;
        Integer xvWebSubCount = 0;
        Integer xvLiteSubCount = 0;
        Integer xv3SubCount = 0;
        Integer xv4SubCount = 0;
        Integer xvWebIncludedCount = 0;
        Integer xvLiteIncludedSubCount = 0;
        Integer xvLiteExcludedSubCount = 0;
        Integer xv3IncludedSubCount = 0;
        Integer xv3ExcludedSubCount = 0;
        Integer xv4IncludedSubCount = 0;
        Integer xv4ExcludedSubCount = 0;
        
      /*  xvLiteIncludedCount = Database.countQuery('Select  count() from Asset where Product2.Product_License_Categories__c  in (\'XVLite\') and Product2.Product_License_Categories__c not in (\'XV3\',\'XV4\',\'XVWeb\') and Status not in (\'Obsolete\') and (AccountId = :accountId  or End_Customer_Ship_To_Account__c = :accountId)');
        xv3IncludedCount = Database.countQuery('Select  count() from Asset where Product2.Product_License_Categories__c  in (\'XV3\') and Product2.Product_License_Categories__c not in (\'XV4\',\'XVWeb\') and Status not in (\'Obsolete\') and (AccountId = :accountId  or End_Customer_Ship_To_Account__c = :accountId)');    
        xv4IncludedCount = Database.countQuery('Select  count() from Asset where Product2.Product_License_Categories__c  in (\'XV4\') and Product2.Product_License_Categories__c not in (\'XVWeb\') and Status not in (\'Obsolete\') and (AccountId = :accountId  or End_Customer_Ship_To_Account__c = :accountId)');    
        xvWebIncludedCount = Database.countQuery('Select  count() from Asset where Product2.Product_License_Categories__c  in (\'XVWeb\') and Status not in (\'Obsolete\') and (AccountId = :accountId  or End_Customer_Ship_To_Account__c = :accountId)');
       */ 
        
        xvLiteIncludedCount = Database.countQuery('Select  count() from Asset where Product2.Product_License_Categories__c  in (\'XVLite\') and Status not in (\'Obsolete\') and (AccountId = :accountId  or End_Customer_Ship_To_Account__c = :accountId)');
        xvLiteExcludedCount = Database.countQuery('Select  count() from Asset where Product2.Product_License_Categories__c  in (\'XV3\',\'XV4\',\'XVWeb\') and Status not in (\'Obsolete\') and (AccountId = :accountId  or End_Customer_Ship_To_Account__c = :accountId)');
        
        xv3IncludedCount = Database.countQuery('Select  count() from Asset where Product2.Product_License_Categories__c  in (\'XV3\') and Status not in (\'Obsolete\') and (AccountId = :accountId  or End_Customer_Ship_To_Account__c = :accountId)');    
        xv3ExcludedCount = Database.countQuery('Select  count() from Asset where Product2.Product_License_Categories__c  in (\'XV4\',\'XVWeb\') and Status not in (\'Obsolete\') and (AccountId = :accountId  or End_Customer_Ship_To_Account__c = :accountId)');
        
        xv4IncludedCount = Database.countQuery('Select  count() from Asset where Product2.Product_License_Categories__c  in (\'XV4\') and Status not in (\'Obsolete\') and (AccountId = :accountId  or End_Customer_Ship_To_Account__c = :accountId)');    
        xv4ExcludedCount = Database.countQuery('Select  count() from Asset where Product2.Product_License_Categories__c  in (\'XVWeb\') and Status not in (\'Obsolete\') and (AccountId = :accountId  or End_Customer_Ship_To_Account__c = :accountId)');
        
       // xvWebIncludedSubCount = Database.countQuery('select count() from Contract where status=\'Activated\' and Id in (select SBQQ__Contract__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c =\'XVWeb\' and (SBQQ__Account__c = :accountId or End_Customer_Ship_To_Account__c = :accountId)) and AccountId = :accountId and endDate > Today');
        xvLiteIncludedSubCount = Database.countQuery('select count() from Contract where status=\'Activated\' and Id in (select SBQQ__Contract__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c =\'XVLite\' and (SBQQ__Account__c = :accountId or End_Customer_Ship_To_Account__c = :accountId)) and AccountId = :accountId and endDate > Today');
        xvLiteExcludedSubCount = Database.countQuery('select count() from Contract where status=\'Activated\' and Id in (select SBQQ__Contract__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c in (\'XV3\',\'XV4\',\'XVWeb\') and (SBQQ__Account__c = :accountId or End_Customer_Ship_To_Account__c = :accountId)) and AccountId = :accountId and endDate > Today');
        xv3IncludedSubCount = Database.countQuery('select count() from Contract where status=\'Activated\' and Id in (select SBQQ__Contract__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c =\'XV3\' and (SBQQ__Account__c = :accountId or End_Customer_Ship_To_Account__c = :accountId)) and AccountId = :accountId and endDate > Today');
        xv3ExcludedSubCount = Database.countQuery('select count() from Contract where status=\'Activated\' and Id in (select SBQQ__Contract__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c in (\'XV4\',\'XVWeb\') and (SBQQ__Account__c = :accountId or End_Customer_Ship_To_Account__c = :accountId)) and AccountId = :accountId and endDate > Today');
        xv4IncludedSubCount = Database.countQuery('select count() from Contract where status=\'Activated\' and Id in (select SBQQ__Contract__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c =\'XV4\' and (SBQQ__Account__c = :accountId or End_Customer_Ship_To_Account__c = :accountId)) and AccountId = :accountId and endDate > Today');
        xv4ExcludedSubCount = Database.countQuery('select count() from Contract where status=\'Activated\' and Id in (select SBQQ__Contract__c from SBQQ__Subscription__c where SBQQ__Product__r.Product_License_Categories__c in (\'XVWeb\') and (SBQQ__Account__c = :accountId or End_Customer_Ship_To_Account__c = :accountId)) and AccountId = :accountId and endDate > Today');
        
        if((xvLiteIncludedCount > 0 && xvLiteExcludedCount == 0) || (xvLiteSubCount >0 && xvLiteExcludedSubCount == 0)) {
            return 'XVLite';            
        }else  if((xv3includedCount > 0 && xv3ExcludedCount == 0) || (xv3IncludedSubCount >0 && xv3ExcludedSubCount == 0)){
            return 'XV3';
        }else  if((xv4IncludedCount > 0 &&  xv4ExcludedCount == 0) || (xv4IncludedSubCount >0 && xv4ExcludedSubCount == 0)){
            return 'XV4';
        }else if(xv4ExcludedCount > 0 || xv4ExcludedSubCount > 0) {
            return 'XVWeb';
        }else{
            return null;
        }
		
        /*
        System.debug('xvLiteIncludedCount>>'+xvLiteIncludedCount +' xvLiteSubCount >>' +xvLiteSubCount + ' xv3IncludedCount>>'+xv3IncludedCount +' xv3SubCount >>' +xv3SubCount + ' xv4IncludedCount>>'+xv4IncludedCount + ' xv4SubCount>>'+xv4SubCount + ' xvWebIncludedCount>>'+xvWebIncludedCount +' xvWebSubCount>>'+xvWebSubCount);
        
        if(xvLiteIncludedCount > 0 || xvLiteSubCount > 0){
            return 'XVLite';            
        }else  if(xv3includedCount > 0 || xv3SubCount > 0){
            return 'XV3'; 
        }else  if(xv4IncludedCount > 0 || xv4SubCount > 0){
            return 'XV4';
        }else if(xvWebIncludedCount > 0 || xvWebSubCount > 0) {
            return 'XVWeb';
        }else{
            return null;
        }
*/
    }
    
}