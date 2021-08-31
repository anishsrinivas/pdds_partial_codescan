/*******************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Status           Completed
* @Class Name       UpdateAutoWithDrawSchedulable
* @description      This class return for scheduling the batch class every day night 12AM PST. 
*********************************************************************************************
Version     Date        Team       	Comments
*********************************************************************************************
* 1    	26-NOV-2019	  Demandblue   Initial created 
*********************************************************************************************/
global class UpdateAutoWithDrawSchedulable implements Schedulable
{
    global void execute(SchedulableContext sc)

    {     
        Id InactiveOpps=Database.executeBatch(new UpdateAutoWithDrawBatch());

    }
}