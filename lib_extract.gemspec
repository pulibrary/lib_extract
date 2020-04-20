Gem::Specification.new do |spec|
  spec.name        = 'lib_extract'
  spec.version     = '0.1.0'
  spec.licenses    = ['MIT']
  spec.summary     = "Methods to extract library information."
  spec.description = "A library with methods to extract information from library data sources."
  spec.authors     = ["Mark Zelesky, Christina Chortaria"]
  spec.email       = ["mzelesky@princeton.edu", "actspatial@gmail.com"]
  spec.files       = ["lib"]
  spec.homepage    = 'https://github.com/pulibrary/lib_extract'

  spec.add_development_dependency 'irb'
  spec.add_development_dependency 'ruby-oci8'
  spec.add_development_dependency 'library_stdnums', '~> 1.6'
  spec.add_development_dependency 'marc', '~> 1.0'
  spec.add_development_dependency 'tiny_tds', '~> 2.1'
  spec.add_development_dependency 'faraday', '~> 1.0'
  spec.add_development_dependency 'nokogiri', '~> 1.10'
  spec.add_development_dependency 'marc_cleanup', github: "pulibrary/marc_cleanup", tag: 'v0.8.7'
end
