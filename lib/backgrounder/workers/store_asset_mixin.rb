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
          record.send(:"#{column}_data_filename=", self.filename)
          record.send(:"#{column}_data_uri=", self.file_as_base64)
          if record.save!
            FileUtils.rm_r(tmp_directory, :force => true)
          end
        else
          when_not_ready
        end
      end

    end # StoreAssetMixin

  end # Workers
end # Backgrounder
