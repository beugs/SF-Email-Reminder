trigger EventTrigger on Event (after insert, after update) {
 	List<Event> events = Trigger.new;
	for(Event theNewEvent :events)
    {

		List<CronTrigger> cronjobs = [ select Id,CronJobDetail.Name from CronTrigger where CronJobDetail.Name =:theNewEvent.Id ];
    	if(cronjobs.size()>0)
    	{
    		if(theNewEvent.Id != null)
	    	{
	    		 System.abortJob(cronjobs[0].Id);
	    		 System.debug('Aborting job: ' + cronjobs[0].Id + ' event: ' + theNewEvent.Id);
	    	}
    	}
         
        /* if the user check the 'send a reminder email' */
		if(theNewEvent.Send_an_email_reminder__c == true )
		{
			EventTriggerHandler.handleSendEmail(theNewEvent.Id);
		 }
    }
}