@isTest
public class UpdateWeeklyScoreCalculatorHandlerTest {

    @isTest
    Public static void WeeklyScoreTest(){
        
        List<Account> accs = new List<Account>();
        Account acc1 = new Account();
        acc1.Name = 'Test1';
        acc1.Total_Hubspot_Score__c  = 10;
        acc1.Demand_Status__c = 'High';
        accs.add(acc1);
        
        Account acc2 = new Account();
        acc2.Name = 'Test2';
        acc2.Total_Hubspot_Score__c  = 20;
        acc2.Demand_Status__c = 'Low';
        accs.add(acc2);
        
        Account acc3 = new Account();
        acc3.Name = 'Test3';
        acc3.Total_Hubspot_Score__c  = 30;
        acc3.Demand_Status__c = 'Medium';
        accs.add(acc3);
        
        Account acc4 = new Account();
        acc4.Name = 'Test4';
        acc4.Total_Hubspot_Score__c  = 40;
        accs.add(acc4);
        
        Account acc5 = new Account();
        acc5.Name = 'Test5';
        acc5.Demand_Status__c = 'High';
        accs.add(acc5);
        
        Account acc6 = new Account();
        acc6.Name = 'Test6';
        acc6.Demand_Status__c = 'Low';
        accs.add(acc6);
        
        Account acc7 = new Account();
        acc7.Name = 'Test7';
        acc7.Demand_Status__c = 'Medium';
        accs.add(acc7);
        
        Account acc8 = new Account();
        acc8.Name = 'Test8';
        accs.add(acc8);
        
        insert accs;
        
    }
    
    @isTest
    Public static void WeeklyScoreTotalHubSpotTest(){
        
        Account acc = new Account();
        acc.Name = 'TestHubSpot';
        acc.Demand_Status__c = 'Low';
        acc.Total_Hubspot_Score__c = 20; 
        insert acc;   
       
        acc.Total_Hubspot_Score__c = 30;
        acc.Demand_Status__c = 'Low';
        update acc;
        
        acc.Total_Hubspot_Score__c = null;
        acc.Demand_Status__c = 'Low';
        update acc;
        
        acc.Total_Hubspot_Score__c = 30;
        acc.Demand_Status__c = 'Low';
        update acc;
        
        acc.Total_Hubspot_Score__c = null;
        acc.Demand_Status__c = 'Low';
        update acc;
   
    }
    
    @isTest
    Public static void WeeklyScoreDemandStatusTest(){
        
        Account acc = new Account();
        acc.Name = 'TestDemandStatus';
        acc.Demand_Status__c = 'Low';
        acc.Total_Hubspot_Score__c = 20; 
        insert acc;   
       
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = 'High';
        update acc;
        
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = 'Medium';
        update acc;
        
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = null;
        update acc;
        
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = 'High';
        update acc;
        
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = null;
        update acc;
        
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = 'Medium';
        update acc;
        
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = 'High';
        update acc;
        
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = 'Medium';
        update acc;
        
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = 'Low';
        update acc;
        
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = 'Medium';
        update acc;
        
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = null;
        update acc;
   
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = 'Low';
        update acc;
        
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = 'Medium';
        update acc;
   
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = 'Low';
        update acc;
        
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = 'High';
        update acc;
   
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = 'Low';
        update acc;
        
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = null;
        update acc;
        
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = 'Medium';
        update acc;
        
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = null;
        update acc;
   
    }
    
    
    @isTest
    Public static void WeeklyScore(){
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Demand_Status__c = 'Low';
        acc.Total_Hubspot_Score__c = 1; 
        insert acc;   
       
        acc.Total_Hubspot_Score__c = 2;
        acc.Demand_Status__c = 'Medium';
        update acc;
        
        acc.Total_Hubspot_Score__c = 3;
        acc.Demand_Status__c = 'High';
        update acc;
        
        acc.Total_Hubspot_Score__c = 4;
        acc.Demand_Status__c = null;
        update acc;
        
        acc.Total_Hubspot_Score__c = 5;
        acc.Demand_Status__c = 'High';
        update acc;
        
        acc.Total_Hubspot_Score__c = 6;
        acc.Demand_Status__c = null;
        update acc;
        
        acc.Total_Hubspot_Score__c = 7;
        acc.Demand_Status__c = 'Medium';
        update acc;
        
         
        acc.Total_Hubspot_Score__c = 8;
        acc.Demand_Status__c = 'High';
        update acc;
        
        acc.Total_Hubspot_Score__c = 9;
        acc.Demand_Status__c = 'Medium';
        update acc;
        
        acc.Total_Hubspot_Score__c = 10;
        acc.Demand_Status__c = 'Low';
        update acc;
        
        acc.Total_Hubspot_Score__c = 11;
        acc.Demand_Status__c = 'Medium';
        update acc;
        
        acc.Total_Hubspot_Score__c = 12;
        acc.Demand_Status__c = null;
        update acc;
        
        acc.Total_Hubspot_Score__c = 13;
        acc.Demand_Status__c = 'Low';
        update acc;
        
        acc.Total_Hubspot_Score__c = 14;
        acc.Demand_Status__c = 'Medium';
        update acc;
        
        acc.Total_Hubspot_Score__c = 15;
        acc.Demand_Status__c = 'Low';
        update acc;
        
        acc.Total_Hubspot_Score__c = 16;
        acc.Demand_Status__c = 'High';
        update acc;
        
        acc.Total_Hubspot_Score__c = 17;
        acc.Demand_Status__c = 'Low';
        update acc;
        
        acc.Total_Hubspot_Score__c = 18;
        acc.Demand_Status__c = 'Low';
        update acc;
        
        acc.Total_Hubspot_Score__c = 19;
        acc.Demand_Status__c = null;
        update acc;
        
        acc.Total_Hubspot_Score__c = 20;
        acc.Demand_Status__c = 'Medium';
        update acc;
        
        acc.Total_Hubspot_Score__c = 21;
        acc.Demand_Status__c = null;
        update acc;
   
    }
}