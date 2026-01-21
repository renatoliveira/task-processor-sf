// TODO: tasks can also be created at creation, so after insert is needed
trigger Task on Task (after update) {
    TaskTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
}