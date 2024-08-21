# Text based setup!
text

# Language, keyboard and timezone
lang en_US
keyboard --xlayouts='fi'
timezone Europe/Helsinki --utc

# Set root passwd
rootpw [ENCRYPTED PASSWD HERE] --iscrypted

# Reboot after installation
reboot

# Use Red Hat CDN for the installation
rhsm --organization=XXXXXXXXX --activation-key=XXXXXXXXXX

# Disk, boot and network settings
bootloader --append="rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M"
zerombr
clearpart --all --initlabel
autopart
network --bootproto=dhcp

# Disable initial setup
firstboot --disable

# Enable SELinux and firewall
selinux --enforcing
firewall --enabled --ssh

# NTP
timesource --ntp-server fi.pool.ntp.org

# Select packages to install
%packages
@^minimal-environment
kexec-tools
%end

# Add admin user and set ssh key for it
user --name=myuser --groups=wheel --password=[ENCRYPTED PASSWD HERE] --iscrypted
sshkey --username=myuser "[SSH KEY HERE]"

# Post install scripts and tasks
%post

# This allows you to enable root login
#sed -Ei -e 's,^(#|)PermitRootLogin .*,PermitRootLogin yes,' /etc/ssh/sshd_config

# This allows you to enable password
#sed -Ei -e 's,^(#|)PasswordAuthentication .*,PasswordAuthentication yes,' /etc/ssh/sshd_config

# select no to disable ipv6
ipv6=no

# IPv6
if [ "$ipv6" = "no" ]; then
  echo "net.ipv6.conf.all.disable_ipv6 = 1" > /etc/sysctl.d/50-ipv6.conf
  echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.d/50-ipv6.conf
  echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.d/50-ipv6.conf
  for netconf in $(ls -1 /etc/NetworkManager/system-connections/*.nmconnection); do
    sed -i -e '/^\[ipv6\]$/,/^\[/ s/method=.*/method=disabled/' $netconf
  done
  sed -i -e '/^::1/d' /etc/hosts
  echo "AddressFamily inet" > /etc/ssh/sshd_config.d/50-ipv6.conf
  sed -i -e 's,^OPTIONS=",OPTIONS="-4 ,g' -e 's, ",",' /etc/sysconfig/chronyd
  sed -i -e 's,^IPv6_rpfilter=yes,IPv6_rpfilter=no,' /etc/firewalld/firewalld.conf
  sed -i -e '/dhcpv6-client/d' /etc/firewalld/zones/public.xml
fi

# Ensure everything is written to the disk
sync ; echo 3 > /proc/sys/vm/drop_caches ;

%end
