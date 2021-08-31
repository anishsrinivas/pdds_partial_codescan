@istest
public class RestweeklyscoreBatchTest {
 
    public static testMethod  void batchClassSucsCase()  {
        List<Account> listAccount = new List<Account>();
        Account AccountRecord = new Account();
        AccountRecord = new Account(Name = 'Test Client DB1 tes452t');
       
        listAccount.add(AccountRecord); 
        insert listAccount; 
        
        List<Contact> listContact = new List<Contact>();
        Contact ContactRecord = new Contact();
        ContactRecord = new Contact(Lastname = 'Test Contact DB1 tes452t', AccountId = listAccount[0].id);

        listContact.add(ContactRecord); 
        insert listContact; 
        
        
        String CRON_EXP = '0 0 0 15 3 ? *';
        
        test.startTest();
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new ResetWeeklyScheduler());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        test.stopTest();
    }
    
}