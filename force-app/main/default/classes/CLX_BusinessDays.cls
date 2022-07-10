public class CLX_BusinessDays {
    public BusinessHours bHours;
    /**
     * Constructor to set business hours name
     * */
    public CLX_BusinessDays(String businessHoursName){
        //get business hours
        bHours = [SELECT Id FROM BusinessHours WHERE Name =: businessHoursName];
    }

    public CLX_BusinessDays(){
        //If no business hours name provided in paramaterized constructor, use deafault hours
        bHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
    }


    public Datetime addDays(Datetime startDate, Integer days)
    {
        //If startdate is not within working days, take next working day
        startDate = BusinessHours.nextStartDate(bHours.Id, startDate);

        for (Integer elapsed = 0; elapsed < days; elapsed++)
        {
            //Add 1 day
            startDate = startDate.addDays(1);

            //Check if new date is within working days
            if (!BusinessHours.isWithin(bHours.Id, startDate))
            {
                //If new date is not within working days, get new working day
                startDate = BusinessHours.nextStartDate(bHours.Id, startDate);
            }
        }
        return startDate;
    }

    public Datetime subtractDays(Datetime startDate, Integer days)
    {
        //If startdate is not within working days, take previous working day
        startDate = getPreviousWorkingDay(startDate);
        for (Integer elapsed = 0; elapsed < days; elapsed++)
        {
            //Subtract 1 day
            startDate = startDate.addDays(-1);
            //Check if new date is within working days
            if (!BusinessHours.isWithin(bHours.Id, startDate))
            {
                //If new date is not within working days, get previous working day
            	startDate = getPreviousWorkingDay(startDate);
            }
        }
        return startDate;
    }

    public Datetime getPreviousWorkingDay(Datetime d){

         //Check if new date is within working days
        if (!BusinessHours.isWithin(bHours.Id, d))
        {
            //New date is not within working days, recursively call same function to get previous date by subtracting 1 day
            d = d.addDays(-1);
            return getPreviousWorkingDay(d);
        } else{
            //New date is within working days, return this date
            return d;
        }
    }

   public Datetime getNextWorkingDay(Datetime d){
        return BusinessHours.nextStartDate(bHours.Id, d);
    }
    public Boolean isWorkingDay(Datetime d){
        return BusinessHours.isWithin(bHours.Id, d);
    }

    public Integer getNoOfBusinessDaysBetweenDates(DateTime startDate, DateTime endDate){
        Integer count = 0;
        while(startDate <= endDate){
            if(BusinessHours.isWithin(bHours.Id, startDate)){
                count++;
            }
            startDate = startDate.addDays(1);
        }
        return count;
    }
}