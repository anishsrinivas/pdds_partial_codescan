/*
 Description : This Schedule class is Scheduled to run on 3rd of Every Month at 4.00 AM PST and runs the Batch
              'Create_Renewal_Quotes' to update Renewal Quoted To True 
               for Historical Contracts which are activated and Ending in the Current Month and has Renewals Opportunities 
               Created.Since there is 'Too Many SOQL Queries' issue caused 
               due to 'ContractAfter' CPQ Managed package trigger on Contract object,Batch size is given as 1 instead of Higher
               Batch Size.

 Author      : Ramana 

 Created Date: 07/17/2020
*/
public class Schedule_Create_Renewals_Quotes implements Schedulable{
    public void execute(SchedulableContext sc){
        
        database.executeBatch(new Create_Renewal_Quotes(new List<String>()),1);
        
    }

}