/*******************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Status           Development Completed
* @description      This schedule class is used for scheduling the batch to process accountcontract records. 
*********************************************************************************************
Version    	Date        	Team    	Comments
*********************************************************************************************
* 1    		13 Jan 2020    	Pradeep    	Initial Development 
*********************************************************************************************/
public class updateAccountcntrctExpDateBatchSchedule implements Schedulable 
{
    public void execute(SchedulableContext sc)
    {
        updateAccountcntrctExpDateBatch batchSchedule=new updateAccountcntrctExpDateBatch();
      database.executebatch(batchSchedule);
   }

}