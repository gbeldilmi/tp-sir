create user guillaume identified by guillaume quota 10G on users;
grant connect to guillaume;
grant resource to guillaume;
grant create view, create synonym, create materialized view to guillaume;

create public database link tp_sir connect to guillaume identified by guillaume using alias "guillaume";
