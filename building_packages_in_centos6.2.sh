#!/bin/sh
# install packages under Centos 6.2 final for sws(sina web service)
# author yaohua.wu@weiyouxi.com
# date 2012-06-04
#
# compile attention: all packages compile without "make test"
# packages contain: nginx, php, memcached
# packages detail:
# 1. nginx: 1.2.0
# 2. libevent:
# 3. memcached:
# 4. libmcrypt:
# 5. php:

# some other tools
# sae sws internal resource MAYBE BROKEN , CHANGE /etc/yum.conf before install
sed -i '27,61s/^/#/' /etc/yum.conf
# pypy dependencies
yum install -y \
gcc make python-devel libffi-devel pkgconfig \
zlib-devel bzip2-devel ncurses-devel expat-devel \
openssl-devel gc-devel python-sphinx python-greenlet

yum install -y gcc cpp gcc-c++ glibc autoconf automake make \
pcre pcre-devel openssl openssl-devel curl curl-devel libxml2-devel zlib-devel bison bison-devel expat-devel bzip2-devel \
perl perl-devel perl-Test-Base \
subversion \
file lsof screen tree nc sudo

# some directorys related to build packages
umount /dev/vdb
mkdir -p /data0
mount /dev/vdb /data0
mkdir -p /data0/{building,software,app/{services,log},tmp}
cat >> /etc/fstab <<EOF
/dev/vdb /data0 ext3 defaults 0 0
EOF

# building enviroment
building_path=/data0/building
software_path=/data0/software
app_path=/data0/app/services
log_path=/data0/app/log
project_path=/data0/wyx

download_tool=/usr/bin/wget
extra_tool=/bin/tar
ln_tool=/bin/ln

# resource download url
resource_url="http://nginx.org/download/nginx-1.2.0.tar.gz
https://github.com/downloads/libevent/libevent/libevent-2.0.18-stable.tar.gz
http://memcached.googlecode.com/files/memcached-1.4.13.tar.gz
https://launchpad.net/libmemcached/1.0/1.0.8/+download/libmemcached-1.0.8.tar.gz
https://launchpad.net/libmemcached/1.0/1.0.4/+download/libmemcached-1.0.4.tar.gz
http://cn.php.net/get/php-5.4.3.tar.gz/from/cn2.php.net/mirror
http://sourceforge.net/projects/mcrypt/files/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz/download
http://pecl.php.net/get/memcached-2.0.1.tgz
http://pecl.php.net/get/memcache-2.2.6.tgz
http://pecl.php.net/get/igbinary-1.1.1.tgz
http://pecl.php.net/get/APC-3.1.9.tgz
"
#cd $software_path
#for src in $resource_url
#do
    #$download_tool --no-check-certificate $src
#done

#################################################
# building begin
# nginx
cd $building_path
$extra_tool xf $software_path/nginx-1.2.0.tar.gz
cd nginx-1.2.0
./configure --prefix=$app_path/nginx-1.2.0 \
--with-http_gzip_static_module \
--with-http_stub_status_module \
--with-pcre \
--without-mail_pop3_module \
--without-mail_imap_module \
--without-mail_smtp_module \
&& make -j3 \
&& make install
$ln_tool -svf $app_path/nginx{-1.2.0,}

# libevent
cd $building_path
$extra_tool xvf $software_path/libevent-2.0.18-stable.tar.gz
cd libevent-2.0.18-stable
./configure --prefix=$app_path/libevent-2.0.18 && make -j3 && make install
ln -svf $app_path/libevent{-2.0.18,}
echo $app_path/libevent/lib >> /etc/ld.so.conf
# vim /etc/ld.so.conf # 注释掉默认的libevent
ldconfig

# memcached
cd $building_path
$extra_tool xvf $software_path/memcached-1.4.13.tar.gz
cd memcached-1.4.13
./configure --prefix=$app_path/memcached-1.4.13 \
--disable-sasl \
--disable-sasl-pwdb \
--disable-dtrace \
--disable-coverage \
--disable-docs \
--enable-64bit \
--with-libevent=$app_path/libevent/ \
&& make -j3 \
&& make install
$ln_tool -svf $app_path/memcached{-1.4.13,}

# libmemcached
# 1.0.8 version compile failed(make test failed)
cd $building_path
$extra_tool xvf $software_path/libmemcached-1.0.4.tar.gz
cd libmemcached-1.0.4
./configure --prefix=$app_path/libmemcached-1.0.4 \
--enable-64bit \
--disable-profiling \
--disable-coverage \
--disable-dtrace \
--disable-assert \
--with-memcached=$app_path/memcached/bin/memcached \
&& make -j3 \
&& make install
$ln_tool -svf $app_path/libmemcached{-1.0.4,}
echo $app_path/libmemcached/lib >> /etc/ld.so.conf
ldconfig

# php
cd $building_path
$extra_tool xvf $software_path/php-5.4.3.tar.gz
cd php-5.4.3
./configure --prefix=$app_path/php-5.4.3 \
--with-config-file-path=$app_path/php-5.4.3/etc \
--with-config-file-scan-dir=$app_path/php-5.4.3/etc/conf.d \
--disable-ipv6 \
--disable-debug \
--disable-all \
--with-mysql=shared,mysqlnd \
--with-mysqli=shared,mysqlnd \
--with-pdo-mysql=shared,mysqlnd \
--with-iconv=shared \
--with-openssl=shared \
--with-curl=shared \
--with-pear \
--with-zend-vm=GOTO \
--enable-sockets \
--enable-pdo \
--enable-json \
--enable-xml \
--enable-libxml \
--enable-session \
--enable-mbstring \
--enable-fpm \
&& make -j3 \
&& make install
$ln_tool -svf $app_path/php{-5.4.3,}
mkdir -p $app_path/php/etc/conf.d
cp php.ini-development  php.ini-production $app_path/php/etc/etc/

# php-igbinary
#$app_path/php/bin/pecl install igbinary
cd $building_path
rm -rvf igbinary-1.1.1/
$extra_tool xvf $software_path/igbinary-1.1.1.tgz
cd igbinary-1.1.1
$app_path/php/bin/phpize
./configure --with-php-config=$app_path/php/bin/php-config \
--enable-igbinary \
&& make -j3 \
&& make install

# php-memcache
#$app_path/php/bin/pecl install memcache
cd $building_path
rm -rvf memcache-2.2.6
$extra_tool xvf $software_path/memcache-2.2.6.tgz
cd memcache-2.2.6
$app_path/php/bin/phpize
./configure --with-php-config=$app_path/php/bin/php-config \
--enable-memcache \
--disable-debug \
&& make -j3 \
&& make install

# php-memcached
#$app_path/php/bin/pecl install memcached
cd $building_path
rm -rvf memcached-2.0.1
$extra_tool xvf $software_path/memcached-2.0.1.tgz
cd memcached-2.0.1
$app_path/php/bin/phpize
./configure --with-php-config=$app_path/php/bin/php-config \
--disable-memcached-sasl \
--disable-debug \
--enable-memcached \
--enable-memcached-igbinary \
--enable-memcached-json \
--with-libmemcached-dir=$app_path/libmemcached/ \
&& make -j3 \
&& make install

# php-mbstring
cd $building_path/php-5.4.3/ext/mbstring
$app_path/php/bin/phpize
./configure --with-php-config=$app_path/php/bin/php-config \
--enable-mbstring \
&& make -j3 \
&& make install

# libmcrypt
cd $building_path
rm -rvf libmcrypt-2.5.8
$extra_tool xvf $software_path/libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure --prefix=$app_path/libmcrypt-2.5.8 \
&& make -j3 \
&& make install
$ln_tool -svf $app_path/libmcrypt{-2.5.8,}
echo $app_path/libmcrypt/lib >>  /etc/ld.so.conf
ldconfig

# php-libmcrypt
cd $building_path/php-5.4.3/ext/mcrypt
$app_path/php/bin/phpize
./configure --with-php-config=$app_path/php/bin/php-config \
--with-mcrypt=$app_path/libmcrypt/ \
&& make -j3 \
&& make install

# building end

#################################################
cd
# config begin
# PATH setting
cat >> ~/.bashrc <<EOF
##########
# user config
##########
export PATH=$app_path/php/bin:$app_path/nginx/sbin:$app_path/memcached/bin:\$PATH
EOF
source ~/.bashrc

# php config
#cp $app_path/php/etc/php.ini{-production,}
rm -rvf $app_path/php/etc/php.ini
touch $app_path/php/etc/php.ini
cat >> $app_path/php/etc/php.ini <<EOF
[PHP]
engine = On
short_open_tag = Off
asp_tags = Off
precision = 14
output_buffering = 4096
zlib.output_compression = Off
implicit_flush = Off
unserialize_callback_func =
serialize_precision = 17
disable_functions =
disable_classes =
zend.enable_gc = On
expose_php = On
max_execution_time = 60
max_input_time = 60
memory_limit = 64M
error_reporting = E_ALL | E_STRICT
display_errors = Off
display_startup_errors = Off
log_errors = On
log_errors_max_len = 1024
ignore_repeated_errors = Off
ignore_repeated_source = Off
report_memleaks = On
track_errors = Off
html_errors = On
variables_order = "GPCS"
request_order = "GP"
register_argc_argv = Off
auto_globals_jit = On
post_max_size = 10M
auto_prepend_file =
auto_append_file =
default_mimetype = "text/html"
doc_root =
user_dir =
enable_dl = Off
file_uploads = On
upload_max_filesize = 10M
max_file_uploads = 10
allow_url_fopen = On
allow_url_include = Off
default_socket_timeout = 60

extension=curl.so
extension=memcache.so
extension=memcached.so
extension=mcrypt.so
extension=igbinary.so
extension=iconv.so
extension=openssl.so
extension=pdo_mysql.so
extension=mysql.so
extension=mysqli.so
;extension=session.so
EOF

rm -rvf $app_path/php/etc/conf.d/date.ini
touch $app_path/php/etc/conf.d/date.ini
cat $app_path/php/etc/conf.d/date.ini <<EOF
[Date]
date.timezone=Asia/Shanghai
EOF

rm -rvf $app_path/php/etc/conf.d/curl.ini
touch $app_path/php/etc/conf.d/curl.ini
cat $app_path/php/etc/conf.d/curl.ini <<EOF
[Curl]
EOF

rm -rvf $app_path/php/etc/conf.d/memcache.ini
touch $app_path/php/etc/conf.d/memcache.ini
cat $app_path/php/etc/conf.d/memcache.ini <<EOF
[memcache]
EOF

rm -rvf $app_path/php/etc/conf.d/memcached.ini
touch $app_path/php/etc/conf.d/memcached.ini
cat $app_path/php/etc/conf.d/memcached.ini <<EOF
[memcached]
EOF

rm -rvf $app_path/php/etc/conf.d/mcrypt.ini
touch $app_path/php/etc/conf.d/mcrypt.ini
cat $app_path/php/etc/conf.d/mcrypt.ini <<EOF
[mcrypt]
EOF

rm -rvf $app_path/php/etc/conf.d/igbinary.ini
touch $app_path/php/etc/conf.d/igbinary.ini
cat $app_path/php/etc/conf.d/igbinary.ini <<EOF
[igbinary]
EOF

rm -rvf $app_path/php/etc/conf.d/iconv.ini
touch $app_path/php/etc/conf.d/iconv.ini
cat $app_path/php/etc/conf.d/iconv.ini <<EOF
[iconv]
EOF

rm -rvf $app_path/php/etc/conf.d/openssl.ini
touch $app_path/php/etc/conf.d/openssl.ini
cat $app_path/php/etc/conf.d/openssl.ini <<EOF
[openssl]
EOF

rm -rvf $app_path/php/etc/conf.d/mail.ini
touch $app_path/php/etc/conf.d/mail.ini
cat >> $app_path/php/etc/conf.d/mail.ini <<EOF
[mail function]
SMTP = localhost
smtp_port = 25
mail.add_x_header = On
EOF

rm -rvf $app_path/php/etc/conf.d/pdo.ini
touch $app_path/php/etc/conf.d/pdo.ini
cat >> $app_path/php/etc/conf.d/pdo.ini <<EOF
[Pdo]
EOF

rm -rvf $app_path/php/etc/conf.d/pdo_mysql.ini
touch $app_path/php/etc/conf.d/pdo_mysql.ini
cat >> $app_path/php/etc/conf.d/pdo_mysql.ini <<EOF
[Pdo_mysql]
pdo_mysql.cache_size = 2000
pdo_mysql.default_socket=
EOF

rm -rvf $app_path/php/etc/conf.d/sql.ini
touch $app_path/php/etc/conf.d/sql.ini
cat >> $app_path/php/etc/conf.d/sql.ini <<EOF
[SQL]
sql.safe_mode = Off
EOF

rm -rvf $app_path/php/etc/conf.d/mysql.ini
touch $app_path/php/etc/conf.d/mysql.ini
cat >> $app_path/php/etc/conf.d/mysql.ini <<EOF
[MySQL]
mysql.allow_local_infile = On
mysql.allow_persistent = On
mysql.cache_size = 2000
mysql.max_persistent = -1
mysql.max_links = -1
mysql.default_port =
mysql.default_socket =
mysql.default_host =
mysql.default_user =
mysql.default_password =
mysql.connect_timeout = 60
mysql.trace_mode = Off
EOF

rm -rvf $app_path/php/etc/conf.d/mysqli.ini
touch $app_path/php/etc/conf.d/mysqli.ini
cat >> $app_path/php/etc/conf.d/mysqli.ini <<EOF
[MySQLi]
mysqli.max_persistent = -1
mysqli.allow_persistent = On
mysqli.max_links = -1
mysqli.cache_size = 2000
mysqli.default_port = 3306
mysqli.default_socket =
mysqli.default_host =
mysqli.default_user =
mysqli.default_pw =
mysqli.reconnect = Off
EOF

rm -rvf $app_path/php/etc/conf.d/mysqlnd.ini
touch $app_path/php/etc/conf.d/mysqlnd.ini
cat >> $app_path/php/etc/conf.d/mysqlnd.ini <<EOF
[mysqlnd]
mysqlnd.collect_statistics = On
mysqlnd.collect_memory_statistics = Off
EOF

rm -rvf $app_path/php/etc/conf.d/session.ini
touch $app_path/php/etc/conf.d/session.ini
cat >> $app_path/php/etc/conf.d/session.ini <<EOF
[Session]
session.save_handler = files
session.use_cookies = 1
session.use_only_cookies = 1
session.name = PHPSESSID
session.auto_start = 0
session.cookie_lifetime = 0
session.cookie_path = /
session.cookie_domain =
session.cookie_httponly =
session.serialize_handler = php
session.gc_probability = 1
session.gc_divisor = 1000
session.gc_maxlifetime = 1440
session.bug_compat_42 = Off
session.bug_compat_warn = Off
session.referer_check =
session.cache_limiter = nocache
session.cache_expire = 180
session.use_trans_sid = 0
session.hash_function = 0
session.hash_bits_per_character = 5
url_rewriter.tags = "a=href,area=href,frame=src,input=src,form=fakeentry"
EOF

rm -rvf $app_path/php/etc/php-fpm.conf
#cp $app_path/php/etc/php-fpm.conf{.default,}
touch $app_path/php/etc/php-fpm.conf
cat >> $app_path/php/etc/php-fpm.conf <<EOF
[www]
user = nobody
group = nobody
listen = 9000
listen.backlog = 98304

pm = dynamic
pm.max_children = 30
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
request_terminate_timeout = 30s
;pm.max_requests = 1000
pm.max_requests = 102400

rlimit_files = 65536
rlimit_core = unlimited

;chdir = /

[wwwsocket]
user = nobody
group = nobody
listen = $app_path/php/var/run/phpfpm.socket
listen.backlog = 98304

pm = dynamic
pm.max_children = 30
pm.start_servers = 6
pm.min_spare_servers = 4
pm.max_spare_servers = 8
request_terminate_timeout = 30s
;pm.max_requests = 1000
pm.max_requests = 102400

rlimit_files = 65536
rlimit_core = unlimited

;chdir = /
EOF

rm -rvf /etc/init.d/phpfpm
touch /etc/init.d/phpfpm
chmod +x /etc/init.d/phpfpm
cat >> /etc/init.d/phpfpm <<EOF
#!/bin/sh
# descript phpfpm管理
# author yaohua.wu@weiyouxi.com
# date 2012-03-02

app_path=/data0/app/services
exec_file=\$app_path/php/sbin/php-fpm
ini_file=\$app_path/php/etc/php.ini
fpm_conf_file=\$app_path/php/etc/php-fpm.conf
pid_file=\$app_path/php/var/run/php-fpm.pid

mode=\$1
case "\$mode" in
  'start')
    if test -f \$pid_file; then
      echo -e 'phpfpm had been start OR stop error!\n'
      echo -e 'TRY TO CHECK AND REMOVE THE FILE: ' \$pid_file '\n'
    else
      \$exec_file -c \$ini_file -y \$fpm_conf_file -g \$pid_file
      echo -e 'phpfpm start successful!\n'
    fi
    ;;

  'stop')
    if test -f \$pid_file; then
      kill -INT \$(cat \$pid_file)
      echo -e 'phpfpm stop successful!\n'
    else
      echo -e 'phpfpm not started OR stop error!\n'
      echo -e 'TRY TO CHECK AND REMOVE THE FILE: ' $pid_file '\n'
    fi
    ;;

  'restart')
    if test -f \$pid_file; then
      kill -USR2 \$(cat \$pid_file)
      echo -e 'phpfpm restart successful!\n'
    else
      echo -e 'phpfpm not started OR phpfpm stop error!\n'
      echo -e 'TRY TO CHECK AND REMOVE THE FILE: ' \$pid_file '\n'
      echo -e 'OR JUST CONFIG MANUAL!'
    fi
    ;;

  # @todo 重写为函数
  'forcerestart')
    # stop
    if test -f \$pid_file; then
      kill -INT \$(cat \$pid_file)
      echo -e 'phpfpm stop successful!\n'
    else
      echo -e 'phpfpm not started OR stop error!\n'
      echo -e 'TRY TO CHECK AND REMOVE THE FILE: ' $pid_file '\n'
    fi

    /bin/sleep 1

    # start
    if test -f \$pid_file; then
      echo -e 'phpfpm had been start OR stop error!\n'
      echo -e 'TRY TO CHECK AND REMOVE THE FILE: ' \$pid_file '\n'
    else
      \$exec_file -c \$ini_file -y \$fpm_conf_file -g \$pid_file
      echo -e 'phpfpm start successful!\n'
    fi
    ;;

  *)
    echo -e "usage: \$0 start|stop|restart|forcerestart\n"
    exit 1
    ;;

esac

exit 0
EOF

# nginx config
mkdir -p $app_path/nginx/conf/conf.d
mkdir -p $log_path/nginx
chmod o+wx $log_path/nginx
rm -rvf $app_path/nginx/conf/nginx.conf
touch $app_path/nginx/conf/nginx.conf
cat >> $app_path/nginx/conf/nginx.conf <<EOF
user  nobody nobody;
worker_processes  2;
worker_cpu_affinity 01 10;

error_log  $log_path/nginx/error.log;

pid        $app_path/nginx/logs/nginx.pid;

worker_rlimit_nofile 200000; # file handler, set by ulimit -n NUM

events {
    worker_connections  20480;
    use epoll;
    accept_mutex on; # default on
    accept_mutex_delay 30ms; # default 500ms
    multi_accept off; # default off
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  $app_path/nginx/logs/access.log  main;

# 性能调优相关参数
# client_body_buffer_size 8K;
# client_header_buffer_size 2k;
# client_max_body_size 2m;
# large_client_header_buffers 56 4k;
# client_body_timeout   30;
# client_header_timeout 30;
# keepalive_timeout     15;
# send_timeout          30;

    sendfile        on;
    tcp_nopush     on; # sendfile 打开时才有效; 为了使用TCP_CORK

    keepalive_timeout  10 10;
    tcp_nodelay on; # keepalive打开才有效

    server_names_hash_bucket_size 64;

# 性能调优相关参数
# open_file_cache max=20480 inactive=20s;
# open_file_cache_min_uses 1;
# open_file_cache_valid 30s;

    gzip  on;
    gzip_min_length 1k;
    gzip_proxied any;
    gzip_types text/plain text/css application/x-javascript text/xml application/xml application/xml+rss text/javascript application/x-shockwave-flash;
    gzip_vary on;
    gzip_buffers 16 8k;
    gzip_comp_level 5;

    gzip_disable ”MSIE [1-6] \.”;
    # 以下内容需要copy到server配置中
    # if ($http_user_agent ~ "MSIE [1-6]\.") {
    #     # Must explicitly turns off gzip to prevent Nginx set Vary:Accept-Encoding
    #     # which will prevent IE6 from caching anything
    #     gzip off;
    #     add_header Vary "User-Agent";
    # }

# 性能调优相关参数
# fastcgi_connect_timeout 30;
# fastcgi_send_timeout 180;
# fastcgi_read_timeout 180;
# fastcgi_buffer_size 64k;
# fastcgi_buffers 4 64k;
# fastcgi_busy_buffers_size 128k;
# fastcgi_temp_file_write_size 128k;
# fastcgi_intercept_errors on;

# 文件缓存, 非必要情况下不需要
# fastcgi_cache_path $app_path/nginx/fastcgi_temp levels=1:2 keys_zone=TEST:10m inactive=5m;
# fastcgi_cache TEST;
# fastcgi_cache_valid 200 302 1h;
# fastcgi_cache_valid 301 1d;
# fastcgi_cache_valid any 1m;
# fastcgi_cache_min_uses 1;
# fastcgi_cache_use_stale error timeout invalid_header http_500;

    upstream  phpcgi  {
        # socket local
        server unix:$app_path/php/var/run/phpfpm.socket weight=50 max_fails=0 fail_timeout=5s;

        # other host example
        # server   10.73.89.74:9000 weight=3 max_fails=0 fail_timeout=10s;
        # server   10.73.89.74:9001 weight=3 max_fails=0 fail_timeout=10s;
        # server   10.73.89.74:9002 weight=3 max_fails=0 fail_timeout=10s;
        # server   10.73.89.74:9003 weight=3 max_fails=0 fail_timeout=10s;
    }

    # other upstream example
    # upstream phpapache {
    #    server 10.79.89.76:8080 weight=50 max_fails=0 fail_timeout=5s;
    # }

    include $app_path/nginx/conf/conf.d/*.conf;
}
EOF

# wyx stat server project
mkdir -p $project_path/statServer
rm -rvf $app_path/nginx/conf/conf.d/statServer.conf
touch $app_path/nginx/conf/conf.d/statServer.conf
cat >> $app_path/nginx/conf/conf.d/statServer.conf <<EOF
server
 {
    listen 80;
    server_name  wtg.game.weibo.com;
    index index.php;
    root $project_path/statServer/current/Web;
    access_log  $log_path/nginx/access-statServer.log;
    error_log $log_path/nginx/error-statServer.log;

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   html;
    }

    location ~ \.(gif|jpg|swf|css|js|jpeg|png)$ {
        root $project_path/statServer/current/Web;
        expires 6h;
    }

    location ~ \.php$ {
        #fastcgi_pass   127.0.0.1:9000;
        fastcgi_pass   phpcgi;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
        include        fastcgi_params;
    }

    rewrite "^/media\/(.*)\$" /media/\$1 last;
    rewrite "^/static\/(.*)\$" /static/\$1 last;
    rewrite "^/stat\/{0,1}([\w]*)\/{0,1}([\w]*)$" /index.php?wyxrewrite_c=\$1&wyxrewrite_m=\$2 last;
}
EOF

# config end

# performance begin
# file description tunning
cat >> /etc/rc.local <<EOF
ulimit -SHn 819200
EOF
cat >> /etc/profile <<EOF
ulimit -SHn 819200
EOF
ulimit -SHn 819200
cat >> /etc/security/limits.conf <<EOF
* soft nofile 819200
* hard nofile 819200
EOF

# kernel tunning, just /etc/sysctl.conf
mv /etc/sysctl.conf /etc/sysctl.conf.bak.`date '+%Y%m%d_%H:%M:%S'`
touch /etc/sysctl.conf
chown root.root /etc/sysctl.conf
cat >> /etc/sysctl.conf <<EOF
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
kernel.panic = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.default.arp_ignore = 1
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
net.ipv4.ip_no_pmtu_disc = 1
net.ipv4.tcp_rmem = 8192        87380   8738000
net.ipv4.tcp_wmem = 4096        65536   6553600
#net.ipv4.ip_local_port_range = 1024     65000
#net.core.rmem_max = 16777216
#net.core.wmem_max = 16777216
#net.ipv4.tcp_tw_recycle=1
#net.ipv4.tcp_tw_reuse=1
#net.ipv4.tcp_fin_timeout=30
#net.ipv4.tcp_keepalive_time=1800
#net.ipv4.tcp_max_syn_backlog=8192
vm.swappiness=0
#net.ipv4.tcp_timestamps = 0

#############################################
# Disable IPv6
net.ipv6.conf.all.disable_ipv6 = 1

net.ipv4.tcp_max_syn_backlog = 65536
net.core.netdev_max_backlog = 32768
net.core.somaxconn = 32768

net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.wmem_max = 16777216
net.core.rmem_max = 16777216

net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2

net.ipv4.tcp_max_tw_buckets = 10000

net.ipv4.tcp_retries1 = 3
net.ipv4.tcp_retries2 = 3
net.ipv4.tcp_orphan_retries = 3

net.ipv4.tcp_tw_recycle = 1
# net.ipv4.tcp_tw_len = 1
net.ipv4.tcp_tw_reuse = 1

# net.ipv4.tcp_mem = 94500000 915000000 927000000
# net.ipv4.tcp_max_orphans = 3276800

net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 120
net.ipv4.ip_local_port_range = 1024 65535

net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15

net.ipv4.tcp_abort_on_overflow = 1
net.ipv4.tcp_syncookies = 1
EOF
sysctl -p

# performance end

# daemon begin
/etc/init.d/iptables stop
/etc/init.d/phpfpm start
nginx -t && nginx
# daemon end

##########################################################
# monit-5.4
# depends
# yum install -y pam-devel
# cd $software_path
# wget http://mmonit.com/monit/dist/monit-5.4.tar.gz
# cd $building_path
# $extra_tool xvf $software_path/monit-5.4.tar.gz
# cd monit-5.4
# ./configure --prefix=$app_path/monit-5.4 && make -j3 && make install
# ln -svf $app_path/monit{-5.4,}


