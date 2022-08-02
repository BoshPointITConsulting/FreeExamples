--DECLARE @sql NVARCHAR(max)=''

--SELECT @sql += ' Drop table ' + QUOTENAME(TABLE_SCHEMA) + '.'+ QUOTENAME(TABLE_NAME) + '; '
--FROM   INFORMATION_SCHEMA.TABLES
--WHERE  TABLE_TYPE = 'BASE TABLE'

DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += N'
  DROP DATABASE ' + QUOTENAME(name)
  + N';' 
FROM sys.databases
WHERE name NOT IN (N'master',N'tempdb',N'model',N'msdb');

PRINT @sql;
-- EXEC master.sys.sp_executesql @sql;