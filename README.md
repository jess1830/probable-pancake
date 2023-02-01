# probable-pancake
Google Data Analytics Capstone Project

Hi! This is where I chose to store the files for the Capstone Project : How Does a Bike-Share Navigate Speedy Success? 

This readme file will serve as the main directory for the other files as well as the "too long to read" (TLTR) section for the project,
wherein I provide my answers to the guide questions and explain some methodologies used for the project. :) 

First things first: The directory. Please note that these files are located right above this readme file.

(1) Data Cleaning Report.txt - As the name suggests, it is the data cleaning log I made for the whole Prepare and process phase. 

(2) Cyclistic - Bikeshare.pptx - Contains all the data visualizations I prepared from the analysis.

(3) 20230129_bike_share.sql - the SQL queries used for the data cleaning and extracting data for further analysis and viz in Microsoft Excel. 

----------------------------

Now, for the Data Analysis Process (Ask - Prepare - Process - Analyze - Share - Act)

-----Brief Background (before the ASK phase)-----

In this scenario I am a junior data analyst working for Cyclistic, a bike-share company in Chicago. The director of marketing believes the company's future
success depends on maximizing the nnumber of annual memberships. Therefore, the team wants to understand how the casual riders and annual members use Cyclistic
bikes different.

----- ASK Phase -----

The main business task is to come up with data-driven insights and recommendations that Marketing can use to influence Cyclistic users to switch from being casual riders
to annual members, as they are said to be more profitable according to the Finance team. In order to do this, the stakeholders want to understand how these two different
types of riders use Cyclistic bikes differently. 

----- PREPARE Phase -----
 
For the prepare phase, the details are already defined in the DATA CLEANING REPORT.txt that comes with this readme file, and the SQL code. 
The data is provided by DIVVY together with a license. This does not mean that we should skip the veryfing stage so we still went through the data cleaning
checklist. We discovered some anomalies or inconsistent data in trip_duration, birthyear, gender which might have skewed data had we not checked it. 

----- PROCESS Phase -----

This phase can still be considered a part of the prepare phase because Data Cleaning is something I found out to be an iterative process. Once you thought your data
is sparkly clean, something else comes up. For the tools , I definitely chose SQL since the datasets exceed what spreadsheets can handle. From there I created
queries that summarize the data ready to be put up into visualizations, but some of them needed further analysis using spreadsheets. I felt more comfortable
using a combination of SQL and spreadsheets rather than using R so I went with that for now. 

----- ANALYZE Phase ----- 

Format changes to the data for proper analysis were done through TYPECASTING in SQL. Some queries were already ready for visualizations after being exported to CSV
while some required the use of Pivot Tables in Excel for better analysis. The results can be seen in the PPTX file while the SQL queries for this is located in the same file as the PREPARE / PROCESS phase. 

----- SHARE phase -----

The tools I used for VIZ were MS EXCEL and MS POWERPOINT. I couldve gone with Tableau but I thought that this was already double handling on my part since I was already on Excel. Please refer to Cyclistic - Bikeshare.pptx for the viz. 

----- ACT phase -----

Recommendations were also included in the powerpoint presentation which is also another reason why i chose MS Powerpoint. I could mix in a few lines of recommendations
together with the charts inside a slideshow. In the end there are some great insights from what seemed to be just more than a million rows of random data. 
