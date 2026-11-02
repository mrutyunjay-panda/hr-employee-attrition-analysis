create  database HR_Employee_Attrition;
use HR_Employee_Attrition;
select * from office;

select count(*) from office;
-- 1. Display the first 10 rows from the table.
select * from office limit 10;

-- 2. Find the total number of employees in the company. 
select count(*) as Total_Employee from office;

-- 3. List all unique departments. 
select distinct(department) from office;

-- 4. Show how many employees have left the company and how many are still working.
select attrition,count(*) as Employee_count from office group by attrition;

-- 5. Retrieve the list of employees who work overtime. 
select * from office where overtime="yes";

-- 6. Find the average monthly income of all employees.
select 
round(avg(monthlyincome),2) as avg_monthly_income 
from office;

-- 7. Identify employees whose number of companies worked is missing (NULL)
select employeenumber, numcompaniesworked from office where numcompaniesworked is NULL;
 
-- 8. Find the employee(s) with the maximum monthly income. 
select 
employeenumber, MonthlyIncome
	from office
	where monthlyincome = (
	select max(monthlyincome)
	from office
);

-- 9. Count the number of employees by gender.
select gender,count(*) as emp_count from office group by gender;
 
-- 10. List all employees who have just joined (YearsAtCompany = 0). 
select employeenumber, yearsatcompany from office where YearsAtCompany = 0;

-- 11. Calculate the attrition rate (%) by department.
select 
	department,
    count(*) as total_employee,
	round(
	sum(case when attrition = 'Yes' then 1 else 0 end)
	* 100.0 / count(*), 2
	) as attrition_rate_pct
	from office
group by department; 

-- 12. List the top 10 employees with the highest total working years. 
select *
from office
order by totalworkingyears desc 
limit 10;

-- 13. Group employees into tenure categories (<1yr, 1–3yr, 4–6yr, 7+yr) and count employees in each.
select
   case
        when yearsatcompany < 1 then '<1yr'
        when yearsatcompany between 1 and 3 then '1-3yr'
        when yearsatcompany between 4 and 6 then '4-6yr'
        else '7+yr'
    end as tenure_group,
    COUNT(*) as employee_count
from office
group by tenure_group
order by field(tenure_group, '<1yr', '1-3yr', '4-6yr', '7+yr'); 

-- 14. Find the average monthly income by job level and attrition status.
select joblevel,
       attrition,
       round(avg(monthlyincome), 2) as avg_monthly_income
from office
group by joblevel, attrition
order by joblevel, attrition;

 -- 15. Identify the top 5 job roles with the highest number of employees who left.
select 
	jobrole,
	count(*) as employees_left
	from office
	where attrition = 'yes'
	group by jobrole
	order by employees_left desc
limit 5;

-- 16. List employees who left the company within their first year. 
select *
from office
where attrition = 'Yes'
and yearsatcompany <= 1;

-- 17. Calculate each employee’s approximate new monthly compensation after applying their salary hike percentage.
select employeenumber,
       monthlyincome,
       percentsalaryhike,
       ROUND(
           monthlyincome * (1 + percentsalaryhike / 100.0), 2
       ) as new_monthly_compensation
from office;
 
-- 18. Count employees grouped by overtime status and attrition. 
select 
   overtime,
   attrition,
   count(*) as employee_count
   from office
group by overtime, attrition;

-- 19. Display the top 10 employees who attended the most training sessions last year.
select 
	employeenumber, 
	trainingtimeslastyear
	from office
	order by trainingtimeslastyear desc
limit 10;

-- 20. Rank employees by total working years (most experienced = rank 1).
select employeenumber,
       totalworkingyears,
       rank() over (
           order by totalworkingyears desc
       ) as experience_rank
from office;

-- 21. For each department, find employees whose monthly income is in the top 25% of that department.
select employeenumber, department, monthlyincome
from (
  select *,
         cume_dist() over (partition by department order by monthlyincome) as cd
  from office
) t
where cd >= 0.75
order by department, monthlyincome desc;

-- 22. Divide employees into 10 income deciles and find attrition rate for each decile.
with income_deciles as (
    select *,
           ntile(10) over (
               order by monthlyincome
           ) as income_decile
    from office
)
select income_decile,
       round(
           sum(case when attrition = 'yes' then 1 else 0 end)
           * 100.0 / count(*), 2
       ) as attrition_rate
from income_deciles
group by income_decile
order by income_decile; 

-- 23. Create a simple risk score based on tenure, performance, overtime, and work-life balance — and list the top 50 high-risk employees.
select employeenumber,
       yearsatcompany,
       performancerating,
       overtime,
       worklifebalance,
       (
         (case when yearsatcompany < 2 then 1 else 0 end)
       + (case when performancerating <= 2 then 1 else 0 end)
       + (case when overtime = 'yes' then 1 else 0 end)
       + (case when worklifebalance <= 2 then 1 else 0 end)
       ) as risk_score
from office
order by risk_score desc, yearsatcompany asc
limit 50;
 
-- 24. Create a summary view showing, for each department and job level: total employees, number of leavers, attrition rate, and average monthly income.
select department,
       joblevel,
       count(*) as total_employees,
       sum(case when attrition = 'yes' then 1 else 0 end) as number_of_leavers,
       round(
           sum(case when attrition = 'yes' then 1 else 0 end)
           * 100.0 / count(*), 2
       ) as attrition_rate,
       round(avg(monthlyincome), 2) as avg_monthly_income
from office
group by department, joblevel
order by department, joblevel; 













