config[:css_dir] = 'stylesheets'
config[:js_dir] = 'javascripts'
config[:images_dir] = 'images'

config[:markdown_engine] = :redcarpet
config[:markdown] = {
  disable_indented_code_blocks: true,
  fenced_code_blocks: true,
  no_intra_emphasis: true
}

activate :directory_indexes

configure :build do
  activate :asset_hash
  activate :gzip
  activate :minify_css
  activate :minify_javascript
end

activate :deploy do |deploy|
  deploy.build_before = true
  deploy.method = :git
end
