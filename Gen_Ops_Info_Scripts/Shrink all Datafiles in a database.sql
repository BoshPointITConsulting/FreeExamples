IF OBJECT_ID(N'tempdb..#tempDatabases2Use') IS NOT NULL
    BEGIN
        DROP TABLE #tempDatabases2Use
    END
CREATE TABLE #tempDatabases2Use
([Name] NVARCHAR(256), [database_id] INT, [state_desc] NVARCHAR(256), [is_read_only] bit, [Role_Desc] NVARCHAR(100), [mirroring_role] NVARCHAR(100), [recovery_model_desc] NVARCHAR(25));
INSERT INTO #tempDatabases2Use
SELECT DISTINCT sdb.name, sdb.database_id, sdb.state_desc, sdb.is_read_only, hars.role_desc, mr.mirroring_role, recovery_model_desc
FROM sys.databases sdb
JOIN SYS.database_mirroring mr on sdb.database_id = mr.database_id
LEFT JOIN sys.dm_hadr_availability_replica_states hars on sdb.replica_id = hars.replica_id
LEFT JOIN sys.dm_hadr_database_replica_states sdhdrs ON sdb.database_id = sdhdrs.database_id
WHERE sdb.name NOT IN ('master','model','msdb','tempdb','distribution');
DELETE FROM #tempDatabases2Use WHERE Role_Desc = 'SECONDARY';
DELETE FROM #tempDatabases2Use WHERE Role_Desc = 'RESOLVING';
DELETE FROM #tempDatabases2Use WHERE state_desc = 'OFFLINE';
DELETE FROM #tempDatabases2Use WHERE state_desc = 'RESTORING';
DELETE FROM #tempDatabases2Use WHERE is_read_only = 1;
SELECT * FROM #tempDatabases2Use
-----------------------------------
DECLARE @ScriptToShrinkdata VARCHAR(MAX);
SET @ScriptToShrinkdata = '';
SELECT
@ScriptToShrinkdata = @ScriptToShrinkdata +
'USE ['+ temp.name +']; CHECKPOINT; DBCC SHRINKDATABASE (['+temp.name+'],0);'
FROM sys.master_files f
INNER JOIN #tempDatabases2Use temp ON temp.database_id = f.database_id
WHERE f.type = 0 AND temp.database_id > 4 and f.type_desc in ('ROWS')
SELECT @ScriptToShrinkdata ScriptToShrinkdata
--PRINT @ScriptToShrinkdata
EXEC (@ScriptToShrinkdata)
