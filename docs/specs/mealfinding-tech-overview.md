# Technical Specification — Overview (Mealfinding)

**Status:** Draft 
**Owner:** Shane
**Version:** v0.1
**Date:** 2025-08-24

---

## 1. Executive summary

Delivers Mealfinding Public site + Api + Business Owner Site with functionality to view and find Restaurants and manage Restaurants. 

---

## 2. Goals & scope

**Goals**

* Primary: Deliver Mealfinding website
* Secondary: Provide functionality to ingest Restaurant info

**In scope**

* Public website (desktop + mobile)
* Backend API (REST) for website and third-party clients
* Restaurant Owner website (desktop + mobile)
* Data Ingestion Processes

**Out of scope**

* Native mobile apps 

---

## 3. Development Infrastructure
See development_workflow.md for process details

* AI Coding - Claude Code
* Code Repo - Github

---

## 4. Deployment Infrastructure

* CDN/DDOS Protection - Fastly
* Web Server - fly.io
* App Server - fly.io
* Database - Supabase postgres
* Auth - Supabase Auth

---

## 5. Tech Stack

* Language - Typescript
* Web Framework - AstroJs + React
* Styling - Tailwind
* Build System - bun
* Package Management - bun
* Bundle System - bun
* Test Execution - bun
* 

 
