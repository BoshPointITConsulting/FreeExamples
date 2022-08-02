
--SQL SERVER – Who is Consuming my TempDB Now?
 

--Off late my love for TempDB and writing on topics of tempDB has been a great learning experience. The more I work with tempDB, the more fascinated I am. TempDb is being used by a number of operations inside SQL Server, let me list some of them here:
-- •Temporary user objects like temp tables, table variables
-- •Cursors
-- •Internal worktables for spool and sorting
-- •Row Versioning for snapshot isolation
-- •Online Index rebuild operations
-- •MARS (Multiple Active Resultsets)
-- •AFTER Triggers and more
 
--These are some of the ways in which tempdb in our servers get used. When I was talking about this to one of my DBA friends, he always asks some interesting questions. He said the previous blogs I wrote helped in understanding how to read temp tables, how to see table variable data. Now his requirement was different. He wanted to know if there was any script which will let him know who was consuming tempDB resources. If tempDB is used by many inside the SQL Server context, it is important that we know how to get this information from DMVs. There are a number of DMVs we can use:
-- •dm_db_file_space_usage – Returns space usage information for each file in tempdb
-- •dm_db_session_space_usage – Returns the number of pages allocated and deallocated by each session
-- •dm_db_task_space_usage – Returns page allocation and deallocation activity by task
-- •We can join these DMV’s with various other DMV’s like sys.dm_exec_sessions, sys.dm_exec_requests, etc and get to the actual TSQL statement and plan responsible for these allocations.
 
--Here is a simple script that will outline the sessions which are using TempDB currently.
 SELECT
 st.dbid AS QueryExecutionContextDBID,
 DB_NAME(st.dbid) AS QueryExecContextDBNAME,
 st.objectid AS ModuleObjectId,
 SUBSTRING(st.TEXT,
 dmv_er.statement_start_offset/2 + 1,
 (CASE WHEN dmv_er.statement_end_offset = -1
 THEN LEN(CONVERT(NVARCHAR(MAX),st.TEXT)) * 2
 ELSE dmv_er.statement_end_offset
 END - dmv_er.statement_start_offset)/2) AS Query_Text,
 dmv_tsu.session_id ,
 dmv_tsu.request_id,
 dmv_tsu.exec_context_id,
 (dmv_tsu.user_objects_alloc_page_count - dmv_tsu.user_objects_dealloc_page_count) AS OutStanding_user_objects_page_counts,
 (dmv_tsu.internal_objects_alloc_page_count - dmv_tsu.internal_objects_dealloc_page_count) AS OutStanding_internal_objects_page_counts,
 dmv_er.start_time,
 dmv_er.command,
 dmv_er.open_transaction_count,
 dmv_er.percent_complete,
 dmv_er.estimated_completion_time,
 dmv_er.cpu_time,
 dmv_er.total_elapsed_time,
 dmv_er.reads,dmv_er.writes,
 dmv_er.logical_reads,
 dmv_er.granted_query_memory,
 dmv_es.HOST_NAME,
 dmv_es.login_name,
 dmv_es.program_name
 FROM sys.dm_db_task_space_usage dmv_tsu
 INNER JOIN sys.dm_exec_requests dmv_er
 ON (dmv_tsu.session_id = dmv_er.session_id AND dmv_tsu.request_id = dmv_er.request_id)
 INNER JOIN sys.dm_exec_sessions dmv_es
 ON (dmv_tsu.session_id = dmv_es.session_id)
 CROSS APPLY sys.dm_exec_sql_text(dmv_er.sql_handle) st
 WHERE (dmv_tsu.internal_objects_alloc_page_count + dmv_tsu.user_objects_alloc_page_count) > 0
 ORDER BY (dmv_tsu.user_objects_alloc_page_count - dmv_tsu.user_objects_dealloc_page_count) + (dmv_tsu.internal_objects_alloc_page_count - dmv_tsu.internal_objects_dealloc_page_count) DESC
 
--Have you ever had such requirements to monitor and troubleshoot tempDB in your environments? What have you been using to monitor your tempDB usage? What is the typical output you are getting in your environments? Do let me know as we can learn together.
 
--Reference: Pinal Dave (http://blog.sqlauthority.com)
