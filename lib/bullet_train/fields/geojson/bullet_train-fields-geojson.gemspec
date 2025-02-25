require_relative 'version'

Gem::Specification.new do |spec|
  spec.name        = 'bullet_train-fields-geojson'
  spec.version     = BulletTrain::Fields::Geojson::VERSION
  spec.authors     = ['VendorSafe Team']
  spec.email       = ['dev@vendorsafe.com']
  spec.homepage    = 'https://github.com/bullet-train-co/bullet_train-fields-geojson'
  spec.summary     = 'GeoJSON field type for Bullet Train'
  spec.description = 'A Bullet Train field type for GeoJSON data, providing map-based input and display capabilities.'
  spec.license     = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.glob('{app,config,db,lib}/**/*', File::FNM_DOTMATCH)
  spec.require_paths = ['lib']

  spec.add_dependency 'bullet_train', '>= 1.0.0'
  spec.add_dependency 'rails', '>= 7.0.0'
  spec.add_dependency 'stimulus-rails', '>= 1.0.0'

  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'sqlite3'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
