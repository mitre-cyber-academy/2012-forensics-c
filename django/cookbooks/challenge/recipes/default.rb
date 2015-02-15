package "apache2" do
  action :install
end

package "unzip" do
  action :install
end

#package "libapache2-mod-python" do
#  action :install
#end

#package "libapache2-mod-wsgi" do
#  action :install
#end

#package "mysql-server" do
#  action[:install}
#end

bash "challenge" do
  user "root"
  code <<-EOH
    
    # install Django
    # wget -O /home/ubuntu/Django-1.1.4.tar.gz https://www.djangoproject.com/download/1.1.4/tarball
    mv /home/ubuntu/chef-solo/cookbooks/challenge/aux/Django-1.1.4.tar.gz /var/
    cd /var
    tar xzvf /var/Django-1.1.4.tar.gz
    cd Django-1.1.4
    python /var/Django-1.1.4/setup.py install
    
    # install Markdown
    # wget -O /home/ubuntu/Markdown-2.1.1.tar.gz http://pypi.python.org/packages/source/M/Markdown/Markdown-2.1.1.tar.gz#md5=3f82d30c488e4b88b8f86eb1c9ad0da7
    mv /home/ubuntu/chef-solo/cookbooks/challenge/aux/Markdown-2.1.1.tar.gz /var/
    cd /var
    tar xzvf /var/Markdown-2.1.1.tar.gz
    cd Markdown-2.1.1
    python /var/Markdown-2.1.1/setup.py install
    
    # setup group
    groupadd fread
    
    # setup flag user
    useradd -p $(openssl passwd -1 "this is the password 4 the flag user but you cant have it") -G fread timmy
    
    # configure sudoers file
    echo "ALL ALL=(timmy) NOPASSWD: /bin/cat" >> /etc/sudoers
    echo "ALL ALL=(ALL) NOPASSWD: /bin/ls" >> /etc/sudoers
    echo "Defaults passwd_tries=0" >> /etc/sudoers
    
    # cleanup
    rm /var/www/*
    rm /etc/apache2/sites-enabled/*
    rm /etc/apache2/sites-available/*
    
    # virtual host
    mv /home/ubuntu/chef-solo/cookbooks/challenge/aux/host /etc/apache2/sites-available/
    ln -s /etc/apache2/sites-available/host /etc/apache2/sites-enabled/host
    
    # all challenge files
    mv /home/ubuntu/chef-solo/cookbooks/challenge/aux/* /var/www/
    
    # set permissions 
    mkdir /home/corporate_secrets
    mv /var/www/flag.txt /home/corporate_secrets/flag.txt
    chown root:fread /home/corporate_secrets/flag.txt
    chmod 040 /home/corporate_secrets/flag.txt
    chmod 701 /home/corporate_secrets
    chmod 755 /home
    
    # start wiki
    unzip -d /var/www /var/www/wiki.zip
    # sudo -u www-data python /var/www/wiki/manage.py runserver $(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'):8080 &
    # sudo -u www-data python /var/www/wiki/manage.py runserver 0.0.0.0:8080 &
    
    # generate main page
    echo "We believe the code for our wiki may have been stolen, altered, and placed back on the server.<br>" > /var/www/index.html
    echo "Take a look and see if you can figure out what they did.<br>" >> /var/www/index.html
    echo "If you find anything, figure out what it does.<br><br>" >> /var/www/index.html
    echo "Our source code is here: http://$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')/wiki.zip<br><br>" >> /var/www/index.html
    echo "The wiki is here: http://$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'):8080/wiki" >> /var/www/index.html
    
  EOH
end

bash "initd" do
  user "root"
  code <<-EOH
    
    # move initd
    mv /home/ubuntu/chef-solo/cookbooks/challenge/aux/init_d_script /etc/init.d/django
    chmod 755 /etc/init.d/django
    
    # register it with boot sequence
    update-rc.d django defaults 98 02
    
  EOH
end

service "apache2" do
  action[:restart]
end

service "django" do
  action[:start]
end
