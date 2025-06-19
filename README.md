# Research Paper Repository

## Overview

This project is a MySQL-based Research Paper Repository system designed for storing academic papers, handling version control, citations, reviews, and managing user roles (authors, reviewers, admins).

All operations are implemented using **pure SQL** (DDL, DML, views, triggers, procedures, functions) with realistic sample data. No frontend or backend code is required.

---

## 📊 Schema Summary

### Tables

* **Users**: Author, Reviewer, Admin with role-based access
* **Papers**: Stores paper metadata and submission info
* **PaperVersions**: Maintains version history for each paper
* **Citations**: Tracks which papers cite others
* **Reviews**: Stores reviewer comments and decisions
* **PaperStatus**: Tracks status (submitted, under\_review, accepted, rejected)
* **Permissions**: Enforces role-based access control
* **Tags** & **PaperTags** *(Bonus)*: Supports paper tagging for better categorization
* **AuditLogs** *(Bonus)*: Tracks all changes to key tables

---

## ⚙️ Features

### Core

* 📑 Paper submission with metadata
* 🧾 Version control for each paper
* 🔁 Citation relationships
* ✅ Role-based access (author/reviewer/admin)
* 📃 Review workflow with comments
* 📍 Status tracking for each paper
* 🔍 Search by title, author, keywords

### Bonus

* 🏷️ Tags for papers
* 📈 Statistics (e.g., citation count)
* 📜 Audit logging
* 📦 Bulk insert via stored procedures

---

## 📥 Sample Queries

```sql
-- Get all papers submitted by "Alice Author"
SELECT * FROM PaperSummary WHERE author = 'Alice Author';

-- Count citations for a paper
SELECT TotalCitations(1) AS citation_count;

-- Get pending reviews
SELECT * FROM Reviews WHERE review_status = 'pending';
```

---

## 🧪 How to Use

1. **Run the SQL file**:

   ```bash
   mysql -u [user] -p < research_paper_repository.sql
   ```
2. **Review the sample data** and explore the tables.
3. **Execute procedures/functions** as needed for updates or reports.

---

## 📌 Notes

* All constraints, foreign keys, and indexes are used for normalization and integrity.
* SQL version: MySQL 8.0+
* Comments are embedded in the SQL for clarity.

---

## 👤 Author

* Prepared as part of **DevifyX Assignment**
