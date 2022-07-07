1. Create database

```bash
initdb -D <database-file-path> -U postgres -E UTF8
```

2. Start database
```bash
pg_ctl start -D D:\Database\Clusters\reedygreedy
```

3. Generate database init file 
```bash
cd patch
sh generate_init.sh
```

4. Initialize database via generated init file
```bash 
cd ..
cat .\patch\init.sql | psql -U postgres
```
