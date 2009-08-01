require 'zfs'
include Zfs

class SetupJob
  FIELDS = %w{ hostname size ip_address filesystem }.map! { |s| s.to_sym }.freeze
  attr_accessor *FIELDS
  @@settings = DaemonKit::Config.load('settings').to_h
  
  DEFAULTS = { :hostname => nil, :size => nil, :ip_address => nil, :filesystem => nil }.freeze
  
  def initialize(args = {})
    args = args ? args.merge(DEFAULTS).merge(args) : DEFAULTS
    
    FIELDS.each do |attr|
      args.each_pair do | key, value |
          instance_variable_set("@#{attr}", args[attr])
      end
    end
    
  end
    
  def create_zfs_fs!
    unless backup_zvol = @@settings['backup_zvol']
      raise ArgumentError, "backup_root not specified in settings.yml"
    end
    
    self.filesystem = backup_zvol + '/' + self.ip_address
    
    # Check that the filesystem does not already exist.
    check = zfs_list("target" => self.filesystem)
    if check[0] == 1 && check[1] =~ /dataset does not exist/
      rstatus = zfs_create({"properties" => { "quota" => self.size }, "filesystem" => self.filesystem})
      snapdir_status = set_snapdir
      unless snapdir_status[0] == 0
        return snapdir_status
      else
        return rstatus
      end
    else
      # Technically this is an error condition so let RunJob know that, but we don't want the job to error out.
      check[0] = 0
      check[1] = "#{self.filesystem} already exists"
      return check
    end
  end
  
  def set_snapdir(filesystem=self.filesystem, prop='visible')
    zfs_set("properties" => { "snapdir" => prop }, "filesystem" => filesystem )
  end
  
  def path(filesystem=self.filesystem)
    path = zfs_get("field" => 'value', "properties" => 'mountpoint', "target" => filesystem )
    
    if path[0] == 0
      return 0, path[1].first['value']
    else
      return path
    end
  end
end