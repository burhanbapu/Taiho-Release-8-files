/*
CCDM Site mapping
Notes: Standard mapping to CCDM Site table
*/

WITH included_studies AS (
                SELECT studyid FROM study ),

    site_data AS (
                SELECT  distinct 'TAS2940_101'::text AS studyid,
                        'TAS2940_101'::text AS studyname,
                        'TAS2940_101_' || split_part("name",'_',1)::text AS siteid,
                        split_part("name",'_',2)::text AS sitename,
                        'UBC'::text AS croid,
                        'UBC'::text AS sitecro,
                        case when "name" like '%201_Gustave Roussy_201%' then 'France'
                        else 'United States' end::text AS sitecountry,
                        null::text AS sitecountrycode,
                        case when "name" like '%201_Gustave Roussy_201%' then 'Europe'
                        else 'North America' end::text AS siteregion,
                        'TRUE'::text as statusapplicable,
                        effectivedate::date AS sitecreationdate,
                        effectivedate::date AS siteactivationdate,
                        case when lower(ms.closeout_status) = 'site closeout' then ms.cov_visit_end_date
                        else null end::date AS sitedeactivationdate,
                        null::text AS siteinvestigatorname,
                        null::text AS sitecraname,
                        null::text AS siteaddress1,
                        null::text AS siteaddress2,
                        null::text AS sitecity,
                        null::text AS sitestate,
                        null::text AS sitepostal,
                        Case when "active"='Yes' then (case when ms.site_status = 'Dropped' then 'Cancelled' else ms.site_status end)
							 else 'Inactive'
						end::text AS sitestatus,
                        nullif(ms.siv_plannned_date::text,'')::date AS sitestatusdate
                        
                        from TAS2940_101.__sites s
                        left join tas2940_101_ctms.site_closeout ms 
                        on split_part(s."name",'_',1) = ms.site_id
                        ),

    sitecountrycode_data AS (
                SELECT studyid, countryname_iso, countrycode3_iso FROM studycountry)

SELECT 
        /*KEY (s.studyid || '~' || s.siteid)::text AS comprehendid, KEY*/
        s.studyid::text AS studyid,
        s.studyname::text AS studyname,
        s.siteid::text AS siteid,
        s.sitename::text AS sitename,
        s.croid::text AS croid,
        s.sitecro::text AS sitecro,
        case when s.sitecountry='United States' then 'United States of America'
        else s.sitecountry
        end::text AS sitecountry,
        cc.countrycode3_iso::text AS sitecountrycode,
        s.siteregion::text AS siteregion,
        s.sitecreationdate::date AS sitecreationdate,
        s.siteactivationdate::date AS siteactivationdate,
        s.sitedeactivationdate::date AS sitedeactivationdate,
        s.siteinvestigatorname::text AS siteinvestigatorname,
        s.sitecraname::text AS sitecraname,
        s.siteaddress1::text AS siteaddress1,
        s.siteaddress2::text AS siteaddress2,
        s.sitecity::text AS sitecity,
        s.sitestate::text AS sitestate,
        s.sitepostal::text AS sitepostal,
        s.sitestatus::text AS sitestatus,
        s.sitestatusdate::date AS sitestatusdate,
        s.statusapplicable::boolean as statusapplicable
        /*KEY , now()::timestamp with time zone AS comprehend_update_time KEY*/
FROM site_data s 
JOIN included_studies st ON (s.studyid = st.studyid)
LEFT JOIN sitecountrycode_data cc ON (s.studyid = cc.studyid AND LOWER(s.sitecountry)=LOWER(cc.countryname_iso));


