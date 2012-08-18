require 'redmine'
require 'rails'

# Taken from lib/redmine.rb
if RUBY_VERSION < '1.9'
  require 'faster_csv'
else
  require 'csv'
end

class TimesheetRailtie < Rails::Railtie
  config.to_prepare do
    require_dependency 'project'
    require_dependency 'principal'
    require_dependency 'user'
    User.send(:include, TimesheetPlugin::Patches::UserPatch)
    Project.send(:include, TimesheetPlugin::Patches::ProjectPatch)
    begin
      require_dependency 'time_entry_activity'
    rescue LoadError
      # TimeEntryActivity is not available
    end
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
      'list_size'      => '5',
      'precision'      => '2',
      'project_status' => 'active',
      'user_status'    => 'active'
  },       :partial => 'settings/timesheet_settings')

  permission :see_project_timesheets, { }, :require => :member

  menu(:top_menu,
       :timesheet,
       { :controller => 'timesheet', :action => 'index' },
       :caption => :timesheet_title,
       :if      => Proc.new {
         User.current.allowed_to?(:see_project_timesheets, nil, :global => true) ||
             User.current.allowed_to?(:view_time_entries, nil, :global => true) ||
             User.current.admin?
       })

end
