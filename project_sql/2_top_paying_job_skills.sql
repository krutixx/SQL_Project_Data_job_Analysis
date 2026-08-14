/*
Q. What skills are required for the top-paying data analyst jobs?
- Use the top 10 highest-paying Data Analyst jobs from the first query
- Add the specific skills required for these roles 
- Why? It provides a detailed look at which high-paying jobs demand certain skills,
helping job seekers understand which skills to develop that align with top salaries
*/


WITH top_paying_jobs AS(
    SELECT
        job_id,
        job_title,
        salary_year_avg,
        name as company_name
    FROM
        job_postings_fact j
        LEFT JOIN company_dim c
        ON j.company_id = c.company_id
    WHERE
        salary_year_avg is not NULL AND
        job_title_short = 'Data Analyst' AND
        job_location = 'Anywhere'
    ORDER BY salary_year_avg DESC
    limit 10
)

SELECT tpj.*,
    skills
FROM top_paying_jobs tpj
INNER JOIN skills_job_dim sjd ON tpj.job_id = sjd.job_id
INNER JOIN skills_dim sd ON sd.skill_id = sjd.skill_id
ORDER BY salary_year_avg DESC 