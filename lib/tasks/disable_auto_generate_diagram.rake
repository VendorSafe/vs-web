# This file temporarily disables the auto_generate_diagram rake task
# to avoid issues with the BulletTrain::Fields::Geojson::Version constant

Rake::Task['erd'].clear if Rake::Task.task_defined?('erd')
Rake::Task['erd:generate'].clear if Rake::Task.task_defined?('erd:generate')
Rake::Task['erd:load_models'].clear if Rake::Task.task_defined?('erd:load_models')
