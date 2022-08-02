with cte as 
 ( 
 	select  
 		count(*) as [count], 
 		query_hash,   
 		min(sql_handle) as sql_handle_example 
 	from sys.dm_exec_query_stats 
 	group by query_hash 
 ) 
 select cte.*, t.text as query_text_example 
 from cte 
 cross apply sys.dm_exec_sql_text(sql_handle_example) t 
 where [count] > 100 
 order by [count] desc 
