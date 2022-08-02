
--select * from sys.dm_os_ring_buffers 
---https://blogs.msdn.microsoft.com/mvpawardprogram/2012/06/04/using-sys-dm_os_ring_buffers-to-diagnose-memory-issues-in-sql-server/
WITH RingBuffer

AS (SELECT CAST(dorb.record AS XML) AS xRecord,

dorb.timestamp

FROM sys.dm_os_ring_buffers AS dorb

WHERE dorb.ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR'

)

SELECT xr.value('(ResourceMonitor/Notification)[1]', 'varchar(75)') AS RmNotification,

xr.value('(ResourceMonitor/IndicatorsProcess)[1]','tinyint') AS IndicatorsProcess,

xr.value('(ResourceMonitor/IndicatorsSystem)[1]','tinyint') AS IndicatorsSystem,

DATEADD(ms, -1 * dosi.ms_ticks - rb.timestamp, GETDATE()) AS RmDateTime

FROM RingBuffer AS rb

CROSS APPLY rb.xRecord.nodes('Record') record (xr)

CROSS JOIN sys.dm_os_sys_info AS dosi

ORDER BY RmDateTime DESC;
