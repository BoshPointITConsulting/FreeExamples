WITH reads_and_writes AS (
	SELECT db.name AS database_name,
		SUM(user_seeks + user_scans + user_lookups) AS reads,
		SUM(user_updates) AS writes,
		SUM(user_seeks + user_scans + user_lookups + user_updates) AS all_activity
	FROM sys.dm_db_index_usage_stats us
	INNER JOIN sys.databases db ON us.database_id = db.database_id
	GROUP BY db.name)
SELECT database_name, reads, 
		Cast(((reads * 1.0) / all_activity) as decimal(6,2)) * 100 AS reads_percent,
		writes,
		Cast(((writes * 1.0) / all_activity) as decimal(6,2)) * 100 AS writes_percent
	FROM reads_and_writes rw
	ORDER BY database_name;