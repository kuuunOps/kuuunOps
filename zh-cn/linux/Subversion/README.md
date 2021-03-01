# Subversion

## SVN+htttp

1. 安装软件包
```bash
yum install -y httpd subversion mod_dav_svn
```

2. 创建svn库
   
3. 生成密码文件
```bash
htpasswd -cb /data/project/svn/conf/httpd.passwd test test
htpasswd -b /data/project/svn/conf/httpd.passwd test test
```

4. 虚拟主机参考配置
```bash
<Location /system>
    DAV svn
        SVNPath /data/project/svn/system
            AuthType Basic
                AuthName "Authorization Realm"
                AuthUserFile /data/project/svn/conf/httpd.passwd
                AuthzSVNAccessFile /data/project/svn/conf/authz
                Satisfy all
                Require valid-user
</Location>
```

---

## SVN+http+AD

1. 安装软件包

```bash
yum install httpd subversion mod_dav_svn mod_ldap
```

2. httpd参考配置
```bash
LoadModule dav_module modules/mod_dav.so
LoadModule dav_svn_module modules/mod_dav_svn.so
LoadModule authz_svn_module modules/mod_authz_svn.so


LoadModule ldap_module modules/mod_ldap.so
LoadModule authnz_ldap_module modules/mod_authnz_ldap.so


LoadModule auth_basic_module modules/mod_auth_basic.so
LoadModule authn_file_module modules/mod_authn_file.so
LoadModule authz_user_module moduels/mod_authz_user.so


<Location /test>
DAV svn
SVNPath /data/project/svn/test
AuthzSVNAccessFile /data/project/svn/conf/authz


AuthName "Subversion repository"
AuthType Basic
AuthBasicProvider ldap
AuthLDAPURL "ldap://10.0.0.1/OU=xxxxx,DC=ibumobile,DC=local?samaccountName?sub?(objectClass=*)"
AuthLDAPBindDN "ad_account"
AuthLDAPBindPassword "ad_password"

Require ldap-user
</Location>
```