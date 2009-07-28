class Schedule < ActiveRecord::Base
  belongs_to :host
  belongs_to :backup_node, :class_name => 'Node'
  has_one :retention_policy, :dependent => :destroy
  has_many :jobs, :dependent => :destroy
  
  #validates_uniqueness_of :backup_node_id, :scope => :host_id, :message => ", a schedule for this host already exists on the selected Backup Node"
end
