default[:host] = '127.0.0.1'
default[:user] = 'postgres'
default[:pgsql] = '/usr/bin/psql'
default[:db4monit] = 'riemann_monit'
default[:conn_warn] = 5 # reserved pool connections
default[:conn_crit] = 3 # reserved pool connections

run_if do
  File.exists? plugin.pgsql
end

collect do

  # helpers
  def run_sql(sql, db='postgres')
    shell_out!("#{plugin.psql} -h #{plugin.host} -U #{plugin.user} -tnc \"#{sql}\" #{db}").stdout
  end

  def in_recovery?
    run_sql('select pg_is_in_recovery()') == 't'
  end

  def db4monit_exists?
    run_sql("select 1 from pg_database where datname = '#{plugin.db4monit}'") == '1'
  end

  def run_master_sql
    run_sql("create database #{plugin.db4monit}") unless db4monit_exists?
    run_sql(
      "drop table if exists timestamp; \
      create table timestamp ( id int primary key, value timestamp default now() ); \
      insert into timestamp (id) values (1); \
          ", plugin.db4monit)
  end

  def repl_lag
    unixnow - run_sql("select extract(epoch from value::timestamp) from timestamp where id = 1;", plugin.db4monit).to_i
  end

  def connections
    max_conn = run_sql('show max_connections').to_i
    res_conn = run_sql('show superuser_reserved_connections').to_i
    cur_conn = run_sql('select count(1) from pg_stat_activity;').to_i
    [cur_conn, (max_conn - res_conn - cur_conn)]
  end

  # check status

  cur_conn, res_conn = connections
  if in_recovery?
    event(:service => 'pgsql replication lag', :desc => 'Postgresql replication lag', :metric => repl_lag, :warning => 120, :critical => 500)
  else
    run_master_sql
  end

  event(:service => 'pgsql connections', :desc => 'Postgresql current connections', :state => 'ok', :metric => cur_conn)

  # check reserved pool size
  if res_conn < plugin.conn_warn
    if res_conn > plugin.conn_crit
      event(:service => 'pgsql reserved connections', :desc => 'Postgresql reserved connections state', :state => 'warning', :metric => res_conn)
    else
      event(:service => 'pgsql reserved connections', :desc => 'Postgresql reserved connections state', :state => 'critical', :metric => res_conn)
    end
  end

end
