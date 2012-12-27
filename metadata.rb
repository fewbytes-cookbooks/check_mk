maintainer       "YOUR_COMPANY_NAME"
maintainer_email "YOUR_EMAIL"
license          "All rights reserved"
description      "Installs/Configures check_mk"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

depends "apache2"
depends "cluster_service_discovery"
depends "fewbytes-common"
depends "xinetd"
depends "source"

supports "ubuntu", ">= 10.04"
supports "debian", ">= 6.0.0"
