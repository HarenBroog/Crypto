class TasksController < ApplicationController

  expose(:task, attributes: :task_params)
  expose(:recent_tasks) {Task.last(5)}

  def new
  end

  def create
    if task.save
        redirect_to task_path(task)
    else
        render :new
    end
  end

  def show
  end

  private

  def task_params
    params.require(:task).permit(:name, :sbox)
  end

end
