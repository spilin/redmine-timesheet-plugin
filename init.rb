require 'redmine'

# Taken from lib/redmine.rb
if RUBY_VERSION < '1.9'
  require 'faster_csv'
else
  require 'csv'
end

Rails.application.config.after_initialize do
  # TODO: require_dependency and to_prepare callback will trigger an error in association, find a solution
  # This way it will be bugged in development
  User.send(:include, TimesheetPlugin::Patches::UserPatch)
  Project.send(:include, TimesheetPlugin::Patches::ProjectPatch)
  # Needed for the compatibility check
  begin
    require_dependency 'time_entry_activity'
  rescue LoadError
    # TimeEntryActivity is not available
  end
end

Redmine::Plugin.register :timesheet do
  name 'Timesheet Plugin'
  author 'Eric Davis of Little Stream Software'
  description 'This is a Timesheet plugin for Redmine to show timelogs for all projects'
  url 'https://projects.littlestreamsoftware.com/projects/redmine-timesheet'
  author_url 'http://www.littlestreamsoftware.com'

  version '0.6.0'
  requires_redmine :version_or_higher => '0.9.0'

  settings(:default => {
             'list_size' => '5',
             'precision' => '2',
             'project_status' => 'active',
             'user_status' => 'active'
           }, :partial => 'settings/timesheet_settings')

  permission :see_project_timesheets, { }, :require => :member

  menu(:top_menu,
       :timesheet,
       {:controller => 'timesheet', :action => 'index'},
       :caption => :timesheet_title,
       :if => Proc.new {
         User.current.allowed_to?(:see_project_timesheets, nil, :global => true) ||
         User.current.allowed_to?(:view_time_entries, nil, :global => true) ||
         User.current.admin?
       })

end
