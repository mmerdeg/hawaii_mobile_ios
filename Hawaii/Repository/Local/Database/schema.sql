BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS `user` (`id` INTEGER NOT NULL, `team_id` INTEGER, `team_name` TEXT, `leave_profile_id` INTEGER, `full_name` TEXT, `email` TEXT, `user_role` TEXT, `job_title` TEXT, `active` INTEGER, `years_of_service` INTEGER, PRIMARY KEY(`id`));
COMMIT;
