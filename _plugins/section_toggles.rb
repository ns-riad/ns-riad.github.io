# frozen_string_literal: true

# Section toggles
# ----------------
# Lets you switch whole parts of the site on/off from `_config.yml`:
#
#   sections:
#     blog: true
#     writing: false   # hides poems + essays everywhere
#
# Any page or document whose front matter has `section: <name>` is dropped
# from the build when `sections.<name>` is false. Collection-wide defaults
# (e.g. every post is `section: blog`) are set under `defaults:` in _config.yml.
# The navbar (`_includes/header.liquid`) reads the same flags for the "More" menu.
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
