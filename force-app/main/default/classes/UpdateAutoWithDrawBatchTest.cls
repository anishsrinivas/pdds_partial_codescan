/*******************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Status           Completed
* @Class Name       UpdateAutoWithDrawBatchTest
* @description      This is test class for UpdateAutoWithDrawBatch,UpdateAutoWithDrawSchedulable.
*********************************************************************************************
Version     Date        Team       	Comments
*********************************************************************************************
* 1    	26-NOV-2019	  Demandblue   Initial created 
*********************************************************************************************/

@isTest     
public class UpdateAutoWithDrawBatchTest 
{        
    Public static testmethod void testOpprecordbatch()
    {
        
        
        //Insert User
        Profile profile = [select id from profile WHERE Name = 'System Administrator'limit 1];
        UserRole  role = [select id from UserRole WHERE Name = 'BDR' limit 1];
        User user = new User();
        user.Username = 'Demandbluete@gmail.com';
        user.LastName = 'TestLastName';
        user.Email = 'demandbluetes@gmail.com';
        user.Alias = 'TA';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'UTF-8';
        user.ProfileId = profile.id;  
        user.UserRoleId = role.id;
        user.LanguageLocaleKey = 'en_US';
        insert user;
        
        System.runas(user){

            Account acc = new Account(Name='Test Account');
            insert acc;
            
            Contact con = new Contact();
            con.LastName='Test Contact'; 
            con.AccountId =acc.Id;
            insert con;
            
                Opportunity opp = new Opportunity();
                
                opp.AccountId=acc.Id;
                opp.Name__c = 'Denticon';
                opp.Type = 'New Business';
                opp.Name='My Opportunity';
                opp.StageName='Investigating';
                opp.SalesLoft1__Primary_Contact__c = con.id;
                opp.Amount = 1000;
                opp.CloseDate=date.today();
                insert opp;

        
            Event event = new Event();  
            event.OwnerId = user.id;
            event.Subject = 'Call';
            event.StartDateTime=system.today();
            event.EndDateTime=system.today();
            event.WhatId = opp.id;
            
            insert event;

         Datetime yesterday = Datetime.now().addDays(-32);
        Test.setCreatedDate(opp.Id, yesterday);

            
        Test.startTest();
            Opportunity testAcc = [SELECT Id, Name, CreatedDate,StageName, LastModifiedDate,LastActivityDate,Last_Activity_Count__c,Last_Modified_Count__c,CreatedBy.UserRole.Name FROM Opportunity WHERE AccountId =: acc.id LIMIT 1];  
        	System.assertEquals(testAcc.CreatedDate, yesterday);  
            system.debug(testAcc);
            system.debug('Today ---> '+system.today()+' Created Date ---> '+testAcc.CreatedDate);
            UpdateAutoWithDrawBatch up = new UpdateAutoWithDrawBatch(); 
            Database.executeBatch(up,200);   
        Test.stopTest();
        }
        
    }
}