global class ResetWeeklyScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        RestweeklyscoreBatch i=new RestweeklyscoreBatch();
        database.executeBatch(i);
    } 
}