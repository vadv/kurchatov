require 'sys/filesystem'

always_start true
interval 60

default[:not_monit_fs_4_size] = %w(sysfs nfs devpts squashfs proc devtmpfs)
default[:monit_fs_4_fstab] = %w(ext2 ext3 ext4 xfs tmpfs)
default[:not_monit_device_4_fstab] = %w(none)
default[:not_monit_point_4_fstab] = %w(/lib/init/rw /dev/shm /dev)
default[:check_fstab] = true

collect :os => 'linux' do

  def get_monit_points_for_size
    monit_points = []
    File.open('/proc/mounts', 'r') do |file|
      while line = file.gets
        mtab = line.split(/\s+/)
        monit_points << mtab[1] unless plugin.not_monit_fs_4_size.include? mtab[2]
      end
    end
    monit_points
  end

  def get_monit_points_for_fstab
    monit_points = []
    File.open('/proc/mounts', 'r') do |file|
      while line = file.gets
        mtab = line.split(/\s+/)
        if plugin.monit_fs_4_fstab.include?(mtab[2]) &&
            !plugin.not_monit_point_4_fstab.include?(mtab[1]) &&
            !plugin.not_monit_device_4_fstab.include?(mtab[0])
          monit_points << mtab[1]
        end
      end
    end
    monit_points
  end

  get_monit_points_for_size.each do |point|
    point_stat  = Sys::Filesystem.stat(point)
    human_point = point == '/' ? '/root' : point
    human_point = human_point.gsub(/^\//, '').gsub(/\//, '_')
    event(:warning => 70, :critical => 85, :service => "disk #{human_point} % block", :desc => "Disk usage #{point}, %", :metric => (1- point_stat.blocks_available.to_f/point_stat.blocks).round(2) * 100) unless point_stat.blocks == 0
    event(:warning => 70, :critical => 85, :service => "disk #{human_point} % inode", :desc => "Disk usage #{point}, inodes %", :metric => (1 - point_stat.files_available.to_f/point_stat.files).round(2) * 100) unless point_stat.files == 0
    event(:service => "disk #{human_point} abs free", :desc => "Disk free #{point}, B", :metric => point_stat.blocks_free * point_stat.block_size, :state => 'ok')
    event(:service => "disk #{human_point} abs total", :desc => "Disk space #{point}, B", :metric => point_stat.blocks * point_stat.block_size, :state => 'ok')
  end

  fstab = File.read('/etc/fstab').split("\n").delete_if { |x| x.strip.match(/^#/) }
  fstab = fstab.join("\n")
  get_monit_points_for_fstab.each do |point|
    event(:service => "disk #{point} fstab entry", :desc => "Mount point #{point} not matched in /etc/fstab", :state => 'critical') unless fstab.match(/#{point}(\s|\/\s)/)
  end if plugin.check_fstab

end
