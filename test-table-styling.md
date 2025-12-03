---
title: Table Styling Tests
author: Julio M. Terra
dates: December 2, 2025
volume: Test Volume
---

# Table Styling Test Cases

## Test 1: Small Table (3 cols, 4 rows, minimal content)

**Expected behavior**: Portrait orientation, normal font size (9pt), regular page flow

Table: Product Pricing

| Product | Price | Stock |
|:--------|:------|:------|
| Widget A | $10 | 100 |
| Widget B | $15 | 50 |
| Widget C | $20 | 75 |

---

## Test 2: Small Table with Dense Content (3 cols, 5 rows, lots of text)

**Expected behavior**: Landscape orientation (dense content, 2+ cols), 9pt font, isolated on own page with page breaks before/after, no footers

Table: Project Status Updates

| Project Name | Current Status | Next Steps and Considerations |
|:-------------|:---------------|:------------------------------|
| Website Redesign | In progress - 60% complete. Design phase finished, moving to development. | Need to finalize color palette, integrate with CMS, test responsive layouts on multiple devices, and schedule client review meeting. |
| Mobile App Development | On hold - waiting for stakeholder approval and budget allocation from finance team. | Prepare detailed cost breakdown, schedule meeting with stakeholders, gather additional user research data, and revise initial wireframes based on feedback. |
| Database Migration | Completed successfully last week with minimal downtime and no data loss. | Monitor performance metrics, document migration process, train team on new system, and schedule follow-up review in two weeks. |
| API Integration | Starting next month after resource allocation is confirmed and requirements are finalized. | Review API documentation thoroughly, set up development environment, coordinate with external vendor, and establish testing protocols. |

---

## Test 3: Medium Table (5 cols, 6 rows, moderate content)

**Expected behavior**: Landscape orientation (5+ cols), 8pt font, tight column spacing (1.5pt), no footers

Table: Employee Performance Review Summary

| Name | Department | Q1 Score | Q2 Score | Notes |
|:-----|:-----------|:---------|:---------|:------|
| Alice Johnson | Engineering | 4.5 | 4.7 | Excellent performance, leading new initiative |
| Bob Smith | Marketing | 4.2 | 4.3 | Consistent contributor, good team player |
| Carol Davis | Sales | 4.8 | 4.9 | Top performer, exceeded all targets |
| David Lee | Engineering | 4.0 | 4.1 | Steady improvement, needs mentoring |
| Emma Wilson | Marketing | 4.6 | 4.5 | Strong creative skills, valuable insights |

---

## Test 4: Large Table with Dense Content (7 cols, 8 rows)

**Expected behavior**: Landscape orientation (7 cols), 8pt font, very tight column spacing (1.5pt), no footers

Table: Studio Shelf Configuration Analysis

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

## Test 5: Multi-Page Table (6 cols, 30 rows) - Tests pagination

**Expected behavior**: Landscape orientation (6 cols), 7pt font (30 rows), spans multiple pages, no footers on ANY landscape page

Table: Monthly Sales Data by Region and Product Category

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

## Test 6: Wide Table with Minimal Rows (8 cols, 3 rows)

**Expected behavior**: Landscape orientation (8 cols), 8pt font, very tight column spacing (1.5pt), no footers

Table: System Configuration Matrix

| Server | OS | CPU Cores | RAM (GB) | Storage (TB) | Network | Backup | Status |
|:-------|:---|:----------|:---------|:-------------|:--------|:-------|:-------|
| PROD-01 | Ubuntu 22.04 | 16 | 64 | 2.0 | 10Gbps | Daily | Active |
| PROD-02 | Ubuntu 22.04 | 32 | 128 | 4.0 | 10Gbps | Daily | Active |

---

# Summary

These test cases cover:
- **Column count**: 3, 5, 6, 7, 8 columns
- **Row count**: 2-30 rows
- **Content density**: Minimal to very dense
- **Pagination**: Single page and multi-page tables
- **Captions**: All tables have captions for testing
