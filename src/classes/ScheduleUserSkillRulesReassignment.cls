global class ScheduleUserSkillRulesReassignment implements Schedulable {
    public Interface IScheduleHandler {
        void execute(SchedulableContext sc);
    }
    
    global void execute(SchedulableContext sc) {
        Type t = Type.forName('UserSkillRulesReassignment.ScheduleHandler');
        if (t != null){
            IScheduleHandler sch = (IScheduleHandler)t.newInstance();
            if (sch != null){
                sch.execute(sc);
            }
        }
    }
}