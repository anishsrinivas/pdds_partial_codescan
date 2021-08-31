/*******************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Status           Completed
* @Class Name       UpdateAutoWithDrawSchedulableTest
* @Dependent        UpdateAutoWithDrawSchedulable
* @description      This class return for scheduling the batch class every day night 12AM PST. 
*********************************************************************************************
Version     Date        Team       	Comments
*********************************************************************************************
* 1    	26-NOV-2019	  Demandblue   Initial created 
*********************************************************************************************/
@istest
public class UpdateAutoWithDrawSchedulableTest {
    @isTest 
    Public static void executeTest(){
        SchedulableContext sc = null;
        UpdateAutoWithDrawSchedulable tsc = new UpdateAutoWithDrawSchedulable();
        tsc.execute(sc);
    } 
}