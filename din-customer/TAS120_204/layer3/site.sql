/*
CCDM Site mapping
Notes: Standard mapping to CCDM Site table
*/
WITH included_studies AS (
                SELECT studyid FROM study ),

    site_data AS (
                SELECT  distinct 'TAS120_204'::text AS studyid,
                        'TAS120_204'::text AS studyname,
                        'TAS120_204_' || split_part("name",'_',1)::text AS siteid,
                        split_part("name",'_',2)::text AS sitename,
                        'Syneos'::text AS croid,
                        'Syneos'::text AS sitecro,
                        'United States'::text AS sitecountry,
                        null::text AS sitecountrycode,
                        'North America'::text AS siteregion,
                        'TRUE'::text as statusapplicable,
                        effectivedate::date AS sitecreationdate,
                        effectivedate::date AS siteactivationdate,
                        null::date AS sitedeactivationdate,
                        null::text AS siteinvestigatorname,
                        null::text AS sitecraname,
                        null::text AS siteaddress1,
                        null::text AS siteaddress2,
                        null::text AS sitecity,
                        null::text AS sitestate,
                        null::text AS sitepostal,
                        --sm.site_status::text AS sitestatus,
						Case when "active"='Yes' then (case when site_status = 'Dropped' then 'Cancelled' else site_status end)
							 else 'Inactive'
						end AS sitestatus,
                        case when lower(site_status)='activated' then sm.site_activated_date
                        	 when lower(site_status)='selected' then sm.site_selected_date
                        	 when lower(site_status) in ('back-up','dropped','recommended') then coalesce(nullif(sm.site_activated_date,''),nullif(sm.site_selected_date,'')) 
                        end::date AS sitestatusdate
                        from tas120_204.__sites
                        left join tas120_204_ctms.sites sm
						on split_part("name",'_',1) = split_part(sm."site_number",'_',2)
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



