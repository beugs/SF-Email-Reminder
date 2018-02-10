public with sharing class EventTriggerHandler {
    public static void handleSendEmail(Id eventId)
	{
			  Event theNewEvent = [SELECT Id, StartDateTime, WhoId FROM Event WHERE Id = :eventId];
			  Integer intDelay = 1;


			 DateTime currentDate = DateTime.now();
		 	 if(theNewEvent.StartDateTime.addHours(intDelay) > currentDate)
			 {
			 	Schedule_RDV_email rdvScheduler = new Schedule_RDV_email(theNewEvent.StartDateTime, theNewEvent.WhoId,theNewEvent.Id);
			    rdvScheduler.sendEmail();
		 	 }
		}
}
