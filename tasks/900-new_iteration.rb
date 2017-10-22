old_iteration_number = /\((\d+)\)/.match(project.current_swimlane.name)[1].to_i
new_iteration_number = old_iteration_number + 1
logger.info "New iteration number will be #{new_iteration_number}"

old_iteration = KanboardSwimlane.create(project.id, 'name' => "Iteration #{old_iteration_number}", 'description' => project.current_swimlane.description)
old_iteration.move_to_position(3)
logger.debug "Created new old Iteration #{old_iteration_number} swimlane"

old_description_attributes = {}
project.current_swimlane.description.lines.each do |line|
  name, value = line.split(':')
  old_description_attributes[name] = value.strip if !name.nil? && !value.nil?
end
start = Time.parse(old_description_attributes['End']) rescue Time.now
finish = start + 3.weeks

new_description_attributes = old_description_attributes.clone
new_description_attributes['Start'] = start.strftime("%Y-%m-%d")
new_description_attributes['End'] = finish.strftime("%Y-%m-%d")
new_description = new_description_attributes.map { |key, value| "#{key}: #{value}" }.join("\n")

project.current_swimlane.update('name' => "Current iteration (#{new_iteration_number})", 'description' => new_description)
logger.info "Please update new current iteration description, interval set to #{new_description_attributes['Start']} - #{new_description_attributes['End']}}"

done_tasks = project.current_done_tasks
logger.info "Moving #{done_tasks.size} tasks to old iteration"
done_tasks.each do |task|
  task.move_to_swimlane(old_iteration.name)
end