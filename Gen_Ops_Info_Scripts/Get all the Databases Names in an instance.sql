select * from sys.databases
where name not in ('master', 'model','msdb','tempdb')
order by name asc