# Using select

## Using distince to filter duplicated value
`select distinct srcuser from mail`
`select distinct srcuser, dituser from mail`

## Rename Null values
`select user,pwd,IF(email is not null, email, "Unknown") as email from user`
`select user,pwd,IFNULL(email, "Unknown") as email from mail`

## Create views to access result multiple times
```
create view mail_view as
select 
DATE_FORMAT(t, '%M %e, %Y') as date_sent,
CONCAT(srcuser, '@', srchost) as sender,
CONCAT(dstuser, '@', dsthost) as reciever,
size
from mail;
```
then access it like a table
`select * from mail_view`

## Selecting data from multiple tables with JOIN
```select id,name,service,contact_name from profile inner join profile_contact on id=profile_id;```

## Selecting data from multiple tables with subquery
```select service,contact_name from profile_contact where profile_id=(select id from profile where name='Nancy');```

## Select rows from result with LIMIT
```select * from profile order by birth limit 1``` get the oldest man
```select *, DATE_FORMAT(birth, '%m-%d') as birthday from profile order by birthday limit 1```

```select * from xxx limit 0, 20```
```select * from xxx limit 20, 20```
```select * from xxx limit 40, 20```

You can get totle number of rows when retrieving first chunk of data
```select SQL_CALC_FOUND_ROWS * from profile limit 5```
```select FOUND_ROWS()```

## What to Do When LIMIT Requires the "Wrong" Sort Order
```select * from (select * from profile order by birth desc limit 4) as t order by birth;```


# Table Management
## Cloning a table
```create table new_profile like profile;```
```insert into new_profile (select * from profile);```

## Check engine of table
```show create table profile;```
```show table status profile;```
```select engine from information_schema.tables where table_schema='cookbook' and table_name='profile';```

## Change engine of table
```Alter table profile engine=MyISAM```
```Alter table profile engine=InnoDB```

## Dump table to .sql file
```mysqldump cookbook mail > mail.sql```
then load it somewhere
`mysql cookbook < mail.sql`


