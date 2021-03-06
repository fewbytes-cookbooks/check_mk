name             "check_mk"
maintainer       "Fewbytes"
maintainer_email "chef@fewbytes.com"
license          "Apache 2.0"
description      "Installs/Configures Check_MK"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.3"

depends "apache2"
depends "php"
depends "xinetd"
depends "ark"
depends "sudo"

supports "ubuntu", ">= 10.04"
supports "debian", ">= 6.0.0"

conflicts "nagios"
