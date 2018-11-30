BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS `user` (`id` INTEGER NOT NULL, `team_id` INTEGER, `team_name` TEXT, `leave_profile_id` INTEGER, `full_name` TEXT, `email` TEXT, `user_role` TEXT, `job_title` TEXT, `active` INTEGER, `years_of_service` INTEGER, PRIMARY KEY(`id`));

CREATE TABLE IF NOT EXISTS `token` (`id` INTEGER NOT NULL, `name` TEXT, `platform` TEXT, `push_token` TEXT UNIQUE, `user_id` INTEGER, PRIMARY KEY(`id`), FOREIGN KEY (user_id) REFERENCES user(id));
COMMIT;
