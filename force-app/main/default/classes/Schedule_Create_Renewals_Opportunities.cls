/*
 Description : This Schedule class is Scheduled to run on 3rd of Every Month at 12.00 AM PST and runs the Batch
              'Create_Renewal_Opportunities' to update Renewal Forecast to True and Renewal Uplift to 4% for Historical 
               Contracts which are activated Ending in the Current Month.Since there is 'Too Many SOQL Queries' issue caused 
               due to 'ContractAfter' CPQ Managed package trigger on Contract object,Batch size is given as 1 instead of Higher
               Batch Size.

 Author      : Ramana 

 Created Date: 07/17/2020
*/
public class Schedule_Create_Renewals_Opportunities implements Schedulable{
    public void execute(SchedulableContext sc){
        
        database.executeBatch(new Create_Renewal_Opportunities(new List<String>()),1);
        
    }

}