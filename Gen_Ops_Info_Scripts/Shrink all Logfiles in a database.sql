DECLARE @ScriptToShrinkLogs VARCHAR(MAX);
SET @ScriptToShrinkLogs = '';
SELECT
@ScriptToShrinkLogs = @ScriptToShrinkLogs +
'USE ['+ d.name +']; CHECKPOINT; DBCC SHRINKFILE ('+f.name+');'
FROM sys.master_files f
INNER JOIN sys.databases d ON d.database_id = f.database_id
WHERE f.type = 1 AND d.database_id > 4 and f.type_desc = 'log'
-- AND d.name = 'NameofDB'
SELECT @ScriptToShrinkLogs ScriptToShrinkLogs
EXEC (@ScriptToShrinkLogs)