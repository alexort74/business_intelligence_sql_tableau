# Project Reflection – *Magist × ENIAC: Brazil Entry Plan*

## Summary
This project evaluates whether ENIAC (a European seller of Apple-compatible tech accessories) should enter the Brazilian market via Magist, a SaaS order-management marketplace.  
Workstreams included:

* **SQL data exploration** – querying a 26-month Magist snapshot to size tech categories, seller locations, and delivery SLAs.  
* **Tableau BI workbook** – building visuals (tech-vs-non-tech share, delivery-time maps, seller treemaps).  
* **Business deck** – translating findings into an executive presentation with a phased market-entry plan and KPI roadmap.

## Languages and Libraries Used
| Layer | Tools / Tech |
|-------|--------------|
| Data exploration | `sql_magist_data_exploration.sql` (PostgreSQL-style SQL) |
| BI / Viz | Tableau (`Business_Intelligence_Magist_Eniac.twbx`) |
| Presentation | PowerPoint (`Magist_Eniac_Business_Presentation.pdf`) |
| Version control | Git / GitHub |

## Key Learnings
* **Marketplace analytics** – quantified that tech represents only 12 – 15 % of Magist GMV and is dominated by €70 – €120 accessories.  
* **Logistics diagnostics** – mapped delivery-time outliers (25-30 days to Amazonas) and linked them to low local-seller density.  
* **Storytelling** – condensed technical insights into three C-suite-ready recommendations (pilot mid-range SKUs, negotiate express shipping, monitor KPIs).  
* **TAM framing** – translated a 2 % share scenario into a €280 M opportunity to anchor discussion in commercial upside.

## Key Insights
1. **Tech footprint is small & mid-tier**  
   *Tech = ~12-15 % of sales; volume led by €100 accessories (computers_accessories, telephony).*

2. **Remote delivery lag**  
   *Average transit = 12 days, but 25-30 days to northern states (e.g., Amazonas) where seller density is minimal.*

3. **Seller pool limited & clustered**  
   *Only 454 tech sellers (~15 % of total); ~60 % are based in São Paulo, leaving other regions under-served.*

4. **€280 M upside even at 2 % share**  
   *Capturing just 2 % of Brazil’s €14 B accessories market yields a €280 M TAM.*

## Actions (Recommendations)
| # | Action | Detail | KPI Trigger |
|---|--------|--------|-------------|
| 1 | **Pilot mid-range accessories** 🛍️🔌 | Launch 3-5 SKUs in the €50-150 band (Apple-compatible chargers, cables, peripherals). | **Sell-through ≥ category avg.** |
| 2 | **Negotiate express shipping** 🚚⚡ | Secure 3-5-day courier (e.g., Sedex) for premium Apple lines, especially outside São Paulo. | **≥ 80 % of tech orders < 7 days** |
| 3 | **Monitor KPIs during 12-mo trial** 📊🔍 | Track (a) Units Sold/Month vs category, (b) Avg delivery time, (c) Post-delivery NPS. | **Quarterly dashboard; pivot if targets missed** |

## Challenges Overcame
* **Data cleanliness** – product categories were in Portuguese; built a translation map to group tech vs non-tech accurately.  
* **Sparse geodata** – zip-code granularity varied; aggregated to state level for reliable delivery-time choropleths.  
* **Metric alignment** – reconciled different timestamps (purchase, dispatch, estimated delivery) to compute true SLA performance.  
* **Executive brevity** – converted >20 SQL outputs into <10 clear Tableau views and a five-slide narrative.

## Additional Reflections
* Pairing geographic seller density with delivery-time visuals proved persuasive—execs immediately grasp why *distance is destiny*.  
* Maintaining one colour palette and icon set across SQL notes, Tableau dashboards, and the PPT saved polish time and reinforced brand consistency.  
* Next steps (post-pilot) would include automating daily KPI pulls and A/B-testing express-courier pricing to balance speed and margin.
