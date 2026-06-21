# Week 4 – Azure Cloud Fundamentals & Data Pipeline Implementation using ADF

**Intern:** G Rithwik Surya  
**Week:** 4  
**Topic:** Azure Data Factory (ADF), Azure Blob Storage, IAM Roles & Pipeline Development

---

## What This Assignment Was About

This week's assignment was all about getting hands-on with **Microsoft Azure** — specifically learning how to build a **data pipeline** using **Azure Data Factory (ADF)**. The goal was to move data from one storage location to another in the cloud, automate the process for multiple files, and understand how access control works in Azure.

---

## What I Did (Step by Step)

### 1. Set Up the Azure Environment

- Logged into the **Azure Portal** using my student account.
- Created a **Resource Group** named `week4assignmenmtdatafactory` in the **East Asia** region under the student subscription. This resource group acts like a folder to organize all the Azure resources I used in this assignment.

### 2. Created a Storage Account & Blob Containers

- Created a **Storage Account** named `week4assignmentstorage` and linked it to my resource group.
- Chose **Azure Blob Storage** as the storage type since I was working with CSV files — blob storage is ideal for unstructured data and integrates smoothly with ADF.
- Created two **Blob Containers**:
  - `source-data` → to hold the raw/input CSV files
  - `processed-data` → to store the copied/output files
- Uploaded the following files into `source-data`:
  - `Sample - Superstore.csv` (main dataset)
  - `customer1.csv`, `customer2.csv`, `customer3.csv` (used for the ForEach activity later)
- Created a placeholder file `cleaned_dataset` inside `processed-data` for the destination.

### 3. Created Azure Data Factory & Explored the UI

- Created an **ADF instance** named `adfweek4assignment` linked to my resource group.
- Explored the three main sections of ADF:
  - **Author** – where you design pipelines, datasets, and linked services
  - **Monitor** – where you track pipeline runs and spot errors
  - **Manage** – where you configure connections, triggers, and integration runtimes

### 4. Configured Linked Services & Datasets

- Created a **Linked Service** (`ls_blobstorage`) to connect ADF to my Azure Blob Storage account. Tested the connection to make sure it was working.
- Created two **Datasets**:
  - `raw_data` → pointing to the source container
  - `cleaned_dataset` → pointing to the destination container
- **Parameterized** the source dataset's file name using `@dataset().rawfile_data` so that the pipeline could dynamically pick up different files instead of being hardcoded to one.

### 5. Built the Data Pipeline

- **Get Metadata Activity** – Created a pipeline (`meta_data_pipeline`) that retrieves metadata like whether a file exists, when it was last modified, and the item name. Ran it with debug and it succeeded.
- **Copy Data Activity** – Configured a copy activity with source and sink (destination) pointing to `source-data` and `processed-data` respectively.
- **ForEach Activity** – This was the big one. I set up a ForEach loop that iterates over the output of Get Metadata and runs the Copy activity for each file. This way, all three customer CSV files could be processed automatically in a single pipeline run.

### 6. Executed & Scheduled the Pipeline

- Ran the pipeline using **Debug** mode to test it — all three pipelines executed successfully.
- Also configured a **Scheduled Trigger** that ran the pipeline automatically on 21st June at 10:00 AM as planned.

### 7. Explored IAM (Identity & Access Management)

- Learned about **IAM roles** in Azure:
  - **Reader** – read-only access to resources
  - **Contributor** – allows managing resources (create, update, delete)
- Assigned the Reader role successfully. However, I **couldn't assign the Contributor role** due to limitations of the student account.
- Provided ADF access to the storage account by assigning **Storage Blob Data Contributor** and **Storage Blob Data Reader** roles.


## Challenges I Faced

1. **ForEach Activity Configuration** – This was hands down the hardest part. I couldn't figure out how to get the ForEach loop to process multiple files at first. The issue was that I didn't understand how dataset parameters work and how values are passed dynamically. I kept getting errors until I realized I needed to use expressions like `@item().name` to pass the current file name from the iteration into the Copy activity. It took me a lot of trial and error to get this right.

2. **Understanding Dynamic Content** – The concept of using dynamic expressions (like `@dataset().rawfile_data` and `@item().name`) was new to me. I had to spend extra time understanding how Get Metadata output connects to ForEach iterations and then feeds into dataset parameters.

3. **IAM Role Assignment Limitation** – My student account didn't allow me to assign the Contributor role, which was a bit frustrating. I worked around it by focusing on what I could do — assigning Reader and the Storage Blob Data roles.

4. **Debugging Pipeline Errors** – When things failed, I had to dig into the activity output logs to figure out what went wrong. Initially, I found the error messages confusing, but over time I got better at reading them and tracing back to the root cause.

---

## What I Learned

- **Azure Resource Organization** – How Resource Groups, Storage Accounts, and services are structured and connected in Azure.
- **Azure Blob Storage** – How to create containers, upload files, and why blob storage is a good fit for unstructured data like CSVs.
- **Azure Data Factory Fundamentals** – How to create linked services, datasets, and pipelines from scratch.
- **Pipeline Activities** – Practical experience with Get Metadata, Copy Data, and ForEach activities.
- **Dynamic Parameterization** – How to make pipelines flexible using dataset parameters and expressions so they can handle multiple files without hardcoding.
- **Pipeline Execution & Monitoring** – How to run pipelines via Debug and Triggers, and how to monitor execution results.
- **IAM & Access Control** – How Azure uses roles like Reader, Contributor, and Storage Blob Data roles to manage who can access what.
- **Troubleshooting Mindset** – More than just building the pipeline, I learned how to debug failures, read error logs, and systematically fix configuration issues.

---

## Summary

This was probably the most hands-on week of my internship so far. Moving from SQL and databases (Weeks 2–3) to cloud services and data pipelines felt like a big jump. The ForEach activity alone taught me more about debugging and patience than anything else this week. But by the end, I had a fully working pipeline that could automatically copy multiple files from one blob container to another — and that felt really satisfying.

---
