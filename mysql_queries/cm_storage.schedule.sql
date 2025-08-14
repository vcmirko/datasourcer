SELECT
    schedule.objid AS id,
    schedule.name AS name,
    schedule.clusterId AS cluster_id,
    schedule.description AS description,
    schedule.scheduleTypeRaw AS type,
    schedule.cronDayOfMonth AS cron_days_of_month,
    schedule.cronDayOfWeek AS cron_days_of_week,
    schedule.cronHour AS cron_hours,
    schedule.cronMinute AS cron_minutes,
    schedule.cronMonth AS cron_months,
    schedule.intervalDays AS interval_days,
    schedule.intervalHours AS interval_hours,
    schedule.intervalMinutes AS interval_minutes,
    schedule.intervalSeconds AS interval_seconds    
FROM
    netapp_model_view.job_schedule schedule