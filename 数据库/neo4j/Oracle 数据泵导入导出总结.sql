Oracle 数据泵（IMPDP/EXPDP）导入导出总结

	Oracle数据泵导入导出是日常工作中常用的基本技术之一，它相对传统的逻辑导入导出要高效，这种特性更适合数据库对象数量巨大的情形，因为我日常运维的数据库对象少则几千，多则几万甚至几十万，所以传统exp/imp就会非常耗时，而数据泵方式就因此脱引而出，下面就详细总结一下数据泵的使用方法，希望能给初学者带来帮助。

一、新建逻辑目录

	最好以system等管理员创建逻辑目录，Oracle不会自动创建实际的物理目录“D:\oracleData”（务必手动创建此目录），仅仅是进行定义逻辑路径dump_dir；

	sql> conn system/123456a?@orcl as sysdba;
	sql> create directory dump_dir as 'D:\oracleData';

二、查看管理员目录（同时查看操作系统是否存在该目录，因为oracle并不关心该目录是否存在，假如不存在，则出错）

	sql> select * from dba_directories;

三、用expdp导出数据

	1)导出用户及其对象
	expdp scott/tiger@orcl schemas=scott dumpfile=expdp.dmp directory=dump_dir;

	2)导出指定表
	expdp scott/tiger@orcl tables=emp,dept dumpfile=expdp.dmp directory=dump_dir;

	3)按查询条件导
	expdp scott/tiger@orcl directory=dump_dir dumpfile=expdp.dmp tables=emp query='where deptno=20';

	4)按表空间导
	expdp system/manager@orcl directory=dump_dir dumpfile=tablespace.dmp tablespaces=temp,example;

	5)导整个数据库
	expdp system/manager@orcl directory=dump_dir dumpfile=full.dmp full=y;

四、用impdp导入数据

	在正式导入数据前，要先确保要导入的用户已存在，如果没有存在，请先用下述命令进行新建用户

	--创建表空间
	create tablespace tb_name datafile 'D:\tablespace\tb_name.dbf' size 1024m AUTOEXTEND ON;

	--创建用户
	create user user_name identified by A123456a default tablespace tb_name temporary tablespace TEMP;

	--给用户授权

	sql> grant read,write on directory dump_dir to user_name;

	sql> grant dba,resource,unlimited tablespace to user_name;

	1)导入用户（从用户scott导入到用户scott）
	impdp scott/tiger@orcl directory=dump_dir dumpfile=expdp.dmp schemas=scott;

	2)导入表（从scott用户中把表dept和emp导入到system用户中）
	impdp system/manager@orcl directory=dump_dir dumpfile=expdp.dmp tables=scott.dept,scott.emp remap_schema=scott:system;

	3)导入表空间
	impdp system/manager@orcl directory=dump_dir dumpfile=tablespace.dmp tablespaces=example;

	4)导入数据库
	impdb system/manager@orcl directory=dump_dir dumpfile=full.dmp full=y;

	5)追加数据
	impdp system/manager@orcl directory=dump_dir dumpfile=expdp.dmp schemas=systemtable_exists_action



1、导出指定表
expdp 'sys/pwd@server1 as sysdba' directory=dbbak dumpfile=tables.dmp logfile=tables.log tables=schema1.table1,schema1.table2

2、导入指定表
--如果源库和目标库对应的表空间没变：
impdp 'sys/pwd@server2 as sysdba' directory=dbbak dumpfile=tables.dmp tables=schema1.table1,schema1.table2  REMAP_SCHEMA=schema1:schema1
--REMAP_SCHEMA=schema1:schema1，源库shema:目标库schema

--如果源库和目标库对应的表空间不一样：
impdp 'sys/pwd@server2 as sysdba' directory=dbbak dumpfile=tables.dmp tables=schema1.table1,schema1.table2  remap_schema=schema1:schema2 remap_tablespace=tablespace1:tablespace2
--remap_schema=schema1:schema2，源库shema:目标库schema
--remap_tablespace=tablespace1:tablespace2，源表空间：目标表空间



6)清空库，TABLE，TRIGGER，SEQUENCE，PROCEDURE，FUNCTION，VIEW
BEGIN
    FOR rec IN
    (SELECT object_name,object_type from user_objects
        WHERE object_type='TABLE'
        OR object_type='TRIGGER'
        OR object_type='SEQUENCE'
        OR object_type='PROCEDURE'
        OR object_type='FUNCTION'
        OR object_type='VIEW'
    )
    LOOP
        IF rec.object_type='TABLE' THEN
           EXECUTE IMMEDIATE 'DROP '||rec.object_type||' '||rec.object_NAME||' CASCADE CONSTRAINTS';
        ELSE
            EXECUTE IMMEDIATE 'DROP '||rec.object_type||' '||rec.object_NAME;
        END IF;
   END LOOP;
END;
/




例子
查询directory目录在哪里，执行：select * from dba_directories;


后台导入数据库执行：nohup impdp hmfmsfd/hmfmsfd directory=dmp dumpfile=user_20201218.dmp logfile=user_20201219.log full=y &

后台导出数据库执行：nohup expdp directory=dmp dumpfile=user_20200907.dmp logfile=user_20200907.log schemas=HMFMSBANK COMPRESSION=all &

nohup impdp hmfmsbank/hmfmsbank directory=dmp dumpfile=user_20201202.dmp logfile=user_20201202.log full=y &

create tablespace TS_INTER_DATABANK datafile '/oradata/bankdb/ts_inter_databank.dbf' size 1024m AUTOEXTEND ON


create tablespace TS_INTER_INDXBANK datafile '/oradata/bankdb/ts_inter_indxbank.dbf' size 32m AUTOEXTEND ON


nohup impdp hmfmsbank/hmfmsbank directory=dmp dumpfile=user_20201202.dmp logfile=interest_detail.log tables=hmfmsbank.interest_detail,hmfmsbank.interest_sum &


nohup expdp directory=dmp dumpfile=user_20201202.dmp logfile=user_20201202.log schemas=HMFMSBANK COMPRESSION=all &




-- 中心端 / 银行端
SELECT T.*, T.ROWID FROM SYS_INFO T;
-- sys_id = 11 --> host_ip = 127.0.0.1

-- 中心端
SELECT T.*, T.ROWID FROM SYS_PARA T;
-- para_id = 33, 34 --> para_value = false
-- para_id = 997 --> para_value = http://162.16.161.48:80/SpfService/SpfService.asmx?wsdl



-- 中心端
UPDATE tellers SET passwd = 'C4CA4238A0B923820DCC509A6F75849B',unlock_passwd = 'C4CA4238A0B923820DCC509A6F75849B';

-- 中心端
SELECT T.*, T.ROWID FROM WS_ORG_SEL T WHERE T.LINK_CELLPHONE IS NOT NULL;
UPDATE WS_ORG_SEL SET LINK_CELLPHONE = '13820120419' WHERE LINK_CELLPHONE IS NOT NULL;


nohup impdp hmfmsfd/hmfmsfd directory=dmp dumpfile=user_20201218.dmp logfile=user_20201222.log schemas=hmfmsfd &
nohup impdp hmfmsbank/hmfmsbank directory=dmp dumpfile=user_20201217.dmp logfile=user_20201222.log full=y &