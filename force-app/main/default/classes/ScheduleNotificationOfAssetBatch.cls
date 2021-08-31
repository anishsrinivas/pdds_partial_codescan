global class ScheduleNotificationOfAssetBatch implements Schedulable {
   global void execute(SchedulableContext SC) {
      Batch_NotificationOnAssetConversion b = new Batch_NotificationOnAssetConversion();
       database.executebatch(b);
   }
}