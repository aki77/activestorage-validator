module LocalesHelper
  def self.locale_files
    Dir[File.join(File.dirname(__FILE__), '../../app/config/locales', '*.yml')]
  end
  
  def available_locales
    LocalesHelper.locale_files.map { |l| File.basename(l, '.yml') }
  end
end