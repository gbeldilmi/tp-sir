create user theo identified by theo quota 10G on users;
grant connect to theo;
grant resource to theo;
grant create view, create synonym, create materialized view to theo;

create public database link tp_sir connect to theo identified by theo using alias "theo";