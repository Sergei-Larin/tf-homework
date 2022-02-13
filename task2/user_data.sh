#!/bin/bash
yum -y update
yum -y install httpd

cat <<EOF > /var/www/html/index.html
<html>
<body bgcolor="black">
<h2><font color="gold">Build by Terraform <font color="red"> v1.1.3</font></h2></font><br>

<p><font color="magenta">
<b>Version 1.0</b>
</font></p>
</body>
</html>
EOF

sudo service httpd start