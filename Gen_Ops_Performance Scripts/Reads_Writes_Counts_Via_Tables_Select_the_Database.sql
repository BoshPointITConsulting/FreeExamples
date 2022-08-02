SELECT db.name, o.name AS table_name, ix.name AS index_name,
	(user_seeks + user_scans + user_lookups) AS reads,
	user_updates AS writes
FROM sys.dm_db_index_usage_stats us
INNER JOIN sys.databases db ON us.database_id = db.database_id
INNER JOIN sys.objects o ON us.object_id = o.object_id
INNER JOIN sys.indexes ix ON us.object_id = ix.object_id AND us.index_id = ix.index_id;