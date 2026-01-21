/**
 * Queueable class to handle the completion of tasks
 */
public with sharing class TaskCompletionHandlerQueueable implements Queueable {
    private List<Task> tasks;

    /**
     * @description Constructor
     * @param tasks The tasks to process
     */
    public TaskCompletionHandlerQueueable(List<Task> tasks) {
        this.tasks = tasks;
    }

    /**
     * @description Execute the queueable
     * @param context The queueable context
     */
    public void execute(QueueableContext context) {
        if (this.tasks.isEmpty()) {
            return;
        }

        Database.update(this.tasks);
    }
}