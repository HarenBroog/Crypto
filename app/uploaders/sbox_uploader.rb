# encoding: utf-8

class SboxUploader < CarrierWave::Uploader::Base
  storage :file
 
  def store_dir
     "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end
  
  def extension_white_list
    %w(SBX)
  end


end
