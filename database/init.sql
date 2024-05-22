-- Create tables
create table "companies" (
    "company_id" serial primary key,
    "name" varchar(100),
    "location" varchar(100)
);

create table "factories" (
    "factory_id" serial primary key,
    "company_id" int,
    "name" varchar(100),
    "location" varchar(100),
    foreign key ("company_id") references "companies"("company_id")
);

create table "products" (
    "product_id" serial primary key,
    "factory_id" int,
    "product_type" varchar(100),
    "quantity_sold" int,
    "revenue" decimal(15, 2),
    "month" date,
    foreign key ("factory_id") references "factories"("factory_id")
);

create table "energy_usage" (
    "usage_id" serial primary key,
    "factory_id" int,
    "timestamp" date,
    "energy_source" varchar(50),
    "energy_used_kWh" decimal(15, 2),
    foreign key ("factory_id") references "factories"("factory_id")
);

create table "water_usage" (
    "usage_id" serial primary key,
    "factory_id" int,
    "timestamp" date,
    "water_used_liters" decimal(15, 2),
    foreign key ("factory_id") references "factories"("factory_id")
);

create table "waste_management" (
    "waste_id" serial primary key,
    "factory_id" int,
    "timestamp" date,
    "waste_type" varchar(50),
    "amount_kg" decimal(15, 2),
    foreign key ("factory_id") references "factories"("factory_id")
);

create table "materials" (
    "material_id" serial primary key,
    "factory_id" int,
    "timestamp" date,
    "material_type" varchar(100),
    "quantity_kg" decimal(15, 2),
    "supplier" varchar(100),
    "distance_km" decimal(10, 2),
    "transport_method" varchar(50),
    foreign key ("factory_id") references "factories"("factory_id")
);

create table "emission_factors" (
    "emission_id" serial primary key,
    "material_type" varchar(20),
    "material" varchar(100),
    "emission_factor" decimal(10, 5),
    "emission_factor_units" varchar(50)
);

create table "energy_emission_factors" (
    "energy_id" serial primary key,
    "energy_source" varchar(50),
    "renewable" boolean,
    "emission_factor_gCO2e_per_kWh" decimal(10, 5)
);

-- Import data into tables
\copy "companies" FROM '/data/companies.csv' DELIMITER ',' CSV HEADER;
\copy "factories" FROM '/data/factories.csv' DELIMITER ',' CSV HEADER;
\copy "products" FROM '/data/products.csv' DELIMITER ',' CSV HEADER;
\copy "energy_usage" FROM '/data/energy_usage.csv' DELIMITER ',' CSV HEADER;
\copy "water_usage" FROM '/data/water_usage.csv' DELIMITER ',' CSV HEADER;
\copy "waste_management" FROM '/data/waste_management.csv' DELIMITER ',' CSV HEADER;
\copy "materials" FROM '/data/materials.csv' DELIMITER ',' CSV HEADER;
\copy "emission_factors" FROM '/data/emission_factors.csv' DELIMITER ',' CSV HEADER;
\copy "energy_emission_factors" FROM '/data/energy_emission_factors.csv' DELIMITER ',' CSV HEADER;

-- Create views for KPIs
-- Material Emissions
create view "material_emissions" as
select 
    m."factory_id",
    f."name" as "factory_name",
    date_trunc('month', m."timestamp")::timestamp as "month",
    sum(m."quantity_kg" * e."emission_factor") as "total_material_emissions"
from "materials" m
join "emission_factors" e on m."material_type" = e."material" and e."material_type" = 'material'
join "factories" f on m."factory_id" = f."factory_id"
group by m."factory_id", "month", f."name";

-- Transport Emissions
create view "transport_emissions" as
select 
    m."factory_id",
    f."name" as "factory_name",
    date_trunc('month', m."timestamp")::timestamp as "month",
    sum(m."quantity_kg" * m."distance_km" * e."emission_factor") as "total_transport_emissions"
from "materials" m
join "emission_factors" e on m."transport_method" = e."material" and e."material_type" = 'transport'
join "factories" f on m."factory_id" = f."factory_id"
group by m."factory_id", "month", f."name";

-- Energy Emissions
create view "energy_emissions" as
select 
    e."factory_id",
    f."name" as "factory_name",
    date_trunc('month', e."timestamp")::timestamp as "month",
    e."energy_source",
    sum(e."energy_used_kWh" * ef."emission_factor_gCO2e_per_kWh" / 1000) as "total_energy_emissions_kgCO2"
from "energy_usage" e
join "factories" f on e."factory_id" = f."factory_id"
join "energy_emission_factors" ef on e."energy_source" = ef."energy_source"
group by e."factory_id", "month", e."energy_source", f."name";

-- Total Water Usage
create view "total_water_usage" as
select 
    "factory_id",
    date_trunc('month', "timestamp")::timestamp as "month",
    sum("water_used_liters") as "total_water_used"
from "water_usage"
group by "factory_id", "month";

-- Total Waste Generated
create view "total_waste_generated" as
select 
    "factory_id",
    date_trunc('month', "timestamp")::timestamp as "month",
    sum("amount_kg") as "total_waste"
from "waste_management"
group by "factory_id", "month";

-- Energy Intensity (Energy Used per Product)
create view "energy_intensity" as
select 
    p."factory_id",
    date_trunc('month', p."month")::timestamp as "month",
    e."energy_source",
    sum(e."energy_used_kWh") / sum(p."quantity_sold") as "energy_intensity_per_product"
from "products" p
join "energy_usage" e on p."factory_id" = e."factory_id" and date_trunc('month', p."month") = date_trunc('month', e."timestamp")
group by p."factory_id", "month", e."energy_source";

-- Water Usage per Product
create view "water_usage_per_product" as
select 
    p."factory_id",
    date_trunc('month', p."month")::timestamp as "month",
    sum(w."water_used_liters") / sum(p."quantity_sold") as "water_usage_per_product"
from "products" p
join "water_usage" w on p."factory_id" = w."factory_id" and date_trunc('month', p."month") = date_trunc('month', w."timestamp")
group by p."factory_id", "month";

-- Waste Generated per Revenue
create view "waste_per_revenue" as
select 
    p."factory_id",
    date_trunc('month', p."month")::timestamp as "month",
    sum(w."amount_kg") / sum(p."revenue") as "waste_per_revenue"
from "products" p
join "waste_management" w on p."factory_id" = w."factory_id" and date_trunc('month', p."month") = date_trunc('month', w."timestamp")
group by p."factory_id", "month";

-- Total Emissions (Material + Transport + Energy)
create view "total_emissions" as
select 
    me."factory_id",
    f."name" as "factory_name",
    me."month",
    coalesce(sum(me."total_material_emissions"), 0) + 
    coalesce(sum(te."total_transport_emissions"), 0) + 
    coalesce(sum(ee."total_energy_emissions_kgCO2"), 0) as "total_emissions"
from "factories" f
left join "material_emissions" me on f."factory_id" = me."factory_id"
left join "transport_emissions" te on f."factory_id" = te."factory_id" and me."month" = te."month"
left join "energy_emissions" ee on f."factory_id" = ee."factory_id" and me."month" = ee."month"
group by me."factory_id", me."month", f."name";
