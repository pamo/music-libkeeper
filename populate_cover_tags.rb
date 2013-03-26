#!/usr/bin/env ruby

require "taglib"
require "mime/types"
require "term/ansicolor"
require "dimensions"

include Term::ANSIColor

def mime_string file
  MIME::Types.type_for(file).first.to_s
end

def log color, message, data
  print color, bold, message, reset, " :: ", data, "\n"
end

def add_cover_to_mp3 song_file, image_file
  TagLib::MPEG::File.open(song_file) do |file|
    file.id3v2_tag.remove_frames 'APIC'

    apic = TagLib::ID3v2::AttachedPictureFrame.new
    apic.mime_type = mime_string image_file
    apic.description = "Cover"
    apic.type = TagLib::ID3v2::AttachedPictureFrame::FrontCover
    apic.picture = File.open(image_file, "rb") { |f| f.read }

    file.id3v2_tag.add_frame apic
    file.save
    log yellow, "saved", song_file
  end
end

def add_cover_to_m4a song_file, image_file
  # to be completed when taglib-ruby supports m4a :)
end

def add_cover_to_flac song_file, image_file
  TagLib::FLAC::File.open(song_file) do |file|
    file.remove_pictures

    pic = TagLib::FLAC::Picture.new
    pic.mime_type = mime_string image_file
    pic.description = "Cover"
    pic.type = TagLib::FLAC::Picture::FrontCover
    pic.width = Dimensions.width(image_file)
    pic.height = Dimensions.height(image_file)
    pic.data = File.open(image_file, "rb") { |f| f.read }

    file.add_picture pic
    file.save
    log yellow, "saved", song_file
  end
end


Dir.glob(File.join(ARGV[0], "**")).each do |folder|
  next unless File.directory? folder

  log red, "entering", folder
  Dir.glob(File.join(folder, "folder.{jpg,jpeg,png,gif}")) do |image_file|
    log blue, "cover file found", image_file
    log green, "mime type for image file", mime_string(image_file)

    Dir.glob(File.join(folder, "*.mp3")) do |song_file|
      add_cover_to_mp3 song_file, image_file
    end

    Dir.glob(File.join(folder, "*.flac")) do |song_file|
      add_cover_to_flac song_file, image_file
    end

  end
end


