require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end
task :test => 'statsite:build'

namespace :statsite do
  desc 'Build statsite binary'
  task :'build' => 'vendor/statsite/statsite'

  desc 'Clean statsite artifacts'
  task :'clean' do
    sh 'make -C vendor/statsite clean'
  end

  file 'vendor/statsite/statsite' do
    sh 'make -C vendor/statsite'
  end
end

task :default => :test
