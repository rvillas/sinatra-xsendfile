module Sinatra
  module Xsendfile
    def x_send_file(path, opts = {})
      if opts[:type] or not response['Content-Type']
        content_type(opts[:type] || File.extname(path) || 'application/octet-stream')
      end

      if opts[:disposition] == 'attachment' || opts[:filename]
        attachment opts[:filename] || path
      elsif opts[:disposition] == 'inline'
        response['Content-Disposition'] = 'inline'
      end

      header_key = opts[:header] || (settings.respond_to?(:xsf_header) && settings.xsf_header) ||
                                    'X-SendFile'
      path = File.expand_path(path).gsub(settings.public_folder, '') if header_key == 'X-Accel-Redirect'

      response[header_key] = path

      halt
    rescue Errno::ENOENT
      not_found
    end

    def self.replace_send_file!
      Sinatra::Helpers.send(:alias_method, :old_send_file, :send_file)
      Sinatra::Helpers.module_eval("def send_file(path, opts={}); x_send_file(path, opts); end;")
    end
  end

  helpers Xsendfile
end