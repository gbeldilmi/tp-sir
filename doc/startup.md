# Démarrage

## Partie Théo

```bash
ssh tc737978@mi104-17
vboxmanage startvm "OL8-O19c" --type headless
# vboxmanage controlvm "OL8-O19c" poweroff 
ssh oracle@::1 -p 2222
. scripts/setEnv.sh
sqlplus /nolog
connect / as sysdba
startup
exit
lsnrctl start
sqlplus theo
# sqlplus guillaume@ens0918
select * from user_tables;
```

## Partie Guillaume

```bash
ssh gb232322@mi104-18
vboxmanage startvm "OL8-O19c" --type headless
# vboxmanage controlvm "OL8-O19c" poweroff
ssh oracle@::1 -p 2222
. scripts/setEnv.sh
sqlplus /nolog
connect / as sysdba
startup
exit
lsnrctl start
sqlplus guillaume
# sqlplus theo@ens0917
select * from user_tables;
```
