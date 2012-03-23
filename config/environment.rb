# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Pipeline::Application.initialize!

JOB_FILES_PATH = Rails.root.join("../job_files")
Dir.mkdir JOB_FILES_PATH unless File.directory?(JOB_FILES_PATH)

PLUGIN_DIRECTORY_PATH = Rails.root.join("../plugins")
Dir.mkdir PLUGIN_DIRECTORY_PATH unless File.directory?(PLUGIN_DIRECTORY_PATH)

# ENV['RAILS_RELATIVE_URL_ROOT'] = "/pipeline"
# ActionController::AbstractRequest.relative_url_root = "/pipeline"
# Rails.configuration.action_controller[:relative_url_root] = "/pipeline"