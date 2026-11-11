# frozen_string_literal: true

# Media library: "drop a file in a folder and it shows up"
# ----------------------------------------------------------
# 1. CERTIFICATES  — every PDF/image under assets/certificates/<category>/ appears on /awards/.
#    The sub-folder name is the filter category. Optional details (nice title, issuer, date,
#    verify link) live in _data/certificates.yml, keyed by the file name without extension.
#
# 2. PHOTOGRAPHY   — every image in assets/photography/ appears on /photography/ and gets
#    its own page at /photography/<file-name>/. Optional title/caption/story link live in
#    _data/photos.yml, keyed the same way.
#
# For both, web-sized copies are generated at build time with ImageMagick (and Ghostscript for
# PDFs). Generated copies are stripped of all metadata (GPS included) and cached in
# .jekyll-cache/media/, so only new or changed files are processed. Original photos are NOT
# published; only the resized copies are.
require "fileutils"
require "json"
require "open3"
require "date"

module MediaLibrary
  IMAGE_EXT = %w[.jpg .jpeg .png .webp .tif .tiff .heic].freeze

  module Tools
    module_function

    def which(cmd)
      ENV["PATH"].to_s.split(File::PATH_SEPARATOR).map { |d| File.join(d, cmd) }.find { |p| File.executable?(p) }
    end

    def magick
      @magick ||= which("magick") || which("convert")
    end

    def gs
      @gs ||= which("gs")
    end

    def run(*cmd)
      _out, err, status = Open3.capture3(*cmd)
      Jekyll.logger.warn("MediaLibrary:", "#{cmd.first} failed: #{err.lines.first}") unless status.success?
      status.success?
    end

    def fresh?(src, dest)
      File.exist?(dest) && File.mtime(dest) >= File.mtime(src)
    end

    # Resize any image/PDF (first page) to a JPEG, strip metadata. Returns true on success.
    def render(src, dest, width, quality: 82)
      return true if fresh?(src, dest)
      return false unless magick

      FileUtils.mkdir_p(File.dirname(dest))
      input = src
      if File.extname(src).downcase == ".pdf"
        return false unless gs

        input = dest.sub(/\.jpg\z/, ".page1.png")
        ok = run(gs, "-q", "-dSAFER", "-dBATCH", "-dNOPAUSE", "-sDEVICE=png16m", "-r150",
                 "-dFirstPage=1", "-dLastPage=1", "-sOutputFile=#{input}", src)
        return false unless ok
      end
      ok = run(magick, "#{input}[0]", "-auto-orient", "-colorspace", "sRGB", "-depth", "8",
               "-resize", "#{width}x#{width}>", "-strip", "-interlace", "Plane",
               "-quality", quality.to_s, dest)
      FileUtils.rm_f(input) if input != src
      ok
    end

    # Width/height + a few EXIF fields (camera, date, exposure), cached alongside the renders.
    def info(src, cache_file)
      return JSON.parse(File.read(cache_file)) if fresh?(src, cache_file)
      return {} unless magick

      fmt = "%w|%h|%[EXIF:Model]|%[EXIF:LensModel]|%[EXIF:DateTimeOriginal]|%[EXIF:FNumber]|" \
            "%[EXIF:ExposureTime]|%[EXIF:PhotographicSensitivity]|%[EXIF:FocalLength]|%[EXIF:Orientation]"
      identify = magick.end_with?("magick") ? [magick, "identify"] : [magick.sub(/convert\z/, "identify")]
      out, _e, st = Open3.capture3(*identify, "-format", fmt, "#{src}[0]")
      return {} unless st.success?

      w, h, model, lens, date, f, exp, iso, focal, orient = out.split("|", -1)
      w = w.to_i
      h = h.to_i
      w, h = h, w if %w[5 6 7 8].include?(orient.to_s.strip) # rotated by auto-orient
      data = { "width" => w, "height" => h, "camera" => model, "lens" => lens, "taken" => date,
               "aperture" => rational(f, prefix: "f/"), "shutter" => exposure(exp),
               "iso" => iso.to_s.strip.empty? ? nil : "ISO #{iso}", "focal" => rational(focal, suffix: " mm") }
      data.transform_values! { |v| v.is_a?(String) && v.strip.empty? ? nil : v }
      FileUtils.mkdir_p(File.dirname(cache_file))
      File.write(cache_file, JSON.generate(data))
      data
    end

    def rational(value, prefix: "", suffix: "")
      return nil if value.to_s.strip.empty?

      n, d = value.split("/").map(&:to_f)
      v = d && d.positive? ? n / d : n
      "#{prefix}#{format('%g', v.round(1))}#{suffix}"
    end

    def exposure(value)
      return nil if value.to_s.strip.empty?

      n, d = value.split("/").map(&:to_f)
      v = d && d.positive? ? n / d : n
      v >= 1 ? "#{format('%g', v.round(1))}s" : "1/#{(1 / v).round}s"
    end
  end

  def self.humanize(stem)
    stem.tr("_-", "  ").gsub(/\s+/, " ").strip.sub(/\A./, &:upcase)
  end

  # "2020-05" -> "May 2020", "2020" -> "2020", "2022-01-14" -> "Jan 2022"
  def self.date_label(value)
    v = value.to_s.strip
    return nil if v.empty?

    y, m = v.split("-")
    m && m.to_i.between?(1, 12) ? "#{Date::ABBR_MONTHNAMES[m.to_i]} #{y}" : y
  end

  def self.cache_root(site)
    File.join(site.source, ".jekyll-cache", "media")
  end

  # Registers a generated file so it is written to _site/<rel_dir>/<name>
  def self.publish(site, rel_dir, name)
    site.static_files << Jekyll::StaticFile.new(site, cache_root(site), rel_dir, name)
  end

  # ---------------------------------------------------------------- certificates
  class Certificates < Jekyll::Generator
    safe true
    priority :low
    FOLDER = "assets/certificates"
    EXT = (IMAGE_EXT + [".pdf"]).freeze

    def generate(site)
      meta = site.data.dig("certificates", "items") || {}
      labels = site.data.dig("certificates", "categories") || {}
      root = File.join(site.source, FOLDER)
      files = Dir.glob(File.join(root, "**", "*")).select { |f| File.file?(f) && EXT.include?(File.extname(f).downcase) }

      items = files.sort.map do |path|
        rel = path.sub("#{site.source}/", "")
        sub = File.dirname(path).sub(root, "").sub(%r{\A/}, "")
        category = sub.empty? ? "other" : sub.split("/").first
        stem = File.basename(path, ".*")
        m = meta[stem] || {}
        thumb_rel = File.join(FOLDER, "thumbs", sub)
        thumb_name = "#{stem}.jpg"
        thumb_url = nil
        if Tools.render(path, File.join(MediaLibrary.cache_root(site), thumb_rel, thumb_name), 1400)
          MediaLibrary.publish(site, thumb_rel, thumb_name)
          thumb_url = "/#{thumb_rel}/#{thumb_name}"
        end
        {
          "key" => stem,
          "title" => m["title"] || MediaLibrary.humanize(stem),
          "issuer" => m["issuer"],
          "date" => m["date"].to_s,
          "date_label" => MediaLibrary.date_label(m["date"]),
          "verify" => m["verify"],
          "category" => m["category"] || category,
          "file" => "/#{rel}",
          "pdf" => File.extname(path).casecmp(".pdf").zero?,
          "thumb" => thumb_url,
        }
      end
      items.sort_by! { |i| [i["date"].empty? ? "0" : i["date"], i["title"]] }.reverse!

      found = items.map { |i| i["key"] }
      listed_only = meta.reject { |k, _| found.include?(k) }.map do |k, m|
        m.merge("key" => k, "title" => m["title"] || MediaLibrary.humanize(k), "date" => m["date"].to_s,
                "date_label" => MediaLibrary.date_label(m["date"]))
      end
      listed_only.sort_by! { |i| [i["date"].empty? ? "0" : i["date"], i["title"]] }.reverse!

      cats = items.map { |i| i["category"] }.uniq
      ordered = labels.keys.select { |k| cats.include?(k) } + (cats - labels.keys).sort
      site.data["certificate_files"] = items
      site.data["certificate_text_only"] = listed_only
      site.data["certificate_categories"] = ordered.map { |c| { "key" => c, "label" => labels[c] || MediaLibrary.humanize(c) } }
      Jekyll.logger.info("MediaLibrary:", "#{items.size} certificates (#{items.count { |i| i['thumb'] }} with previews)")
    end
  end

  # ---------------------------------------------------------------- photography
  class PhotoPage < Jekyll::PageWithoutAFile; end

  class Photos < Jekyll::Generator
    safe true
    priority :low
    FOLDER = "assets/photography"
    OUT = "assets/photos"

    def generate(site)
      return if site.config.dig("sections", "photography") == false

      root = File.join(site.source, FOLDER)
      files = Dir.glob(File.join(root, "*")).select { |f| File.file?(f) && IMAGE_EXT.include?(File.extname(f).downcase) }
      # never publish the (large, metadata-carrying) originals
      site.static_files.reject! { |sf| sf.path.start_with?(root + "/") }

      meta = site.data.dig("photos", "items") || {}
      cache = MediaLibrary.cache_root(site)
      photos = files.map do |path|
        stem = File.basename(path, ".*")
        slug = Jekyll::Utils.slugify(stem)
        m = meta[stem] || {}
        next nil if m["hidden"]

        sizes = { "thumb" => 900, "large" => 2200 }
        urls = {}
        sizes.each do |label, width|
          name = "#{slug}-#{label}.jpg"
          next unless Tools.render(path, File.join(cache, OUT, name), width, quality: label == "thumb" ? 78 : 86)

          MediaLibrary.publish(site, OUT, name)
          urls[label] = "/#{OUT}/#{name}"
        end
        next nil if urls.empty?

        info = Tools.info(path, File.join(cache, "info", "#{slug}.json"))
        exif_date = info["taken"].to_s[0, 10].tr(":", "-")
        date = (m["date"] || exif_date).to_s
        {
          "slug" => slug,
          "url" => "/photography/#{slug}/",
          "title" => m["title"] || MediaLibrary.humanize(stem),
          "caption" => m["caption"],
          "place" => m["place"],
          "date" => date,
          "album" => m["album"],
          "story" => m["story"],
          "story_label" => m["story_label"],
          "thumb" => urls["thumb"] || urls["large"],
          "large" => urls["large"] || urls["thumb"],
          "width" => info["width"],
          "height" => info["height"],
          "orientation" => info["width"].to_i >= info["height"].to_i ? "landscape" : "portrait",
          "exif" => info.slice("camera", "lens", "focal", "aperture", "shutter", "iso").compact,
          "order" => m["order"],
        }
      end.compact

      # explicit `order:` first, then newest date, then name
      photos.sort_by! { |p| [p["order"] || 9999, -(p["date"].to_s.delete("-").to_i), p["title"]] }
      site.data["photo_list"] = photos

      photos.each_with_index do |p, i|
        page = PhotoPage.new(site, site.source, "photography/#{p['slug']}", "index.html")
        page.data.merge!(
          "layout" => "photo",
          "title" => p["title"],
          "description" => p["caption"] || p["title"],
          "photo" => p,
          "prev_photo" => i.positive? ? photos[i - 1] : nil,
          "next_photo" => photos[i + 1],
          "section" => "photography",
          "og_image" => p["large"],
          "sitemap" => true,
        )
        site.pages << page
      end
      Jekyll.logger.info("MediaLibrary:", "#{photos.size} photos")
    end
  end
end
