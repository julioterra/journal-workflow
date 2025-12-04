---
title: Table Styling Tests
author: Julio M. Terra
dates: December 2, 2025
volume: Test Volume
---

# Table Styling Test Cases

## 2-Column Tables

### Test 2.1: Two Column Table - Sparse (2 cols, 5 rows, short text)

**Expected behavior**: Portrait orientation (narrow), tests equal column distribution

Table: 2.1 - Contact List

| Name | Email |
|:-----|:------|
| John Doe | john@example.com |
| Jane Smith | jane@example.com |
| Bob Johnson | bob@example.com |
| Alice Williams | alice@example.com |
| Charlie Brown | charlie@example.com |

---

### Test 2.2: Two Column Table - Unbalanced Density (2 cols, 5 rows, one wide column)

**Expected behavior**: Portrait orientation, tests programmatic column width (second column should be wider)

Table: 2.2 - Book Summaries

| Title | Description |
|:------|:------------|
| The Great Gatsby | A classic American novel exploring themes of wealth, love, and the American Dream in the Jazz Age, following Jay Gatsby's pursuit of Daisy Buchanan in 1920s Long Island. |
| 1984 | George Orwell's dystopian masterpiece depicting a totalitarian society under constant surveillance, where independent thinking is suppressed and history is continuously rewritten by the Party. |
| To Kill a Mockingbird | Harper Lee's Pulitzer Prize-winning novel about racial injustice in the American South, told through the eyes of young Scout Finch as her father defends an innocent Black man. |
| Pride and Prejudice | Jane Austen's beloved romantic comedy of manners following Elizabeth Bennet and Mr. Darcy as they overcome pride, prejudice, and social expectations to find love. |
| The Catcher in the Rye | J.D. Salinger's coming-of-age story narrated by the cynical teenager Holden Caulfield, capturing the alienation and confusion of adolescence in post-war America. |

---

## 3-Column Tables

### Test 3.1: Small Table (3 cols, 4 rows, minimal content)

**Expected behavior**: Portrait orientation (sparse content, below density threshold)

Table: 3.1 - Product Pricing

| Product | Price | Stock |
|:--------|:------|:------|
| Widget A | $10 | 100 |
| Widget B | $15 | 50 |
| Widget C | $20 | 75 |

---

### Test 3.2: Small Table with Dense Content (3 cols, 5 rows, lots of text)

**Expected behavior**: Landscape orientation (dense content exceeds threshold)

Table: 3.2 - Project Status Updates

| Project Name | Current Status | Next Steps and Considerations |
|:-------------|:---------------|:------------------------------|
| Website Redesign | In progress - 60% complete. Design phase finished, moving to development. | Need to finalize color palette, integrate with CMS, test responsive layouts on multiple devices, and schedule client review meeting. |
| Mobile App Development | On hold - waiting for stakeholder approval and budget allocation from finance team. | Prepare detailed cost breakdown, schedule meeting with stakeholders, gather additional user research data, and revise initial wireframes based on feedback. |
| Database Migration | Completed successfully last week with minimal downtime and no data loss. | Monitor performance metrics, document migration process, train team on new system, and schedule follow-up review in two weeks. |
| API Integration | Starting next month after resource allocation is confirmed and requirements are finalized. | Review API documentation thoroughly, set up development environment, coordinate with external vendor, and establish testing protocols. |

---

## 4-Column Tables

### Test 4.1: Four Column Table - Sparse (4 cols, 4 rows, minimal content)

**Expected behavior**: Portrait orientation (below density threshold), tests 4-column portrait layout

Table: 4.1 - Meeting Schedule

| Date | Time | Room | Attendees |
|:-----|:-----|:-----|:----------|
| Mon 12/4 | 10:00 AM | 201 | 5 |
| Tue 12/5 | 2:00 PM | 305 | 8 |
| Wed 12/6 | 9:00 AM | 201 | 6 |
| Thu 12/7 | 3:00 PM | 401 | 4 |

---

### Test 4.2: Four Column Table - Dense (4 cols, 5 rows, detailed content)

**Expected behavior**: Landscape orientation (exceeds density threshold), tests column width distribution with mixed content

Table: 4.2 - Software Requirements Analysis

| Feature | Business Value | Technical Complexity | Implementation Timeline |
|:--------|:---------------|:---------------------|:------------------------|
| Real-time Collaboration | High - Enables multiple users to work simultaneously on documents, significantly improving team productivity and reducing version control conflicts. | High - Requires WebSocket infrastructure, conflict resolution algorithms, operational transformation for concurrent editing, and robust state synchronization across distributed clients. | Q2 2024 - 12 weeks development, 2 weeks testing, phased rollout over 4 weeks |
| Advanced Search | Medium - Improves user experience by allowing complex queries across all data types, reducing time to find information. | Medium - Needs full-text indexing with Elasticsearch, query parsing engine, relevance ranking algorithm, and faceted filtering capabilities. | Q1 2024 - 8 weeks development, 2 weeks testing, single release |
| Mobile Offline Mode | High - Critical for field workers who need access in areas with poor connectivity, enabling uninterrupted workflow. | High - Requires local database synchronization, conflict resolution when reconnecting, background sync service, and differential update algorithm. | Q3 2024 - 10 weeks development, 3 weeks testing, beta program first |
| API Rate Limiting | Low - Prevents abuse but not user-facing, primarily a defensive mechanism for infrastructure protection. | Low - Standard middleware implementation with Redis-based token bucket algorithm and configurable thresholds per endpoint. | Q1 2024 - 2 weeks development, 1 week testing, immediate deployment |
| Audit Logging | Medium - Required for compliance and security investigations, provides accountability trail for all system actions. | Low - Database schema extension with background write operations, log rotation policies, and retention management with automated archival. | Q1 2024 - 3 weeks development, 1 week testing, gradual rollout |

---

## 5-Column Tables

### Test 5.1: Medium Table (5 cols, 6 rows, moderate content)

**Expected behavior**: Portrait orientation (moderate density, below threshold)

Table: 5.1 - Employee Performance Review Summary

| Name | Department | Q1 Score | Q2 Score | Notes |
|:-----|:-----------|:---------|:---------|:------|
| Alice Johnson | Engineering | 4.5 | 4.7 | Excellent performance, leading new initiative |
| Bob Smith | Marketing | 4.2 | 4.3 | Consistent contributor, good team player |
| Carol Davis | Sales | 4.8 | 4.9 | Top performer, exceeded all targets |
| David Lee | Engineering | 4.0 | 4.1 | Steady improvement, needs mentoring |
| Emma Wilson | Marketing | 4.6 | 4.5 | Strong creative skills, valuable insights |

---

### Test 5.2: Five Column Table - Dense (5 cols, 6 rows, detailed numeric and text)

**Expected behavior**: Landscape orientation (exceeds density threshold), tests 5-column width distribution with mixed numeric/text

Table: 5.2 - Quarterly Budget Analysis by Department

| Department | Q1 Budget | Q1 Actual | Variance | Key Drivers and Explanation |
|:-----------|:----------|:----------|:---------|:----------------------------|
| Engineering | $450,000 | $478,500 | +6.3% | Higher than projected contractor costs for cloud infrastructure migration, plus unplanned security audit expenses following industry-wide vulnerability disclosure. |
| Marketing | $280,000 | $265,200 | -5.3% | Delayed product launch pushed major advertising campaign to Q2, resulted in lower media spend and reduced conference participation in quarter. |
| Sales | $320,000 | $334,800 | +4.6% | Expanded team by two senior account executives earlier than planned to capitalize on increased market demand, plus higher commission payouts from exceptional Q1 performance. |
| Operations | $195,000 | $198,300 | +1.7% | Minor increase due to facility maintenance issues that required immediate attention, including HVAC system replacement and network infrastructure upgrades. |
| Finance | $125,000 | $119,400 | -4.5% | Efficiency gains from process automation reduced external accounting support needs, lower than expected software licensing costs due to volume discount renegotiation. |
| HR | $165,000 | $172,100 | +4.3% | Additional recruiting expenses for hard-to-fill engineering positions, expanded employee wellness programs, and costs associated with onboarding larger than expected new hire class. |

---

## 6-Column Tables

### Test 6.0: Six Column Table - Sparse (6 cols, 5 rows, minimal content)

**Expected behavior**: Currently goes to landscape (6+ cols always landscape). Testing if portrait could work on 6×9 with sparse content.

Table: 6.0 - Weekly Task Status

| Mon | Tue | Wed | Thu | Fri | Sat |
|:----|:----|:----|:----|:----|:----|
| Yes | Yes | Yes | No  | Yes | -   |
| 3   | 4   | 2   | 0   | 5   | 0   |
| OK  | OK  | OK  | Skip| OK  | Off |
| 8am | 9am | 8am | -   | 7am | -   |
| Done| Done| Done| N/A | Done| N/A |

---

### Test 6.1: Six Column Table - Dense (6 cols, 7 rows, detailed content)

**Expected behavior**: Should go to landscape based on content density despite having 6 columns (at the limit for 6×9).

Table: 6.1 - Project Resource Allocation Summary

| Project Name | Department | Team Lead | Budget Allocated | Resources Assigned | Completion Status |
|:-------------|:-----------|:----------|:-----------------|:-------------------|:------------------|
| Customer Portal Redesign | Engineering | Sarah Johnson | $245,000 | 8 developers, 2 designers, 1 PM | 65% complete, on track for Q2 delivery |
| Mobile App Enhancement | Product | Michael Chen | $180,000 | 5 developers, 3 QA engineers | 80% complete, beta testing phase |
| Data Migration Initiative | Infrastructure | David Williams | $320,000 | 6 engineers, 2 DBAs, 1 architect | 45% complete, some delays expected |
| Marketing Automation | Marketing | Jennifer Davis | $95,000 | 3 developers, 1 designer | 90% complete, final UAT in progress |
| Security Audit Implementation | Security | Robert Martinez | $275,000 | 4 security engineers, 2 consultants | 55% complete, additional resources needed |
| AI/ML Integration Project | Data Science | Emily Thompson | $410,000 | 7 data scientists, 4 ML engineers | 35% complete, research phase ongoing |

---

### Test 6.2: Multi-Page Table (6 cols, 30 rows) - Tests pagination

**Expected behavior**: Landscape orientation (multi-page rule), spans multiple pages

Table: 6.2 - Monthly Sales Data by Region and Product Category

| Month | Region | Product Category | Revenue ($) | Units Sold | Growth (%) |
|:------|:-------|:-----------------|:------------|:-----------|:-----------|
| January | North | Electronics | 125,000 | 450 | 12.5 |
| January | North | Furniture | 85,000 | 120 | 8.3 |
| January | South | Electronics | 98,000 | 380 | 15.2 |
| January | South | Furniture | 62,000 | 95 | 6.8 |
| January | East | Electronics | 142,000 | 520 | 18.5 |
| January | East | Furniture | 78,000 | 110 | 9.2 |
| February | North | Electronics | 132,000 | 475 | 5.6 |
| February | North | Furniture | 91,000 | 135 | 7.1 |
| February | South | Electronics | 105,000 | 410 | 7.1 |
| February | South | Furniture | 68,000 | 105 | 9.7 |
| February | East | Electronics | 155,000 | 565 | 9.2 |
| February | East | Furniture | 84,000 | 125 | 7.7 |
| March | North | Electronics | 145,000 | 510 | 9.8 |
| March | North | Furniture | 96,000 | 145 | 5.5 |
| March | South | Electronics | 118,000 | 445 | 12.4 |
| March | South | Furniture | 75,000 | 118 | 10.3 |
| March | East | Electronics | 168,000 | 615 | 8.4 |
| March | East | Furniture | 92,000 | 138 | 9.5 |
| April | North | Electronics | 138,000 | 495 | -4.8 |
| April | North | Furniture | 89,000 | 132 | -7.3 |
| April | South | Electronics | 112,000 | 425 | -5.1 |
| April | South | Furniture | 71,000 | 112 | -5.3 |
| April | East | Electronics | 162,000 | 590 | -3.6 |
| April | East | Furniture | 88,000 | 132 | -4.3 |
| May | North | Electronics | 148,000 | 525 | 7.2 |
| May | North | Furniture | 94,000 | 142 | 5.6 |
| May | South | Electronics | 122,000 | 460 | 8.9 |
| May | South | Furniture | 78,000 | 122 | 9.9 |
| May | East | Electronics | 175,000 | 635 | 8.0 |
| May | East | Furniture | 95,000 | 145 | 8.0 |

---

## 7-Column Tables

### Test 7.1: Large Table with Dense Content (7 cols, 8 rows)

**Expected behavior**: Landscape orientation (7 cols always landscape)

Table: 7.1 - Studio Shelf Configuration Analysis

| Room / Wall | Wall Length (cm) | Available Tracks | Track Run Length | Bay Count (61cm) | Total Shelf Width | Standards Required |
|:------------|:-----------------|:-----------------|:-----------------|:-----------------|:------------------|:-------------------|
| Sala – Long Wall | 450 | 80″ + 56″ = 345 cm total available | 345 cm actual usage | 5 bays configured | 305 cm total width | 6 vertical standards |
| Sala – Short Wall | 280 | 64″ + 41″ = 267 cm total available | 267 cm actual usage | 4 bays configured | 244 cm total width | 5 vertical standards |
| Quarto 1 - Left Wall | 220 | 56″ + 23″ = 200 cm total available | 200 cm actual usage | 3 bays configured | 183 cm total width | 4 vertical standards |
| Quarto 1 - Right Wall | 180 | 41″ + 23″ = 163 cm total available | 163 cm actual usage | 2 bays configured | 122 cm total width | 3 vertical standards |
| Studio Main Wall | 520 | 80″ + 80″ = 406 cm total available | 406 cm actual usage | 6 bays configured | 366 cm total width | 7 vertical standards |
| Storage Room | 300 | 64″ + 56″ = 305 cm total available | 305 cm actual usage | 5 bays configured | 305 cm total width | 6 vertical standards |
| Office Space | 240 | 56″ + 41″ = 246 cm total available | 246 cm actual usage | 4 bays configured | 244 cm total width | 5 vertical standards |

---

### Test 7.2: Seven Column Table - Varied Density (7 cols, 5 rows, different column widths needed)

**Expected behavior**: Landscape orientation (7+ cols always landscape), tests column width distribution with highly unbalanced content

Table: 7.2 - Project Resource Allocation Matrix

| Project Code | PM | Start | End | Team Size | Budget | Detailed Scope and Deliverables |
|:-------------|:---|:------|:----|:----------|:-------|:--------------------------------|
| PROJ-2024-001 | SK | Jan 15 | Apr 30 | 8 | $450K | Complete redesign of customer-facing web portal including responsive mobile interface, accessibility compliance to WCAG 2.1 AA standards, integration with new authentication system, comprehensive user testing program with at least 50 participants, and migration of legacy content to new CMS platform. |
| PROJ-2024-002 | MR | Feb 1 | May 15 | 12 | $680K | Development of iOS and Android native applications with offline functionality, real-time synchronization capabilities, push notifications, in-app purchase system, social media integration, analytics tracking, beta testing program with 200 users across three countries, and App Store optimization. |
| PROJ-2024-003 | JL | Mar 1 | Jun 30 | 6 | $320K | Database performance optimization initiative including query analysis, index restructuring, caching layer implementation, database sharding strategy, backup and recovery procedure enhancement, monitoring dashboard creation, documentation of all optimizations, and knowledge transfer sessions. |
| PROJ-2024-004 | AS | Jan 1 | Dec 31 | 4 | $280K | Ongoing infrastructure maintenance covering 24/7 system monitoring, monthly security patches, quarterly disaster recovery drills, annual penetration testing, continuous performance tuning, capacity planning and forecasting, vendor relationship management, and comprehensive technical documentation updates. |
| PROJ-2024-005 | TC | Apr 1 | Jul 31 | 10 | $520K | Machine learning model development for predictive analytics including data pipeline construction, feature engineering across multiple data sources, model training and validation with cross-validation, hyperparameter tuning, deployment to production environment with A/B testing framework, and creation of monitoring dashboards for model performance. |

---

## 8-Column Tables

### Test 8.1: Wide Table with Minimal Rows (8 cols, 3 rows)

**Expected behavior**: Landscape orientation (8 cols always landscape)

Table: 8.1 - System Configuration Matrix

| Server | OS | CPU Cores | RAM (GB) | Storage (TB) | Network | Backup | Status |
|:-------|:---|:----------|:---------|:-------------|:--------|:-------|:-------|
| PROD-01 | Ubuntu 22.04 | 16 | 64 | 2.0 | 10Gbps | Daily | Active |
| PROD-02 | Ubuntu 22.04 | 32 | 128 | 4.0 | 10Gbps | Daily | Active |

---

# Summary

These test cases cover:
- **Column count**: 2, 3, 4, 5, 6, 7, 8 columns
- **Row count**: 2-30 rows
- **Content density**: Minimal to very dense
- **Landscape vs Portrait**: Tests for 2-col (portrait), 3-col (both), 4-col (both), 5-col (both), 6+ col (landscape)
- **Column width distribution**: Unbalanced columns (2-col), mixed numeric/text (4-col, 5-col), highly varied widths (7-col)
- **Pagination**: Single page and multi-page tables
- **Captions**: All tables have captions for testing
