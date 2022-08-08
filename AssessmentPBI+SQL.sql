use OracleDataset

--Create table Player
create table [Player Table] (
  Player varchar(25), 
  Matches int, 
  Runs int
)
insert into [Player Table] 
values 
  ('Allen', 10, 401) insert into [Player Table] 
values 
  ('Peter', 50, 1802) insert into [Player Table] 
values 
  ('Denis', 45, 1308) insert into [Player Table] 
values 
  ('Tom', 36, 896) insert into [Player Table] 
values 
  ('Michael', 76, 2856)
select * from [Player Table]

/*Write a query to find all Players detail from Player table whose name start with any single character between (a-p)*/
select 
	p.* 
from 
	[Player Table] p 
where 
	Player like '[a-p]%'

/*Write a query to find second highest runs from Player table.*/
--Method1
select 
  max(Runs) Second_highest_run 
from 
  [Player Table] 
where 
  Runs not in (
    select 
      max(Runs) Highest_run 
    from 
      [Player Table]
  )

--Method2
With cte as (
  select 
    max(Runs) Second_highest_run 
  from 
    [Player Table] 
  where 
    Runs not in (
      select 
        max(Runs) Highest_run 
      from 
        [Player Table]
    )
) 
select 
  p.Runs 
from 
  [Player Table] p 
  join cte c on p.Runs = c.Second_highest_run

--Method3
--by this method you can get top n number of values from the required table
select	
	Runs 
from (
	select 
		p.*, 
		DENSE_RANK() over(order by Runs desc) Top_scores_ranking 
	from 
		[Player Table] p)r
where Top_scores_ranking = 2

/*If Location B has highest score and who is top scoring agent of this location from RawData table*/
--Method1
with cte
as (select a.[Locations],
           a.Agent_Name,
           a.Score,
           rank() over (partition by Locations order by Score desc) Ranking
    from
    (
        select [value] Locations,
               Agent_Name,
               Score
        from RawData r
            cross apply string_split([Location], ';')
    ) a
   )
select Top 1
    [Locations],
    Agent_Name,
    Score
from cte
where Ranking = 1
order by Locations desc

/*Evaluation count values by week from RawData table*/
--Method1
select 
	sum(Evaluation_Count) Total_evaluation_count 
from 
	(
	select 
		[Week], 
		count([SN]) Evaluation_Count 
	from 
		RawData 
	group by [Week]
	)a

--Method2
with Result as (
	select 
		[Week], 
		count([SN]) Evaluation_Count 
	from 
		RawData 
	group by [Week]
	)
select 
	sum(Evaluation_Count) total_evaluation_count
from
	Result

/*Location wise count from RawData table*/
--Method1
select 
	Locations, 
	Count(Locations) Total_City 
from 
	(
		select 
			r.* ,
			[Value] as Locations 
		from 
			RawData r cross apply string_split(r.[Location], ';')
			)a  
group by Locations;

--Method2
with cte as (
	select 
			r.* ,
			[Value] as Locations 
		from 
			RawData r cross apply string_split(r.[Location], ';')
			)
select 
	c.Locations, 
	count(Locations) Total_city 
from 
	cte c 
group by 
	Locations ;

/*show agent wise score and Apply a condition if score>=50, colour should be blue and if score is less than 50, 
colour should be red.*/
with result
as (select [Value] as Locations,
           r.Score,
           r.Agent_Name,
           case
               when Score >= 50 then
                   'Blue'
               when Score < 50 then
                   'Red'
               else
                   'null'
           end as [Status]
    from RawData r
        cross apply string_split(r.[Location], ';')
   )
select re.Agent_Name,
       re.Score,
       re.[Status]
from Result re

