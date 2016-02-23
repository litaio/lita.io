config[:css_dir] = 'stylesheets'
config[:js_dir] = 'javascripts'
config[:images_dir] = 'images'

config[:markdown] = { auto_ids: false }

page '/index.html', layout: 'outer'

activate :directory_indexes

configure :server do
  activate :livereload
end

configure :build do
  activate :asset_hash
  activate :gzip
  activate :minify_css
  activate :minify_javascript
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
