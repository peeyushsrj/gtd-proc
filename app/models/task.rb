class Task < ApplicationRecord
   # Filter tasks based on context and energy level
  def self.filter_by_context_and_energy(context, energy_level)
    where(context: context, energy_level: energy_level)
  end
end
