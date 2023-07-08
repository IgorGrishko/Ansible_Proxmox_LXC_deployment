external_url 'https://192.168.1.60'
nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.crt"
nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.key"
letsencrypt['enable'] = false
package['modify_kernel_parameters'] = false
