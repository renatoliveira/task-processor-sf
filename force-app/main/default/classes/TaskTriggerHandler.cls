public with sharing class TaskTriggerHandler {
    public static void onAfterUpdate(List<Task> newTasks, Map<Id, Task> oldTasks) {
        List<Task> processableTasks = new List<Task>();

        for (Task t : newTasks) {
            if (t.Status == 'Completed') {
                continue;
            }

            if (String.isNotBlank(t.TaskDefinitionRef__c)) {
                processableTasks.add(t);
            }
        }

        process(processableTasks);
    }

    /**
     * @description Process the tasks
     * @param tasks The tasks to process
     */
    private static void process(List<Task> tasks) {
        Set<Id> taskDefinitionIds = new Set<Id>();

        for (Task t : tasks) {
            taskDefinitionIds.add(t.TaskDefinitionRef__c);
        }

        Map<Id, TaskDefinition__c> taskDefinitions = new Map<Id, TaskDefinition__c>([
            SELECT Id, Name, StageRef__r.ProcessRef__c, StageRef__c, CompletionFormula__c
            FROM TaskDefinition__c
            WHERE Id IN :taskDefinitionIds
        ]);

        Schema.SObjectType taskSobjectType = Schema.Task.getSObjectType();
        Map<Id, FormulaEval.FormulaInstance> formulaInstances = new Map<Id, FormulaEval.FormulaInstance>();

        for (TaskDefinition__c td : taskDefinitions.values()) {
            // Build the formula for each
            FormulaEval.FormulaInstance ff = Formula.builder()
                .withType(taskSobjectType)
                .withReturnType(FormulaEval.FormulaReturnType.BOOLEAN)
                .withFormula(td.CompletionFormula__c)
                // .parseAsTemplate(false)
                .build();

            formulaInstances.put(td.Id, ff);
        }

        List<Task> tasksToUpdate = new List<Task>();

        for (Task t : tasks) {
            if (!formulaInstances.containsKey(t.TaskDefinitionRef__c)) {
                continue;
            }

            FormulaEval.FormulaInstance ff = formulaInstances.get(t.TaskDefinitionRef__c);

            if (!Boolean.valueOf(ff.evaluate(t))) {
                continue;
            }

            Task copy = new Task(Id = t.Id);
            // set task fields
            copy.Status = 'Completed';
            tasksToUpdate.add(copy);
        }

        System.enqueueJob(new TaskCompletionHandlerQueueable(tasksToUpdate));
    }
}