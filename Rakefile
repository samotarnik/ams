
task :ensure_folder_structure do
  # TODO: this is duplicated in the code and should go into settings
  sh 'mkdir -p data/relationships/{html,json}'
  mkdir_p 'log'
  mkdir_p 'tmp/pids'
  touch 'log/data-retrieval.log'
end

desc 'raises sidekiq in production or development'
task :start_sidekiq_server => :ensure_folder_structure do
  if ENV['AMS_ENV'] == 'production'
    sh 'bundle exec sidekiq -d -e production -r ./lib/ams.rb'
  else
    sh 'bundle exec sidekiq -r ./lib/ams.rb'
  end
end

desc 'stop sidekiq production instance'
task :stop_sidekiq_server do
  sh 'sidekiqctl stop tmp/pids/sidekiq.pid'
end

desc 'initial enqueue, accepts artist id as param'
task :enqueue_artist do
  am_id = ARGV.shift
  raise "requires an am_id as argument" if am_id.nil?
  sh "ruby -r ./lib/ams.rb -e \"Ams::Init.new(#{am_id}).relationships\""
end
