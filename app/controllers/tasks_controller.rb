class TasksController < ApplicationController
  before_action :set_task, only: %i[ show edit update destroy ]

  # GET /tasks or /tasks.json
  # GET /tasks/1 or /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks or /tasks.json
  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to task_url(@task), notice: "Task was successfully created." }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1 or /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to task_url(@task), notice: "Task was successfully updated." }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1 or /tasks/1.json
  def destroy
    @task.destroy

    respond_to do |format|
      format.html { redirect_to tasks_url, notice: "Task was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def index
    #@tasks = Task.all
    #@tasks_by_status = Task.all.group_by(&:status)
    @tasks_by_status = Task.where.not(status: 'DONE').group_by(&:status)

  end

  def gtd
    context = params[:context]
    energy = params[:energy]

    print("&&&&&&")
    print(context, energy)
    if context.present?
      print("####")
      context_and_energy_tasks = Task.where(context: context)
    else
      print("----")
      context_and_energy_tasks = Task.all()
    end
    print(context_and_energy_tasks.count())

    if energy == "1" # High energy (checked)
      context_and_energy_tasks = context_and_energy_tasks.where(energy_level: true)
    else
      context_and_energy_tasks = context_and_energy_tasks.where(energy_level: false)
    end
    print(context_and_energy_tasks.count())

    due_today_tasks = Task.where(due_date: Date.today)

    @tasks = context_and_energy_tasks.or(due_today_tasks).group_by(&:project)

    @tasks.transform_values! { |tasks| sort_tasks(tasks) }
    render :gtd 
    # Render the gtd.html.erb template
  end

  def analytics
    @done_tasks_by_last_edited = Task.where(status: 'DONE').group_by { |task| task.updated_at.to_date }
  end

  private
  def filter_and_sort_tasks(tasks, context = nil, energy = nil)
    if context.present? && energy.present?
      tasks = tasks.where(context: context, energy_level: energy)
    end

    tasks_by_project = tasks.group_by(&:project)
    tasks_by_project.transform_values { |tasks| sort_tasks(tasks) }
  end

  def sort_tasks(tasks)
    tasks.sort_by { |task| [task.description.length, task.impact] }
  end
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.require(:task).permit(:description, :context, :project, :due_date, :schedule_date, :impact, :energy_level, :status, :notes, :size)
    end
end
