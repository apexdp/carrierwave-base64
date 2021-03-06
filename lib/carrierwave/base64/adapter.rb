module Carrierwave
  module Base64
    module Adapter
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def mount_base64_uploader(attribute, uploader_class, options = {})
        mount_uploader attribute, uploader_class, options
        options[:file_name] ||= proc { attribute }

        define_method "#{attribute}=" do |data|
          return if data == send(attribute).to_s

          if respond_to?("#{attribute}_will_change!") && data.present?
            send "#{attribute}_will_change!"
          end

          return super(data) unless data.is_a?(String) &&
                                    data.strip.start_with?('data')

          filename = if options[:file_name].respond_to?(:call)
                       options[:file_name].call(self)
                     else
                       options[:file_name].to_s
                     end

          super Carrierwave::Base64::Base64StringIO.new(data.strip, proc { filename })
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/PerceivedComplexity
      end

      def mount_base64_uploaders(attribute, uploader_class, options = {})
        mount_uploaders attribute, uploader_class, options
        options[:file_name] ||= proc { attribute }

        define_method "#{attribute}=" do |data|
          return if data == send(attribute).to_s

          if respond_to?("#{attribute}_will_change!") && data.present?
            send "#{attribute}_will_change!"
          end

          data = [data].flatten

          processed_data = data.map.with_index do |item, index|
            if item.is_a?(String) && item.strip.start_with?('data')
              filename = if options[:file_name].respond_to?(:call)
                options[:file_name].call(self)
              else
                options[:file_name].to_s
              end

              Carrierwave::Base64::Base64StringIO.new(item.strip, proc {"#{filename}_#{index}"})
            else
              item
            end
          end

          super processed_data
        end
      end
    end
  end
end
