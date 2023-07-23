json.extract! task, :id, :description, :context, :project, :due_date, :schedule_date, :impact, :energy_level, :status, :notes, :size, :created_at, :updated_at
json.url task_url(task, format: :json)
