config[:css_dir] = 'stylesheets'
config[:js_dir] = 'javascripts'
config[:images_dir] = 'images'

config[:markdown] = { auto_ids: false }

page '/index.html', layout: 'outer'

activate :directory_indexes
activate :livereload

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

helpers do
  def title_tag
    data = current_page.data

    title = if data.title
      data.title
    elsif data.guide && data.overview
      data.guide
    elsif data.guide
      "#{data.guide}: #{data.section}"
    else
      'Documentation'
    end

    "#{title} - Lita.io"
  end
end
