# frozen_string_literal: true

# Section toggles
# ----------------
# Lets you switch whole parts of the site on/off from `_config.yml`:
#
#   sections:
#     blog: true
#     writing: false   # hides poems + essays everywhere
#
# The switches can also live in `_data/sections.yml` (editable from the /admin portal);
# values there override `_config.yml`.
#
# Any page or document whose front matter has `section: <name>` is dropped
# from the build when `sections.<name>` is false. Collection-wide defaults
# (e.g. every post is `section: blog`) are set under `defaults:` in _config.yml.
# The navbar (`_includes/header.liquid`) reads the same flags for the "More" menu.
# merge _data/sections.yml over _config.yml `sections:` as soon as data is read, so every
# reader of site.config["sections"] (generators, navbar Liquid via site.sections) sees it
Jekyll::Hooks.register :site, :post_read do |site|
  data = site.data["sections"]
  if data.is_a?(Hash)
    site.config["sections"] = (site.config["sections"] || {}).merge(data)
  end
end

module SectionToggles
  class Generator < Jekyll::Generator
    safe true
    priority :highest

    def generate(site)
      flags = site.config["sections"] || {}
      disabled = flags.select { |_, on| on == false }.keys
      return if disabled.empty?

      site.pages.reject! { |p| disabled.include?(p.data["section"]) }
      site.collections.each_value do |collection|
        collection.docs.reject! { |d| disabled.include?(d.data["section"]) }
      end
      Jekyll.logger.info "SectionToggles:", "disabled #{disabled.join(', ')}"
    end
  end
end
