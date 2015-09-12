with ventdays as
(
select SUBJECT_ID, HADM_ID
, count(chartdate) as NumVentDays
from mimic2v30.cptevents
where COSTCENTER = 'Resp'
and DESCRIPTION in 
(
'VENT MGMT, 1ST DAY (INVASIVE)'
, 'VENT MGMT;SUBSQ DAYS(INVASIVE)'
)
group by SUBJECT_ID, HADM_ID
)
select adm.SUBJECT_ID, adm.HADM_ID
, coalesce(ventdays.NumVentDays,0) as NumVentDays
, adm.admittime, adm.dischtime, adm.deathtime
, case when adm.deathtime is null then 0 else 1 end as hosdead
, (coalesce(pat.DOD_HOSP, pat.DOD_SSN) - adm.dischtime) as DaysUntilDeath
from mimic2v30.admissions adm
inner join mimic2v30.patients pat
    on adm.subject_id = pat.subject_id
left join ventdays
    on adm.hadm_id = ventdays.hadm_id
order by adm.subject_id, adm.hadm_id;
