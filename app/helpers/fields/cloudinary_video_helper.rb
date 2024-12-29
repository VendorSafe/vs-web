# Ejected from `bullet_train-fields-1.12.0/app/helpers/fields/cloudinary_image_helper.rb`.
module Fields::CloudinaryVideoHelper
  def cloudinary_video_tag(cloudinary_id, video_tag_options = {}, cloudinary_video_options = {})
    return nil unless cloudinary_id.present?

    if video_tag_options[:width]
      cloudinary_video_options[:width] ||= video_tag_options[:width] * 2
    end

    if video_tag_options[:height]
      cloudinary_video_options[:height] ||= video_tag_options[:height] * 2
    end

    cloudinary_video_options[:crop] ||= :fill

    video_tag cl_video_path(cloudinary_id, cloudinary_video_options), video_tag_options
  end
end
