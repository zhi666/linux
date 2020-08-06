-- 删除数据库中的测试账号（没有手机号的账号）和他们的好友关系表数据
DELETE FROM missu_friendreq WHERE user_uid in (SELECT user_uid FROM missu_users WHERE mobile = "") OR be_user_uid in  (SELECT user_uid FROM missu_users WHERE mobile = "");
SET foreign_key_checks = 0;
DELETE FROM missu_users WHERE mobile = "";
SET foreign_key_checks = 1;

-- 修改添加好友最大上限，同时会同步数据库中已经存在的用户的好友上限值（注意两条语句的值应该保持一致）
 alter table missu_users alter column max_friend set default 100;
 update missu_users set max_friend = 100;
 
 -- 修改用户默认是否可以添加好友（0不允许 1允许），同时会同步数据库中已经存在的数据（注意两条语句的值应该保持一致）
 alter table missu_users alter column can_add_friend set default 1;
 update missu_users set can_add_friend = 1;
 
 -- 修改用户默认是否可以创建组（0不允许 1允许），同时会同步数据库中已经存在的数据（注意两条语句的值应该保持一致）
 alter table missu_users alter column can_create_group set default 1;
 update missu_users set can_create_group = 1;