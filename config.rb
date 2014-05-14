set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

activate :directory_indexes

configure :build do
  activate :asset_hash
  activate :gzip
  activate :minify_css
  activate :minify_javascript
end

activate :deploy do |deploy|
  deploy.method = :git
end
