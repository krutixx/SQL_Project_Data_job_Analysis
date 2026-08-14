/*
Question: What are the top paying skills based on salary?
- Look at the average salary associated with each skill for Data Analyst positions
- Focuses on roles with specified salaries, regardless of location
- Why? It reveales how different skills impact salary levels for Data Analysts and 
    helps identify the most financially rewarding skills to acquire or improve 
*/

SELECT skills,
    round(AVG(salary_year_avg),2) as average_salary
FROM job_postings_fact jpf
INNER JOIN skills_job_dim sjd ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
WHERE jpf.job_title_short = 'Data Analyst' AND salary_year_avg is not NULL
GROUP BY skills
ORDER BY average_salary DESC
LIMIT 25    