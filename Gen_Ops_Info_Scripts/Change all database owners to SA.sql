DECLARE @ScriptToChange2sa VARCHAR(MAX);
SET @ScriptToChange2sa = '';
SELECT
@ScriptToChange2sa = @ScriptToChange2sa +
'USE ['+ d.name +']; exec sp_changedbowner @loginame =''sa''; '
FROM sys.master_files f
INNER JOIN sys.databases d ON d.database_id = f.database_id
WHERE f.type = 1 AND d.database_id > 4
-- AND d.name = 'NameofDB'
SELECT @ScriptToChange2sa ScriptoChange2sa
EXEC (@ScriptToChange2sa)