Oracle ���ݱã�IMPDP/EXPDP�����뵼���ܽ�

	Oracle���ݱõ��뵼�����ճ������г��õĻ�������֮һ������Դ�ͳ���߼����뵼��Ҫ��Ч���������Ը��ʺ����ݿ���������޴�����Σ���Ϊ���ճ���ά�����ݿ��������ǧ��������������ʮ�����Դ�ͳexp/imp�ͻ�ǳ���ʱ�������ݱ÷�ʽ����������������������ϸ�ܽ�һ�����ݱõ�ʹ�÷�����ϣ���ܸ���ѧ�ߴ���������

һ���½��߼�Ŀ¼

	�����system�ȹ���Ա�����߼�Ŀ¼��Oracle�����Զ�����ʵ�ʵ�����Ŀ¼��D:\oracleData��������ֶ�������Ŀ¼���������ǽ��ж����߼�·��dump_dir��

	sql> conn system/123456a?@orcl as sysdba;
	sql> create directory dump_dir as 'D:\oracleData';

�����鿴����ԱĿ¼��ͬʱ�鿴����ϵͳ�Ƿ���ڸ�Ŀ¼����Ϊoracle�������ĸ�Ŀ¼�Ƿ���ڣ����粻���ڣ������

	sql> select * from dba_directories;

������expdp��������

	1)�����û��������
	expdp scott/tiger@orcl schemas=scott dumpfile=expdp.dmp directory=dump_dir;

	2)����ָ����
	expdp scott/tiger@orcl tables=emp,dept dumpfile=expdp.dmp directory=dump_dir;

	3)����ѯ������
	expdp scott/tiger@orcl directory=dump_dir dumpfile=expdp.dmp tables=emp query='where deptno=20';

	4)����ռ䵼
	expdp system/manager@orcl directory=dump_dir dumpfile=tablespace.dmp tablespaces=temp,example;

	5)���������ݿ�
	expdp system/manager@orcl directory=dump_dir dumpfile=full.dmp full=y;

�ġ���impdp��������

	����ʽ��������ǰ��Ҫ��ȷ��Ҫ������û��Ѵ��ڣ����û�д��ڣ�������������������½��û�

	--������ռ�
	create tablespace tb_name datafile 'D:\tablespace\tb_name.dbf' size 1024m AUTOEXTEND ON;

	--�����û�
	create user user_name identified by A123456a default tablespace tb_name temporary tablespace TEMP;

	--���û���Ȩ

	sql> grant read,write on directory dump_dir to user_name;

	sql> grant dba,resource,unlimited tablespace to user_name;

	1)�����û������û�scott���뵽�û�scott��
	impdp scott/tiger@orcl directory=dump_dir dumpfile=expdp.dmp schemas=scott;

	2)�������scott�û��аѱ�dept��emp���뵽system�û��У�
	impdp system/manager@orcl directory=dump_dir dumpfile=expdp.dmp tables=scott.dept,scott.emp remap_schema=scott:system;

	3)�����ռ�
	impdp system/manager@orcl directory=dump_dir dumpfile=tablespace.dmp tablespaces=example;

	4)�������ݿ�
	impdb system/manager@orcl directory=dump_dir dumpfile=full.dmp full=y;

	5)׷������
	impdp system/manager@orcl directory=dump_dir dumpfile=expdp.dmp schemas=systemtable_exists_action



1������ָ����
expdp 'sys/pwd@server1 as sysdba' directory=dbbak dumpfile=tables.dmp logfile=tables.log tables=schema1.table1,schema1.table2

2������ָ����
--���Դ���Ŀ����Ӧ�ı�ռ�û�䣺
impdp 'sys/pwd@server2 as sysdba' directory=dbbak dumpfile=tables.dmp tables=schema1.table1,schema1.table2  REMAP_SCHEMA=schema1:schema1
--REMAP_SCHEMA=schema1:schema1��Դ��shema:Ŀ���schema

--���Դ���Ŀ����Ӧ�ı�ռ䲻һ����
impdp 'sys/pwd@server2 as sysdba' directory=dbbak dumpfile=tables.dmp tables=schema1.table1,schema1.table2  remap_schema=schema1:schema2 remap_tablespace=tablespace1:tablespace2
--remap_schema=schema1:schema2��Դ��shema:Ŀ���schema
--remap_tablespace=tablespace1:tablespace2��Դ��ռ䣺Ŀ���ռ�



6)��տ⣬TABLE��TRIGGER��SEQUENCE��PROCEDURE��FUNCTION��VIEW
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




����
��ѯdirectoryĿ¼�����ִ�У�select * from dba_directories;


��̨�������ݿ�ִ�У�nohup impdp hmfmsfd/hmfmsfd directory=dmp dumpfile=user_20201218.dmp logfile=user_20201219.log full=y &

��̨�������ݿ�ִ�У�nohup expdp directory=dmp dumpfile=user_20200907.dmp logfile=user_20200907.log schemas=HMFMSBANK COMPRESSION=all &

nohup impdp hmfmsbank/hmfmsbank directory=dmp dumpfile=user_20201202.dmp logfile=user_20201202.log full=y &

create tablespace TS_INTER_DATABANK datafile '/oradata/bankdb/ts_inter_databank.dbf' size 1024m AUTOEXTEND ON


create tablespace TS_INTER_INDXBANK datafile '/oradata/bankdb/ts_inter_indxbank.dbf' size 32m AUTOEXTEND ON


nohup impdp hmfmsbank/hmfmsbank directory=dmp dumpfile=user_20201202.dmp logfile=interest_detail.log tables=hmfmsbank.interest_detail,hmfmsbank.interest_sum &


nohup expdp directory=dmp dumpfile=user_20201202.dmp logfile=user_20201202.log schemas=HMFMSBANK COMPRESSION=all &




-- ���Ķ� / ���ж�
SELECT T.*, T.ROWID FROM SYS_INFO T;
-- sys_id = 11 --> host_ip = 127.0.0.1

-- ���Ķ�
SELECT T.*, T.ROWID FROM SYS_PARA T;
-- para_id = 33, 34 --> para_value = false
-- para_id = 997 --> para_value = http://162.16.161.48:80/SpfService/SpfService.asmx?wsdl



-- ���Ķ�
UPDATE tellers SET passwd = 'C4CA4238A0B923820DCC509A6F75849B',unlock_passwd = 'C4CA4238A0B923820DCC509A6F75849B';

-- ���Ķ�
SELECT T.*, T.ROWID FROM WS_ORG_SEL T WHERE T.LINK_CELLPHONE IS NOT NULL;
UPDATE WS_ORG_SEL SET LINK_CELLPHONE = '13820120419' WHERE LINK_CELLPHONE IS NOT NULL;


nohup impdp hmfmsfd/hmfmsfd directory=dmp dumpfile=user_20201218.dmp logfile=user_20201222.log schemas=hmfmsfd &
nohup impdp hmfmsbank/hmfmsbank directory=dmp dumpfile=user_20201217.dmp logfile=user_20201222.log full=y &