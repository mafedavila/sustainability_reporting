CREATE TABLE "order" (
    "ordernumber" int   NOT NULL,
    "productid" int   NOT NULL,
    "startdate" timestamp   NOT NULL,
    "enddate" timestamp   NOT NULL,
    "productserial" varchar(200)   NOT NULL,
    "factory" varchar(200)   NOT NULL,
    "hall" varchar(200)   NOT NULL,
    CONSTRAINT "pk_order" PRIMARY KEY (
        "ordernumber"
     )
);

CREATE TABLE "component" (
    "componentid" varchar(200)   NOT NULL,
    "productserial" varchar(200)   NOT NULL,
    "componentname" varchar(200)   NOT NULL,
    "supplied" boolean   NOT NULL,
    "supplierid" varchar(200)   NOT NULL,
    "quantity" int   NOT NULL,
    "material" varchar(20)   NOT NULL,
    "masskg" double precision   NOT NULL,
    CONSTRAINT "pk_component" PRIMARY KEY (
        "componentid"
     )
);

CREATE TABLE "material" (
    "material" varchar(200)   NOT NULL,
    "emissionfactor" double precision   NOT NULL,
    "factorunit" varchar(20)   NOT NULL,
    "datasource" varchar(200)   NOT NULL,
    "datadate" int   NOT NULL,
    CONSTRAINT "pk_material" PRIMARY KEY (
        "material"
     )
);

CREATE TABLE "workplan" (
    "processid" varchar(200)   NOT NULL,
    "productserial" varchar(200)   NOT NULL,
    "processname" varchar(200)   NOT NULL,
    "machineid" varchar(200)   NOT NULL,
    "processminutes" double precision  NOT NULL,
    CONSTRAINT "pk_workplan" PRIMARY KEY (
        "processid"
     )
);


CREATE TABLE "machine" (
    "machineid" varchar(200)   NOT NULL,
    "machinename" varchar(200)   NOT NULL,
    "nominalpower" double precision   NOT NULL,
    "powerunit" varchar(20)   NOT NULL,
    CONSTRAINT "pk_machine" PRIMARY KEY (
        "machineid"
     )
);

CREATE TABLE "supplier" (
    "supplierid" varchar(200)   NOT NULL,
    "suppliername" varchar(200)   NOT NULL,
    "distance" int   NOT NULL,
    "distanceunit" varchar(20)   NOT NULL,
    CONSTRAINT "pk_supplier" PRIMARY KEY (
        "supplierid"
     )
);

CREATE TABLE "energy" (
    "startdate" timestamp   NOT NULL,
    "renewablespercentage" double precision   NOT NULL,
    "conventionalpercentage" double precision   NOT NULL,
    "emissionfactor" double precision   NOT NULL,
    "factorunit" varchar(20)   NOT NULL
);

CREATE TABLE "energy_smard" (
    "datum_von" timestamp   NOT NULL,
    "datum_bis" timestamp   NOT NULL,
    "biomasse_mwh" double precision   NOT NULL,
    "wasserkraft_mwh" double precision   NOT NULL,
    "wind_offshore_mwh" double precision   NOT NULL,
    "wind_onshore_mwh" double precision   NOT NULL,
    "photovoltaik_mwh" double precision   NOT NULL,
    "sonstige_erneuerbare_mwh" double precision   NOT NULL,
    "kernenergie_mwh" double precision   NOT NULL,
    "braunkohle_mwh" double precision   NOT NULL,
    "steinkohle_mwh" double precision   NOT NULL,
    "erdgas_mwh" double precision   NOT NULL,
    "pumpspeicher_mwh" double precision   NOT NULL,
    "sonstige_konventionelle_mwh" double precision   NOT NULL
);

CREATE TABLE "energy_sources" (
    "sourcename" varchar(200)   NOT NULL,
    "renewable" boolean   NOT NULL,
    "emissionfactor" double precision   NOT NULL,
    "unit" varchar(200)   NOT NULL
);

ALTER TABLE "component" ADD CONSTRAINT "fk_component_supplierid" FOREIGN KEY("supplierid")
REFERENCES "supplier" ("supplierid");

ALTER TABLE "component" ADD CONSTRAINT "fk_component_material" FOREIGN KEY("material")
REFERENCES "material" ("material");

ALTER TABLE "workplan" ADD CONSTRAINT "fk_workplan_machineid" FOREIGN KEY("machineid")
REFERENCES "machine" ("machineid");

-- Import data into tables
\copy machine FROM '/data/machine.csv' DELIMITER ',' CSV HEADER;
\copy material FROM '/data/material.csv' DELIMITER ',' CSV HEADER;
\copy supplier FROM '/data/supplier.csv' DELIMITER ',' CSV HEADER;
\copy "order" FROM '/data/order.csv' DELIMITER ',' CSV HEADER;
\copy workplan FROM '/data/workplan.csv' DELIMITER ',' CSV HEADER;
\copy component FROM '/data/component.csv' DELIMITER ',' CSV HEADER;
\copy energy_sources FROM '/data/energy_sources.csv' DELIMITER ',' CSV HEADER;
\copy energy_smard FROM '/data/energy_smard.csv' DELIMITER ',' CSV HEADER;
\copy energy FROM '/data/energy.csv' DELIMITER ',' CSV HEADER;

CREATE VIEW energy_consumption_view AS
SELECT
    wp.productserial,
    SUM(wp.processminutes * m.nominalpower / 60) AS energyconsumption -- Convert kW-minutes to kWh
FROM
    workplan wp
JOIN
    machine m ON wp.machineid = m.machineid
GROUP BY
    wp.productserial;

-- Energy Emission Factor View
CREATE VIEW energy_emission_factor_view AS
SELECT
    o.ordernumber,
    (e1.emissionfactor + e2.emissionfactor) / 2 / 1000 AS energyemissionfactor -- Convert gCO2e/kWh to kgCO2/kWh
FROM
    "order" o
JOIN
    energy e1 ON o.startdate = e1.startdate
JOIN
    energy e2 ON o.enddate = e2.startdate;

-- Energy Emission View
CREATE VIEW energy_emission_view AS
SELECT
    o.ordernumber,
    ecv.energyconsumption * eefv.energyemissionfactor AS energyemission
FROM
    "order" o
JOIN
    energy_consumption_view ecv ON o.productserial = ecv.productserial
JOIN
    energy_emission_factor_view eefv ON o.ordernumber = eefv.ordernumber;

-- Material Emission View
CREATE VIEW material_emission_view AS
SELECT
    c.productserial,
    SUM(c.quantity * c.masskg * m.emissionfactor) AS materialemission
FROM
    component c
JOIN
    material m ON c.material = m.material
GROUP BY
    c.productserial;

-- Transport Emission View
CREATE VIEW transport_emission_view AS
SELECT
    c.productserial,
    SUM((c.quantity * c.masskg / 1000) * s.distance * m.emissionfactor) AS transportemission -- Convert kg to tons
FROM
    component c
JOIN
    supplier s ON c.supplierid = s.supplierid
JOIN
    material m ON m.material = 'Transport'
GROUP BY
    c.productserial;

-- Product Footprint View
CREATE VIEW product_footprint AS
SELECT
    o.ordernumber,
    o.productid,
    o.productserial,
    ecv.energyconsumption,
    eefv.energyemissionfactor,
    eev.energyemission,
    mev.materialemission,
    tev.transportemission
FROM
    "order" o
JOIN
    energy_consumption_view ecv ON o.productserial = ecv.productserial
JOIN
    energy_emission_factor_view eefv ON o.ordernumber = eefv.ordernumber
JOIN
    energy_emission_view eev ON o.ordernumber = eev.ordernumber
JOIN
    material_emission_view mev ON o.productserial = mev.productserial
JOIN
    transport_emission_view tev ON o.productserial = tev.productserial;