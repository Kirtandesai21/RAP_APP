# Complete End-to-End ABAP RAP & SAP Fiori Elements Application

This project is a complete, production-grade implementation of an enterprise application built with the **ABAP RESTful Application Programming Model (RAP)**, **ABAP Core Data Services (CDS)**, and **SAP Fiori Elements (UI5)**.

---

## Architecture Overview

```
┌────────────────────────────────────────────────────────────────────────┐
│                   SAP Fiori Elements UI5 Application                   │
│             (List Report & Object Page V4 with Annotations)            │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ OData V4 Request / Response
┌───────────────────────────────────▼────────────────────────────────────┐
│                  ABAP RAP Business Service Layer                       │
│     Service Definition: ZUI_RAP_TRAVEL_001_O4                          │
│     Service Binding:    ZUI_RAP_TRAVEL_001_O4 (OData V4 - UI)          │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│                    ABAP CDS Consumption / Projection                   │
│     ZC_RAP_TRAVEL_001 (Root Projection View)                           │
│     ZC_RAP_BOOKING_001 (Child Projection View)                         │
│     ZC_RAP_TRAVEL_001.ddlx.asddlxs (Fiori Elements UI Annotations)     │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│               ABAP RAP Behavior & Runtime Services                     │
│     Behavior Definition: ZI_RAP_TRAVEL_001 (Managed + Draft Enabled)   │
│     - Determinations: setInitialStatus, calculateTotalPrice            │
│     - Validations: validateCustomer, validateDates                     │
│     - Actions: acceptTravel, rejectTravel, recalcTotalPrice            │
│     Behavior Implementation: ZCL_BP_I_RAP_TRAVEL_001                   │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│                    ABAP CDS Data Model (Interface)                     │
│     ZI_RAP_TRAVEL_001 (Root View Entity)                               │
│     ZI_RAP_BOOKING_001 (Child View Entity with Composition)            │
│     ZI_RAP_AGENCY_VH / ZI_RAP_CUSTOMER_VH (Value Helps)                │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│                         Database Tables (DDIC)                         │
│     Active Tables: ZRAP_ATRAV_001, ZRAP_ABOOK_001                      │
│     Draft Tables:  ZRAP_DTRAV_001, ZRAP_DBOOK_001                      │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Directory Structure

```
RAP_APP/
├── abap/                                  # ABAP RAP Backend Artifacts
│   ├── ddic/                              # DDIC Database & Draft Tables
│   │   ├── zrap_atrav_001.tabl.xml        # Travel Active Table
│   │   ├── zrap_dtrav_001.tabl.xml        # Travel Draft Table
│   │   ├── zrap_abook_001.tabl.xml        # Booking Active Table
│   │   └── zrap_dbook_001.tabl.xml        # Booking Draft Table
│   ├── cds/                               # ABAP CDS View Entities
│   │   ├── zi_rap_travel_001.ddls.asddls  # Root Interface View Entity
│   │   ├── zi_rap_booking_001.ddls.asddls # Child Interface View Entity
│   │   ├── zc_rap_travel_001.ddls.asddls  # Root Consumption / Projection View
│   │   ├── zc_rap_booking_001.ddls.asddls # Child Consumption / Projection View
│   │   ├── zi_rap_agency_vh.ddls.asddls   # Agency Value Help View
│   │   └── zi_rap_customer_vh.ddls.asddls # Customer Value Help View
│   ├── metadata_extensions/               # Fiori Elements UI Annotations
│   │   ├── zc_rap_travel_001.ddlx.asddlxs # Travel List Report & Object Page UI Annotations
│   │   └── zc_rap_booking_001.ddlx.asddlxs# Booking Line Item UI Annotations
│   ├── bdef/                              # Behavior Definitions (RAP Runtime Services)
│   │   ├── zi_rap_travel_001.bdef.asbdef  # Interface Managed Behavior Definition (with Draft)
│   │   └── zc_rap_travel_001.bdef.asbdef  # Consumption Projection Behavior Definition
│   ├── classes/                           # ABAP Classes
│   │   ├── zcl_bp_i_rap_travel_001.clas.abap             # Behavior Handler Class Definition
│   │   ├── zcl_bp_i_rap_travel_001.clas.locals_imp.abap  # Local Implementation (Handlers, Saver)
│   │   └── zcl_rap_generator_data.clas.abap              # Test Data Generator (F9 Console Runner)
│   └── service/                           # Business Service
│       ├── zui_rap_travel_001_o4.srvd.srvdsrv # Service Definition
│       └── zui_rap_travel_001_o4.srvb.xml     # Service Binding (OData V4 - UI)
│
├── webapp/                                # SAP Fiori UI5 Elements Frontend
│   ├── index.html                         # Fiori Launchpad / Component Container
│   ├── preview.html                       # Standalone Interactive Fiori Elements Preview
│   ├── manifest.json                      # Fiori Elements V4 App Descriptor
│   ├── Component.js                       # UI5 Root Component
│   ├── localService/                      # Local Mock Service
│   │   ├── metadata.xml                   # OData V4 EDMX Metadata with UI Annotations
│   │   └── mockdata/                      # Realistic mock datasets
│   │       ├── Travel.json
│   │       ├── Booking.json
│   │       ├── Agency.json
│   │       └── Customer.json
│   └── i18n/
│       └── i18n.properties                # UI Translations
├── server.py                              # Local Dev Server
├── package.json
└── README.md
```

---

## 1. ABAP RAP Core Data Services (CDS) Views

### Interface Root View Entity: `ZI_RAP_TRAVEL_001`
- Exposes basic persistence fields from `zrap_atrav_001`.
- Contains composition `composition [0..*] of ZI_RAP_BOOKING_001 as _Booking`.
- Exposes associations to value helps (`_Agency`, `_Customer`, `_Currency`).
- Implements semantic annotations for currency amounts, audit timestamps, and ETag fields.

### Consumption Projection View: `ZC_RAP_TRAVEL_001`
- Defines `provider contract transactional_query`.
- Enforces `@Metadata.allowExtensions: true` to decouple business logic from UI layout.
- Provides `@Consumption.valueHelpDefinition` for Agency, Customer, and Currency.
- Redirects composition target `_Booking : redirected to composition child ZC_RAP_BOOKING_001`.

---

## 2. Fiori Elements CDS UI Annotations (`.ddlx.asddlxs`)

The metadata extension file `zc_rap_travel_001.ddlx.asddlxs` drives the Fiori Elements application automatically:
- **`@UI.headerInfo`**: Defines the title ("Travel"), plural ("Travels"), header title (`TravelID`), and subtitle (`Description`).
- **`@UI.facet`**:
  - `HeaderStatus` (`#DATAPOINT_REFERENCE`) for KPI badge.
  - `HeaderTotalPrice` (`#DATAPOINT_REFERENCE`) for amount KPI.
  - `GeneralInfoCollection` (`#COLLECTION`) hosting `TravelDetailsFacet` and `DatesFacet`.
  - `BookingsFacet` (`#LINEITEM_REFERENCE`) rendering the child booking table.
- **`@UI.lineItem`**:
  - Defines table columns with order, priority, and criticality.
  - Quick action buttons: `acceptTravel` and `rejectTravel` directly on table items.
- **`@UI.selectionField`**: Adds TravelID, AgencyID, CustomerID, and OverallStatus to the Smart Filter Bar.

---

## 3. ABAP RAP Runtime Services (Behavior Definition & Implementation)

The Behavior Definition `zi_rap_travel_001.bdef.asbdef` defines:
- **Managed Implementation with Draft**: Draft table `zrap_dtrav_001` automatically manages user work-in-progress states.
- **Determinations**:
  - `setInitialStatus` triggers `on modify { create; }` to default status to `'O'` (Open).
  - `calculateTotalPrice` recalculates the total sum when `BookingFee` or child flight prices change.
- **Validations**:
  - `validateCustomer` verifies Customer ID existence before saving.
  - `validateDates` ensures `BeginDate <= EndDate`.
- **Actions**:
  - `acceptTravel`: sets overall status to `'A'` (Accepted).
  - `rejectTravel`: sets overall status to `'X'` (Rejected / Cancelled).
- **Concurrency & Locking**: `lock master total etag LastChangedAt` with `etag master LocalLastChangedAt`.

---

## 4. Running the Application

### Option A: Local Interactive Preview
You can test and interact with the complete Fiori Elements application immediately on your machine without a live SAP backend:

```bash
# Run local dev server
python3 server.py
```
Then open your browser at:
**[http://localhost:8080/webapp/preview.html](http://localhost:8080/webapp/preview.html)**

Features in preview:
- Live List Report with Smart Filter Bar.
- Status criticality chips (Green for Accepted, Yellow for Open, Red for Rejected).
- "Accept Travel" and "Reject Travel" actions.
- Click any row to navigate to the Fiori Elements Object Page with Header KPIs, Form facets, and child Bookings table.

### Option B: Deploying to SAP S/4HANA or SAP BTP ABAP Environment (ADT)
1. In Eclipse with **ABAP Development Tools (ADT)**, create a package (e.g. `ZRAP_TRAVEL_001`).
2. Create the DDIC database tables from `abap/ddic/`.
3. Create the CDS View Entities from `abap/cds/`.
4. Create the Metadata Extensions from `abap/metadata_extensions/`.
5. Create the Behavior Definitions from `abap/bdef/`.
6. Create the Behavior Implementation class and local types from `abap/classes/`.
7. Run class `ZCL_RAP_GENERATOR_DATA` by pressing **F9** to populate sample data.
8. Create the Service Definition and Service Binding (`abap/service/`) and click **Publish**.
9. In the Service Binding editor, select entity `Travel` and click **Preview** to launch the SAP Fiori Elements app directly in SAP Fiori Launchpad!
