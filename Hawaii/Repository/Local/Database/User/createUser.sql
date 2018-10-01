DELETE FROM `user`;
INSERT INTO `user`(`id`,`team_id`,`leave_profile_id`,`full_name`,`email`,`user_role`,`job_title`,`active`,`years_of_service`) VALUES (?,?,?,?,?,?,?,?,?);
