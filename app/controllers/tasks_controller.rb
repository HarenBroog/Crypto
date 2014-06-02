class TasksController < ApplicationController

  expose(:task, attributes: :task_params)

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
