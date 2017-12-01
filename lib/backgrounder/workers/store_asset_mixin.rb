# encoding: utf-8
module CarrierWave
  module Workers

    module StoreAssetMixin
      include CarrierWave::Workers::Base

      def self.included(base)
        base.extend CarrierWave::Workers::ClassMethods
      end

      attr_reader :cache_path, :tmp_directory

      def perform(*args)
        record = super(*args)

        if record && record.send(:"#{column}_tmp")
          record.send :"process_#{column}_upload=", true
          record.send :"#{column}_processing=", false if record.respond_to?(:"#{column}_processing")
          if record.send(:"#{column}").is_a? Array
            data_uris = self.file_as_base64.map.with_index do |c, i|
              "data:#{self.content_type[i]};filename=#{self.filename[i]};base64,#{c}"
            end
            record.send(:"#{column}_urls=", data_uris)
          else
            record.send(:"#{column}_data_filename=", self.filename)
            record.send(:"#{column}_data_uri=", "data:#{self.content_type};base64,#{self.file_as_base64}")
          end
          record.save!
        else
          when_not_ready
        end
      end

    end # StoreAssetMixin

  end # Workers
end # Backgrounder
