select subsystem, 
      right(subsystem_dll,20) as 'Agent DLL', 
 right(agent_exe,20) as 'Agent Exe', 
    max_worker_threads 
from msdb.dbo.syssubsystems
