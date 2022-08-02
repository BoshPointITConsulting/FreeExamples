SELECT 
    exec_context_id, 
    blocking_session_id, 
    blocking_exec_context_id, 
    wait_type 
FROM sys.dm_os_waiting_tasks 