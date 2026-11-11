# frozen_string_literal: true

# Make main.css's "?v=<hash>" change whenever OUR styles change.
#
# The theme's `bust_css_cache` filter hashes only the theme's built-in Sass partials, so edits to
# _sass/_custom.scss (colors, fonts, every custom component) kept the same ?v= value. Browsers and
# GitHub Pages' CDN then served the old cached main.css after a deploy, and pages looked half-styled.
# Here the hash is recomputed from the theme's partials plus this repo's _sass/ and assets/css/main.scss.
require "digest/md5"

module SiteCssCacheBust
  LOCAL_FILES = ["_sass/**/*.scss", "assets/css/main.scss"].freeze

  def digest!
    return super unless directory # bust_file_cache (single files) is unchanged

    local = LOCAL_FILES.flat_map { |g| Dir[g] }.sort.map { |f| File.read(f) }.join
    base = super.split("?v=").last
    [file_name, "?v=", Digest::MD5.hexdigest(base + local)].join
  end
end

Jekyll::Hooks.register :site, :after_init do
  digester = defined?(Jekyll::CacheBust::CacheDigester) && Jekyll::CacheBust::CacheDigester
  digester.prepend(SiteCssCacheBust) if digester && !digester.ancestors.include?(SiteCssCacheBust)
end
