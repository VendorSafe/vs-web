class CompanyGenerator
  POWER_PREFIXES = %w[
    Pacific Northwest Western Eastern Southern Northern
    American United National Global Interstate
    Crown Summit Valley Peak Mountain
  ]

  POWER_SUFFIXES = [
    'Power', 'Energy', 'Generation', 'Electric', 'Grid', 'Utilities', 'Resources', 'Power & Light'
  ]

  VENDOR_PREFIXES = %w[
    Advanced Precision Elite Pro Technical
    Industrial Environmental Digital Smart Integrated
    Modern Reliable Accurate
  ]

  VENDOR_SUFFIXES = %w[
    Systems Solutions Controls Monitoring Analytics
    Technologies Engineering Services Equipment
  ]

  class << self
    def generate_power_company
      "#{POWER_PREFIXES.sample} #{POWER_SUFFIXES.sample}"
    end

    def generate_vendor_company
      "#{VENDOR_PREFIXES.sample} #{VENDOR_SUFFIXES.sample}"
    end

    def generate_environment(count)
      environments = []
      count.times do
        power_company = generate_power_company
        vendor_company = generate_vendor_company

        environments << {
          power_company: power_company,
          vendor_company: vendor_company,
          emails: {
            customer: "demo.#{power_company.downcase.gsub(/\s+/, '.')}@vendorsafe.app",
            vendor: "demo.#{vendor_company.downcase.gsub(/\s+/, '.')}@vendorsafe.app",
            employee: "demo.employee.#{vendor_company.downcase.gsub(/\s+/, '.')}@vendorsafe.app"
          }
        }
      end
      environments
    end
  end
end
