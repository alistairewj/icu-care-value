with iodate as
(
select
subject_id, hadm_id
, itemid
, date_trunc('day',endtime) as enddate
from mimic2v30.ioevents
where itemid in
(
30047,30120,30044,30119,30309,30127
,30128,30051,30043,30307,30042,30306,30125
)
and ( (rate is not null and rate != 0) or (volume is not null and volume != 0) )
)
, vaso as 
(
select 
subject_id, hadm_id, enddate
, max(case when itemid in (30047,30120) then 1 else 0 end) as levophed
, max(case when itemid in (30044,30119,30309) then 1 else 0 end) as epinephrine
, max(case when itemid in (30127,30128) then 1 else 0 end) as neosynephrine
, max(case when itemid = 30051 then 1 else 0 end) as vasopressin
, max(case when itemid in (30043,30307) then 1 else 0 end) as dopamine
, max(case when itemid in (30042,30306) then 1 else 0 end) as dobutamine
, max(case when itemid = 30125 then 1 else 0 end) as milrinone
from iodate id
group by subject_id, hadm_id, enddate
)
select adm.subject_id, adm.hadm_id
, sum(levophed) as LevophedDays
, sum(epinephrine) as EpinephrineDays
, sum(neosynephrine) as NeosynephrineDays
, sum(vasopressin) as VasopressinDays
, sum(dopamine) as DopamineDays
, sum(dobutamine) as DobutamineDays
, sum(milrinone) as MilrinoneDays
, count(enddate) as VasopressorDays
from mimic2v30.admissions adm
left join vaso
    on adm.hadm_id = vaso.hadm_id
group by adm.subject_id, adm.hadm_id, vaso.hadm_id;
