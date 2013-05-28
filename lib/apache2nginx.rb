# Dominio público. 2013. vtamara@pasosdeJesus.org

require "apache2nginx/version"
require "treetop"
require "rubygems"
require "apacheconf_parser"

module Apache2nginx

    def busca(h, mk) 
        if h.is_a?(Hash)
            h.each { |k, v| 
                if k.to_s == mk.to_s
                    return v
                end
                n = busca(v, mk)
                if n != nil
                    return n
                end
            }
        elsif h.is_a?(Array)
            h.each { |v| 
                n = busca(v, mk)
                if n != nil
                    return n
                end
            }
        end
        return nil
    end


    def trans_vhost(h, ind) 
        pind = " "*ind
        ret = pind + "server {\n"
        ret += pind + "  listen " + h[:port].to_s + ";\n"
#        s = busca(h[:entries], "ServerName")
#        if s != nil
#            ret += pind + "  server_name " + s[0].to_s + ";\n"
#        end
#        s = busca(h[:entries], "DocumentRoot")
#        if s != nil
#            ret += pind + "  root " + s[0].to_s + ";\n"
#        end 
        if h[:port] == 443
            ret += pind + "  ssl on" + ";\n"
            s = busca(h[:entries], "SSLCertificateFile")
            if s != nil
                ret += pind + "  ssl_certificate " + s[0].to_s + ";\n"
            end
            s = busca(h[:entries], "SSLCertificateKeyFile")
            if s != nil
                ret += pind + "  ssl_certificate_key " + s[0].to_s + ";\n"
            end
            ret += pind + "  ssl_session_timeout  5m;\n"
            ret += pind + "  ssl_protocols  SSLv3 TLSv1;\n"
            ret += pind + "  ssl_ciphers  HIGH:!aNULL:!MD5;\n"
        end
        ret += recorre(h[:entries], ind + 2)
        ret += pind + "}\n\n"
        return ret
    end

    def recorre(h, ind) 
        pind = " "*ind
        ret = "";
        if h.is_a?(Hash)
            h.each { |k, v| 
                if k.to_s == "ip_addr"
                    ret += trans_vhost(h, ind)
                    break
                elsif k.to_s == "ServerName"
                    ret += pind + "servername " + v[0].to_s + ";\n"
                elsif k.to_s == "KeepAlive" and v[0].to_s == "On"
                    # Ref http://winginx.com/htaccess
                    ret += pind + "keepalive_disable msie6;\n"
                elsif k.to_s == "MaxKeepAliveRequests"
                    # Ref http://winginx.com/htaccess
                    ret += pind + "keepalive_request " + v[0].to_s + ";\n"
                elsif k.to_s == "KeepAliveTimeout"
                    # Ref http://winginx.com/htaccess
                    ret += pind + "keepalive_timeout " + v[0].to_s + ";\n"
                elsif k.to_s == "DefaultType"
                    # Ref http://winginx.com/htaccess
                    ret += pind + "default_type" + v[0].to_s + ";\n"
                elsif k.to_s == "DocumentRoot"
                    ret += pind + "root " + v[0].to_s + ";\n"
                elsif k.to_s == "LogFormat "
                    # Ref http://winginx.com/htaccess
                    ret += pind + "log_format " + v[0].to_s + ";\n"
                elsif k.to_s == "ErrorLog"
                    # Ref http://winginx.com/htaccess
                    ret += pind + "error_log " + v[0].to_s + ";\n"
                elsif k.to_s == "DirectoryIndex"
                    # Ref http://winginx.com/htaccess
                    ret += pind + "index " + v.join(", ") + ";\n"
                else
                    ret += recorre(v, ind)
                end

            }
        elsif h.is_a?(Array)
            h.each { |v| 
                ret += recorre(v, ind)
            }
        end
        return ret
    end

    def transforma(conf = '/var/www/conf/httpd.conf')
        parser = ApacheconfParser.new(conf);
        ret = "# Produced automatically from Apache configuration "
        ret += " with apache2nginx.\n\n"
        ret += "worker_processes 1;\n";
        ret += "events {\n";
        ret += "  worker_connections 1024;\n";
        ret += "}\n\n";
        ret += "http {\n";
        ret += "  include       mime.types;\n"
        ret += "  default_type  application/octet-stream;\n"
        ret += "  index         index.html index.htm;\n"
        ret += "  keepalive_timeout 65;\n"

        ret += recorre(parser.ast, 2)

        ret += "}";
        return ret
    end
end
