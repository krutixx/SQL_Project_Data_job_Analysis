# Data Analyst Job Market Analysis (SQL)

An SQL analysis of the data analyst job market, exploring top-paying jobs, in-demand skills, and where high demand meets high salary.

Built as a guided project following Luke Barousse's SQL for Data Analytics course. The dataset comes from the course. Questions 1-4 follow the course structure. Question 5 is my own adaptation, applied to India-based postings instead of remote jobs.

SQL queries are available here: project_sql folder

## Background

This project explores the data analyst job market to identify top-paying roles and in-demand skills, and to see where those two overlap.

The questions I wanted to answer through my SQL queries were:

1. What are the top-paying data analyst jobs?
2. What skills are required for these top-paying jobs?
3. What skills are most in demand for data analysts?
4. Which skills are associated with higher salaries?
5. Which skills combine high demand and high salary for data analyst roles in India?

## Tools Used

- **SQL**: the backbone of the analysis, used to query the database and extract insights.
- **PostgreSQL**: the database management system used to store and query the job posting data.
- **Visual Studio Code**: used for writing and running SQL queries.
- **Git & GitHub**: used for version control and sharing the project.

## The Analysis

### 1. Top-Paying Data Analyst Jobs

To find the highest-paying roles, I filtered data analyst postings by average yearly salary, focusing on remote ("Anywhere") jobs with a salary listed.

```sql
SELECT
    job_id,
    job_title,
    job_location,
    job_via,
    job_schedule_type,
    job_posted_date,
    salary_year_avg,
    name AS company_name
FROM
    job_postings_fact j
    LEFT JOIN company_dim c ON j.company_id = c.company_id
WHERE
    salary_year_avg IS NOT NULL
    AND job_title_short = 'Data Analyst'
    AND job_location = 'Anywhere'
ORDER BY salary_year_avg DESC
LIMIT 10;
```

| Job title | Company | Salary (USD) |
|---|---|---|
| Data Analyst | Mantys | 650,000 |
| Director of Analytics | Meta | 336,500 |
| Associate Director- Data Insights | AT&T | 255,830 |
| Data Analyst, Marketing | Pinterest | 232,423 |
| Data Analyst (Hybrid/Remote) | UCLA Health | 217,000 |
| Principal Data Analyst (Remote) | SmartAsset | 205,000 |
| Director, Data Analyst - HYBRID | Inclusively | 189,309 |
| Principal Data Analyst, AV Performance Analysis | Motional | 189,000 |
| Principal Data Analyst | SmartAsset | 186,000 |
| ERM Data Analyst | Get It Recruit | 184,000 |

The top 10 remote data analyst salaries range from $184,000 to $650,000. Job titles vary widely, from Data Analyst to Director of Analytics, and employers span several industries, including AT&T, Meta, and Pinterest.

### 2. Skills for the Top-Paying Jobs

Using the query above as a CTE, I joined the top 10 jobs to the skills tables to see what they require.

```sql
WITH top_paying_jobs AS (
    SELECT
        job_id,
        job_title,
        salary_year_avg,
        name AS company_name
    FROM
        job_postings_fact j
        LEFT JOIN company_dim c ON j.company_id = c.company_id
    WHERE
        salary_year_avg IS NOT NULL
        AND job_title_short = 'Data Analyst'
        AND job_location = 'Anywhere'
    ORDER BY salary_year_avg DESC
    LIMIT 10
)

SELECT
    tpj.*,
    skills
FROM top_paying_jobs tpj
INNER JOIN skills_job_dim sjd ON tpj.job_id = sjd.job_id
INNER JOIN skills_dim sd ON sd.skill_id = sjd.skill_id
ORDER BY salary_year_avg DESC;
```

The `INNER JOIN` only returns jobs that have at least one skill listed, so this covers 8 of the 10 top-paying jobs.

| Skill | Jobs (of 8) |
|---|---|
| SQL | 8 |
| Python | 7 |
| Tableau | 6 |
| R | 4 |
| Excel | 3 |
| Snowflake | 3 |
| Pandas | 3 |

SQL appears in every top-paying job that lists skills, followed by Python and Tableau. Cloud and Python-ecosystem tools (Snowflake, Pandas) also show up more than once.

### 3. Most In-Demand Skills

This query counts skill occurrences across all data analyst postings, regardless of location or salary.

```sql
SELECT
    skills,
    COUNT(sjd.job_id) AS demand_count
FROM job_postings_fact jpf
INNER JOIN skills_job_dim sjd ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
WHERE jpf.job_title_short = 'Data Analyst'
GROUP BY skills
ORDER BY demand_count DESC
LIMIT 5;
```

| Skill | Postings |
|---|---|
| SQL | 92,628 |
| Excel | 67,031 |
| Python | 57,326 |
| Tableau | 46,554 |
| Power BI | 39,468 |

SQL and Excel lead by a wide margin, pointing to strong demand for foundational data-handling skills. Python, Tableau, and Power BI follow, reflecting the added value of programming and visualization skills.

### 4. Skills Based on Salary

This query looks at average salary per skill across all data analyst postings with a listed salary.

```sql
SELECT
    skills,
    ROUND(AVG(salary_year_avg), 2) AS average_salary,
    COUNT(*) AS posting_count
FROM job_postings_fact jpf
INNER JOIN skills_job_dim sjd ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
WHERE jpf.job_title_short = 'Data Analyst' AND salary_year_avg IS NOT NULL
GROUP BY skills
ORDER BY average_salary DESC
LIMIT 10;
```

| Skill | Average salary (USD) | Postings |
|---|---|---|
| SVN | 400,000 | 1 |
| Solidity | 179,000 | 1 |
| Couchbase | 160,515 | 1 |
| DataRobot | 155,486 | 1 |
| Golang | 155,000 | 2 |
| MXNet | 149,000 | 2 |
| dplyr | 147,633 | 3 |
| VMware | 147,500 | 1 |
| Terraform | 146,734 | 3 |
| Twilio | 138,500 | 2 |

Each skill in this top 10 is backed by 3 postings or fewer, so these averages reflect a handful of high-paying outliers rather than a broad trend. The posting count makes that visible, which is why it's included alongside the average.

### 5. Optimal Skills for Data Analysts in India

Adapting the "optimal skills" idea from the course, I applied it to India-based postings: skills that combine demand (more than 10 postings) with a high average salary.

```sql
SELECT
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_location LIKE '%India'
GROUP BY
    skills_dim.skill_id
HAVING
    COUNT(skills_job_dim.job_id) > 10
ORDER BY
    avg_salary DESC,
    demand_count DESC
LIMIT 25;
```

| Skill | Postings | Average salary (USD) |
|---|---|---|
| Spark | 11 | 118,332 |
| Power BI | 17 | 109,832 |
| Oracle | 11 | 104,260 |
| Azure | 15 | 98,570 |
| Python | 36 | 95,933 |
| AWS | 12 | 95,333 |
| Tableau | 20 | 95,103 |
| SQL | 46 | 92,984 |
| Excel | 39 | 88,519 |
| R | 18 | 86,609 |

SQL, Excel, and Python have the highest posting counts, confirming them as the core skills for the Indian market as well. Power BI stands out with the second-highest average salary in this set alongside strong demand (17 postings), making it a reasonable choice for skill development for this market.

## What I Learned

- Using a CTE (`WITH`) to reuse the top-10 query as a building block for a second query.
- The difference between an `INNER JOIN` and a `LEFT JOIN`: an `INNER JOIN` only returns rows with a match on both sides, which is why Question 2 covers 8 of the 10 top-paying jobs instead of all 10.
- The importance of pairing an average with a count: without `COUNT(*)`, an average over 1-3 postings (as in Question 4) can look identical to an average over hundreds.
- Adapting an existing query to a new condition, by changing the location filter and re-checking the results in Question 5.

## Conclusions

- **Top-paying jobs**: remote data analyst roles in this dataset range from $184,000 to $650,000 a year.
- **Skills for top-paying jobs**: SQL, Python, and Tableau are the most common requirements among the highest-paying postings.
- **Most in-demand skills**: SQL and Excel are the two most requested skills across all data analyst postings.
- **Skills and salary**: high average salaries for individual skills can be driven by very few postings, so they should be read alongside posting counts, not on their own.
- **India market**: SQL, Excel, and Python lead in demand, while Power BI offers a strong combination of demand and average salary.
